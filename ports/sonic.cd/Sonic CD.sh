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

get_controls

GAMEDIR="/$directory/ports/soniccd"

$ESUDO chmod 666 /dev/tty1

if [[ ! -z $(cat /storage/.config/.OS_ARCH | grep "351V") ]] || [[ -e "/boot/rk3326-rg351v-linux.dtb" ]] || [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] || [[ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [[ -e $GAMEDIR/settings.ini.640 ]]; then
    mv $GAMEDIR/settings.ini.640 $GAMEDIR/settings.ini
  fi
fi

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  export LD_LIBRARY_PATH="$GAMEDIR/libs"
else
  export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib:/usr/lib32"
fi

cd $GAMEDIR
$GPTOKEYB "soniccd" -c "soniccd.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./soniccd 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
