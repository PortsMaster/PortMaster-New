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

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$controlfolder/libs/aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 777 -R $GAMEDIR/*

sed -i 's/ScreenMode = 1/ScreenMode = 0/' $GAMEDIR/conf/eduke32/eduke32.cfg
sed -i "s/ScreenWidth[[:space:]]*=[[:space:]]*[^[:space:]]*/ScreenWidth = $DISPLAY_WIDTH/" "$GAMEDIR/conf/eduke32/eduke32.cfg"
sed -i "s/ScreenHeight[[:space:]]*=[[:space:]]*[^[:space:]]*/ScreenHeight = $DISPLAY_HEIGHT/" "$GAMEDIR/conf/eduke32/eduke32.cfg"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO rm $GAMEDIR/eduke32.log
$ESUDO rm $GAMEDIR/fury.log

bind_directories ~/.config/eduke32 $GAMEDIR/conf/eduke32

# Ensure Swap space is prepared or eduke32 may crash or fail to launch
printf "\033c" > /dev/tty0
if [[ $CFW_NAME == *"ArkOS"* ]] || [[ $CFW_NAME == *"ODROID"* ]]; then
	  echo "Preparing Swap File, please wait..." > /dev/tty0
    [ -f /swapfile ] && $ESUDO swapoff -v /swapfile
    [ -f /swapfile ] && $ESUDO rm -f /swapfile
    $ESUDO fallocate -l 384M /swapfile
    $ESUDO chmod 600 /swapfile
    $ESUDO mkswap /swapfile
    $ESUDO swapon /swapfile
fi

if [[ "${DEVICE_NAME^^}" == 'X55' ]] || [[ "${DEVICE_NAME^^}" == 'RG353P' ]] || [[ "${DEVICE_NAME^^}" == *'RG40XX'* ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/ionfurytriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/ionfury.gptk"
fi

$GPTOKEYB "eduke32.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/eduke32.${DEVICE_ARCH}"
./eduke32.${DEVICE_ARCH} -gfury.grp

pm_finish
