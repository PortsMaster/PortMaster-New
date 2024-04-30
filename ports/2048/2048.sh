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
elif [[ $CFW_NAME == "muOS" && $DEVICE_ARCH == "aarch64" ]]; then
  raloc="/usr/bin"
  raconf="--config /mnt/mmc/MUOS/retroarch/retroarch32.cfg"
elif [[ $CFW_NAME == "muOS" && $DEVICE_ARCH != "aarch64" ]]; then
  raloc="/mnt/mmc/MUOS"
  raconf="--config /mnt/mmc/MUOS/.retroarch/retroarch.cfg"
else
  raloc="/usr/bin"
  raconf=""
fi

GAMEDIR="/$directory/ports/2048"

if [[ $CFW_NAME == "muOS" && $DEVICE_ARCH == "aarch64" ]]; then
  $GPTOKEYB "retroarch32" &
  $raloc/retroarch32 $raconf -L $GAMEDIR/2048_libretro.so.armhf
else
  $GPTOKEYB "retroarch" &
  $raloc/retroarch $raconf -L $GAMEDIR/2048_libretro.so.${DEVICE_ARCH}
fi
