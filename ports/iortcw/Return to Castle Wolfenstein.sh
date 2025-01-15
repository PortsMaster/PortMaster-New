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

GAMEDIR="/$directory/ports/iortcw"

if [ ! -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg ]; then
  if [ "$LOWRES" == "Y" ]; then 
    mv -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.480 $GAMEDIR/conf/.wolf/main/wolfconfig.cfg
    rm -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.*
  elif [[ -f /etc/trimui_device.txt && "x$(cat /etc/trimui_device.txt)" == "xtsp" ]]; then
      mv -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.tsp $GAMEDIR/conf/.wolf/main/wolfconfig.cfg
      rm -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.*
  elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] && [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then 
    mv -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.rg552 $GAMEDIR/conf/.wolf/main/wolfconfig.cfg
    rm -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.* 
  elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Rockchip RK3566 EVB2 LP4X V10 Board" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]]; then
    mv -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.ogs $GAMEDIR/conf/.wolf/main/wolfconfig.cfg
    rm -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.*
  else
    mv -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.640 $GAMEDIR/conf/.wolf/main/wolfconfig.cfg
    rm -f $GAMEDIR/conf/.wolf/main/wolfconfig.cfg.*
  fi
fi

bind_directories ~/.wolf $GAMEDIR/conf/.wolf/
cd $GAMEDIR

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  APP_TO_KILL="."
else
  APP_TO_KILL="iowolfsp.aarch64"
fi

$GPTOKEYB $APP_TO_KILL &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./iowolfsp.aarch64 2>&1 | tee $GAMEDIR/log.txt

pm_finish
