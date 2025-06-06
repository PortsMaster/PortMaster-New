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
GAMEDIR="/$directory/ports/supermutantalienassault"
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

# Check if SuperMutantAlienAssault.exe exists and unzip if so
if [ -f "$GAMEDIR/SuperMutantAlienAssault.exe" ]; then
    pm_message "Unzipping SuperMutantAlienAssault.exe to $GAMEDIR/assets"
    # Calculate the MD5 checksum of SuperMutantAlienAssault.exe
    actual_checksum=$(md5sum "$GAMEDIR/SuperMutantAlienAssault.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "2b892b06a89b378f771b5756f79d3d29" ]; then
        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/tools/7zzs" x "$GAMEDIR/SuperMutantAlienAssault.exe" -o"$DATADIR" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if SuperMutantAlienAssault.exe file exists
        if [ -f "$DATADIR/SuperMutantAlienAssault.exe" ]; then
            # Delete the files
            rm -rf $DATADIR/*.exe $DATADIR/*.dll $DATADIR/.gitkeep $GAMEDIR/SuperMutantAlienAssault.exe $GAMEDIR/"Place SuperMutantAlienAssault.exe here.txt"
        fi
    else
        pm_message "Error: MD5 checksum of SuperMutantAlienAssault.exe does not match the expected checksum. You have the wrong version of the game!"
        exit 1
    fi
else
    pm_message "SuperMutantAlienAssault.exe not found in ports/supermutantalientassault."
fi

#Patch Game
    # Check if the data.win file exists and apply xdelta
    if [ -f "$DATADIR/data.win" ]; then
	    pm_message "Patching Super Mutant Alien Assault"
        mv $DATADIR/data.win $DATADIR/game.droid
    
	    for file in "$DATADIR"/*.json; do
          filename="$(basename "$file")"
          if [[ "$filename" == *@* ]]; then
            prefix="${filename%%@*}"                 # Extract prefix (e.g., 'menu')
            base="${filename#*@}"                    # Extract remainder (e.g., 'controls.json')
            mkdir -p "$DATADIR/$prefix"              # Make sure subfolder exists
            mv "$file" "$DATADIR/$prefix/$base"      # Move and rename file
            pm_message "Moved $file → $DATADIR/$prefix/$base"
          else
          pm_message "Skipped (no @): $file"
          fi
        done
    sleep 1
	
	if [ -f "$DATADIR/game.droid" ]; then
      zip -r -0 $DATAFILE ./assets/
          rm -rf ./assets
          mkdir -p saves
    fi
	else
        pm_message "Game has been patched or files are missing."
    fi 

$GPTOKEYB "gmloader" &
$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader game.apk

pm_finish
