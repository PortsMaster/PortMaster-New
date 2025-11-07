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

# pm
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# variables
GAMEDIR=/$directory/ports/penguneverleft
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# remove spaces in .exe file name
mv -- *.exe PenguNeverLeft.exe

# run the love runtime
$GPTOKEYB2 "$LOVE_GPTK" -c "./penguneverleft.ini" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/PenguNeverLeft.exe"

# cleanup
pm_finish
