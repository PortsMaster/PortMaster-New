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

GAMEDIR="/$directory/ports/opentyrian"

$ESUDO chmod 666 /dev/tty1

if [[ -e "/usr/share/plymouth/themes/text.plymouth" ]]; then
    plymouth="/usr/share/plymouth/themes/text.plymouth"
    whichos=$(grep "title=" $plymouth)
fi

if [[ $whichos == *"ArkOS"* ]]; then
  cp /home/ark/.asoundrcfords /home/ark/.asoundrc
elif [[ $whichos == *"RetroOZ"* ]]; then
  cp /home/odroid/.asoundrcfords /home/odroid/.asoundrc
fi
#export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
bind_directories ~/.config/opentyrian $GAMEDIR/

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$GPTOKEYB opentyrian.${DEVICE_ARCH} -c ./opentyrian.gptk &
pm_platform_helper "$GAMEDIR/opentyrian.${DEVICE_ARCH}"
$GAMEDIR/opentyrian.${DEVICE_ARCH} --data=$GAMEDIR/data

if [[ $whichos == *"ArkOS"* ]]; then
  cp /home/ark/.asoundrcbak /home/ark/.asoundrc
elif [[ $whichos == *"RetroOZ"* ]]; then
  cp /home/odroid/.asoundrcbak /home/odroid/.asoundrc
fi

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish


