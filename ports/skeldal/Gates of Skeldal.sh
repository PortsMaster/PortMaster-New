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

GAMEDIR=/$directory/ports/skeldal/

cd $GAMEDIR

# Set logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set exports and permissions
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so:$LD_PRELOAD"
export OMNI_MODE=instant
export OMNI_CONFIRM_KEY=ENTER
export OMNI_EVENT_MODE=key
export OMNI_CHARSET_KEY=a
export OMNI_WIDTH=0.75
export OMNI_HEIGHT=0.40
$ESUDO chmod +x $GAMEDIR/skeldal

# Initial setup
if [ ! -f "install_complete" ] && [ -f "$GAMEDIR/skeldal.ini" ]; then
	
	# Copy pre-set config file and clean needless files
	cp $GAMEDIR/config/skeldal.ini $GAMEDIR
	rm -f $GAMEDIR/*.{dll,exe}
	
	# Adjust deadzone_scale based on resolution width
	echo "DISPLAY_WIDTH: $DISPLAY_WIDTH"

	if [ "$DISPLAY_WIDTH" -lt 1280 ]; then
		sed -i -E 's/(deadzone_scale) = [0-20]/\1 = 7/g' controls.ini
		elif [ "$DISPLAY_WIDTH" -lt 1920 ]; then
		sed -i -E 's/(deadzone_scale) = [0-20]/\1 = 10/g' controls.ini
		else
		sed -i -E 's/(deadzone_scale) = [0-20]/\1 = 15/g' controls.ini
	fi
	touch install_complete
fi

$GPTOKEYB2 "skeldal" -c "controls.ini" &
pm_platform_helper "$GAMEDIR/skeldal"
./skeldal	

pm_finish