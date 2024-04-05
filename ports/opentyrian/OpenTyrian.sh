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

$ESUDO rm -rf ~/.config/opentyrian
ln -sfv $GAMEDIR/ ~/.config/
cd $GAMEDIR
$GPTOKEYB opentyrian &
$GAMEDIR/opentyrian --data=$GAMEDIR/data 2>&1 | tee $GAMEDIR/log.txt

if [[ $whichos == *"ArkOS"* ]]; then
  cp /home/ark/.asoundrcbak /home/ark/.asoundrc
elif [[ $whichos == *"RetroOZ"* ]]; then
  cp /home/odroid/.asoundrcbak /home/odroid/.asoundrc
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1

