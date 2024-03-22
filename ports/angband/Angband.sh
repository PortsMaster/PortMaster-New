#!/bin/bash
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

GAMEDIR=/$directory/ports/angband
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO rm -rf ~/.angband
ln -sfv $GAMEDIR/conf/.angband ~/

# Set up game resolution
if [ ! -f $GAMEDIR/conf/.angband/Angband/sdl2init.txt ]; then
  mkdir -p $GAMEDIR/conf/.angband/Angband
  cp $GAMEDIR/conf/template/sdl2init.txt $GAMEDIR/conf/.angband/Angband
fi

IS_DISPLAY_EQ=$(grep -q "$DISPLAY_WIDTH:$DISPLAY_HEIGHT" "$GAMEDIR/conf/.angband/Angband/sdl2init.txt")

if [ $? -ne 0 ]; then
  printf "Setting up resolution...\n"

  if [ ! -f $GAMEDIR/conf/.angband/Angband/sdl2init.txt ]; then
    rm $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  fi

  cp $GAMEDIR/conf/template/sdl2init.txt $GAMEDIR/conf/.angband/Angband
  sed -i "s/CONF_DISPLAY_WIDTH/$DISPLAY_WIDTH/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  sed -i "s/CONF_DISPLAY_HEIGHT/$DISPLAY_HEIGHT/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  sed -i "s/CONF_WINDOW_WIDTH/$DISPLAY_WIDTH/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  WINDOW_OFFSET=12
  WINDOW_HEIGHT="$((DISPLAY_HEIGHT-WINDOW_OFFSET))"
  sed -i "s/CONF_WINDOW_HEIGHT/$WINDOW_HEIGHT/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt

  if [ "$DISPLAY_WIDTH" -lt "481" ] && [ "$DISPLAY_HEIGHT" -lt "321" ]; then
    sed -i "s/CONF_FONT_SIZE/5x8x/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  elif [ "$DISPLAY_WIDTH" -lt "641" ] && [ "$DISPLAY_HEIGHT" -lt "481" ]; then
    sed -i "s/CONF_FONT_SIZE/7x13x/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  elif [ "$DISPLAY_WIDTH" -lt "900" ] && [ "$DISPLAY_HEIGHT" -lt "481" ]; then
    sed -i "s/CONF_FONT_SIZE/8x12x/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  elif [ "$DISPLAY_HEIGHT" -lt "721" ] && [ "$DISPLAY_WIDTH" -lt "721" ]; then
    sed -i "s/CONF_FONT_SIZE/8x16x/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  else
    sed -i "s/CONF_FONT_SIZE/12x24x/" $GAMEDIR/conf/.angband/Angband/sdl2init.txt
  fi
fi

if [ ! -f $GAMEDIR/conf/.angband/Angband/customized_interface_options.txt ]; then
  cp $GAMEDIR/conf/template/customized_interface_options.txt $GAMEDIR/conf/.angband/Angband
fi

if grep -q "option:use_sound:no" "$GAMEDIR/conf/.angband/Angband/customized_interface_options.txt"; then
  printf "Enabling sound...\n"
  sed -i "s/option:use_sound:no/option:use_sound:yes/" $GAMEDIR/conf/.angband/Angband/customized_interface_options.txt
fi

export LANG=en_US.utf8

cd $GAMEDIR

printf "Starting game...\n"

$GPTOKEYB "angband" -c angband.gptk &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./angband 

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0