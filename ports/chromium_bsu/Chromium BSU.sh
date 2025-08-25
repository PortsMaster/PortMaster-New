#!/bin/bash
# PORTMASTER:chromium_bsu.zip, Chromium BSU.sh

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

GAMEDIR=/$directory/ports/chromium_bsu
EXE_NAME=$EXE_BASE_NAME.$DEVICE_ARCH
SAVED_CONF_FILE=$GAMEDIR/$EXE_BASE_NAME.conf
export CHROMIUM_BSU_DATA=$GAMEDIR/data
export CHROMIUM_BSU_SCORE=$GAMEDIR/chromium-bsu-score

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

A_BUTTON_INDEX="$(echo $SDL_GAMECONTROLLERCONFIG | awk -F',a:b' '{print $2}' | awk -F, '{print $1}')"
Y_BUTTON_INDEX="$(echo $SDL_GAMECONTROLLERCONFIG | awk -F',y:b' '{print $2}' | awk -F, '{print $1}')"

FIRE_BUTTON_SETTING="$(cat $SAVED_CONF_FILE | grep -e fireButton)"
USE_ITEM_BUTTON_SETTING="$(cat $SAVED_CONF_FILE | grep -e useItemButton)"

if [[ "$FIRE_BUTTON_SETTING" == "" ]] && [[ "$A_BUTTON_INDEX" =~ ^[0-9]+$ ]]; then
  echo "fireButton $A_BUTTON_INDEX" >> $SAVED_CONF_FILE
fi

if [[ "$USE_ITEM_BUTTON_SETTING" == "" ]] && [[ "$Y_BUTTON_INDEX" =~ ^[0-9]+$ ]]; then
  echo "useItemButton $Y_BUTTON_INDEX" >> $SAVED_CONF_FILE
fi

####################################################
## Prepare game directory, logs, libs, and config ##
####################################################

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/bin/$EXE_NAME"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Copy the config from the port directory to the user's home directory
cp $SAVED_CONF_FILE $EXPECTED_CONF_FILE

#####################################
## Start gptokeyb and run the game ##
#####################################

$GPTOKEYB "$EXE_NAME" -c "$GAMEDIR/$EXE_BASE_NAME.gptk" &
pm_platform_helper "$GAMEDIR/bin/$EXE_NAME"
bin/$EXE_NAME

######################
## Post-run cleanup ##
######################

# Copy the config back to the port folder so any changes get picked up
cp $EXPECTED_CONF_FILE $SAVED_CONF_FILE

pm_finish
