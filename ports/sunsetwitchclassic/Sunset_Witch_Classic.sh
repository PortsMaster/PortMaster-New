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
export PORT_32BIT="Y" # game is gameloader, armhf, but 7za used is 64bit for 
[ -f "${controlfolder}/mod${CFWNAME}.txt" ] && source "${controlfolder}/mod${CFWNAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/sunsetwitchclassic"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

# Run the installer file if it hasn't been run yet
if [ ! -f "$GAMEDIR/installed" ]; then
	EXE="./gamedata/Sunset Witch.exe"
	ASSETS="assets"
	DATA="gamedata"
	
	# Redirect output to install.log only for the commands within the if condition
	(
		exec > >(tee -a "$GAMEDIR/install.log") 2>&1

		# Extract .ogg files to the Assets folder
		echo "Extracting music into $ASSETS..." > /dev/tty0
		./libs/7za e "$EXE" "*.ogg" -o"$ASSETS"

		# Extract .win and .ini files to the Data folder
		echo "Extracting data into $DATA..." > /dev/tty0
		./libs/7za e -y "$EXE" "*.win" "*.ini" -o"$DATA"

		# Rename data.win
		mv "$DATA/data.win" "$DATA/game.droid"

		# Create a new zip file game.apk from specified directories
		echo "Zipping $ASSETS into apk..." > /dev/tty0
		./libs/7za a -r "./game.apk" "./$ASSETS"

		# Delete the executable file after extraction
		rm "$EXE"
	
		# Create 'installed' file to indicate successful installation
		touch "$GAMEDIR/installed"
	)
fi

$GPTOKEYB "gmloader" -c sunset.gptk &
$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader game.apk 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 "$(pidof gptokeyb)"
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0

