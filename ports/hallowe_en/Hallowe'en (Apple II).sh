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

GAMEDIR="/$directory/ports/hallowe_en"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"

[ "${CFW_NAME^^}" == "RETRODECK" ] && ADDLPARAMS=" -f"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

./text_viewer.${DEVICE_ARCH} -f 21 -w -t "Instructions" --input_file $GAMEDIR/halloween.txt

$GPTOKEYB "linapple.${DEVICE_ARCH}" -c "$GAMEDIR/halloween.gptk" &
pm_platform_helper "$GAMEDIR/linapple.${DEVICE_ARCH}"
./linapple.${DEVICE_ARCH} --conf $GAMEDIR/conf/nojoy.conf --d1 $GAMEDIR/disks/halloween.dsk --autoboot $ADDLPARAMS

pm_finish
