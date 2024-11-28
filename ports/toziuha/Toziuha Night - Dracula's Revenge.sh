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

GAMEDIR=/$directory/ports/toziuha/
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# patch game
if [ -f "gamedata/toziuha.pck" ]; then
    # get toziuha.pck checksum for the Linux version from Itch.io
    checksum=$(md5sum "gamedata/toziuha.pck" | awk '{ print $1 }')
		# # Checksum for the Itch versio
		if [ "$checksum" == "7a9a0252621e36cc053f1efec1a646ec" ]; then
		$controlfolder/xdelta3 -d -s "gamedata/toziuha.pck" "patch/toziuhapatch.xdelta" "gamedata/toziuhapatched.pck" && rm "gamedata/toziuha.pck"
		echo "Pck file from itch.io has been patched"
    else
	    echo "checksum does not match; wrong build/version of game"
	fi
	elif [ -f "gamedata/toziuha_night_dracula's_revenge.pck" ]; then
	 # get toziuha_night_dracula's_revenge.pck checksum for Windows and Linux versions from Steam
    checksum=$(md5sum "gamedata/toziuha_night_dracula's_revenge.pck" | awk '{ print $1 }')
		# # Checksum for the Steam versio
		if [ "$checksum" == "7a9a0252621e36cc053f1efec1a646ec" ]; then
		$controlfolder/xdelta3 -d -s "gamedata/toziuha_night_dracula's_revenge.pck" "patch/toziuhapatch.xdelta" "gamedata/toziuhapatched.pck" && rm "gamedata/toziuha_night_dracula's_revenge.pck"
		echo "Pck file from Steam has been patched"
    else
	    echo "checksum does not match; wrong build/version of game"
	fi
else    
    echo "Missing file in gamedata folder or game has been patched."
fi

runtime="frt_3.5.2"
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

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$GPTOKEYB "$runtime" -c "toziuha.gptk" &
pm_platform_helper "$runtime"
"$runtime" $GODOT_OPTS --main-pack "gamedata/toziuhapatched.pck"


if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$godot_dir"
fi
pm_finish
