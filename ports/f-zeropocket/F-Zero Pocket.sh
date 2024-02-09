#!/bin/bash
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/f-zeropocket"

# Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.
# Prioritize the armhf libs to avoid conflicts with aarch64
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

# Run the installer file if it hasn't been run yet
set -e  # Exit on error
set -x  # Enable debugging
if [ ! -f "$GAMEDIR/installed" ]; then
	EXE="./gamedata/FZero_Pocket.exe"
	TRACKS="gamedata/Tracks"
	ASSETS="assets"
	DATA="gamedata"
	
	# Redirect output to install.log only for the commands within the if condition
	(
		exec > >(tee -a "$GAMEDIR/install.log") 2>&1

		# Extract .trk files to the Tracks folder
		echo "Extracting tracks into $TRACKS..." > /dev/tty0
		./libs/7za e "$EXE" "*.trk" -o"$TRACKS"

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

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c "control.gptk" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader game.apk 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
