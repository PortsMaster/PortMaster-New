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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEBINARY=defendguin
GAMEDIR=/$directory/ports/defendguin
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR
controls/controls.${DEVICE_ARCH} controls/controls.png
# Needed if config data binding to the conf folder
bind_directories ~/.local/share/$GAMEBINARY $GAMEDIR/conf
# Needed if any extra libs addded.
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

$GPTOKEYB "$GAMEBINARY.${DEVICE_ARCH}" -c "./$GAMEBINARY.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./$GAMEBINARY.${DEVICE_ARCH} --fullscreen --width 800 --height 480
pm_finish
