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

GAMEDIR=/$directory/ports/koreader/
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


ZIPFILE="koreader.zip"
TARGET_DIR="./koreader"

if [ -f "$ZIPFILE" ]; then
    echo "Unzipping $ZIPFILE to $TARGET_DIR..."
    unzip "$ZIPFILE" -d "$TARGET_DIR"
elif [ -f "$GAMEDIR/koreader/luajit" ]; then
    echo "ZIP IS ALREADY EXTRACTED"
else
    echo "File $ZIPFILE does not exist 😢"
fi


export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

$GPTOKEYB "$GAMEDIR/koreader/luajit" -c "./koreader.gptk" -k "luajit" &
pm_platform_helper "$GAMEDIR/bin/koreader"

cd koreader
LD_PRELOAD=$GAMEDIR/libcrusty.so CRUSTY_BLOCK_INPUT=1 ./luajit reader.lua ../books

pm_finish
