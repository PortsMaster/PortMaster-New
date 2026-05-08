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

GAMEDIR="/$directory/ports/stardewvalleymainline"
gamedir="$GAMEDIR"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

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
port_arch="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$gamedir/libs.${port_arch}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Request libGL from PortMaster.
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_ES" != "" ]]; then
  export SDL_VIDEO_GL_DRIVER="${gamedir}/gl4es.${port_arch}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="${gamedir}/gl4es.${port_arch}/libEGL.so.1"
fi

if [ ! -f "$gamedir/gamedata/Stardew Valley.dll" ]; then
  echo "Missing Stardew Valley game files. Copy the Steam mainline install into /ports/stardewvalleymainline/gamedata." > /dev/tty0
  sleep 5
  exit 1
fi

if ! "$DOTNET_ROOT/dotnet" "$gamedir/tools/MainlineGameDataPatcher/MainlineGameDataPatcher.dll" "${patcher_args[@]}"; then
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

$GPTOKEYB "$DOTNET_ROOT/dotnet" &
command -v pm_platform_helper >/dev/null 2>&1 && pm_platform_helper "$DOTNET_ROOT/dotnet"
"$DOTNET_ROOT/dotnet" "$entry_assembly"
game_status=$?

if command -v pm_finish >/dev/null 2>&1; then
  pm_finish
else
  gptokeyb_pid="$(pidof gptokeyb 2>/dev/null || true)"
  [ -n "$gptokeyb_pid" ] && $ESUDO kill -9 $gptokeyb_pid
  command -v systemctl >/dev/null 2>&1 && $ESUDO systemctl restart oga_events &
fi

printf "\033c" >> /dev/tty1

exit "$game_status"
