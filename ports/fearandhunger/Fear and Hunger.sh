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

# Fear & Hunger con quixjs (tools/portmaster.py lo genera desde portmaster/portmaster.sh)

GAMEDIR=/$directory/ports/fearandhunger
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "Fear & Hunger port 1.0.2, quixjs $(cat VERSION 2>/dev/null): quixjs.${DEVICE_ARCH} ($CFW_NAME)"
# el dispositivo y el CFW en el log (lo de PortMaster: modelo, pantalla, RAM...)
$controlfolder/device_info.txt 2> /dev/null
$ESUDO chmod +x "$GAMEDIR/quixjs.${DEVICE_ARCH}"

# la fuente del launcher y las librerias que no todos los CFW traen
export QUIXJS_FONT="$GAMEDIR/fonts/DejaVuSans-Bold.ttf"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# sin la rom del juego (su .zip, junto a port.toml), un aviso en pantalla
if [ ! -f "$GAMEDIR/www.zip" ]; then
  pm_message "Copy www.zip of your copy of Fear & Hunger into ports/fearandhunger/ (see README.md)"
  sleep 8
  pm_finish
  exit 1
fi

# quixjs lee el mando con SDL; gptokeyb sin -c solo da hotkey+Start para cerrar
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HOTKEY="${HOTKEY:-guide}"
if [ -n "$GPTOKEYB2" ]; then
  $GPTOKEYB2 "quixjs.${DEVICE_ARCH}" &
else
  $GPTOKEYB "quixjs.${DEVICE_ARCH}" &
fi

pm_platform_helper "$GAMEDIR/quixjs.${DEVICE_ARCH}"
./quixjs.${DEVICE_ARCH} --launcher -c port.toml

pm_finish
