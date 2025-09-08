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

GAMEDIR=/$directory/ports/intothedeepweb
CONFDIR="$GAMEDIR/conf/"

# ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# set the xdg environment variables for config and save files
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# load runtime
runtime="frt_3.5.2"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# patch file
if [ -f "./IntotheDeepWeb_Linux.pck" ]; then
  $controlfolder/xdelta3 -d -s "./IntotheDeepWeb_Linux.pck" "./patch.xdelta3" "./IntotheDeepWeb_Linux_patched.pck"
  [ $? -eq 0 ] && rm "./IntotheDeepWeb_Linux.pck" || echo "Patching of Blackout.exe has failed"
fi

# setup godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$GPTOKEYB "$runtime" -c "./intothedeepweb.gptk" &
pm_platform_helper "$godot_dir/$runtime" 
"$runtime" $GODOT_OPTS --main-pack "./IntotheDeepWeb_Linux_patched.pck"

$ESUDO umount "$godot_dir"
pm_finish
