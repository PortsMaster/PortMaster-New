#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/undertale"
LIBDIR="$GAMEDIR/lib32"
BINDIR="$GAMEDIR/box86"

# gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# system
export LD_LIBRARY_PATH="$LIBDIR:/usr/lib32:/usr/local/lib/arm-linux-gnueabihf/"

# box86
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LD_LIBRARY_PATH="$LIBDIR"
export BOX86_LIBGL="$LIBDIR/libGL.so.1"
export BOX86_PATH="$BINDIR"

cd $GAMEDIR

$ESUDO rm -rf ~/.config/UNDERTALE
$ESUDO ln -s /$GAMEDIR/conf/UNDERTALE ~/.config/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "box86" -c "$GAMEDIR/undertale.gptk" &
echo "Loading, please wait... (might take a while!)" > /dev/tty0
$BINDIR/box86 $GAMEDIR/runner 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
