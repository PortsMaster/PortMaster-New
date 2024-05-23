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
get_controls

export PORT_32BIT="Y"
GAMEDIR="/$directory/ports/rednukem-dn3d-atomic"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# set resolution
if [[ -f $GAMEDIR/conf/rednukem/rednukem.cfg ]]; then
  sed -i -E \
  -e "s/^(\s*ScreenHeight\s*=\s*).*/\1$DISPLAY_HEIGHT/" \
  -e "s/^(\s*ScreenWidth\s*=\s*).*/\1$DISPLAY_WIDTH/" \
  "$GAMEDIR/conf/rednukem/rednukem.cfg"
fi

# set data dir 
if [[ -f $GAMEDIR/conf/rednukem/rednukem.cfg ]]; then
  sed -i -E \
  -e "s/^(\s*ModDir\s*=\s*).*/\1\"$GAMEDIR\/gamedata\"/" \
  "$GAMEDIR/conf/rednukem/rednukem.cfg"
fi


$ESUDO rm -rf ~/.config/rednukem
$ESUDO ln -s $GAMEDIR/conf/rednukem ~/.config/
cd $GAMEDIR
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "rednukem" &
LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./rednukem -game_dir $GAMEDIR/gamedata
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1