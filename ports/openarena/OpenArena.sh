#!/bin/bash

setup() {
    echo "Setup first start..."

    mkdir -p "$GAMEDIR/conf/baseoa/"
    cp "$GAMEDIR/conf_defaults/conf_${GAMEPAD_TYPE}.cfg" "$GAMEDIR/conf/baseoa/q3config.cfg"
}

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

GAMEDIR=/$directory/ports/openarena
cd $GAMEDIR

if [ $ANALOG_STICKS -ge 2 ]; then
    export GAMEPAD_TYPE=analogs
fi
if [ $ANALOG_STICKS -eq 1 ]; then
    export GAMEPAD_TYPE=1analog
fi
if [ $ANALOG_STICKS -le 0 ]; then
    export GAMEPAD_TYPE=dpad
fi

bind_directories ~/.local/share/OpenArena $GAMEDIR/conf

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

libglscr="$controlfolder/libgl_${CFW_NAME}.txt"
if [ ! -f "$libglscr" ]; then
    libglscr="$controlfolder/libgl_default.txt"
fi
source "${libglscr}"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ ! -f "$GAMEDIR/conf/baseoa/q3config.cfg" ]; then
  setup
fi


$GPTOKEYB "openarena.${DEVICE_ARCH}" -c "$GAMEDIR/controls_${GAMEPAD_TYPE}.txt" textinput &
pm_platform_helper "openarena.${DEVICE_ARCH}"

"$GAMEDIR/openarena.${DEVICE_ARCH}" \
  +set r_customheight "$DISPLAY_HEIGHT" \
  +set r_customwidth "$DISPLAY_WIDTH" \
  +set r_fullscreen "1" \
  +set r_mode "-1" \
  +set in_joystick "0"

pm_finish
