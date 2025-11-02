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
GAMEDIR=/$directory/ports/voidcall
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# prepare files
if [ -f VoidCall_exe.zip ]; then
  pm_message "Unpacking VoidCall_exe.zip ..."
  unzip -o VoidCall_exe.zip -d voidcall.love
  pm_message "Extracting embedded .love file ..."
  unzip -o "voidcall.love/VoidCall_exe/voidcall.exe" -d voidcall.love
  pm_message "Cleaning up ..."
  rm VoidCall_exe.zip
  rm -rf "voidcall.love/VoidCall_exe"
  rm -rf "voidcall.love/.git"
  rm -rf "voidcall.love/.vscode"
  pm_message "Copying main.lua ..."
  cp main.lua voidcall.love
  pm_message "Done!"
fi

# source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# run the love runtime
$GPTOKEYB2 "$LOVE_GPTK" -c "./voidcall.ini" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/voidcall.love"

# cleanup
pm_finish
