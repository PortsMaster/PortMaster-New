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

GAMEDIR=/$directory/ports/cairn/
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

# Patch cairn.pck file
if [ -f "./gamedata/cairn.pck" ]; then
    $controlfolder/xdelta3 -d -s "./gamedata/cairn.pck" "./patch/cairn.xdelta3" "./gamedata/cairn-patch.pck"
    [ $? -eq 0 ] && rm "./gamedata/cairn.pck" || echo "Patching of cairn.pck has failed"
    # Delete unneeded files
    rm -f gamedata/*.{dll,exe} 
fi

runtime="frt_3.6"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

#  If XDG Path does not work
# Use _directories to reroute that to a location within the ports folder.
bind_directories ~/godot $GAMEDIR/conf/

# Setup Godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

# By default FRT sets Select as a Force Quit Hotkey, with this we disable that.
export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS 

$GPTOKEYB "$runtime" -c "./cairn.gptk" &
pm_platform_helper "$godot_dir/$runtime"
"$runtime" $GODOT_OPTS --main-pack "gamedata/cairn-patch.pck"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$godot_dir"
fi
pm_finish