#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/gmu-music-player"

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
      param_device="anbernic"
      hotkey="Select"
      GPTOKEYB="$GAMEDIR/gptokeyb $ESUDOKILL"
      GMU_CONFIG="gmu.rg351p.conf"
      if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ] || [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
        param_device="anbernic"
        hotkey="Select"
        GPTOKEYB="$GAMEDIR/gptokeyb $ESUDOKILL"
        GMU_CONFIG="gmu.rg351v.conf"
      fi
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
      param_device="oga"
      hotkey="Minus"
      GMU_CONFIG="gmu.rg351p.conf"
	else
      param_device="rk2020"
      hotkey="Select"
      GMU_CONFIG="gmu.rg351p.conf"
   fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
      param_device="ogs"
      hotkey="Select"
      #SCREENW="854"  --The Odroid Go Super has a 848x480 display, but the RG351MP has a 640x480 res
      GMU_CONFIG="gmu.rg351mp.conf"
elif [[ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]]; then
      param_device="chi"
      hotkey="1"
      GMU_CONFIG="gmu.rg351mp.conf"
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]]; then
      param_device="rg552"
      hotkey="L3"
      GMU_CONFIG="gmu.rg351mp.conf"
elif [ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ] || [ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]; then
      param_device="rg503"
      hotkey="Select"
      GMU_CONFIG="gmu.rg351mp.conf"
else
      param_device="${2}"
      hotkey="Select"
      GMU_CONFIG="gmu.rg351mp.conf"
fi

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# system
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/
export LD_LIBRARY_PATH=$GAMEDIR/libs

$ESUDO chmod ugo+rwx -R $GAMEDIR

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm $GAMEDIR/log.txt
sleep 1

$GPTOKEYB "gmu.bin" -c "$GAMEDIR/gmu.gptk" &
./gmu.bin -c $GMU_CONFIG 2>&1 | tee -a $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
printf "\033c" > /dev/tty1
printf "\033c" >> /dev/tty1