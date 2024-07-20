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
source $controlfolder/device_info.txt

get_controls

GAMEDIR="/$directory/ports/rott"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

[ ! -f "$GAMEDIR/conf/.rott/config.rot" ] && $ESUDO cp -f -v "$GAMEDIR/conf/.rott/config_bak.rot" "$GAMEDIR/conf/.rott/config.rot"
[[ "$CFW_NAME" != *"ArkOS"* ]] && $ESUDO cp -f -v $GAMEDIR/timidity_cfg.bak $GAMEDIR/timidity.cfg

$ESUDO chmod 777 -R $GAMEDIR/*

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

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

$ESUDO rm -rf ~/.rott
$ESUDO ln -sfv $GAMEDIR/conf/.rott ~/

if [[ "$ANALOG_STICKS" == '1' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/rott1joy.gptk"  
elif [[ "$DEVICE_NAME" == 'x55' ]] || [[ "$DEVICE_NAME" == 'RG353P' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/rott_triggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/rott.gptk"
fi

$GPTOKEYB "rott_sw" -c "$GPTOKEYB_CONFIG" &
./rott_sw

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
