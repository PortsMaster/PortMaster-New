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

GAMEDIR="/$directory/ports/notransmission"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=0
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

#Patch Game

expected_checksum="680577f6121ef8ed67218ce06c2bc8dc"

if [ -f "$GAMEDIR/gamedata/YCJY_GGJ18_NO_TRANSMISSION_666.exe" ]; then
    # Calculate the MD5 checksum of YCJY_GGJ18_NO_TRANSMISSION_666.exe
    actual_checksum=$(md5sum "$GAMEDIR/gamedata/YCJY_GGJ18_NO_TRANSMISSION_666.exe" | awk '{print $1}')

    # Check if the file exists and the checksum matches
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        # Change directory to the specified directory
        cd "$GAMEDIR" || exit

        # Use 7zip to extract the .exe file to the destination directory
        "$GAMEDIR/patch/7zzs" x "$GAMEDIR/gamedata/YCJY_GGJ18_NO_TRANSMISSION_666.exe" -o"$GAMEDIR/gamedata" & pid=$!

        # Wait for the extraction process to complete
        wait $pid

        # Check if the GGJ2018.exe file exists and delete the .exe files
        if [ -f "$GAMEDIR/gamedata/GGJ2018.exe" ]; then
            # Delete the redundant .exe files
            rm "$GAMEDIR/gamedata/GGJ2018.exe"
            rm "$GAMEDIR/gamedata/YCJY_GGJ18_NO_TRANSMISSION_666.exe"
	
	# Rename data.win
	mv "gamedata/data.win" "gamedata/game.droid"        

	# Move all .ogg files from ./gamedata to ./assets
        mkdir -p ./assets
        mv ./gamedata/*.ogg ./assets/
        echo "Moved ogg files from ./gamedata to ./assets/"  	

	# Zip the contents of ./notransmission.apk including the new .ogg files
    	zip -r -0 ./notransmission.apk ./notransmission.apk ./assets/
    	echo "Zipped contents to ./notransmission.apk"
    	rm -Rf "$GAMEDIR/assets/"
	fi
    else
        echo "Error: MD5 checksum of YCJY_GGJ18_NO_TRANSMISSION_666.exe does not match the expected checksum."
    fi
else
    echo "Missing .exe file in gamedata folder OR game has been patched!"
fi

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./notransmission.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader notransmission.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
