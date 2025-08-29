#!/bin/bash

################################
## Pre-setup global variables ##
################################

EXE_BASE_NAME=chromium-bsu
EXPECTED_CONF_FILE=$HOME/.$EXE_BASE_NAME

#############################
## PortMaster helper setup ##
#############################

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

#######################################
## Post-setup variables and settings ##
#######################################

DEVICE_ARCH=${DEVICE_ARCH:-aarch64}

GAMEDIR=/$directory/ports/chromium_bsu
EXE_NAME=$EXE_BASE_NAME.$DEVICE_ARCH

export CHROMIUM_BSU_DATA=$GAMEDIR/data
export CHROMIUM_BSU_SCORE=$GAMEDIR/chromium-bsu-score
export CHROMIUM_BSU_CONFIG=$GAMEDIR/chromium-bsu.conf

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

############################################
## Prepare game directory, logs, and libs ##
############################################

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/bin/$EXE_NAME"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Only write these values if they aren't set
# That way, they won't get overwritten if customized
if [[ -z $(grep screenWidth $CHROMIUM_BSU_CONFIG) ]]; then
    echo "screenWidth $DISPLAY_WIDTH" >> $CHROMIUM_BSU_CONFIG
fi
if [[ -z $(grep screenHeight $CHROMIUM_BSU_CONFIG) ]]; then
    echo "screenHeight $DISPLAY_HEIGHT" >> $CHROMIUM_BSU_CONFIG
fi

#####################################
## Start gptokeyb and run the game ##
#####################################

# Only need gptokeyb for stopping the port; SDL input is used in-game
$GPTOKEYB "$EXE_NAME" &
pm_platform_helper "$GAMEDIR/bin/$EXE_NAME"
bin/$EXE_NAME

######################
## Post-run cleanup ##
######################

pm_finish
