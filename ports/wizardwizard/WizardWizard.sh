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

# Define paths and exports
GAMEDIR="/$directory/ports/wizardwizard"
DATADIR="$GAMEDIR/assets"
DATAFILE="game.apk"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/saves/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x $GAMEDIR/gmloader
$ESUDO chmod +x $GAMEDIR/tools/7zzs

# Change Drive and Patch Game
cd "$GAMEDIR"

# Check if wizardwizard.exe exists and unzip if so
if [ -f "$GAMEDIR/wizardwizard.exe" ]; then
    pm_message "Unzipping wizardwizard.exe to $GAMEDIR/assets"
    # Calculate the MD5 checksum of wizardwizard.exe
    actual_checksum=$(md5sum "$GAMEDIR/wizardwizard.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "5a6f3b86a7610307b6275cdcbb15f765" ]; then
        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/tools/7zzs" x "$GAMEDIR/wizardwizard.exe" -o"$DATADIR" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if wizardwizard.exe file exists
        if [ -f "$DATADIR/wizardwizard.exe" ]; then
            # Delete the files
            rm -rf $GAMEDIR/wizardwizard.exe $GAMEDIR/"Place wizardwizard.exe here.txt"
        fi
    else
        pm_message "Error: MD5 checksum of wizardwizard.exe does not match the expected checksum. You have the wrong version of the game!"
        exit 1
    fi
else
    pm_message "wizardwizard.exe not found in ports/wizardwizard."
fi

#Patch Game
if [ -f ./assets/data.win ]; then
	# Apply a patch
	pm_message "Patching data.win"
	$controlfolder/xdelta3 -d -s "$GAMEDIR/assets/data.win" "$GAMEDIR/tools/wizardwizard.xdelta" "$GAMEDIR/assets/game.droid"
	# Delete all redundant files
	rm -f assets/*.{dll,exe,win}
	# Zip all game files into the game.port
	zip -r -0 $DATAFILE ./assets/
	rm -Rf ./assets/
	mkdir -p saves
fi

$GPTOKEYB "gmloader" -c ./wizardwizard.gptk &
$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
