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

GAMEDIR="/$directory/ports/JediOutcast"

if [ ! -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg ]; then
  if [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Rockchip RK3566 EVB2 LP4X V10 Board" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]]; then
    mv -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.ogs $GAMEDIR/conf/openjo/base/openjo_sp.cfg
    rm -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.*
  else
    mv -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.rg552 $GAMEDIR/conf/openjo/base/openjo_sp.cfg
    rm -f $GAMEDIR/conf/openjo/base/openjo_sp.cfg.* 
  fi
fi

cd $GAMEDIR

$ESUDO rm -rf ~/.local/share/openjo
ln -sfv $GAMEDIR/conf/openjo/ ~/.local/share/

export SDL_VIDEO_GL_DRIVER="$GAMEDIR/libs/libGL.so.1"
export LIBGL_FB=4

source /etc/profile

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  APP_TO_KILL="."
  execute_perf=0
else
  APP_TO_KILL="openjo_sp.aarch64"
  execute_perf=1
fi

((execute_perf)) && maxperf

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB $APP_TO_KILL -c "openjo_sp.aarch64.gptk" &
LD_LIBRARY_PATH=$GAMEDIR/libs:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./openjo_sp.aarch64 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
((execute_perf)) && normperf
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1