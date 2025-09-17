#!/bin/bash
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# PortMaster header
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

export controlfolder

# Source the controls and device info
source $controlfolder/control.txt

# Source custom mod files from the portmaster folder
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
# Pull the controller configs for native controls
get_controls

# Directory setup
GAMEDIR=/$directory/ports/hylics

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

export PATCHER_FILE="$GAMEDIR/tools/patchscript"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="around 2 seconds"
export PATH="$GAMEDIR/tools:$PATH"

# If the game is in the itch.io exe format, uncompress it
if [ -f "./Hylics_2024_1.exe" ]; then
  pm_message "Extracting Hylics_2024_1.exe ..."
  if ./tools/7za x "Hylics_2024_1.exe"; then
    pm_message "Extraction complete"
    rm -f "Hylics_2024_1.exe"
  else
    pm_message "Extraction failed"
  fi
fi

# Check if patchlog.txt exists to skip patching
if [ ! -f patchlog.txt ]; then
    source "$controlfolder/utils/patcher.txt"
fi

# Gptk and run port
$GPTOKEYB "mkxp-z.${DEVICE_ARCH}" -c "./hylics.gptk" &
pm_platform_helper "$GAMEDIR/mkxp-z.${DEVICE_ARCH}" >/dev/null
./mkxp-z.${DEVICE_ARCH}

# Cleanup
pm_finish
