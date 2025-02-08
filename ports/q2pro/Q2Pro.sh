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

GAMEDIR="/$directory/ports/q2pro"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export ANALOGSTICKS="${ANALOGSTICKS:-2}"
export ANALOG_STICKS="${ANALOG_STICKS:-2}"

$ESUDO chmod 777 $GAMEDIR/q2pro_legacy
$ESUDO chmod 777 $GAMEDIR/q2pro_glsl
$ESUDO chmod 777 $GAMEDIR/*/gamearm64.so

# Copy control configs on first run
if [ ! -f "firsttime" ]; then
    if [[ "$DISPLAY_WIDTH" -lt "640" ]]; then
        sed -i 's/seta con_scale "[0-9]*"/seta con_scale "1"/' "$GAMEDIR/${ANALOG_STICKS}stick.cfg"
        sed -i 's/seta scr_scale "[0-9]*"/seta scr_scale "1"/' "$GAMEDIR/${ANALOG_STICKS}stick.cfg"
        sed -i 's/seta ui_scale "[0-9]*"/seta ui_scale "1"/' "$GAMEDIR/${ANALOG_STICKS}stick.cfg"
    fi
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/baseq2/config.cfg"
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/ctf/config.cfg"
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/rogue/config.cfg"
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/xatrix/config.cfg"
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/smd/config.cfg"
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/zaero/config.cfg"
    cp "$GAMEDIR/${ANALOG_STICKS}stick.cfg" "$GAMEDIR/rerelease/config.cfg"
    touch firsttime
fi

if [[ "${CFW_NAME^^}" == 'ROCKNIX' ]] || [[ "${CFW_NAME^^}" == 'JELOS' ]]; then
    BINARY=q2pro_legacy
else
    BINARY=q2pro_glsl
fi

$GPTOKEYB "$BINARY" -c "$GAMEDIR/q2pro.gptk" &
pm_platform_helper "$GAMEDIR/$BINARY"
./$BINARY

pm_finish
