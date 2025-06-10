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
GAMEDIR="/$directory/ports/deltarune"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x $GAMEDIR/gmloadernext.aarch64

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"

export controlfolder
export DEVICE_ARCH

# Pretend we're on SteamDeck, some game code needs this
export SteamDeck=1

check_patch() {
    # Check for items in install folder (excluding base.port), data.win, or other subfolders
    install_items=$(find "$GAMEDIR/assets/install" -maxdepth 1 -mindepth 1 -not -name "base.port")
    has_data_win=$( [ -f "$GAMEDIR/assets/data.win" ] && echo true || echo false )
    has_other_subdir=$(find "$GAMEDIR/assets" -mindepth 1 -maxdepth 1 -type d ! -name "install" | head -n 1)

    # If patchlog.txt is missing, or we have installable items, data.win, or other subdirs
    if [ ! -f "$GAMEDIR/patchlog.txt" ] || [ -n "$install_items" ] || [ "$has_data_win" = true ] || [ -n "$has_other_subdir" ]; then
        if [ -f "$controlfolder/utils/patcher.txt" ]; then
            set -o pipefail
            
            # Setup mono environment variables
            DOTNETDIR="$HOME/mono"
            DOTNETFILE="$controlfolder/libs/dotnet-8.0.12.squashfs"
            $ESUDO mkdir -p "$DOTNETDIR"
            $ESUDO umount "$DOTNETFILE" || true
            $ESUDO mount "$DOTNETFILE" "$DOTNETDIR"
            export PATH="$DOTNETDIR":"$PATH"
            
            # Setup and execute the Portmaster Patcher utility with our patch file
            export PATCHER_FILE="$GAMEDIR/tools/patchscript"
            export PATCHER_GAME="$(basename "${0%.*}")"
            export PATCHER_TIME="a while"
            source "$controlfolder/utils/patcher.txt"
            $ESUDO umount "$DOTNETDIR"
        else
            pm_message "This port requires the latest version of PortMaster."
            pm_finish
            exit 1
        fi
    fi
}

# Check if we need to patch the game
check_patch

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" xbox360 &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Kill processes
pm_finish
