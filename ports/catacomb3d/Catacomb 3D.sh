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

GAMEDIR="/$directory/ports/catacomb3d"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 777 -R $GAMEDIR/*

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [[ "${DEVICE_NAME^^}" == 'X55' ]] || [[ "${DEVICE_NAME^^}" == 'RG353P' ]] || [[ "${DEVICE_NAME^^}" == *'RG40XX'* ]]; then
      if [ ! -f $GAMEDIR/conf/reflectionhle/reflection-cat3d.cfg ]; then
        cp -f $GAMEDIR/conf/reflectionhle/reflection-cat3d-triggers.cfg $GAMEDIR/conf/reflectionhle/reflection-cat3d.cfg
      fi
elif [[ "${ANALOG_STICKS}" -lt 2 ]]; then
      if [ ! -f $GAMEDIR/conf/reflectionhle/reflection-cat3d.cfg ]; then
        cp -f $GAMEDIR/conf/reflectionhle/reflection-cat3d-nosticks.cfg $GAMEDIR/conf/reflectionhle/reflection-cat3d.cfg
      fi
else
      if [ ! -f $GAMEDIR/conf/reflectionhle/reflection-cat3d.cfg ]; then
        cp -f $GAMEDIR/conf/reflectionhle/reflection-cat3d-default.cfg $GAMEDIR/conf/reflectionhle/reflection-cat3d.cfg
      fi
fi

bind_directories  ~/.config/reflectionhle $GAMEDIR/conf/reflectionhle

$GPTOKEYB "reflectionhle.${DEVICE_ARCH}" -c "$GAMEDIR/reflectionhle.gptk" &
pm_platform_helper "$GAMEDIR/reflectionhle.${DEVICE_ARCH}"
./reflectionhle.${DEVICE_ARCH}

pm_finish
