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

GAMEDIR="/$directory/ports/openclaw"
cd $GAMEDIR

yres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f2)"

if [[ -f "CLAW.REZ.gz" ]]; then
  # Delete the old CLAW.REZ if it already exists before extracting the new one.
  $ESUDO rm -f CLAW.REZ
  # Extract the CLAW.REZ file.
  gzip -d CLAW.REZ.gz
fi

if [[ "$LOWRES" == "Y" ]]; then
  sed -i '/width\=\"1920\"/s//width\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"857\"/s//width\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"640\"/s//width\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"960\"/s//width\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"544\"/s//height\=\"320\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"1080\"/s//height\=\"320\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"480\"/s//height\=\"320\"/g' $GAMEDIR/config.xml
  sed -i '/<Scale>3/s//<Scale>1/g' $GAMEDIR/config.xml
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] && [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  sed -i '/width\=\"857\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"640\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"480\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"960\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"544\"/s//height\=\"1080\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"480\"/s//height\=\"1080\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"320\"/s//height\=\"1080\"/g' $GAMEDIR/config.xml
  sed -i '/<Scale>1/s//<Scale>3/g' $GAMEDIR/config.xml
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Rockchip RK3566 EVB2 LP4X V10 Board" ]] || [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG503" ]]; then
  sed -i '/width\=\"857\"/s//width\=\"960\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"640\"/s//width\=\"960\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"480\"/s//width\=\"960\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"1920\"/s//width\=\"960\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"1080\"/s//height\=\"544\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"480\"/s//height\=\"544\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"320\"/s//height\=\"544\"/g' $GAMEDIR/config.xml
  sed -i '/<Scale>3/s//<Scale>1/g' $GAMEDIR/config.xml
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sed -i '/width\=\"1920\"/s//width\=\"857\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"640\"/s//width\=\"857\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"480\"/s//width\=\"857\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"960\"/s//width\=\"857\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"544\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"1080\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"320\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/<Scale>3/s//<Scale>1/g' $GAMEDIR/config.xml
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG353P" ]]; then
  if [[ $yres = 480 ]]; then
    	sed -i '/width\=\"857\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
	sed -i '/width\=\"960\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
	sed -i '/width\=\"480\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
	sed -i "/width\=\"1920\"/s//width\=\"640\"/g" $GAMEDIR/config.xml
	sed -i "/height\=\"1080\"/s//height\=\"480\"/g" $GAMEDIR/config.xml
	sed -i '/height\=\"544\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
	sed -i '/height\=\"320\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
	sed -i '/<Scale>2/s//<Scale>1/g' $GAMEDIR/config.xml
  else
	sed -i '/width\=\"857\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
	sed -i '/width\=\"640\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
	sed -i '/width\=\"480\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
	sed -i '/width\=\"960\"/s//width\=\"1920\"/g' $GAMEDIR/config.xml
	sed -i '/height\=\"544\"/s//height\=\"1080\"/g' $GAMEDIR/config.xml
	sed -i '/height\=\"480\"/s//height\=\"1080\"/g' $GAMEDIR/config.xml
	sed -i '/height\=\"320\"/s//height\=\"1080\"/g' $GAMEDIR/config.xml
  	sed -i '/<Scale>1/s//<Scale>2/g' $GAMEDIR/config.xml
  fi
else
  sed -i '/width\=\"1920\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"857\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"480\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
  sed -i '/width\=\"960\"/s//width\=\"640\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"544\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"1080\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/height\=\"320\"/s//height\=\"480\"/g' $GAMEDIR/config.xml
  sed -i '/<Scale>3/s//<Scale>1/g' $GAMEDIR/config.xml
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "openclaw" -c "$GAMEDIR/openclaw.gptk.1" &
LD_LIBRARY_PATH="$GAMEDIR/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./openclaw 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

