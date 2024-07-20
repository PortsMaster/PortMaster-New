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

get_controls

GAMEDIR="/$directory/ports/to_the_moon"
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$GAMEDATA"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Extract and organize game files if the installer exists

WOG_FILE=$(ls to_the_moon_*.sh 2> /dev/null | head -n 1)

if [ -f ""$WOG_FILE"" ]; then
    unzip -o "$WOG_FILE" > "$CUR_TTY"
    if [ -d "data/noarch/game" ]; then
        $ESUDO mv -f data/noarch/game/* "$GAMEDIR/gamedata/" || { echo "Failed to move game directory." > "$CUR_TTY"; sleep 5; exit 1; }
    else
        echo "Game directory not found after extraction." > "$CUR_TTY"
		sleep 5
        exit 1
    fi
	rm -f "$WOG_FILE"
    echo "Setup complete. Have fun playing!" > "$CUR_TTY"
fi

# Run minilauncher
chmod +x ./love
$GPTOKEYB "love" &
./love minilauncher
FOLDER=$(<selected_game.txt)

# Cleanup minilauncher
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0


[ -d gamedata/lib ] && rm -rf data/ meta/ scripts/ $FOLDER/lib gamedata/lib64
[ -f falcon_mkxp.bin ] && cp falcon_mkxp.bin "$FOLDER/falcon_mkxp.bin"
if [ $FOLDER == "minisode2" ]; then
  cp conf/mkxp2.conf "$FOLDER/mkxp.conf"
else
  cp conf/mkxp.conf $FOLDER/
fi

$GPTOKEYB "falcon_mkxp.bin" -c "./to_the_moon.gptk" &
$GAMEDIR/$FOLDER/falcon_mkxp.bin
$ESUDO rm -f selected_game.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
