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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/slipstream"
GAMEDATA="$GAMEDIR/gamedata"
BUNDLE="$GAMEDATA/slipstream"
ASSEMBLY="$GAMEDATA/slipstream.dll"
ASPECT="$GAMEDIR/patches/aspect"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Accepts the game's folder itself as well as its contents.
for dir in "$GAMEDATA"/*/; do
  dir=${dir%/}
  if [ -f "$dir/slipstream" ] && [ -f "$dir/FNA.dll" ]; then
    mv "$dir" "$GAMEDATA/copied" && mv "$GAMEDATA/copied/"* "$GAMEDATA/" && rmdir "$GAMEDATA/copied"
    break
  fi
done
# FNA.dll.config maps FNA's native libraries to their sonames.
if [ ! -f "$BUNDLE" ] || [ ! -f "$GAMEDATA/FNA.dll" ] || [ ! -f "$GAMEDATA/FNA.dll.config" ] || [ ! -f "$GAMEDATA/Steamworks.NET.dll" ] || [ ! -d "$GAMEDATA/assets" ]; then
  pm_show_error "Copy all files and folders from the Linux game's folder into ports/slipstream/gamedata/ and launch the game again." --title "Game files missing" --type warning
  exit 1
fi

# The x86-64 bundle carries the game as a managed assembly.
stamp="$GAMEDIR/unbundled.txt"
# Identified by content: aspect patcher needs an unpatched assembly, so it counts too.
bundle_id="$(md5sum < "$BUNDLE") $(md5sum < "$ASPECT/aspect-patch.dll")"
if [ ! -f "$ASSEMBLY" ] || [ "$(cat "$stamp" 2>/dev/null)" != "$bundle_id" ]; then
  if ! python3 "$GAMEDIR/patches/unbundle.py" "$BUNDLE" slipstream.dll "$ASSEMBLY"; then
    pm_show_error "Could not extract slipstream.dll from the game's slipstream file. Copy the files from the current Linux version of the game." --title "Unknown game version"
    exit 1
  fi
  echo "$bundle_id" > "$stamp"
fi
if ! python3 "$GAMEDIR/patches/retarget.py" "$ASSEMBLY" "$GAMEDATA/Steamworks.NET.dll"; then
  pm_show_error "Could not prepare the game's assemblies for ARM64. Copy the files from the current Linux version of the game." --title "Unknown game version"
  exit 1
fi

dotnet_runtime="dotnet-8.0.12"
if [ ! -f "$controlfolder/libs/${dotnet_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
    exit 1
  fi
  pm_message "Downloading the .NET 8 runtime, this can take a few minutes..." --title "Please wait"
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${dotnet_runtime}.squashfs"
fi

dotnet_dir=/tmp/dotnet8
$ESUDO mkdir -p "$dotnet_dir"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$dotnet_dir" 2>/dev/null
fi
$ESUDO mount "$controlfolder/libs/${dotnet_runtime}.squashfs" "$dotnet_dir"

mkdir -p "$GAMEDIR/conf"
# Fullscreen defaults
if [ ! -f "$GAMEDIR/conf/settings-1.2.bin" ] || [ ! -f "$GAMEDIR/conf/version-check-1.2.bin" ]; then
  cp "$GAMEDIR/defaults/"*.bin "$GAMEDIR/conf/"
fi
bind_directories "$HOME/.config/ansdorGames/Slipstream" "$GAMEDIR/conf"

cd "$GAMEDATA"

export DOTNET_ROOT="$dotnet_dir"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
# Default key bindings must not depend on the keyboard layout.
export FNA_KEYBOARD_USE_SCANCODES=1

# The player's screen settings
screen=$(tr -d '\r' < "$GAMEDIR/screen.cfg" 2>/dev/null | grep -E '^SLIPSTREAM_(ASPECT=16:9|HORIZON=[0-9]+)$')
[ -n "$screen" ] && export $screen

cp "$ASPECT/SlipstreamAspect.dll" "$GAMEDATA/"
aspect_stamp="$GAMEDIR/aspect.txt"
if [ "$(cat "$aspect_stamp" 2>/dev/null)" != "$(md5sum < "$ASSEMBLY")" ]; then
  "$dotnet_dir/dotnet" "$ASPECT/aspect-patch.dll" "$ASSEMBLY" && md5sum < "$ASSEMBLY" > "$aspect_stamp"
fi

$GPTOKEYB2 "dotnet" > /dev/null &
pm_platform_helper "$dotnet_dir/dotnet"

"$dotnet_dir/dotnet" exec --runtimeconfig "$GAMEDIR/slipstream.runtimeconfig.json" "$ASSEMBLY"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$dotnet_dir"
fi
pm_finish
