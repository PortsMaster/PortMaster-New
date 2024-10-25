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

GAMEDIR="/$directory/ports/spacecadetpinball"
CONFDIR="$GAMEDIR/conf/SpaceCadetPinball"
BINARY="SpaceCadetPinball.${DEVICE_ARCH}"

mkdir -p "$CONFDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories "$HOME/.local/share/SpaceCadetPinball" "$CONFDIR"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

if [[ -f "$CONFDIR/imgui_pb.ini" ]]; then
  # The config file is created on the first launch.
  # We can update the file to hide the menu for
  # the next runs
  sed -i 's/ShowMenu=1/ShowMenu=0/g' "$CONFDIR/imgui_pb.ini"
fi

$GPTOKEYB "$BINARY" -c "spacecadetpinball.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY > /dev/null # too much SDL Error we don't log

pm_finish
