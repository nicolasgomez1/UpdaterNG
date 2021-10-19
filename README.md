# UpdaterNG <img align="left" src="https://user-images.githubusercontent.com/5092697/136836589-b655f88e-f67e-433d-bc2a-12c0534e05d9.png" width="100px"> <img src="https://img.shields.io/badge/Version-RELEASE-orange"></img>

Updater plugin for Autoplay Media Studio 8.5.3.0 applications.<br/>

# Information
To update the .exe and .cdd rename your new files with the name of your application name.exe.new / your application name.cdd.new, when the decompression is complete a BAT file will be executed that will replace the old files with the new ones.
```
local Filename = (String.Left(_SourceFilename, String.Length(_SourceFilename)-4));
		TextFile.WriteFromString(_SourceFolder.."\\Updater.bat", [[
			:Repeat
			del "]]..Filename..[[.exe"
			if exist "]]..Filename..[[.exe" goto Repeat
			move "]]..Filename..[[.exe.new" "]]..Filename..[[.exe"
			
			:Repeat
			del "]]..Filename..[[.cdd"
			if exist "]]..Filename..[[.cdd" goto Repeat
			move "]]..Filename..[[.cdd.new" "]]..Filename..[[.cdd"
			
			start /NORMAL ]]..Filename..".exe"..[[
			del "Updater.bat"
		]], false);
```
# Note
__Important__
This plugin is designed for a 'Hard Drive Folder' type application.
