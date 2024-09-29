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

get_controls

GAMEDIR="/$directory/ports/openomf"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$ESUDO rm -rf ~/.local/share/openomfproject
ln -sfv $GAMEDIR/conf/openomfproject ~/.local/share

export OPENOMF_RESOURCE_DIR="$GAMEDIR/gamedata"
export OPENOMF_PLUGIN_DIR="$GAMEDIR/plugins"
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"

$GPTOKEYB "openomf" -c "$GAMEDIR/openomf.gptk" &
./openomf

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

