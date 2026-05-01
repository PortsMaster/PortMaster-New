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
source $controlfolder/tasksetter

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

gamedir="/$directory/ports/stardewvalleymainline"
cd "$gamedir/"

$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

bind_directories ~/.config/StardewValley "$gamedir/savedata"

modsdir="$gamedir/Mods"
smapi_bundle_dir="$gamedir/tools/SMAPIBundle"
smapi_game_root="$smapi_bundle_dir/game-root"
smapi_default_mods_dir="$smapi_bundle_dir/default-mods"
smapi_helper="$gamedir/tools/smapi-common"

if [ ! -f "$smapi_helper" ]; then
  echo "Missing SMAPI helper script at $smapi_helper." > /dev/tty0
  sleep 5
  exit 1
fi

source "$smapi_helper"
mkdir -p "$modsdir"

launch_mode="$(sdv_smapi_determine_mode "$modsdir")"
entry_assembly="Stardew Valley.dll"
smapi_patch_path="$gamedir/dlls/StardewPatches.dll"
patcher_args=(
  --game-dir "$gamedir/gamedata"
  --overlay-dir "$gamedir/overrides/gamedata"
  --mods-dir "$modsdir"
)

if [ "$launch_mode" = "smapi" ]; then
  sdv_smapi_sync_default_mods "$smapi_default_mods_dir" "$modsdir"
  entry_assembly="StardewModdingAPI.dll"
  smapi_patch_path="$gamedir/gamedata/smapi-internal/StardewPatches.dll"
  patcher_args+=(
    --smapi-bundle-dir "$smapi_game_root"
    --smapi-patch-assembly "$gamedir/dlls/StardewPatches.dll"
  )
fi

export DOTNET_ROOT="$gamedir/dotnet"
export LD_LIBRARY_PATH="$gamedir/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export DOTNET_ReadyToRun="${DOTNET_ReadyToRun:-1}"
export COMPlus_ReadyToRun="${COMPlus_ReadyToRun:-1}"
export COMPlus_ZapDisable="${COMPlus_ZapDisable:-0}"

# Delete older GL4ES installs.
rm -f "$gamedir/libs/libGL.so.1" "$gamedir/libs/libEGL.so.1"

# Request libGL from PortMaster.
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_ES" != "" ]]; then
  export SDL_VIDEO_GL_DRIVER="${gamedir}/gl4es/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="${gamedir}/gl4es/libEGL.so.1"
fi

if [ ! -f "$gamedir/gamedata/Stardew Valley.dll" ]; then
  echo "Missing Stardew Valley game files. Copy the Steam mainline install into /ports/stardewvalleymainline/gamedata." > /dev/tty0
  sleep 5
  exit 1
fi

: > "${gamedir}/log.txt"

set -o pipefail

if ! "$DOTNET_ROOT/dotnet" "$gamedir/tools/MainlineGameDataPatcher/MainlineGameDataPatcher.dll" \
  "${patcher_args[@]}" 2>&1 | tee -a "${gamedir}/log.txt"; then
  cat "${gamedir}/log.txt" > /dev/tty0
  sleep 5
  exit 1
fi

export MONOGAME_PATCH="$smapi_patch_path"
if [ "$launch_mode" = "smapi" ]; then
  export SMAPI_MODS_PATH="$modsdir"
  export SMAPI_USE_CURRENT_SHELL=true
else
  unset SMAPI_MODS_PATH
  unset SMAPI_USE_CURRENT_SHELL
fi

cd "$gamedir/gamedata"

$GPTOKEYB "dotnet" &
$TASKSET "$DOTNET_ROOT/dotnet" "$entry_assembly" 2>&1 | tee -a "${gamedir}/log.txt"
game_status=${PIPESTATUS[0]}
gptokeyb_pid="$(pidof gptokeyb 2>/dev/null || true)"
[ -n "$gptokeyb_pid" ] && $ESUDO kill -9 $gptokeyb_pid
command -v systemctl >/dev/null 2>&1 && $ESUDO systemctl restart oga_events &

printf "\033c" >> /dev/tty1

exit "$game_status"
