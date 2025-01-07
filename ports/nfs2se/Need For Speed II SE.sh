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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/nfs2se
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export LD_LIBRARY_PATH="/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

bind_directories ~/.nfs2se /$directory/ports/nfs2se/conf/.nfs2se

# Rename all game data files and directories to lower case
find . -depth | grep -e "[A-Z]" | while read -r SRC; do
  DST=`dirname "${SRC}"`/`basename "${SRC}" | tr '[A-Z]' '[a-z]'`
  mv ${SRC} ${SRC}.1
  mv ${SRC}.1 ${DST}
done

#export TEXTINPUTINTERACTIVE="Y"

$GPTOKEYB "nfs2se" -c "./nfs2se.gptk" &
$GAMEDIR/nfs2se
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
