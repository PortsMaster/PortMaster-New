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
GAMEDIR=/$directory/ports/ot
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# unzip files
if [ -f ./ot.love/Ot_Linux.zip ]; then
  pm_message "Preparing files ..."
  cd $GAMEDIR/ot.love
  unzip -n Ot_Linux.zip
  unzip -n Ot_Linux/Ot.love
  rm Ot_Linux.zip
  rm -rf Ot_Linux
  rm -rf release
  cd $GAMEDIR
  pm_message "Launching game ..."
fi

# source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# run the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./ot.gptk"  &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/ot.love"

# cleanup
pm_finish
