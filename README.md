# emerald-pokemon-grabber
Lua script for BizHawk emulator that grabs the party pokemon data and saves it in a json file.
To be used with [OBSPokemonHUD](https://github.com/guitaristtom/obspokemonhud) which reads the team from said json file.


The OBSPokemonHUD Python script in this repository (licence included) was adjusted slightly to include a new option for the Emerald edition, since the showdown Pokemon have use a different pokedex number scheme than Emerald.

# Useage
* Put altered `obspokemonhud.py` into downloaded OBSPokemonHUD folder, overwriting original
* Put `emerald_team.json` into OBSPokemonHUD folder as well (this contains a mapping of pokedex number to pokemon name specifically for Emerald)
* Put lua file wherever (OBSPokemonHUD folder is convenient, or the BizHawk Lua folder)
* In the BizHawk script window, open the lua script
* When running the script, it will ask you to select a json file to put the team into. This has to be an already filled team file as used by OBSPokemonHUD (it comes with a template one you can copy and rename)
* The script is now running and will continuously update the team file
