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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/oxytone"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATH="$GAMEDIR/tools:$PATH"
$ESUDO chmod +x $GAMEDIR/gmloadernext.${DEVICE_ARCH}
$ESUDO chmod +x $GAMEDIR/tools/SDL_swap_gpbuttons.py

#Prepare game files
	#Check if compatible game files are present
	if [ -f "$GAMEDIR/assets/data.win" ]; then
			# Get data.win checksum for the demo version from Itch.io
			checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
				if [ "$checksum" == "edf83c4f9f4961ecbb398bdb526c9ee7" ]; then
				sed -i 's|"apk_path" : "oxytone.port"|"apk_path" : "oxytone109.port"|' $GMLOADER_JSON
				# Rename data.win file
				mv assets/data.win assets/game.droid
				# Delete all redundant files
				rm -f assets/*.{dll,exe}
				# Zip all game files into the oxytone109.port
				zip -r -0 ./oxytone109.port ./assets/
				rm -Rf ./assets/
			# Get data.win checksum for the demo version from Steam.io
			checksum=$(md5sum "assets/data.win" | awk '{ print $1 }')
				elif [ "$checksum" == "897007bdb8ca0dd37bfe6ffffb2e7405" ]; then
				sed -i 's|"apk_path" : "oxytone.port"|"apk_path" : "oxytone109.port"|' $GMLOADER_JSON
				# Rename data.win file
				mv assets/data.win assets/game.droid
				# Delete all redundant files
				rm -f assets/*.{dll,exe}
				# Zip all game files into the oxytone109.port
				zip -r -0 ./oxytone109.port ./assets/
				rm -Rf ./assets/
			else 
			# Setup files for the full version
				# Rename data.win file
				mv assets/data.win assets/game.droid
				#Delete all redundant files
				rm -f assets/*.{dll,exe}
				# Zip all game files into the oxytone.port
				zip -r -0 ./oxytone.port ./assets/
				rm -Rf ./assets/
			fi
	else
		pm_message "Data.win is missing or the game is already installed." 
fi

# Swap left and right sticks for broader device compatibility
swapsticks() {
     # Update SDL_GAMECONTROLLERCONFIG to swap sticks
    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
      # Knulli seems to use SDL_GAMECONTROLLERCONFIG_FILE (on rg40xxh at least)
      SDL_swap_gpbuttons.py -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
      export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
      # Other CFW use SDL_GAMECONTROLLERCONFIG
      export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | SDL_swap_gpbuttons.py -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"
    fi
}
if [ "${ANALOG_STICKS}" -lt 2 ]; then
    swapsticks
fi
 
# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "oxytone.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish
