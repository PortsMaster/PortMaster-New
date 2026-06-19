#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
elif [ -d "/mnt/mmc/MUOS/PortMaster/" ]; then
  controlfolder="/mnt/mmc/MUOS/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/crimsonland/
RUNTIME_DIR="$GAMEDIR/runtime"
ASSETS_DIR="$GAMEDIR/assets"
BIN="$GAMEDIR/crimson.${DEVICE_ARCH}"
DISPLAY_W="${DISPLAY_WIDTH:-640}"
DISPLAY_H="${DISPLAY_HEIGHT:-480}"

mkdir -p "$RUNTIME_DIR" "$RUNTIME_DIR/home" "$ASSETS_DIR"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export HOME="$RUNTIME_DIR/home"
export XDG_DATA_HOME="$RUNTIME_DIR"
export CRIMSON_RUNTIME_DIR="$RUNTIME_DIR"
export CRIMSON_ASSETS_DIR="$ASSETS_DIR"
export CRIMSON_PORTMASTER_CONTROLS=1
export CRIMSON_HIDE_UI_CURSOR=1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

$GPTOKEYB "crimson.${DEVICE_ARCH}" -c "$GAMEDIR/crimson.gptk" &

pm_platform_helper "$BIN"

"$BIN" \
    --runtime-dir "$RUNTIME_DIR" \
    --assets-dir "$ASSETS_DIR" \
    --width "$DISPLAY_W" \
    --height "$DISPLAY_H" \
    --fullscreen

pm_finish
