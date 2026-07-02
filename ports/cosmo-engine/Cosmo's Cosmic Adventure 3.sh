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

GAMEDIR="/$directory/ports/cosmo-engine"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export PORTMASTER_HOME="$GAMEDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
  ADDLPARAMS=" -fs"
fi

$ESUDO cp "$GAMEDIR/cosmo_engine.${DEVICE_ARCH}" "$GAMEDIR/cosmo_engine"

$ESUDO chmod +x "$GAMEDIR/cosmo_engine"
$ESUDO chmod +x "$GAMEDIR/text_viewer.${DEVICE_ARCH}"

if [ ! -f "$GAMEDIR/data/cosmo3.vol" ] && [ ! -f "$GAMEDIR/data/COSMO3.VOL" ]; then
    ./text_viewer.${DEVICE_ARCH} -f 18 -w -t "Instructions" --input_file "$GAMEDIR/ep3inst.txt"
fi

$GPTOKEYB "cosmo_engine" -c "$GAMEDIR/cosmo_engine.gptk" &
pm_platform_helper "$GAMEDIR/cosmo_engine"
./cosmo_engine -datadir data -savedir data -gamedir data -ep3 $ADDLPARAMS

pm_finish
