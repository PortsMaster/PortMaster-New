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

export PORT_32BIT="Y"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

BINARYNAME="game-bin"
GAMEDIR=/$directory/ports/guacamelee
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Setup Box86

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export BOX86_DYNAREC_X87DOUBLE=1
export BOX86_X87_NO80BITS=1

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
fi 

export LIBGL_SHRINK=4

export PATCHER_FILE="$GAMEDIR/tools/extractscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="about 5 minutes"

if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster." > $CUR_TTY
    fi
else
    echo "Patching process already completed. Skipping."
fi

$GPTOKEYB "game-bin" &
pm_platform_helper "$GAMEDIR/box86/box86"
$GAMEDIR/box86/box86 gamedata/game-bin
pm_finish
