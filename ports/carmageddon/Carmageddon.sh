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
GAMEDIR="/$directory/ports/carmageddon"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x $GAMEDIR/dethrace

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check for gamedata
if [[ ! -d "DATA" ]]; then
	pm_message "Missing game files. Unzip the game files to $GAMEDIR."
	sleep 5
	exit 1
fi

if [[ ! -e ".init_done" && -e "DATA/KEYMAP_0.TXT" ]]; then
	# Apply default settings when the game is executed for the first time
	mv init/* DATA && rm -r init && touch .init_done
fi

# Run the game
$GPTOKEYB "dethrace" -c "./dethrace.gptk" &
pm_platform_helper "$GAMEDIR/dethrace"
./dethrace --full-screen -hires

# Cleanup
pm_finish

