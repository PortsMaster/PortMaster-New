#!/bin/bash


if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

$ESUDO chmod 666 /dev/tty1

GAMEDIR="/$directory/ports/freedomplanet"
cd $GAMEDIR/gamedata

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export BOX86_LOG=1
export SDL_DYNAMIC_API=libSDL2-2.0.so.0

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
    export LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32:$GAMEDIR/box86/native"
    export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/"
else
    export LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:/usr/lib32"
    export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:./:lib/:libbin32/:x86/"
fi

export BOX86_DYNAREC=1
export BOX86_FORCE_ES=31

if [ ! -f "$GAMEDIR/gamedata/freedomplanet/bin32/oga_controls" ]; then
  cp -f $GAMEDIR/oga_controls* .
fi

$ESUDO $controlfolder/oga_controls box86 $param_device &
$GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1