#!/bin/bash
# PORTMASTER: quake.2.zip, Quake 2.sh

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

# Source control.txt and tasksetter from PortMaster
source $controlfolder/device_info.txt
source $controlfolder/control.txt


# Function to get controls from control.txt
get_controls

GAMEDIR="/$directory/ports/quake2"


 if [[ $LOWRES == 'Y' && $CFW_NAME != "muOS" ]]; then
  swidth="640"
  sheight="480"
  sscale="3"
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  swidth="1920"
  sheight="1080"
  sscale="3"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  swidth="854"
  sheight="480"
  sscale="3"
else
  swidth="640"
  sheight="480"
  sscale="3"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
# $GPTOKEYB "quake2" -c "$GAMEDIR/quake2.gptk" &
$GPTOKEYB "quake2" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./quake2 +set vid_renderer gles3 +set r_customwidth $swidth +set r_customheight $sheight +set r_hudscale $sscale +set r_menuscale $sscale -datadir $GAMEDIR  +set vid_fullscreen 2 -portable 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> "$CUR_TTY"