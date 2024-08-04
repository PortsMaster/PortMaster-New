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

#export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/hexen2

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO rm -rf ~/.hexen2
$ESUDO ln -sfv $GAMEDIR/conf/.hexen2 ~/
$ESUDO cp -f "$GAMEDIR/conf/.hexen2/data1/config.cfg" "$GAMEDIR/data1/autoexec.cfg"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 777 -R $GAMEDIR/*

if [[ "${DEVICE_NAME^^}" == 'X55' ]] || [[ "${DEVICE_NAME^^}" == 'RG353P' ]] || [[ "${DEVICE_NAME^^}" == 'RG40XX' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2triggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/hexen2.gptk"
fi

ADDLPARAMS="-conwidth 340 -lm_2 +viewsize 120 +gl_glows 1 +gl_extra_dynamic_lights 1 +gl_missile_glows 1 +gl_other_glows 1 +gl_colored_dynamic_lights 1 +gl_coloredlight 2 +r_waterwarp 0 +showfps 0"

# Load directly into an expansion, a map, or a mod
#RUNMOD="+map hexn1"

$GPTOKEYB "glhexen2.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
./glhexen2.${DEVICE_ARCH} -width $DISPLAY_WIDTH -height $DISPLAY_HEIGHT $ADDLPARAMS -basedir ./ $RUNMOD

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0

