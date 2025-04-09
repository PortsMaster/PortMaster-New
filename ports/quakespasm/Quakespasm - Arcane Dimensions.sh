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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/quakespasm

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
[[ "$CFW_NAME" == 'muOS' ]] && [[ "$DEVICE_ARCH" == 'armhf' ]] && export LIBGL_GL=15

$ESUDO chmod 777 -R $GAMEDIR/*

if [[ "${DEVICE_NAME^^}" == 'X55' ]] || [[ "${DEVICE_NAME^^}" == 'RG353P' ]] || [[ "${DEVICE_NAME^^}" == 'RG40XX' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/quakespasmtriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/quakespasm.gptk"
fi

# Load directly into an expansion, a map, or a mod
RUNMOD="-game ad +map start"

$GPTOKEYB "quakespasm.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
./quakespasm.${DEVICE_ARCH} -current +scr_showfps 1 +joy_enable 0 +r_oldwater 1 +r_particles 1 +r_shadows 0 +r_sky_quality 5 $RUNMOD

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
