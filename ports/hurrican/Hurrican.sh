#!/bin/bash

DATA="https://github.com/drfiemost/Hurrican/archive/refs/heads/master.zip"

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

CONFIGFOLDER="/$directory/ports/hurrican"
DATAFOLDER="$CONFIGFOLDER/data"

WGET="wget"

if [[ -f "/storage/.config/.OS_ARCH" ]]; then
  WGET="$CONFIGFOLDER/wget"
fi

export LD_LIBRARY_PATH="$CONFIGFOLDER/libs:$LD_LIBRARY_PATH"

printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

cd "${CONFIGFOLDER}"

if [[ ! -e "${DATAFOLDER}/levels/levellist.dat" ]]; then
    cat /etc/motd > /dev/tty0
    echo "Downloading Hurrican data, please wait..." > /dev/tty0
    rm -rf "${DATAFOLDER}"
    rm -rf "${CONFIGFOLDER}/lang"
    $WGET "${DATA}" -q --show-progress > /dev/tty0 2>&1
    echo "Installing Hurrican data, please wait..." > /dev/tty0
    $ESUDO unzip "${CONFIGFOLDER}/master.zip" "Hurrican-master/Hurrican/data/*" -d "${CONFIGFOLDER}"
    $ESUDO unzip "${CONFIGFOLDER}/master.zip" "Hurrican-master/Hurrican/lang/*.lng" -d "${CONFIGFOLDER}"
    mv "${CONFIGFOLDER}/Hurrican-master/Hurrican/data" "${CONFIGFOLDER}"
    mv "${CONFIGFOLDER}/Hurrican-master/Hurrican/lang" "${CONFIGFOLDER}"
    rm -rf "${CONFIGFOLDER}/Hurrican-master" > /dev/tty0 2>&1
    rm "${CONFIGFOLDER}/master.zip" > /dev/tty0 2>&1
    rm "${DATAFOLDER}/textures/pvr/PVRCompress.sh" > /dev/tty0 2>&1
fi

mkdir -p ${CONFIGFOLDER}/conf/hurrican
bind_directories ~/.config/hurrican ${CONFIGFOLDER}/conf/hurrican
mkdir -p ${CONFIGFOLDER}/highscores/hurrican
bind_directories ~/.local/share/hurrican ${CONFIGFOLDER}/highscores/hurrican

$GPTOKEYB "hurrican" -c "$CONFIGFOLDER/hurrican.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./hurrican --depth 16 2>&1 | tee $CONFIGFOLDER/log.txt

pm_finish

unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty0
