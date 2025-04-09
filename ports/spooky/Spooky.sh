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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/Spooky/
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

cd $GAMEDIR

export LD_LIBRARY_PATH=/$GAMEDIR/lib:$LD_LIBRARY_PATH

if [ -e "SpookyGhostsDotCom-Steam" ]; then
  $ESUDO $controlfolder/xdelta3 -d -s "SpookyGhostsDotCom-Steam" "SpookyConvertSteam.xdelta" "SpookyGhostsDotCom" && $ESUDO ./xdelta3 -d -s "SpookyGhostsDotCom" "Spooky.xdelta" "data.pck"
else
  echo "SpookyGhostsDotCom-Steam not found, patching Itch version."
  $ESUDO $controlfolder/xdelta3 -d -s "SpookyGhostsDotCom" "Spooky.xdelta" "data.pck"
fi


runtime="frt_2.1.6"
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
rm SpookyGhostsDotCom
rm SpookyGhostsDotCom-Steam

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$runtime" -c "spooky.gptk" &
"$runtime" $GODOT2_OPT -path "data.pck"

$ESUDO umount "$godot_dir"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

