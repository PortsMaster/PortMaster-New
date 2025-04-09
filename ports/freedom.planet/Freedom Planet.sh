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

GAMEDIR="/$directory/ports/freedomplanet"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

cd $GAMEDIR/gamedata

export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export BOX86_LOG=1
export SDL_DYNAMIC_API=libSDL2-2.0.so.0

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  export LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32:$GAMEDIR/box86/native"
  export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/"
else
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:/usr/lib32"
  export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:./:lib/:libbin32/:x86/"
fi

export BOX86_DYNAREC=1

if [ ! -f "$GAMEDIR/gamedata/freedomplanet/bin32/oga_controls" ]; then
  cp -f $GAMEDIR/oga_controls* .
fi

$ESUDO $controlfolder/oga_controls box86 $param_device &

pm_platform_helper "$GAMEDIR/gamedata/bin32/Chowdren"

$GAMEDIR/box86/box86 bin32/Chowdren

pm_finish
