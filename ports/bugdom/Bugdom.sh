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

GAMEDIR="/$directory/ports/bugdom"

cd $GAMEDIR

if [[ "${QUIRK_DEVICE}" == "Anbernic RG351M" ]] || [[ "${QUIRK_DEVICE}" == "Anbernic RG351V" ]]; then
  export SDL_GAMECONTROLLERCONFIG="03002758091200000031000011010000,OpenSimHardware OSH PB Controller,platform:Linux,x:b2,a:b0,b:b1,y:b3,back:b7,start:b6,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,dpup:h0.1,leftshoulder:b4,lefttrigger:b10,rightshoulder:b5,righttrigger:b11,leftstick:b8,rightstick:b9,leftx:a0~,lefty:a1~,rightx:a2,righty:a3,"
fi

$GPTOKEYB "Bugdom" -c "./bugdom.gptk" &
./Bugdom | tee ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
