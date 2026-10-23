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

GAMEDIR="/$directory/ports/dijeweled"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64"

if [ -f "$GAMEDIR/dijeweled.apk.part00" ]; then
  pm_message "Preparing game data, this can take a minute..." --title "Please wait"
  if ! cat "$GAMEDIR"/dijeweled.apk.part* > "$GAMEDIR/dijeweled.apk"; then
    $ESUDO rm -f "$GAMEDIR/dijeweled.apk"
    pm_show_error "Could not prepare the game data. Check that there is enough free space, then launch again." --title "Preparation failed"
    exit 1
  fi
  $ESUDO rm -f "$GAMEDIR"/dijeweled.apk.part*
elif [ ! -f "$GAMEDIR/dijeweled.apk" ]; then
  pm_show_error "Game data is missing. Reinstall the port." --title "Game data missing"
  exit 1
fi

mkdir -p "$GAMEDIR/gamedata"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/dijeweled.ini"
fi

$GPTOKEYB2 "gmloadernext" -c "$GAMEDIR/dijeweled.ini" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
./gmloadernext.aarch64 -c gmloader.json

pm_finish
