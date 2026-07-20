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

GAMEDIR="/$directory/ports/pvz_portable"
BINARY="pvz_portable.${DEVICE_ARCH}"
CONFDIR="$GAMEDIR/conf/"
LIB_DIR="$GAMEDIR/libs.${DEVICE_ARCH}"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR
$ESUDO chmod +x $BINARY

export LD_LIBRARY_PATH="$LIB_DIR:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"

export MALLOC_CHECK_=0
export GLIBC_TUNABLES="glibc.malloc.tcache_count=0:glibc.malloc.mmap_threshold=16384"

$GPTOKEYB "$BINARY" -c "$GAMEDIR/PvzPortable.gptk" textinput &
export IS_PORTMASTER=1

pm_platform_helper "$BINARY"
./$BINARY -resdir=$GAMEDIR -savedir=$GAMEDIR
pm_finish