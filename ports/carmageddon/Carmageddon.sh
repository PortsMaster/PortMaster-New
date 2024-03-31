#!/bin/bash
# Ported by Maciej Suminski <orson at orson dot net dot pl>
# Built from https://github.com/orsonmmz/dethrace (branch gles)

PORTNAME="Carmageddon"

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

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

GAMEDIR="/$directory/ports/carmageddon"
cd "$GAMEDIR"

if [[ ! -d "DATA" ]]; then
	echo Missing game files. Unzip the game files to $GAMEDIR. > $CUR_TTY
	sleep 5
	printf "\033c" >> $CUR_TTY
	exit 1
fi

if [[ ! -e ".init_done" && -e "DATA/KEYMAP_0.TXT" ]]; then
	# Apply default settings when the game is executed for the first time
	mv init/* DATA && rm -r init && touch .init_done
fi

$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$GPTOKEYB "dethrace" -c "./dethrace.gptk" &

./dethrace 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> $CUR_TTY

