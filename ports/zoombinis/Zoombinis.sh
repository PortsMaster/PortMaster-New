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

GAMEDIR=/$directory/ports/zoombinis
BINARY=zoombinis.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "game/D/DATA/ZOOMBINI.MHK" ]; then
    pm_message "Installing Zoombinis from your disc..." --title "Please wait"
    ./zbinstall.${DEVICE_ARCH} gamedata game
    case $? in
        0) ;;
        3)
            pm_show_error "Copy your Logical Journey of the Zoombinis disc (.iso, .bin/.cue, or all the files on the CD) into ports/zoombinis/gamedata, then launch again." --title "Game disc missing"
            exit 1 ;;
        *)
            pm_show_error "Could not install from the disc in ports/zoombinis/gamedata. Check ports/zoombinis/log.txt for what is missing, and that there is enough free space." --title "Install failed"
            exit 1 ;;
    esac
fi

mkdir -p "$GAMEDIR/conf/zoombinis"
bind_directories "$XDG_DATA_HOME/zoombinis" "$GAMEDIR/conf/zoombinis"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export OMNI_EVENT_MODE=key

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/zoombinis.ini"
fi

$GPTOKEYB2 "zoombinis" -c "./zoombinis.ini" &

pm_platform_helper "$GAMEDIR/$BINARY"

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./$BINARY --soundfont GeneralUser-GS.sf2

pm_finish
