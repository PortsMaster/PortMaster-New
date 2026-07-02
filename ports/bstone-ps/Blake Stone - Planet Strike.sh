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

GAMEDIR="/$directory/ports/bstone-ps"

if [[ "${CFW_NAME^^}" == *"ARKOS"* ]] || [[ "${CFW_NAME^^}" == "AMBERELEC" ]] || [[ "${CFW_NAME^^}" == "ROCKNIX" ]]; then
    sed -i 's/^\(vid_renderer\s*\)"[^"]*"/\1"gles_2_0"/' "$GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt"
elif [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    sed -i 's/^\(vid_renderer\s*\)"[^"]*"/\1"gl_2_0"/' "$GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt"
else
    sed -i 's/^\(vid_renderer\s*\)"[^"]*"/\1"software"/' "$GAMEDIR/conf/bibendovsky/bstone/bstone_config.txt"
fi

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

[ -d ~/.local/share/bibendovsky ] && $ESUDO rm -rf ~/.local/share/bibendovsky

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/bstone.${DEVICE_ARCH}"

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/bstonetriggers.gptk"
else
    GPTOKEYB_CONFIG="$GAMEDIR/bstone$ANALOG_STICKS.gptk"
fi

$GPTOKEYB "bstone.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/bstone.${DEVICE_ARCH}"
./bstone.${DEVICE_ARCH} --vid_windowed_width $DISPLAY_WIDTH --vid_windowed_height $DISPLAY_HEIGHT --profile_dir $GAMEDIR/conf/bibendovsky/bstone --data_dir $GAMEDIR/gamedata/planet_strike

pm_finish
