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

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/spookynakki"
TOOLDIR="$GAMEDIR/tools"

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATH="$TOOLDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Functions BEGIN
swapabxy() {
    # Update SDL_GAMECONTROLLERCONFIG to swap a/b and x/y button

    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
      # Knulli seems to use SDL_GAMECONTROLLERCONFIG_FILE (on rg40xxh at least)
        cat "$SDL_GAMECONTROLLERCONFIG_FILE" | swapabxy.py > "$GAMEDIR/gamecontrollerdb_swapped.txt"
      export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
        # Other CFW use SDL_GAMECONTROLLERCONFIG
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | swapabxy.py`"
    fi
}
# Functions END

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

# Make sure execution flags are set
$ESUDO chmod 777 "$TOOLDIR/swapabxy.py"
$ESUDO chmod 777 "$GAMEDIR/gmloadernext.aarch64"

# Swap a/b and x/y button if needed
if [ -f "$GAMEDIR/swapabxy.txt" ]; then
    swapabxy
fi

# Splash loading screen
[ "$CFW_NAME" == "muOS" ] && splash "splash.png" 1 # workaround for muOS
splash "splash.png" 10000 &

$GPTOKEYB "gmloadernext.aarch64" &
pm_platform_helper "gmloadernext.aarch64" > /dev/null
./gmloadernext.aarch64 -c "gmloader.json"

pm_finish