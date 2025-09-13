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
GAMEDIR=/$directory/ports/snowmanstack
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set the xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LOVE_GRAPHICS_USE_OPENGLES=1
export LD_LIBRARY_PATH="$PWD/libs:$LD_LIBRARY_PATH"

if [[ -f "snowman stack.love" ]]; then
  pm_message "Begin patching ..."
  mkdir -p snowmanstack.love
  unzip -o "snowman stack.love" -d snowmanstack.love
  rm -f snowmanstack.love/main.lua
  mv -f ./main.lua snowmanstack.love/
  rm "snowman stack.love"
  pm_message "Patch applied successfully"
fi

$ESUDO chmod 666 /dev/uinput

# run the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./snowmanstack.gptk" &
pm_platform_helper ./love
./love "snowmanstack.love"

# cleanup any running gptokeyb instances, and any platform specific stuff
pm_finish
