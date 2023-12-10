#!/bin/bash
# Built from https://github.com/alexbatalov/fallout2-ce

PORTNAME="Fallout 1"

if [ -d "/opt/system/Tools/PortMaster/" ]; then
    controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
    controlfolder="/opt/tools/PortMaster"
else
    controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

to_lower_case() {
    for SRC in $(find "$1" -depth); do
    DST=$(dirname "${SRC}")/$(basename "${SRC}" | tr '[A-Z]' '[a-z]')
    if [ "${SRC}" != "${DST}" ]; then
        [ ! -e "${DST}" ] && $ESUDO mv -vT "${SRC}" "${DST}" || echo "- ${SRC} was not renamed"
    fi
    done
}

get_controls

PORTDIR="/$directory/ports/fallout1"

cd "$PORTDIR"

for file in data critter.dat master.dat; do
    if [[ ! -e "$file" ]]; then
        file_uc=$(echo "$file" | tr '[a-z]' '[A-Z]')

        if [[ -e "$file_uc" ]]; then
            # File exists but it is in uppercase, make it lowercase.
            to_lower_case "${PORTDIR}"

            if [[ ! -e "$file" ]]; then
                echo "Missing file: $file" > /dev/tty1
                sleep 5
                printf "\033c" >> /dev/tty1
                exit 1
            fi
        else
            echo "Missing file: $file" > /dev/tty1
            sleep 5
            printf "\033c" >> /dev/tty1
            exit 1
        fi
    fi
done

$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"

$GPTOKEYB "fallout-ce" -c "./fallout1.gptk.$ANALOGSTICKS" textinput &
if [[ $whichos == *"ArkOS"* ]]; then
    LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ./fallout-ce 2>&1 | tee -a ./log.txt
else
    ./fallout-ce 2>&1 | tee -a ./log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
