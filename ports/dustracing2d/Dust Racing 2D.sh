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

GAMEDIR=/$directory/ports/dustracing2d
BINARY=dustrac-game.${DEVICE_ARCH}

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

qt6dir="$HOME/qt6-eglfs"
qt6_runtime="qt6-eglfs-6.6.3-aarch64"
qt6file="$controlfolder/libs/${qt6_runtime}.squashfs"
if [ ! -f "$qt6file" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${qt6_runtime}.squashfs"
fi
$ESUDO mkdir -p "$qt6dir"
$ESUDO umount "$qt6file" || true
$ESUDO mount "$qt6file" "$qt6dir"

if [ -n "$WAYLAND_DISPLAY" ] || ls "${XDG_RUNTIME_DIR:-/tmp}"/wayland-* >/dev/null 2>&1; then
  export QT_QPA_PLATFORM=wayland
  export QT_WAYLAND_SHELL_INTEGRATION=xdg-shell
else
  export QT_QPA_PLATFORM=eglfs
  [ -e "/dev/dri/card0" ] || export QT_QPA_EGLFS_INTEGRATION=none
fi
export QT_PLUGIN_PATH="$qt6dir/plugins"
export LD_LIBRARY_PATH="$qt6dir/lib:$LD_LIBRARY_PATH"
export XKB_CONFIG_ROOT="$qt6dir/xkb"

$GPTOKEYB2 "dustrac-game" -c "./dustracing2d.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

"$GAMEDIR/$BINARY"

pm_finish
