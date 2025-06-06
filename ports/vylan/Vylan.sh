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

GAMEDIR=/$directory/ports/vylan
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check for demo version
if [ -f "$GAMEDIR/gamedata/VylanDemo.pck" ]; then
	# Rename VylanDemo.pck
	mv gamedata/VylanDemo.pck gamedata/Vylan.pck
fi

runtime="frt_3.6"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Setup Godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$GPTOKEYB "$runtime" -c "vylan.gptk" &

export LD_PRELOAD="$GAMEDIR/hacksdl/hacksdl.aarch64.so"
export HACKSDL_NO_GAMECONTROLLER=2

pm_platform_helper "$godot_dir/$runtime"

# Check for the ROCKNIX's problematic LibMali driver.
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    # If OpenGL version string is not available, assume it's using LibMali
    if ! glxinfo | grep -q "OpenGL version string"; then
        # Use GLES2 to get around broken rendering
        "$runtime" $GODOT_OPTS --video-driver GLES2 --main-pack "gamedata/Vylan.pck"
    else
        # Using Panfrost or Freedreno driver
        "$runtime" $GODOT_OPTS --main-pack "gamedata/Vylan.pck"
    fi
else
    # Default for all other OSes
    "$runtime" $GODOT_OPTS --main-pack "gamedata/Vylan.pck"
fi

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$godot_dir"
fi
pm_finish
