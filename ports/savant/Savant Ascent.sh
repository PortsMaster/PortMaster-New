#!/bin/bash
# PORTMASTER: savant.zip, Savant Ascend.sh

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
GAMEDIR="/$directory/ports/savant"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# Change dir & add config
cd $GAMEDIR

# Check if the 'installed' file exists
if [ ! -f "$GAMEDIR/installed" ]; then
   
    ASSETS="assets"
    
    # Redirect output to install.log only for the commands within the if condition
    (
        exec > >(tee -a "$GAMEDIR/install.log") 2>&1

        # Move all .ogg files from ./gamedata to ./assets
        mkdir -p assets && mv ./gamedata/*.ogg ./assets/

        # Rename data.win
        mv "gamedata/data.win" "gamedata/game.droid"

        # Add assets to savant.apk
        echo "Zipping $ASSETS into apk..."
        ./libs/7za a -r "./savant.apk" "./$ASSETS" 2>/dev/null || { echo "Error: Unable to add assets to savant.apk" >&2; exit 1; }

        # Create 'installed' file to indicate successful installation
        touch "$GAMEDIR/installed"
    )
fi

# Setup controls
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "gmloader" & 
echo "Loading, please wait... " > /dev/tty0

# Run the game
./gmloader savant.apk |& tee log.txt /dev/tty0

# Kill proccesses & restart services
$ESUDO kill -9 "$(pidof gptokeyb)"
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
