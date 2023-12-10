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

GAMEDIR="/$directory/ports/spelunky"
LIBDIR="$GAMEDIR/lib32"
BINDIR="$GAMEDIR/box86"

# gl4es
export LIBGL_FB=4

# system
export LD_LIBRARY_PATH="$LIBDIR:/usr/lib32:/usr/local/lib/arm-linux-gnueabihf/"

# box86
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LD_LIBRARY_PATH="$LIBDIR"
export BOX86_LIBGL="$LIBDIR/libGL.so.1"
export BOX86_PATH="$BINDIR"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO sudo rm -rf ~/.config/SpelunkyClassicHD
ln -sfv $GAMEDIR/.config/SpelunkyClassicHD/ ~/.config
$ESUDO $controlfolder/oga_controls box86 $param_device &
$BINDIR/box86 $GAMEDIR/spelunky 2>&1 | tee $GAMEDIR/log.txt
$ESUDO sudo kill -9 $(pidof oga_controls)
$ESUDO sudo systemctl restart oga_events &
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
