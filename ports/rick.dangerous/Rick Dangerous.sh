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
get_controls

if [[ $CFW_NAME == "TheRA" ]]; then
  raloc="/opt/retroarch/bin"
  raconf=""
elif [[ $CFW_NAME == "RetroOZ" ]]; then
  raloc="/opt/retroarch/bin"
  raconf="--config /home/odroid/.config/retroarch/retroarch.cfg"
elif [[ $CFW_NAME == *"ArkOS"* ]]; then
  raloc="/usr/local/bin"
  raconf=""
elif [[ $CFW_NAME == "muOS" ]]; then
  raloc="/usr/bin"
  if [ -f /run/muos/storage/info/config/retroarch.cfg ]; then
    raconf="--config /run/muos/storage/info/config/retroarch.cfg"
  elif [ -f /mnt/mmc/MUOS/retroarch/retroarch.cfg ]; then
    raconf="--config /mnt/mmc/MUOS/retroarch/retroarch.cfg"
  else
    raconf=""
  fi
elif [[ $CFW_NAME == "Miyoo" ]]; then
  raloc="/mnt/sdcard/RetroArch"
  raconf=""
else
  raloc="/usr/bin"
  raconf=""
fi

GAMEDIR="/$directory/ports/xrick"

$GPTOKEYB "retroarch" &
$raloc/retroarch $raconf -L $GAMEDIR/xrick_libretro.so $GAMEDIR
pm_finish
