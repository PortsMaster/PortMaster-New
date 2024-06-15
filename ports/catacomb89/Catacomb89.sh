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

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

to_upper_case() {
    find "$1" -depth \( -name "*.ca2" -o -name "*.bak" -o -name "*.cat" \) | while IFS= read -r SRC; do
        DST=$(dirname "$SRC")/$(basename "$SRC" | tr '[:lower:]' '[:upper:]')
        TMP_DST=$(dirname "$SRC")/TEMP_$(basename "$SRC" | tr '[:lower:]' '[:upper:]')
        echo "SRC: $SRC"
        echo "DST: $DST"
        echo "TMP_DST: $TMP_DST"
        if [ "$SRC" != "$DST" ]; then
            echo "Renaming $SRC to $TMP_DST"
            $ESUDO mv -vf "$SRC" "$TMP_DST"
            echo "Renaming $TMP_DST to $DST"
            $ESUDO mv -vf "$TMP_DST" "$DST"
        else
            echo "- $SRC is already uppercase"
        fi
    done
}

#GAMEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/catacomb89"
GAMEDIR="/$directory/ports/catacomb89"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

to_upper_case "$GAMEDIR"

$ESUDO cp -f -v $GAMEDIR/CTLPANEL.BAK $GAMEDIR/CTLPANEL.CA2
$ESUDO cp -f -v $GAMEDIR/CTLPANEL.BAK $GAMEDIR/CTLPANEL.CAT

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 777 -R $GAMEDIR/*

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "catacomb89" -c "$GAMEDIR/catacomb89.gptk" &
./catacomb89

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
