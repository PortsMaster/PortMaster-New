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

GAMEDIR=/$directory/ports/samuraibrothers/
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

# Patch Samurai-Brothers-v1-2.pck file
if [ -f "./gamedata/Samurai-Brothers-v1-2.pck" ]; then
    $controlfolder/xdelta3 -d -s "./gamedata/Samurai-Brothers-v1-2.pck" "./patch/Samurai-Brothers-v1-2.pck.xdelta3" "./gamedata/Samurai-Brothers-v1-2(patched).pck"
    [ $? -eq 0 ] && rm "./gamedata/Samurai-Brothers-v1-2.pck" || echo "Patching of Samurai-Brothers-v1-2.pck.pck has failed"
fi

runtime="frt_3.5.2"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Setup Godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$GPTOKEYB "$runtime" -c "samuraibrothers.gptk" &
pm_platform_helper "$godot_dir/$runtime"
"$runtime" $GODOT_OPTS --main-pack "gamedata/Samurai-Brothers-v1-2(patched).pck"


if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$godot_dir"
fi
pm_finish
