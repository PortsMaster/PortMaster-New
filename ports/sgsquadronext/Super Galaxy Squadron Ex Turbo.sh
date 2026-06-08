#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/sgsquadronext"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

cd "$GAMEDIR"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=0
export GMLOADER_SAVEDIR="$GAMEDIR/saves/"
export GMLOADER_PLATFORM="os_windows"

# Prepare game files
if [ -f "./assets/Super Galaxy Squadron EX.exe" ]; then
		# Use 7zip to extract the Super Galaxy Squadron EX.exe to the destination directory
		"$controlfolder/7zzs.$DEVICE_ARCH" -aoa e "$GAMEDIR/assets/Super Galaxy Squadron EX.exe" -x!*.exe -o"$GAMEDIR/assets"
		# Rename data.win
		mv assets/data.win assets/game.droid
		# Delete all redundant files
		rm -f assets/*.{dll,exe,txt}
		# Zip all game files into the sgsquadronext.port
		zip -r -0 ./sgsquadronext.port ./assets/
		rm -Rf ./assets/
	elif [ -f "./assets/Super Galaxy Squadron.exe" ]; then
		# Use 7zip to extract the Super Galaxy Squadron.exe to the destination directory
		"$controlfolder/7zzs.$DEVICE_ARCH" -aoa e "$GAMEDIR/assets/Super Galaxy Squadron.exe" -x!*.exe -o"$GAMEDIR/assets"
		# Apply a patch
		$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/assets/game.droid" 2>&1
		# Delete all redundant files
		rm -f assets/*.{dll,exe,txt,win}
		# Zip all game files into the sgsquadronext.port
		zip -r -0 ./sgsquadronext.port ./assets/
		rm -Rf ./assets/
fi


$GPTOKEYB "gmloader" &

pm_platform_helper "$GAMEDIR/gmloader"

./gmloader sgsquadronext.port

pm_finish