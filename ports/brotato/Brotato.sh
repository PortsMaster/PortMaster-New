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

GAMEDIR=/$directory/ports/brotato/
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"


cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

[ -f "./gamedata/Brotato.pck" ] && mv gamedata/Brotato.pck gamedata/brotato.pck

$GPTOKEYB "brotato_runner" -c "./brotato.gptk" &
pm_platform_helper "$GAMEDIR/brotato_runner"
LD_PRELOAD="$GAMEDIR/hacksdl/hacksdl.aarch64.so" HACKSDL_DEVICE_DISABLE_0=2 $GAMEDIR/brotato_runner $GODOT_OPTS --main-pack "gamedata/brotato.pck"

$ESUDO umount "$godot_dir"
pm_finish