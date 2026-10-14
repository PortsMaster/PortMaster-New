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

GAMEDIR=/$directory/ports/sundog
BINARY=sundog.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

IMAGE=$(ls *.st *.ST 2>/dev/null | head -n 1)
STX=$(ls *.stx *.STX 2>/dev/null | head -n 1)

if [ -z "$IMAGE" ] && [ -n "$STX" ]; then
  pm_message "Converting $STX, one moment..." --title "Please wait"
  ./stx2st.${DEVICE_ARCH} "$STX" sundog.st && IMAGE=sundog.st || rm -f sundog.st
  if [ -z "$IMAGE" ]; then
    pm_show_error "$STX could not be converted. Use an image of the original SunDog: Frozen Legacy v3.0 disk, not the re-packed version." --title "Disk image not supported"
    exit 1
  fi
fi

if [ -z "$IMAGE" ]; then
  pm_show_error "Copy your SunDog: Frozen Legacy Atari ST disk image (.st or .stx, original disk layout) to ports/sundog/ and launch the game again." --title "Disk image missing"
  exit 1
fi

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/sundog.ini"
fi

$GPTOKEYB2 "$BINARY" -c "./sundog.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY --fullscreen --software-cursor "$GAMEDIR/$IMAGE"

pm_finish
