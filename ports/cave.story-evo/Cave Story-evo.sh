#!/bin/bash
# PORTMASTER: cave.story-evo.zip, Cave Story-evo.sh


if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR=/$directory/ports/nxengine-evo

exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [[ $LOWRES == "Y" ]]; then
  if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    mv -f $GAMEDIR/conf/nxengine/settings.dat.480 $GAMEDIR/conf/nxengine/settings.dat
    rm -f $GAMEDIR/conf/nxengine/settings.dat.*
  fi
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == *"RK3566"* ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    if [[ "$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)" == "960" ]]; then
      mv -f $GAMEDIR/conf/nxengine/settings.dat.rg503 $GAMEDIR/conf/nxengine/settings.dat
      rm -f $GAMEDIR/conf/nxengine/settings.dat.*
    else
      mv -f $GAMEDIR/conf/nxengine/settings.dat.640 $GAMEDIR/conf/nxengine/settings.dat
      rm -f $GAMEDIR/conf/nxengine/settings.dat.*
	fi
  fi
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    mv -f $GAMEDIR/conf/nxengine/settings.dat.rg552 $GAMEDIR/conf/nxengine/settings.dat
    rm -f $GAMEDIR/conf/nxengine/settings.dat.*
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    mv -f $GAMEDIR/conf/nxengine/settings.dat.ogs $GAMEDIR/conf/nxengine/settings.dat
    rm -f $GAMEDIR/conf/nxengine/settings.dat.*
  fi
else
  if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    mv -f $GAMEDIR/conf/nxengine/settings.dat.640 $GAMEDIR/conf/nxengine/settings.dat
    rm -f $GAMEDIR/conf/nxengine/settings.dat.*
  fi
fi

$ESUDO rm -rf ~/.local/share/nxengine
$ESUDO ln -s $GAMEDIR/conf/nxengine ~/.local/share/
cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "nxengine-evo" -c nxengine-evo.gptk &
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GAMEDIR/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./nxengine-evo

$ESUDO kill -9 $(pidof gptokeyb) & 
printf "\033c" >> /dev/tty1
