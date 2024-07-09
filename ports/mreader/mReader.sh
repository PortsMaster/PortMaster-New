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


# Sourcing controlfolders
source $controlfolder/control.txt 
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls


GAMEDIR=/$directory/ports/mreader/
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR




# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SCREEN_WIDTH=$DISPLAY_WIDTH
export SCREEN_HEIGHT=$DISPLAY_HEIGHT


# Extra spicy high tech splash
clear > /dev/console
mpv /roms/ports/mreader/mreader.gif 2&>1 >/dev/null


$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "reader" -c "./reader.gptk" &
./reader


$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0