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
GAMEDIR="/$directory/ports/thesunandmoon"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
TOOLDIR="$GAMEDIR/tools"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure executable permissions
$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"
$ESUDO chmod +x "$GAMEDIR/tools/splash"
$ESUDO chmod +x "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

# Prepare game files and patch game
expected_checksum="9e5f9d9f00aff805b47030217b64795b"

# Extract game files
if [ -f "$GAMEDIR/The Sun and Moon.exe" ]; then
    # Calculate the MD5 checksum of The Sun and Moon.exe
    actual_checksum=$(md5sum "$GAMEDIR/The Sun and Moon.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "$expected_checksum" ]; then

        # Use 7zip to extract the .exe file to the destination directory
        "$TOOLDIR/7zzs" x "$GAMEDIR/The Sun and Moon.exe" -o"$GAMEDIR/assets" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if the The Sun and Moon.exe file exists
        if [ -f "$GAMEDIR/assets/The Sun and Moon.exe" ]; then
            # Delete the redundant .exe files
            rm "$GAMEDIR/The Sun and Moon.exe"
        fi
    else
        pm_message "Error: MD5 checksum of The Sun and Moon.exe does not match the expected checksum."
    fi
else
    pm_message "The Sun and Moon.exe not detected in $GAMEDIR"
fi

# Patch data.win 
if [ -f ./assets/data.win ]; then
	# Apply a patch
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$TOOLDIR/thesunandmoon.xdelta" "$GAMEDIR/assets/game.droid"
	# Delete all redundant files
	rm -f assets/*.{exe,dll,win,gitkeep}
	# Zip all game files into the game.port
	zip -r -0 ./game.port ./assets/
	rm -rf ./assets/
fi

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`pm_message "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Display loading splash
if [ ! -d ./assets ]; then
    $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 4000 & 
fi

# Assign configs and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "thesunandmoon.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c "$GMLOADER_JSON"

# Cleanup
pm_finish