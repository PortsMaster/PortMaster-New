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

GAMEDIR="/$directory/ports/monolith"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod +x "$GAMEDIR/gmloader"

# Check if we have new enough version of PortMaster that contains xdelta3
if [ ! -f "$controlfolder/xdelta3" ]; then
  echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
  sleep 5
  exit 1
fi

# Patch game
cd "$GAMEDIR"

# Update config.ini file
if [ ! -f "./config.ini" ]; then
  cp ./conf/config.ini ./gamedata/config.ini
fi

# Check if config.ini exists and update resolutions
if [ -f "./gamedata/config.ini" ]; then
  sed -i "s/h_resolution=\".*\"/h_resolution=\"${DISPLAY_WIDTH}\"/" "./gamedata/config.ini"
  sed -i "s/v_resolution=\".*\"/v_resolution=\"${DISPLAY_HEIGHT}\"/" "./gamedata/config.ini"
  echo "h_resolution and v_resolution updated to ${DISPLAY_WIDTH}H x ${DISPLAY_HEIGHT} in config.ini"
else
  echo "Error: config.ini file not found in ports/monolith/gamedata"
  exit 1
fi

if [ -f "$GAMEDIR/Monolith.exe" ]; then
  # Calculate the MD5 checksum of Monolith.exe
  actual_checksum=$(md5sum "$GAMEDIR/Monolith.exe" | awk '{print $1}')

  # Check if the file exists and the checksum matches
  if [ "$actual_checksum" = "1f9c7039ca9f5d33aa7bc1ad83bd4586" ] || \
     [ "$actual_checksum" = "c61248cb34926ecdc4cfc9256330e58f" ] || \
     [ "$actual_checksum" = "46caa22818757df9f32fe1df78f330e8" ]; then
    echo "Checksum validated successfully."

    # Use 7zip to extract the .exe file to the destination directory
    "$GAMEDIR/patch/7zzs" x "$GAMEDIR/Monolith.exe" -o"$GAMEDIR/gamedata" & pid=$!

    # Wait for the extraction process to complete
    wait $pid

    # Check if Monolith.exe file exists
    if [ -f "$GAMEDIR/gamedata/Monolith.exe" ]; then
      # Delete the redundant .exe files
      rm -f "$GAMEDIR/gamedata/Monolith.exe" \
      rm -f "$GAMEDIR/gamedata/"*.dll \
      rm -f "$GAMEDIR/Monolith.exe" \
      rm -f "$GAMEDIR/place Monolith.exe here.txt"
    fi
  else
    echo "Error: MD5 checksum of Monolith.exe does not match the expected checksum."
    exit 1
  fi
else
  echo "Monolith.exe not detected in $GAMEDIR"
fi

# Check if there are any .ogg files in the current directory
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
  # Create the assets directory if it doesn't exist
  mkdir -p ./assets

  # Move all .ogg files from the current directory to ./assets
  mv ./gamedata/*.ogg ./assets/
  echo "Moved .ogg files to ./assets/"

  # Zip the contents of ./assets into ./game.apk without compression
  zip -r -0 ./monolith.apk ./assets/
  echo "Zipped contents to ./monolith.apk"

  # Delete the assets directory after processing
  rm -rf ./assets
  echo "Deleted assets directory"
else
  echo "No .ogg files found"
fi

# If "gamedata/data.win" exists and matches the checksum of the itch or steam versions
if [ -f "./gamedata/data.win" ]; then
  checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
  
  # Checksum for the Steam version
  if [ "$checksum" = "9005092c36786b977495753e3486ece4" ]; then
    $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/monolithsteam.xdelta gamedata/game.droid && \
    rm gamedata/data.win
  # Checksum for the itch version
  elif [ "$checksum" = "b1a345b628f15900a034c24881f05757" ]; then
    $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/monolithitch.xdelta gamedata/game.droid && \
    rm gamedata/data.win
  else
    echo "Error: MD5 checksum of data.win does not match any expected version."
    exit 1
  fi
else    
  echo "Error: Missing files in gamedata folder or game has been patched."
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader monolith.apk

pm_finish
printf "\033c" > /dev/tty0

