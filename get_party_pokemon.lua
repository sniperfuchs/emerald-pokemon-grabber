-- This template lives at `.../Lua/.template.lua`.

local memory_domain = "EWRAM"
local EWRAM_offset = 0x02000000
local party_offset = 0x020244EC - EWRAM_offset
local pokemon_size = 100
local level_offset = 84
local language_offset = 18
local checksum_offset = 28
local data_offset = 32
--local party_file = "team.json"

local party_data = {0, 0, 0, 0, 0, 0}

local party_file = forms.openfile()

local file = io.open(party_file, 'r')
print("Opened file " .. party_file)
local fileContent = {}
for line in file:lines() do
	table.insert(fileContent, line)
end
io.close(file)

local function get_pokedex_number(party_index)
	local party_offset = party_offset + party_index * pokemon_size
	local personality_value = memory.read_u32_le(party_offset)
	local original_trainer_id = memory.read_u32_le(party_offset + 4)
	local checksum = memory.read_u16_le(party_offset + checksum_offset)

	local shiny_value = (original_trainer_id & 0xFFFF) ~ ((original_trainer_id & 0xFFFF0000) >> 16) ~ ((personality_value & 0xFFFF0000) >> 16) ~ (personality_value & 0xFFFF)
	local growth_offset = 0
	local personality_value_mod = personality_value % 24

	if personality_value_mod % 6 == 0 or (personality_value_mod ~= 1 and personality_value_mod % 6 == 1) then
		growth_offset = 12
	elseif (personality_value_mod ~= 2 and personality_value_mod % 6 == 2) or (personality_value_mod ~= 4 and personality_value_mod % 6 == 4) then
		growth_offset = 24
	elseif (personality_value_mod ~= 3 and personality_value_mod % 6 == 3) or (personality_value_mod ~= 5 and personality_value_mod % 6 == 5) then
		growth_offset = 36
	end

	local four_growth_bytes = memory.read_u32_le(party_offset + data_offset + growth_offset)

	local encryption_key = personality_value ~ original_trainer_id

	local decrypted_data = four_growth_bytes ~ encryption_key
	return decrypted_data & 0xFFFF, shiny_value < 8
end

local function change_party_file_data(party_index, is_shiny)
	fileContent[3 + party_index * 4] = "        \"dexnumber\": " .. party_data[party_index] .. ","
	fileContent[4 + party_index * 4] = "        \"shiny\": " .. tostring(is_shiny)
end

while true do
	local domain_success = memory.usememorydomain(memory_domain)
	if domain_success == true then
		local rewrite = false
		for i=0, 5 do
			local pokedex_number, is_shiny = get_pokedex_number(i)
			if party_data[i] ~= pokedex_number then
				party_data[i] = pokedex_number
				change_party_file_data(i, is_shiny)
				rewrite = true
			end
		end
		if rewrite == true then
			print("Need to change json file")
			local file = io.open(party_file, 'w')
			file:seek("set", 0)
			for index, value in ipairs(fileContent) do
        		file:write(value..'\n')
    		end
			file:close()
		end
	end

	-- Code here will run once when the script is loaded, then after each emulated frame.
	emu.frameadvance();
end