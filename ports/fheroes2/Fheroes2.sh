#!/bin/bash

DATAFILE="h2demo.zip"
DATA="https://archive.org/download/HeroesofMightandMagicIITheSuccessionWars_1020/${DATAFILE}"
PORTNAME="Free Heroes of Might and Magic II"

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

CONFIGFOLDER="/$directory/ports/fheroes2"

cd "${CONFIGFOLDER}"

$ESUDO chmod 666 /dev/tty0
if [ ! -e "${CONFIGFOLDER}/data/HEROES2.AGG" ]; then
    clear > /dev/tty0
    cat /etc/motd > /dev/tty0
    echo "Downloading ${PORTNAME} data, please wait..." > /dev/tty0
    wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
    echo "Installing ${PORTNAME} data, please wait..." > /dev/tty0
    $ESUDO unzip -o "${DATAFILE}" -d "${CONFIGFOLDER}/zip" > /dev/tty0
    mv ${CONFIGFOLDER}/zip/DATA/* "${CONFIGFOLDER}/data/" > /dev/tty0 2>&1
    mv ${CONFIGFOLDER}/zip/MAPS/* "${CONFIGFOLDER}/maps/" > /dev/tty0 2>&1
    rm "${DATAFILE}" > /dev/tty0 2>&1
    rm -rf "${CONFIGFOLDER}/zip" > /dev/tty0 2>&1
    echo "Starting ${PORTNAME} for the first time, please wait..." > /dev/tty0
    cd "${CONFIGFOLDER}"
fi

$ESUDO rm -rf ~/.config/fheroes2
ln -sfv ${CONFIGFOLDER}/conf/fheroes2/ ~/.config/
$ESUDO rm -rf ~/.local/share/fheroes2
ln -sfv ${CONFIGFOLDER}/save/fheroes2/ ~/.local/share/

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "fheroes2" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./fheroes2 2>&1 | tee $CONFIGFOLDER/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty10
