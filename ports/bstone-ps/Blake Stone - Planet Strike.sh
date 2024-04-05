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

GAMEDIR="/$directory/ports/bstone-ps"

GPTOKEYB_CONFIG="$GAMEDIR/bstone.gptk"

if [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]]; then
  xres="1920"
  yres="1152"
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]]; then
  xres="960"
  yres="544"
elif [[ "$(cat /sys/class/drm/card0-HDMI-A-1/status)" == "connected" ]]; then
  xres="$(cat /sys/class/drm/card0-HDMI-A-1/modes | grep -o -P '\d*x\d*' | cut -dx -f1)"
  yres="$(cat /sys/class/drm/card0-HDMI-A-1/modes | grep -o -P '\d*x\d*' | cut -dx -f2)"
elif [[ "$(cat /sys/class/drm/card0-DSI-1/status)" == "connected" ]]; then
  xres="$(cat /sys/class/drm/card0-DSI-1/modes | grep -o -P '\d*x\d*' | cut -dx -f1)"
  yres="$(cat /sys/class/drm/card0-DSI-1/modes | grep -o -P '\d*x\d*' | cut -dx -f2)"
else
  xres="640"
  yres="480"
fi

echo $xres
echo $yres

$ESUDO sed -i "s|vid_width \"[0-9]\+\"|vid_width \"$xres\"|g" $GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt
$ESUDO sed -i "s|vid_height \"[0-9]\+\"|vid_height \"$yres\"|g" $GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt

if [[ $xres == '480' ]] || [[$xres == '320']]; then
    $ESUDO sed -i '/vid_is_ui_stretched / s/"1"/"0"/' $GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt
    $ESUDO sed -i '/vid_is_widescreen / s/"1"/"0"/' $GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt
else
    $ESUDO sed -i '/vid_is_ui_stretched / s/"0"/"1"/' $GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt
    $ESUDO sed -i '/vid_is_widescreen / s/"0"/"1"/' $GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt
fi

if [[ $ANALOGSTICKS == '1' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/bstone.gptk.leftanalog"  
fi

cd $GAMEDIR

$ESUDO rm -rf ~/.local/share/bibendovsky
ln -sfv $GAMEDIR/conf/bibendovsky ~/.local/share/

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "bstone" -c "$GPTOKEYB_CONFIG" &
LD_LIBRARY_PATH="$GAMEDIR/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bstone --data_dir $GAMEDIR/gamedata/planet_strike  2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

