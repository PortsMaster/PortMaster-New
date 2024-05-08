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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod 666 /dev/tty1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

GAMEDIR="/$directory/ports/Abuse"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GAMEDIR/libs"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

GPTOKEYB_CONFIG="abuse.gptk"

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  GPTOKEYB_CONFIG="abuse.gptk.rg351p.rightanalog"
  sed -i '/ctr_left_stick_aim\=1/s//ctr_left_stick_aim\=0/' $GAMEDIR/user/config.txt
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    GPTOKEYB_CONFIG="abuse.gptk.leftanalog" # it's also necessary to modify ./user/config.txt ctr_left_stick_aim=1 to enable left stick aiming
	sed -i '/ctr_left_stick_aim\=0/s//ctr_left_stick_aim\=1/' $GAMEDIR/user/config.txt
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sed -i '/ctr_left_stick_aim\=1/s//ctr_left_stick_aim\=0/' $GAMEDIR/user/config.txt
else
  sed -i '/ctr_left_stick_aim\=1/s//ctr_left_stick_aim\=0/' $GAMEDIR/user/config.txt
fi

if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ $(cat "/storage/.config/.OS_ARCH") == "RG351V" ]; then
  GPTOKEYB_CONFIG="abuse.gptk.rg351p.leftanalog"
  sed -i '/ctr_left_stick_aim\=0/s//ctr_left_stick_aim\=1/' $GAMEDIR/user/config.txt
fi

cd $GAMEDIR

$ESUDO rm -rf ~/.abuse
ln -sfv $GAMEDIR/conf/.abuse ~/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "abuse" -c "$GAMEDIR/$GPTOKEYB_CONFIG" &
./abuse
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1