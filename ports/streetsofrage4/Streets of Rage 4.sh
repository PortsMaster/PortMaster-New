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
source $controlfolder/tasksetter

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export GAMEDIR="/$directory/ports/streetsofrage4"
game_exe="$GAMEDIR/sorage4"

mkdir -p "$GAMEDIR/conf"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
set -o pipefail

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PYTHONDONTWRITEBYTECODE=1
# Search the game's native libraries and PortMaster's shared libraries.
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$controlfolder/libs:$controlfolder/libs.aarch64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

dotnet_runtime="dotnet-9.0.22"
if [ ! -f "$controlfolder/libs/${dotnet_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
    exit 1
  fi
  pm_message "Downloading the .NET 9 runtime, this can take a few minutes..." --title "Please wait"
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${dotnet_runtime}.squashfs"
fi

dotnet_dir=/tmp/dotnet9
$ESUDO mkdir -p "$dotnet_dir"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$dotnet_dir" 2>/dev/null
fi
$ESUDO mount "$controlfolder/libs/${dotnet_runtime}.squashfs" "$dotnet_dir"

export DOTNET_ROOT="$dotnet_dir"

# Give the patcher the display only after the runtime is available.
pm_message_end

if ! bash "$GAMEDIR/repack.src" --ready; then
  echo "Preparing Streets of Rage 4 for first launch. Keep the device powered."
  export PATCHER_FILE="bash \"$GAMEDIR/patches/setup-screen.src\""
  export PATCHER_GAME="Streets of Rage 4"
  export PATCHER_TIME="a while. Keep the device powered and awake"
  export PATCHER_QUESTIONS="$GAMEDIR/utils/patcher-name.lua"
  export controlfolder
  source "$controlfolder/utils/patcher.txt"
  if ! bash "$GAMEDIR/repack.src" --ready; then
    $ESUDO umount "$dotnet_dir"
    pm_finish
    exit 1
  fi
fi

export SOR4_SAVE_DIR="$HOME/.local/share/streetsofrage4"
if ! source "$GAMEDIR/patches/runtime.src"; then
  pm_show_error "The game runtime could not start. See streetsofrage4/log.txt." --title "Game runtime failed"
  [ -z "${compatdir:-}" ] || rm -rf -- "$compatdir"
  $ESUDO umount "$dotnet_dir"
  pm_finish
  exit 1
fi

mkdir -p "${SOR4_SAVE_DIR%/*}"
bind_directories "$SOR4_SAVE_DIR" "$GAMEDIR/conf"

pm_platform_helper "$game_exe"
$GPTOKEYB2 "${game_exe##*/}" &
$TASKSET "$game_exe" --game "$prepared/code/SOR4.dll"

[ -z "${compatdir:-}" ] || rm -rf -- "$compatdir"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$SOR4_SAVE_DIR"
  $ESUDO umount "$dotnet_dir"
fi
pm_finish
