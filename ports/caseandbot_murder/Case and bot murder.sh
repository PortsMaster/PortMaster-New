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

# Variables
GAMEDIR="/$directory/ports/caseandbot_murder"
GMLOADER_JSON="$GAMEDIR/gmloader.json"
VERSION_FILE="$GAMEDIR/version.txt"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if version.txt exists and is not empty
if [ -s "$VERSION_FILE" ]; then
  EXECUTABLE=$(cat "$VERSION_FILE")
else
  # version.txt missing or empty — detect executable version
  if [ -f "assets/Case&Bot.exe" ]; then
    # steam version
    EXECUTABLE="gmloadernext.armhf"
  elif [ -f "assets/CaseAndBot.exe" ]; then
    # itch.io version
    EXECUTABLE="gmloadernext.aarch64"
  else
    echo "Error: Could not detect version of case and bot."
    exit 1
  fi

  # Write detected executable name to version.txt
  echo "$EXECUTABLE" > "$VERSION_FILE"
fi

# Detect or load game version
if [ "$(cat "$VERSION_FILE")" = "gmloadernext.armhf" ]; then
  export PORT_32BIT="Y"
  export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib32:$GAMEDIR/lib:$LD_LIBRARY_PATH"
elif [ "$(cat "$VERSION_FILE")" = "gmloadernext.aarch64" ]; then
  export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib64:$GAMEDIR/lib:$LD_LIBRARY_PATH"
fi


$ESUDO chmod +x "$GAMEDIR/$EXECUTABLE"


# Prepare game files (only on first run)
if [ -f ./assets/data.win ]; then
  mv assets/data.win assets/game.droid
  mv assets/assets/* assets
  rm -f assets/*.{dll,exe,txt,pdf}
  zip -r -0 ./game.port ./assets/
  rm -Rf ./assets/
fi

$GPTOKEYB "$EXECUTABLE" &
pm_platform_helper "$GAMEDIR/$EXECUTABLE"
./"$EXECUTABLE" -c "$GMLOADER_JSON"

pm_finish
