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

GAMEDIR="/$directory/ports/endacopia"
BINARY="ags.${DEVICE_ARCH}"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDIR/Endacopia.ags" ]; then
  pm_message "Copy Endacopia.ags, audio.vox and sp_speechsounds.vox from the Data folder of your Endacopia to $GAMEDIR"
  sleep 5
  exit 1
fi

CONTROLS="endacopia.ini"
if [ "${ANALOGSTICKS:-2}" -lt 1 ]; then
  CONTROLS="endacopia-0stick.ini"
elif [ "${ANALOGSTICKS:-2}" -lt 2 ]; then
  CONTROLS="endacopia-1stick.ini"
fi

$ESUDO chmod +x "$GAMEDIR/$BINARY"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export XDG_DATA_HOME="$GAMEDIR/saves"
mkdir -p "$XDG_DATA_HOME"

export OMNI_MODE=buffered
export OMNI_EVENT_MODE=auto
export OMNI_UP_KEY=W
export OMNI_DOWN_KEY=S
export OMNI_LEFT_KEY=A
export OMNI_RIGHT_KEY=D
export OMNI_CONFIRM_KEY=SPACE

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/$CONTROLS" &

pm_platform_helper "$GAMEDIR/$BINARY"

LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" ./"$BINARY" --log-stdout=main:info,sdl:info

pm_finish
