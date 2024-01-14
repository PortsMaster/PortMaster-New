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
$ESUDO chmod 666 /dev/uinput

GAMEDIR="/$directory/ports/sorr"

if [ -f $GAMEDIR/savegame/savegame-widescreen.sor ]; then
  if [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
    rm -f $GAMEDIR/savegame/savegame.sor
    mv -f $GAMEDIR/savegame/savegame-widescreen.sor $GAMEDIR/savegame/savegame.sor
  fi
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib32:/usr/local/lib/arm-linux-gnueabihf/"
cd $GAMEDIR
$GPTOKEYB "bgdi" -c "$GAMEDIR/sorr.gptk" &
./bgdi $(find "$GAMEDIR" -type f -iname "sorr.dat") 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
