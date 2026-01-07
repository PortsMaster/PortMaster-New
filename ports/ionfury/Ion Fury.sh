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

GAMEDIR="/$directory/ports/ionfury"

$ESUDO chmod 777 -R $GAMEDIR/*

sed -i 's/ScreenMode = 1/ScreenMode = 0/' $GAMEDIR/conf/eduke32/eduke32.cfg
sed -i "s/ScreenWidth[[:space:]]*=[[:space:]]*[^[:space:]]*/ScreenWidth = $DISPLAY_WIDTH/" "$GAMEDIR/conf/eduke32/eduke32.cfg"
sed -i "s/ScreenHeight[[:space:]]*=[[:space:]]*[^[:space:]]*/ScreenHeight = $DISPLAY_HEIGHT/" "$GAMEDIR/conf/eduke32/eduke32.cfg"
sleep 0.3

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO rm $GAMEDIR/eduke32.log
$ESUDO rm $GAMEDIR/fury.log

bind_directories ~/.config/eduke32 "$GAMEDIR/conf/eduke32"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure Swap space is prepared or eduke32 may crash or fail to launch
if [[ $CFW_NAME == *"ArkOS"* ]] || [[ $CFW_NAME == *"ODROID"* ]]; then
    pm_message "Preparing Swap File, please wait..."
    if [[ $CFW_NAME == "dArkOS" ]]; then
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
elif [[ "${CFW_NAME^^}" == "KNULLI" ]]; then
    pm_message "Preparing Swap File, please wait..."
    [ -f /media/SHARE/swapfile ] && $ESUDO swapoff -v /media/SHARE/swapfile
    [ -f /media/SHARE/swapfile ] && $ESUDO rm -f /media/SHARE/swapfile
    $ESUDO fallocate -l 384M /media/SHARE/swapfile
    $ESUDO chmod 600 /media/SHARE/swapfile
    $ESUDO mkswap /media/SHARE/swapfile
    $ESUDO swapon /media/SHARE/swapfile
fi

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/ionfurytriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/ionfury.gptk"
fi

$GPTOKEYB "eduke32.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/eduke32.${DEVICE_ARCH}"
./eduke32.${DEVICE_ARCH} -gfury.grp

pm_finish
