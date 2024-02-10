#!/bin/bash
# PORTMASTER: mimisdeliverydash.zip, Mimis_Delivery_Dash.sh

# Source PortMaster tools
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

# Declare variables
GAMEDIR="/$directory/ports/mimisdeliverydash"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# Change dir & add config
cd $GAMEDIR

# Run the installer file if it hasn't been run yet
set -e  # Exit on error
set -x  # Enable debugging
if [ ! -f "$GAMEDIR/installed" ]; then
	ASSETS="assets"
	
	# Redirect output to install.log only for the commands within the if condition
	(
		exec > >(tee -a "$GAMEDIR/install.log") 2>&1

		# Move all .ogg files from ./gamedata to ./assets
		mkdir assets & mv ./gamedata/*.ogg ./assets/

		# Rename data.win
		mv "gamedata/data.win" "gamedata/game.droid"

		# Add assets to MDD.apk
		echo "Zipping $ASSETS into apk..." > /dev/tty0
		./libs/7za a -r "./MDD.apk" "./$ASSETS"
	
		# Create 'installed' file to indicate successful installation
		touch "$GAMEDIR/installed"
	)
fi

# Setup controls
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "gmloader" -c "controls.gptk" &
echo "Loading, please wait... " > /dev/tty0

# Run the game
./gmloader MDD.apk |& tee log.txt /dev/tty0

# Kill proccesses & restart services
$ESUDO kill -9 "$(pidof gptokeyb)"
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
