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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/nfshp2

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# First run: install the game's files from the disc image in gamedata/.
export NFSHP2_ROOT="$GAMEDIR/gamedata"
if [ ! -d "$NFSHP2_ROOT/NFSHP2/GLOBAL" ]; then
  # The disc image the installer reads.
  export NFSHP2_ISO=$(find "$NFSHP2_ROOT" -maxdepth 1 -type f -iname '*.iso' | head -n 1)
  if [ -z "$NFSHP2_ISO" ]; then
    pm_message "Copy your PS2 disc image (.iso) into ports/nfshp2/gamedata. See README.md."
    sleep 10
    pm_finish
    exit 1
  fi
  export PATCHER_FILE="$GAMEDIR/tools/patchscript"
  export PATCHER_GAME="Need for Speed: Hot Pursuit 2"
  export PATCHER_TIME="about 10 minutes"
  $ESUDO chmod a+x "$GAMEDIR/tools/patchscript"
  source "$controlfolder/utils/patcher.txt"
  cd $GAMEDIR
fi
if [ ! -d "$NFSHP2_ROOT/NFSHP2/GLOBAL" ]; then
  pm_message "Need for Speed: Hot Pursuit 2 is not installed yet. See ports/nfshp2/patchlog.txt, then launch again."
  sleep 5
  pm_finish
  exit 1
fi

# Settings from nfshp2.cfg (README.md).
if [ -f "$GAMEDIR/nfshp2.cfg" ]; then
  set -a; source "$GAMEDIR/nfshp2.cfg"; set +a
fi

export LD_LIBRARY_PATH="/usr/lib32:$LD_LIBRARY_PATH"
# The game reads buttons by position; PortMaster maps pads by label, so these pads get their own lines.
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig
190000004b4800000011000000010000,GO-Super Gamepad,a:b0,b:b1,x:b3,y:b2,back:b12,start:b13,leftstick:b14,rightstick:b15,guide:b16,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,
19000000010000000100000000010000,Deeplay-keys,a:b4,b:b3,x:b5,y:b6,back:b9,start:b10,guide:b11,leftstick:b12,rightstick:b15,leftshoulder:b7,rightshoulder:b8,lefttrigger:b13,righttrigger:b14,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,dpup:h0.1,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,
060000006d750000010700006f730000,muOS-Keys,a:b3,b:b2,x:b5,y:b4,leftshoulder:b6,rightshoulder:b7,lefttrigger:b8,righttrigger:b9,guide:b12,start:b11,back:b10,dpup:h0.1,dpleft:h0.8,dpright:h0.2,dpdown:h0.4,volumedown:b0,volumeup:b1,leftx:a0,lefty:a1,platform:Linux,"

$ESUDO chmod +x "$GAMEDIR/nfshp2.armhf"

$GPTOKEYB2 "nfshp2.armhf" > /dev/null 2>&1 &
pm_platform_helper "$GAMEDIR/nfshp2.armhf"

./nfshp2.armhf

pm_finish
