#!/bin/bash
# PORTMASTER: cataclysm-dda.zip, Cataclysm DDA.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/ports/freesynd/
cd $GAMEDIR

# Convert all filenames in the data directory to lowercase
to_lower_case() {
    for SRC in $(find "$1" -depth); do
    DST=$(dirname "${SRC}")/$(basename "${SRC}" | tr '[A-Z]' '[a-z]')
    if [ "${SRC}" != "${DST}" ]; then
        [ ! -e "${DST}" ] && $ESUDO mv -vT "${SRC}" "${DST}" || echo "- ${SRC} was not renamed"
    fi
    done
}

export LD_LIBRARY_PATH="$PWD/libs:$LD_LIBRARY_PATH"
export TEXTINPUTINTERACTIVE="Y"

$ESUDO rm -rf ~/.freesynd
ln -sfv $GAMEDIR/conf/.freesynd ~/

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "freesynd" -c "freesynd.gptk" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./freesynd -i ./ 2>&1 | tee $GAMEDIR/log.txt

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0