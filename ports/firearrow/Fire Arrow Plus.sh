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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# GAMEDIR needs to be exported or love will not 'see' the envar
export GAMEDIR="/$directory/ports/firearrow"

export DEVICE_ARCH="${DEVICE_ARCH:-armhf}"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Steam Fire Arrow
if [ -d "$GAMEDIR/FA1" ]; then
    mv "$GAMEDIR/FA1/data.win" "$GAMEDIR/firearrow/gamedata/data.win"
    mv "$GAMEDIR/FA1/"*.ogg "$GAMEDIR/firearrow/gamedata/."
    sleep 0.5
    rm -rf "$GAMEDIR/FA1"
fi

# Steam Fire Arrow X
if [ -d "$GAMEDIR/FAX" ]; then
    mv "$GAMEDIR/FAX/data.win" "$GAMEDIR/firearrowx/gamedata/data.win"
    mv "$GAMEDIR/FAX/"*.ogg "$GAMEDIR/firearrowx/gamedata/."
    sleep 0.5
    rm -rf "$GAMEDIR/FAX"
fi

# itch.io Fire Arrow (tested with Fire_Arrow_complete_2717.zip)
itch_io_fire_arrow=$(find $GAMEDIR -maxdepth 1 -iname "fire_arrow_complete*.zip" | head -n 1)
if [[ -n "$itch_io_fire_arrow" ]]; then
    $ESUDO unzip -X -o "$itch_io_fire_arrow" -d "$GAMEDIR/firearrow/gamedata/"
    sleep 0.5
    rm -f "$itch_io_fire_arrow"
fi

# itch.io Fire Arrow X (tested with FAX_complete_2717.zip)
itch_io_fire_arrow_x=$(find $GAMEDIR -maxdepth 1 -iname "FAX_complete*.zip" | head -n 1)
if [[ -n "$itch_io_fire_arrow_x" ]]; then
    $ESUDO unzip -X -o "$itch_io_fire_arrow_x" -d "$GAMEDIR/firearrowx/gamedata/"
    sleep 0.5
    rm -f "$itch_io_fire_arrow_x"
fi

if [ -f "$GAMEDIR/firearrow/gamedata/data.win" ]; then
    mv "$GAMEDIR/firearrow/gamedata/data.win" "$GAMEDIR/firearrow/gamedata/game.droid"
    sleep 0.5
    mkdir -p $GAMEDIR/firearrow/assets
    mv $GAMEDIR/firearrow/gamedata/*.ogg $GAMEDIR/firearrow/assets/ 
    mv $GAMEDIR/firearrow/gamedata/game.droid $GAMEDIR/firearrow/assets/ 
    sleep 0.5
    cd "$GAMEDIR/firearrow"
    zip -r -0 ./firearrow.port assets lib
    rm -rf "$GAMEDIR/firearrow/assets"
    rm -rf "$GAMEDIR/firearrow/gamedata"
    rm -rf "$GAMEDIR/firearrow/lib"
    cd "$GAMEDIR"
fi

if [ -f "$GAMEDIR/firearrowx/gamedata/data.win" ]; then
    mv "$GAMEDIR/firearrowx/gamedata/data.win" "$GAMEDIR/firearrowx/gamedata/game.droid"
    sleep 0.5
    mkdir -p $GAMEDIR/firearrowx/assets
    mv $GAMEDIR/firearrowx/gamedata/*.ogg $GAMEDIR/firearrowx/assets/ 
    mv $GAMEDIR/firearrowx/gamedata/game.droid $GAMEDIR/firearrowx/assets/ 
    sleep 0.5
    cd "$GAMEDIR/firearrowx"
    zip -r -0 ./firearrowx.port assets lib
    rm -rf "$GAMEDIR/firearrowx/assets"
    rm -rf "$GAMEDIR/firearrowx/gamedata"
    rm -rf "$GAMEDIR/firearrowx/lib"
    cd "$GAMEDIR"
fi

$GPTOKEYB "gameselector.armhf" -c "$GAMEDIR/gameselector.gptk" &
pm_message "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gameselector.armhf"
$ESUDO chmod +x "$GAMEDIR/firearrow.run"
$ESUDO chmod +x "$GAMEDIR/firearrowx.run"
$ESUDO chmod +x "$GAMEDIR/firearrow/gmloader"
$ESUDO chmod +x "$GAMEDIR/firearrowx/gmloader"

pm_platform_helper "$GAMEDIR/gameselector.armhf"
./gameselector.armhf

pm_finish
