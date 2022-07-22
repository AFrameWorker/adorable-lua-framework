# adorable-lua-framework
Make stuff, compile stuff... Stuff! Originally made for allowing easy modding through Lua on various games.


# How to compile?

1. Download and install Cheat Engine 7.4
2. "Download ZIP" on this repo and extract the files somewhere.
2.5 Run "applymain.exe" to apply the main library to all subdirectories (important!)
3. Head into the "templategame" folder
4. Run "scriptcompiler.exe" to compile all the lua scripts inside _lua (they're then copied to _luacompiled)
5. Open "template.ct" with Cheat Engine.
6. Press the "Table" tab on the top of the program, then "Show Cheat Table Lua Script"
7. Switch the "compiled" variable from false, to true and exit out of the Lua Editor.
8. Press "File" in Cheat Engine, then "Save As..."
9. Select the "Save as type" to be "Cheat Engine Trainer Standalone (*.EXE)" and click "Save"
10. Select "Default" compression, Max is unnecessary and doesn't do that much.
11. Press "Add folder", head over to the templategame folder and select "_luacompiled"
12. Press "Generate" - This will generate the executable. It'll complain about the newly created software not having an icon, but I can recommend setting an icon using a software named "Resource Hacker". The built-in icon thingy in Cheat Engine is awful.

# What exactly can I do with this?

You're able to make your own software, you're able to modify existing PC games and a lot more.

# Example of game modding

Say, you want to give a game full Lua moddability... Well, you can easily do that with ALF (adorable-lua-framework). Simply copy the templategame folder and rename the folder to whatever you want, then grab the executable of the game you'd like to modify, and shove it into _luacompiled. And then RENAME the executable so it ends with a .code extension. (As per main.lua's MAIN_Setup() function)

Next, we need to modify templategame.lua (ideally, you should rename this to something else.)

Here's some example code you can use:

```lua
require 'main'

GAME_NAME = "TheGame" --The name of the game, though you don't have to define this.
VERSION_NUMBER = "0.00" --version number, if you want it.
ALLOW_AUTORUN_LUA = true --allowing lua files to be automatically ran externally through /lua/autorun/
ALLOW_MANUALLY_DEFINED_LUA = true --allowing external loading of lua files in /lua/_dofile.lua

SETUP_TABLE = {"asi","acd","aci","ini","dat"} --extensions of files to be setup and used by the executable

local EXE_NAME = "yourgame" --the exe name of the game you want to modify

function GAME_UPDATE()
  --code that can change and update every 10ms (changable in main.lua)
end


CREATE_PROCESS(EXE_NAME,"")
```

Follow the compilation process as I explained in the beginning, replace the old executable in your game with your newly created one, and done! The game *should* run and you should now have a fully functional lua framework integrated. You can now add your own functions into "yourgame.lua" (previously templategame.lua). You can add as many internal scripts as you want. Scriptcompiler.exe will handle them all. Don't forget to run "applymain.exe" to apply the main library though. 

# What else can I shove into _luacompiled?

You can add .acs files (.dll's renamed to .acs) | These will get manually injected by the CE Process in the background.
You can add .dll files, asi's, acd's, ini's, dat's, aci's, and whatever else you define in SETUP_TABLE = {}.
