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
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/hyperlightdrifter"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x "$GAMEDIR/gmloadernext.armhf"
$ESUDO chmod +x "$GAMEDIR/tools/patchscript"
$ESUDO chmod +x "$GAMEDIR/tools/splash"
$ESUDO chmod +x "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="Hyper Light Drifter"
export PATCHER_TIME="13 to 15 minutes"

# dos2unix in case we need it
dos2unix "$GAMEDIR/tools/patchscript"
dos2unix "$GAMEDIR/tools/SDL_swap_gpbuttons.py"

# Check if RAM is greater than 1GB to assign correct patch
        if [ "$DEVICE_RAM" -gt 1 ]; then
            # Delete the 1GB patch if RAM is greater than 1GB
            rm -f "$GAMEDIR/tools/patch/hyperlightdrifter1gb.xdelta"
            pm_message "Device has more than 1gb ram"
      	    echo "Removed hyperlightdrifter1gb.xdelta"
        else
            # Rename the 1GB patch to the standard patch if RAM is less than or equal to 1GB
            mv -f "$GAMEDIR/tools/patch/hyperlightdrifter1gb.xdelta" "$GAMEDIR/tools/patch/hyperlightdrifter.xdelta"
            pm_message "Device has 1gb ram or less"
	    echo "Renamed hyperlightdrifter1gb.xdelta to hyperlightdrifter.xdelta"
        fi

# Check if patchlog.txt to skip patching
if [ ! -f patchlog.txt ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest version of PortMaster."
    fi
else
    pm_message "Patching process already completed. Skipping."
fi

# Delete the section here between the dash lines to allow the game to run on 1gb ram device with ArkOS
# -----------------------------------------------------------------------------------------------------------------------------
# Check for 1gb RAM and ArkOS to display and log warning message
if [ "$DEVICE_RAM" -le 1 ] && [ "$CFW_NAME" = "ArkOS" ]; then
    pm_message "This game will crash often on your device!"
    pm_message "If you wish to continue playing despite this warning..."
    pm_message "Delete the section of the script within Hyper Light Drifter.sh"
    echo "This game will crash often on your device!"
    echo "If you wish to continue playing despite this warning..."
    echo "Delete the section of the script within Hyper Light Drifter.sh"
    exit 1
fi
# -----------------------------------------------------------------------------------------------------------------------------

# Swap buttons
"$GAMEDIR/tools/SDL_swap_gpbuttons.py" -i "$SDL_GAMECONTROLLERCONFIG_FILE" -o "$GAMEDIR/gamecontrollerdb_swapped.txt" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | "$GAMEDIR/tools/SDL_swap_gpbuttons.py" -l "$GAMEDIR/SDL_swap_gpbuttons.txt"`"

# Display loading splash
if [ -f "$GAMEDIR/patchlog.txt" ]; then
    [ "$CFW_NAME" == "muOS" ] && $ESUDO ./tools/splash "splash.png" 1 
    $ESUDO ./tools/splash "splash.png" 2000 &
fi

$GPTOKEYB "gmloadernext.armhf" -c ./hyperlightdrifter.gptk &
pm_platform_helper "$GAMEDIR/gmloadernext.armhf"

#gmloadernext will use config.json
./gmloadernext.armhf -c "$GAMEDIR/gmloader.json"

pm_finish
