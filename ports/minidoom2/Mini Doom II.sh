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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/minidoom2"
TOOLDIR="$GAMEDIR/tools"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export PATH="$PATH:$GAMEDIR/tools"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Patcher config
export PATCHER_FILE="$GAMEDIR/tools/install_minidoom2"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="2 to 5 minutes"

# We log the execution of the script into log.txt
exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/gmloadernext"
$ESUDO chmod +x "$GAMEDIR/tools/swapabxy.py"

cd $GAMEDIR

# Functions BEGIN
swapabxy() {
    # Update SDL_GAMECONTROLLERCONFIG to swap a/b and x/y button

    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
      # Knulli seems to use SDL_GAMECONTROLLERCONFIG_FILE (on rg40xxh at least)
      SDL_swap_gpbuttons.py -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" $(<SDL_swap_gpbuttons.txt)
      export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
      # Other CFW use SDL_GAMECONTROLLERCONFIG
      export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | SDL_swap_gpbuttons.py $(<SDL_swap_gpbuttons.txt)`"
    fi
}
# Functions END

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster." > $CUR_TTY
    fi
else
    echo "Patching process already completed. Skipping."
fi

[ "$CFW_NAME" == "muOS" ] && splash "splash.png" 1 # workaround for muOS
splash "splash.png" 5000 & # 5 seconds

if [ -f "$GAMEDIR/SDL_swap_gpbuttons.txt" ]; then
    swapabxy
fi

#$GPTOKEYB "gmloader" -c ./minidoom2.gptk &
$GPTOKEYB "gmloadernext" &
pm_plateform_helper "$GAMEDIR/gmloadernext"

# gmloadernext will use config.json
./gmloadernext

pm_finish