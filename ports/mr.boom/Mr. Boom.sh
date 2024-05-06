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

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"TheRA"* ]]; then
  raloc="/opt/retroarch/bin"
  raconf=""
elif [[ $whichos == *"RetroOZ"* ]]; then
  raloc="/opt/retroarch/bin"
  raconf="--config /home/odroid/.config/retroarch/retroarch.cfg"
elif [[ -e "/storage/.config/.OS_ARCH" ]] || [ -z $ESUDO ]; then
  raloc="/usr/bin"
  raconf=""
else
  raloc="/usr/local/bin"
  raconf=""
fi

GAMEDIR="/$directory/ports/mrboom"

$raloc/retroarch $raconf -L $GAMEDIR/mrboom_libretro.so

