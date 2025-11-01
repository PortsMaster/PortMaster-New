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
GAMEDIR=/$directory/ports/shelloutshowdown
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# set xdg environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
chmod +x "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

# patch file
if [ -f ShellOutShowdown.exe ]; then
  pm_message "Prepare game files ..."
  unzip ShellOutShowdown.exe -d ShellOutShowdown.love
  cp conf.lua ShellOutShowdown.love
  rm ShellOutShowdown.exe 
  pm_message "Launching game ..."
fi

# swap buttons on arkos and rocknix
if { [ "$CFW_NAME" = "ArkOS" ] || [ "$CFW_NAME" = "ROCKNIX" ]; } && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ]; then
  "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
  export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
  export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"
fi

# source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# run the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./shelloutshowdown.gptk"  &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/ShellOutShowdown.love"

# cleanup
pm_finish
