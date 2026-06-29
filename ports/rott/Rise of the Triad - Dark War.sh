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

GAMEDIR="/$directory/ports/rott"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

[ ! -f "$GAMEDIR/conf/.rott/darkwar/config.rot" ] && $ESUDO cp -f -v "$GAMEDIR/conf/.rott/darkwar/config_bak.rot" "$GAMEDIR/conf/.rott/darkwar/config.rot"
[[ "$CFW_NAME" != *"ArkOS"* ]] && $ESUDO cp -f -v $GAMEDIR/timidity_cfg.bak $GAMEDIR/timidity.cfg

cd $GAMEDIR

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

if [[ $CFW_NAME == *"ArkOS"* ]] || [[ $CFW_NAME == *"ODROID"* ]]; then
    if [[ $CFW_NAME == *"dArkOS"* ]]; then
        [ -e /dev/zram0 ] && $ESUDO swapoff -a
        [ -e /dev/zram0 ] && $ESUDO zramctl --reset /dev/zram0
        [ -e /dev/zram1 ] && $ESUDO zramctl --reset /dev/zram1
        [ -e /dev/zram2 ] && $ESUDO zramctl --reset /dev/zram2
        modprobe zram
        $ESUDO zramctl --find --size 384M
        $ESUDO mkswap /dev/zram0
        $ESUDO swapon /dev/zram0
    else
        [ -f /swapfile ] && $ESUDO swapoff -v /swapfile
        [ -f /swapfile ] && $ESUDO rm -f /swapfile
        $ESUDO fallocate -l 384M /swapfile
        $ESUDO chmod 600 /swapfile
        $ESUDO mkswap /swapfile
        $ESUDO swapon /swapfile
    fi
    [ -f $GAMEDIR/timidity.cfg ] && $ESUDO rm -f $GAMEDIR/timidity.cfg
elif [[ "${CFW_NAME^^}" == "KNULLI" ]]; then
    if [ ! -e /dev/zram0 ]; then
        pm_message "For Knulli, you must enable ZRAM.  Start -> System Settings -> Services -> ZRAMSWAP"
        sleep 7
    fi
    [ -f $GAMEDIR/timidity.cfg ] && $ESUDO rm -f $GAMEDIR/timidity.cfg
fi

bind_directories ~/.rott $GAMEDIR/conf/.rott

if [[ "$ANALOG_STICKS" == '1' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/rott1joy.gptk"
elif [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/rott_triggers.gptk"
else
    GPTOKEYB_CONFIG="$GAMEDIR/rott.gptk"
fi

$ESUDO chmod +x "$GAMEDIR/rott_dw.${DEVICE_ARCH}"
$ESUDO chmod +x "$GAMEDIR/text_viewer.${DEVICE_ARCH}"

[ ! -f "$GAMEDIR/DARKWAR.WAD" ] && ./text_viewer.${DEVICE_ARCH} -f 25 -w -t "Missing gamedata" -m "Please place your DARKWAR.WAD, DARKWAR.RTC, and DARKWAR.RTL files into the /ports/rott/ directory! \n\nPress 'Select' to exit this Text Viewer"

$GPTOKEYB "rott_dw.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/rott_dw.${DEVICE_ARCH}"
./rott_dw.${DEVICE_ARCH}

pm_finish
