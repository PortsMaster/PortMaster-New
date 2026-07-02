#!/bin/bash
# PORTMASTER: minetest.zip, Minetest.sh

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

GAMEDIR="/$directory/ports/minetest"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export TERM=linux
printf "\033c" > /dev/tty0

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

CUR_TTY=/dev/tty0

ARCHIVE_FILE="$GAMEDIR/data.tar.gz"
SEVENZIP="${controlfolder}/7zzs.aarch64"

if [[ -f "$ARCHIVE_FILE" ]]; then
    echo "Extracting game data, this will take some time..." > "$CUR_TTY"

    if "$SEVENZIP" x "$ARCHIVE_FILE"; then
        TAR_FILE="${ARCHIVE_FILE%.gz}"

        if "$SEVENZIP" x "$TAR_FILE" -o"./"; then
            echo "Game data extracted successfully" > "$CUR_TTY"

            # cleanup
            rm -f "$ARCHIVE_FILE"
            rm -f "$TAR_FILE"
        else
            echo "ERROR!!!  Failed to extract TAR contents." > "$CUR_TTY"
            sleep 5
            exit 1
        fi
    else
        echo "ERROR!!!  Failed to decompress GZIP." > "$CUR_TTY"
        sleep 5
        exit 1
    fi
fi

ifconfig lo up
if [ "$CFW_NAME" = "ROCKNIX" ]; then
	swaymsg seat seat0 hide_cursor 0
fi
chmod +x ./bin/luanti
$GPTOKEYB "luanti" -c "$GAMEDIR/minetest.gptk.$ANALOG_STICKS" &
./bin/luanti
if [ "$CFW_NAME" = "ROCKNIX" ]; then
	swaymsg seat seat0 hide_cursor 1000
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
