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

GAMEDIR="/$directory/ports/cdogs"

if [[ $LOWRES == "Y" ]]; then
      if [ ! -f "$GAMEDIR/conf/cdogs-sdl/options.cnf" ]; then
        mv -f $GAMEDIR/conf/cdogs-sdl/options.cnf.480 $GAMEDIR/conf/cdogs-sdl/options.cnf
        rm -f $GAMEDIR/conf/cdogs-sdl/options.cnf.*
      fi
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] && [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [ ! -f "$GAMEDIR/conf/cdogs-sdl/options.cnf" ]; then
    mv -f $GAMEDIR/conf/cdogs-sdl/options.cnf.rg552 $GAMEDIR/conf/cdogs-sdl/options.cnf
    rm -f $GAMEDIR/conf/cdogs-sdl/options.cnf.*
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Rockchip RK3566 EVB2 LP4X V10 Board" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]]; then
  if [ ! -f "$GAMEDIR/conf/cdogs-sdl/options.cnf" ]; then
    mv -f $GAMEDIR/conf/cdogs-sdl/options.cnf.ogs $GAMEDIR/conf/cdogs-sdl/options.cnf
    rm -f $GAMEDIR/conf/cdogs-sdl/options.cnf.*
  fi
else
  if [ ! -f "$GAMEDIR/conf/cdogs-sdl/options.cnf" ]; then
    mv -f $GAMEDIR/conf/cdogs-sdl/options.cnf.640 $GAMEDIR/conf/cdogs-sdl/options.cnf
    rm -f $GAMEDIR/conf/cdogs-sdl/options.cnf.*
  fi
fi



rm -rf ~/.config/cdogs-sdl
ln -sfv $GAMEDIR/conf/cdogs-sdl/ ~/.config/

cd $GAMEDIR/data

chmod 666 /dev/tty1
$ESUDO $controlfolder/oga_controls cdogs-sdl $param_device &
./cdogs-sdl 2>&1 | tee -a $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1

