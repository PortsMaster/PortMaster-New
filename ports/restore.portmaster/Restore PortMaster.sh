#!/bin/bash
# PORTMASTER: restore.portmaster.zip, Restore PortMaster.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

GAMEDIR="/$directory/ports/restore.portmaster"

cd "$GAMEDIR"

touch "$HOME/no_es_restart"

chmod +x ./Install.PortMaster.txt
./Install.PortMaster.txt

cd ..

$controlfolder/harbourmaster --no-check uninstall restore.portmaster.zip

if [[ -e "/usr/share/plymouth/themes/text.plymouth" ]]; then
  ES_NAME="emulationstation"
else
  ES_NAME="emustation"
fi

$ESUDO systemctl restart $ES_NAME
