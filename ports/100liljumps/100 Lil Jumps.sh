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
GAMEDIR=/$directory/ports/100liljumps
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# rocknix must use libmali driver
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  if glxinfo | grep -q "OpenGL version string"; then
    pm_message "This port does not support the Panfrost graphics driver. Switch to libMail to continue."
    sleep 5
    exit 1
  fi
fi

# source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# run the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./100liljumps.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/100liljumps.love"

# cleanup
pm_finish
