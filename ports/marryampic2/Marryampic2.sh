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

GAMEDIR=/$directory/ports/marryampic2
BINARY=marryampic2.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf"
$ESUDO mkdir -p "${CONFDIR}"
$ESUDO touch "$CONFDIR/.marryampic2_prefs"
bind_files ~/.marryampic2_prefs "$CONFDIR/.marryampic2_prefs"

if [[ -f 'cards.tar.gz' ]]; then
    if [[ -d 'cards/' ]]; then
        pm_message "Removing old cardsets"
        $ESUDO rm -fR 'cards/'
    fi
    pm_message "Extracting cardsets, this can take a few minutes..."
    if gunzip -c 'cards.tar.gz' | tar xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f 'cards.tar.gz'
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -d 'cards/' ]; then
    pm_message "Error: No cards directory present and cards.tar.gz not found."
    sleep 5
    exit 1
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/marryampic2.ini"
fi

$GPTOKEYB2 "marryampic2" -c "./marryampic2.ini" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

"$GAMEDIR/$BINARY" -f

pm_finish
