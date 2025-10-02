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

GAMEDIR="/$directory/ports/littlegptracker"
CUR_TTY="/dev/tty0"
BINARY="lgpt"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="/usr/lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib32/:$LD_LIBRARY_PATH"
export XDG_CONFIG_HOME="$GAMEDIR"
export XDG_DATA_HOME="$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
printf "\033c" > $CUR_TTY
printf "Starting...\n" > $CUR_TTY

MULT_W=$(($DISPLAY_WIDTH / 320))
MULT_H=$(($DISPLAY_HEIGHT / 240))
NEW_MULT=$((MULT_W < MULT_H ? MULT_W : MULT_H))

if [ "$NEW_MULT" -le 0 ]; then
	NEW_MULT=1
fi

sed -i "s/SCREENMULT value='[0-9]'/SCREENMULT value='$NEW_MULT'/" "$GAMEDIR/config.xml"

if [[ $CFW_NAME == "ArkOS"* ]]; then
	sed -E -i "s/FULLSCREEN value='(YES|NO)'/FULLSCREEN value='NO'/" "$GAMEDIR/config.xml"
else
	sed -E -i "s/FULLSCREEN value='(YES|NO)'/FULLSCREEN value='YES'/" "$GAMEDIR/config.xml"
fi

$GPTOKEYB "$BINARY" -c "$BINARY.gptk" &
./$BINARY

pm_finish
printf "\033c" > $CUR_TTY
