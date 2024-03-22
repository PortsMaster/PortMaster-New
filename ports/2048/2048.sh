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

if [[ $CFW_NAME == "TheRA" ]]; then
  raloc="/opt/retroarch/bin"
  raconf=""
elif [[ $CFW_NAME == "RetroOZ" ]]; then
  raloc="/opt/retroarch/bin"
  raconf="--config /home/odroid/.config/retroarch/retroarch.cfg"
elif [[ $CFW_NAME == "ArkOS" ]]; then
  raloc="/usr/local/bin"
  raconf=""
elif [[ $CFW_NAME == "muOS" ]]; then
  raloc="/mnt/mmc/MUOS"
  raconf="--config /mnt/mmc/MUOS/.retroarch/retroarch.cfg"
else
  raloc="/usr/bin"
  raconf=""
fi

GAMEDIR="/$directory/ports/2048"

$GPTOKEYB "retroarch" &
$raloc/retroarch $raconf -L $GAMEDIR/2048_libretro.so.${DEVICE_ARCH}