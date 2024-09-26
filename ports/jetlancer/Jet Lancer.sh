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
source $controlfolder/device_info.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/jetlancer"
TOOLDIR="$GAMEDIR/tools"
TMPDIR="$GAMEDIR/tmp"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=0
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"
export TOOLDIR="$GAMEDIR/tools"
export PATH=$PATH:$GAMEDIR/tools

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x "$GAMEDIR/gmloader"
$ESUDO chmod +x "$GAMEDIR/lib/splash"
$ESUDO chmod 777 "$TOOLDIR/gmKtool.py"
$ESUDO chmod 777 "$TOOLDIR/oggenc"
$ESUDO chmod 777 "$TOOLDIR/oggdec"

cd $GAMEDIR

process_game() {
    local files_to_delete=(
      "./gamedata/Galaxy.dll"
      "./gamedata/GOG.gml.dll"
      "./gamedata/gog.ico"
      "./gamedata/goggame-1489231569.hashdb"
      "./gamedata/goggame-1489231569.ico"
      "./gamedata/goggame-1489231569.info"
      "./gamedata/goggame-galaxyFileList.ini"
      "./gamedata/goglog.ini"
      "./gamedata/Jet Lancer.exe"
      "./gamedata/Launch Jet Lancer.lnk"
      "./gamedata/support.ico"
      "./gamedata/unins000.dat"
      "./gamedata/unins000.exe"
      "./gamedata/unins000.ini"
      "./gamedata/unins000.msg"
      "./gamedata/steam_api.dll"
    )

    # Delete unnecessary files
    for file in "${files_to_delete[@]}"; do
      if [ -f "$file" ]; then
        rm "$file"
        echo "Deleted $file"
      else
        echo "$file not found"
      fi
    done

    # If "gamedata/data.win" exists and matches the checksum of the GOG or Steam versions
    if [ -f "./gamedata/data.win" ]; then
        checksum=$(md5sum "./gamedata/data.win" | awk '{print $1}')
    
        # Checksum for the GOG version
        if [ "$checksum" = "0258cadce342712c2ffbd5fc70e0dfd7" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/gogdata.xdelta gamedata/game.droid && \
        rm gamedata/data.win
	echo "GOG data.win has been patched"
        # Checksum for the Steam version
        elif [ "$checksum" = "86045b6464bb909851634c3e34b2a82e" ]; then
            $ESUDO $controlfolder/xdelta3 -d -s gamedata/data.win -f ./patch/steamdata.xdelta gamedata/game.droid && \
            rm gamedata/data.win
 	    echo "Steam data.win has been patched"
        else
            echo "Error: MD5 checksum of data.win does not match any expected version."
        fi
    else    
        echo "Error: Missing data.win in gamedata folder or game has been patched."
    fi

    # If "gamedata/audiogroup1.dat" exists and matches the checksum of the Steam version
    if [ -f "./gamedata/data.win" ]; then
        checksum=$(md5sum "./gamedata/audiogroup1.dat" | awk '{print $1}')
    
        # Checksum for the Steam audiogroup1.dat version
        if [ "$checksum" = "bcadc44e45f8a6caf9b5c5db538ced13" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s gamedata/audiogroup1.dat -f ./patch/steamaudiogroup1.xdelta gamedata/audiogroup1patched.dat && \
        rm gamedata/audiogroup1.dat
        mv gamedata/audiogroup1patched.dat gamedata/audiogroup1.dat
        else
            echo "Error: MD5 checksum of audiogroup1.dat does not match any expected version."
        fi
    else    
        echo "Error: Missing audiogroup1.dat in gamedata folder or game has been patched."
    fi

    # Compress audio
    if [ -f "$GAMEDIR/compress.txt" ]; then
        echo "Compressing audio. The process will take 5-10 minutes"  > $CUR_TTY
        mkdir -p "$TMPDIR"
        ./tools/gmKtool.py -v -m 262144 -b 64 -d "$TMPDIR" "$GAMEDIR/gamedata/game.droid"

        if [ $? -eq 0 ]; then
            mv $TMPDIR/* "$GAMEDIR/gamedata"
            rm "$GAMEDIR/compress.txt"
            rmdir "$TMPDIR"
            echo "Audio compression applied successfully." > $CUR_TTY
        else
            echo "Audio compression failed." > $CUR_TTY
            rm -rf "$TMPDIR"
        fi
    fi

    sleep 3

    # Find and compress all .ogg files in the /gamedata directory
    find "$GAMEDIR/gamedata" -type f -name "*.ogg" | while read -r file; do
    # Create a temporary file for the compressed version
    temp_file="${file%.ogg}_temp.ogg"

    # Decode the .ogg file and encode it with the specified bitrate
    "$TOOLDIR/oggdec" -o - "$file" | "$TOOLDIR/oggenc" -b 64 -o "$temp_file" -
    if [ $? -eq 0 ]; then
        # Replace the original file with the compressed version if successful
        mv "$temp_file" "$file"
        echo "Compressed: $file to 64 kbps"
    else
        echo "Failed to compress: $file" >&2
        rm -f "$temp_file" # Clean up the temp file in case of error
    fi
    done

    echo "All .ogg files have been processed."

    # Check for .ogg files and move to APK
    if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
        mkdir -p ./assets
        mv ./gamedata/*.ogg ./assets/
        echo "Moved .ogg files to ./assets/"

        zip -r -0 ./jetlancer.apk ./assets/
        echo "Zipped contents to ./jetlancer.apk"

        rm -rf ./assets
        echo "Deleted assets directory"
    else
        echo "No .ogg files found"
    fi
}

# Run install if needed
if [ ! -f "$GAMEDIR/gamedata/game.droid" ]; then
[ "$CFW_NAME" == "muOS" ] && splash "splash-install.png" 1 # workaround for muOS
    splash "splash-install.png" 600000 & # 10 minutes
    SPLASH_PID=$!
    process_game
    res=$?
    $ESUDO kill -9 $SPLASH_PID
    if [ ! $res -eq 0 ]; then
      exit 1
    fi
fi

config_file="$GAMEDIR/gamedata/config.ini"

if [ ! -f "$GAMEDIR/gamedata/config.ini" ]; then
  mv "$GAMEDIR/config.ini.default" "$GAMEDIR/gamedata/config.ini"
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader jetlancer.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
