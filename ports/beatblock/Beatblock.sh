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

GAMEDIR=/$directory/ports/beatblock
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


if [[ -f "gamedata/Beatblock-linux.zip" ]]; then
   cd gamedata

   mkdir tmp && cd tmp
   $GAMEDIR/patch/unzip -o $GAMEDIR/gamedata/Beatblock-linux.zip
   cd ..

   find . -name "Beatblock" | xargs $GAMEDIR/patch/unzip

   $GAMEDIR/patch/patch -p1 --binary < $GAMEDIR/patch/patch.diff

   rm -rf Beatblock-linux.zip tmp

   $ESUDO chmod -R a+rw .

   cd $GAMEDIR
fi

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

source $controlfolder/runtimes/"love_11.5"/love.txt

# Run the love runtime
$GPTOKEYB "$LOVE_GPTK" -k &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/gamedata"

pm_finish
