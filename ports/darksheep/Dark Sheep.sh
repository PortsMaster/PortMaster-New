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
source $controlfolder/device_info.txt

GAMEDIR=/$directory/ports/darksheep/
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"
export XDG_DATA_HOME="$CONFDIR"


runtime="frt_3.3.4" # was built using 3.3.2
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Setup Godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS # By default FRT sets Select as a Force Quit Hotkey, with this we disable that.

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$runtime" -c "./darksheep.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
"$runtime" --main-pack "./gamedata/DarkSheep.pck"

$ESUDO umount "$godot_dir"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0