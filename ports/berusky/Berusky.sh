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

GAMEDIR=/$directory/ports/berusky
BINARY=berusky.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
    pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
    if ! gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
        pm_show_error "Could not extract $ARCHIVE_FILE. Check that there is enough free space, then launch again." --title "Extraction failed"
        exit 1
    fi
    $ESUDO rm -f "$ARCHIVE_FILE"
elif [ ! -f 'GameData/items.dat' ]; then
    pm_show_error "No game data found and $ARCHIVE_FILE is missing. Reinstall the port." --title "Game data missing"
    exit 1
fi

mkdir -p "$GAMEDIR/conf/.berusky"
[ -f "$GAMEDIR/conf/.berusky/berusky.ini" ] || cp "$GAMEDIR/berusky_default.ini" "$GAMEDIR/conf/.berusky/berusky.ini"
bind_directories ~/.berusky "$GAMEDIR/conf/.berusky"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/controls.ini"
fi

if [ "$ANALOG_STICKS" = "0" ]; then
  sed -i "s/^r2 = .*/r2 = hold_state dpad_mouse/" "$GAMEDIR/controls.ini"
fi

$GPTOKEYB2 "$BINARY" -c "./controls.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

SDL_TOUCH_MOUSE_EVENTS=0 LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH" ./$BINARY

pm_finish
