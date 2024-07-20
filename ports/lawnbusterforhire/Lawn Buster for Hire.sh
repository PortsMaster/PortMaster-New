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

GAMEDIR="/$directory/ports/lawnbusterforhire"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

# we log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# extract exe
if [ -f "./gamedata/Lawn Buster for Hire.exe" ]; then
  mv "gamedata/Lawn Buster for Hire.exe" ./LawnBusterforHire.exe
  ./7z x -mhe=off LawnBusterforHire.exe -ogamedata -r
  mv "gamedata/data.win" "gamedata/game.droid"
  mv "gamedata/new_splash.png" "gamedata/splash.png"
  rm gamedata/*.dll gamedata/*.exe
else
  echo "Lawn Buster for Hire.exe does not exist (or already extracted)"
fi

# make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c ./lawnbusterforhire.gptk &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader lawnbusterforhire.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

