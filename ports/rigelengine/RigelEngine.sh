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

GAMEDIR="/$directory/ports/RigelEngine"
cd $GAMEDIR

$ESUDO rm -rf ~/.local/share/lethal-guitar
ln -sfv $GAMEDIR/conf/lethal-guitar ~/.local/share/
if [ -f "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json" ]; then
  if [ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]; then
    $ESUDO sed -i '/windowWidth\"\: / s/854/1920/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
    $ESUDO sed -i '/windowWidth\"\: / s/640/1920/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
    $ESUDO sed -i '/windowHeight\"\: / s/480/1080/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
  elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
echo "config OGS"
    $ESUDO sed -i '/windowWidth\"\: / s/1920/854/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
    $ESUDO sed -i '/windowWidth\"\: / s/640/854/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
    $ESUDO sed -i '/windowHeight\"\: / s/1080/480/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
  else
    $ESUDO sed -i '/windowWidth\"\: / s/1920/640/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
    $ESUDO sed -i '/windowWidth\"\: / s/854/640/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
    $ESUDO sed -i '/windowHeight\"\: / s/1080/480/' "$GAMEDIR/conf/lethal-guitar/Rigel Engine/Options.json"
  fi
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "RigelEngine" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./RigelEngine 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

