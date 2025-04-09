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

GAMEDIR=/$directory/ports/wakingmars
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

get_controls

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
fi 

# Setup Box86
export BOX86_LOG=1

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/x86":"$GAMEDIR/box86/native":"$GAMEDIR/libs/x86":
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

#export TEXTINPUTINTERACTIVE="Y"

if [ "$ANALOG_STICKS" = "1" ] || [ "$ANALOG_STICKS" = "0" ]; then
    GPTK_FILE="wakingmars_1stick.gptk"
else
    GPTK_FILE="wakingmars.gptk"
fi

$GPTOKEYB "wakingmars" -c "./$GPTK_FILE" &
pm_platform_helper "$GAMEDIR/box86/box86"
$GAMEDIR/box86/box86 gamedata/wakingmars

pm_finish