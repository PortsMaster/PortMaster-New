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

GAMEDIR=/$directory/ports/dudelingsarcadesportsball
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# Extract APK and repack assets folder into dudelings.zip
APK_FILE=$(find "gamedata" -type f -name "*.apk" -print -quit)

if [ -n "$APK_FILE" ]; then
  pm_message "Found APK file: $APK_FILE"
  unzip -o "$APK_FILE" -d "apk_unzipped"
  pm_message "APK file unzipped to apk_unzipped"
  cd apk_unzipped/assets
  zip -r "../../gamedata/dudelings.zip" ./* .[^.] .??*
  cd ../../
  pm_message "Repacked assets to dudelings.zip"
  rm ./gamedata/*.apk
  rm -r apk_unzipped
  pm_message "Finished clean up."
fi

# Load runtime
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

# Setup Godot
godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS

$GPTOKEYB "$runtime" -c "./dudelingsarcadesportsball.gptk" &
pm_platform_helper "$godot_dir/$runtime" 
"$runtime" $GODOT_OPTS --main-pack "gamedata/dudelings.zip"

$ESUDO umount "$godot_dir"
pm_finish
