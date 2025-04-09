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
export PORT_32BIT="Y"
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/swapwoodquestr"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFWNAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# on ROCKNIX for some reason it's looking for the music in assets/ and in all lower case, so just put it there as well
if [ ! -d ./assets ]; then
  unzip ./swapwoodquestr.apk 'assets/*'
  for file in ./assets/*.ogg ; do
      mv -v "$file" "${file,,}"
  done
fi

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "gmloader" -c "$GAMEDIR/swapwoodquestr.gptk" &

$ESUDO chmod +x "$GAMEDIR/gmloader"
./gmloader swapwoodquestr.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0