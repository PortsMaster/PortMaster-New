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

GAMEDIR="/$directory/ports/kenslabyrinth"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ $ANALOG_STICKS == '1' ]; then
    GPTOKEYB_CONFIG="$GAMEDIR/ken1joy.gptk"
elif [[ "${DEVICE_NAME^^}" == 'X55' ]] || [[ "${DEVICE_NAME^^}" == 'RG353P' ]] || [[ "${DEVICE_NAME^^}" == 'RG40XX' ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/kentriggers.gptk"
else
    GPTOKEYB_CONFIG="$GAMEDIR/ken.gptk"
fi

$ESUDO cp -f -v $GAMEDIR/template.ini $GAMEDIR/settings.ini

$ESUDO chmod 777 -R $GAMEDIR/*

if [[ $DISPLAY_WIDTH != '640' ]]; then
    sed -i 's/1 6400480 1 1 1 1/1 $DISPLAY_WIDTH0$DISPLAY_HEIGHT 1 1 1 1/' $GAMEDIR/settings.ini
fi

cd $GAMEDIR

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$GPTOKEYB "ken.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
./ken.${DEVICE_ARCH}

pm_finish
