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

GAMEDIR="/$directory/ports/choochootracker"
CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR"
mkdir -p "$CONFDIR/.choochootracker"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

merge_data() {
  local asset relative
  for asset in "$1"/*; do
    relative="${asset#"$data_stage/"}"
    # Move whole missing directories; recurse only where user assets exist.
    if [ ! -e "$relative" ] && [ ! -L "$relative" ]; then
      mv -n "$asset" "$relative" || return 1
    elif [ -d "$asset" ]; then
      [ -d "$relative" ] || return 1
      merge_data "$asset" || return 1
    fi
  done
}

unpack_data() {
  (set -o pipefail; gunzip -c data.tar.gz | tar --no-same-owner -xf - -C "$data_stage") || return 1
  shopt -s nullglob dotglob
  merge_data "$data_stage" || return 1
  [ -f instruments/FACTORY/catalog.tsv ] && [ -f instruments/FACTORY/builtins.tsv ]
}

if [ -f data.tar.gz ]; then
  pm_message "Extracting application data, please wait..."
  data_stage=$(mktemp -d "$GAMEDIR/.data-extract.XXXXXX") || {
    pm_message "Error: Cannot create extraction directory."
    exit 1
  }
  if unpack_data; then
    if ! rm -rf "$data_stage" || ! rm -f data.tar.gz; then
      pm_message "Error: Cannot finish extraction cleanup."
      exit 1
    fi
    pm_message "Extraction successful."
  else
    rm -rf "$data_stage"
    pm_message "Error: Extraction failed. Archive retained for retry."
    exit 1
  fi
elif [ ! -f instruments/FACTORY/catalog.tsv ] || [ ! -f instruments/FACTORY/builtins.tsv ]; then
  pm_message "Error: Application data and data.tar.gz are missing. Reinstall the port."
  exit 1
fi

export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HOTKEY=guide
# Keep ArkOS's default ALSA route so its volume controls affect playback.
# Some installations cannot open that route, so the audio backend may retry
# with the internal card. Respect a device already chosen by the user/platform.
if [ "$CFW_NAME" = "ArkOS" ] && [ -z "$AUDIODEV" ]; then
  export CCT_AUDIODEV_FALLBACK="plughw:0,0"
fi

bind_directories ~/.choochootracker "$CONFDIR/.choochootracker"

$ESUDO chmod +x "./choochootracker.${DEVICE_ARCH}" || exit 1

# ROCKNIX can emit Select and Guide together; the old mapper loses Shift-up.
if [ "$CFW_NAME" = "ROCKNIX" ]; then
  $GPTOKEYB2 "choochootracker.${DEVICE_ARCH}" -c "./choochootracker.gptk" &
else
  $GPTOKEYB "choochootracker.${DEVICE_ARCH}" -c "./choochootracker.gptk" &
fi
pm_platform_helper "$GAMEDIR/choochootracker.${DEVICE_ARCH}"
"./choochootracker.${DEVICE_ARCH}"

pm_finish
