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
PORTEXEC="renpy/startRENPY"
GAMEDIR="/$directory/ports/milkinside"

cd $GAMEDIR

runtime="renpy_8.3.4"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi



renpydir="$GAMEDIR/renpy/"
gamefiles="$GAMEDIR/game/"
renpy_runtime="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$renpydir"

$ESUDO umount "$gamefiles" || true
$ESUDO umount "$renpy_runtime" || true
$ESUDO mount "$renpy_runtime" "$renpydir"
sleep 2
$ESUDO mount --bind "$gamefiles" "$renpydir/game"

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PYTHONHOME=$GAMEDIR/renpy/lib/py3-linux-aarch64/../../
export PYTHONPATH=$GAMEDIR/renpy/lib/python3.9
export RENPY_DISABLE_JOYSTICK=1
export RENPY_LESS_MEMORY=1

if [ -d $GAMEDIR/gamefiles ]; then
    echo "Game Files found"
    $GAMEDIR/renpy/lib/py3-linux-aarch64/python ./rpatool -x $GAMEDIR/gamefiles/archive.rpa -o $GAMEDIR/gamefiles
	 cp $GAMEDIR/gamefiles/images/* $GAMEDIR/gamefiles
	 mv $GAMEDIR/gamefiles $GAMEDIR/game
    cp $GAMEDIR/patches/* $GAMEDIR/game/
    #rm $GAMEDIR/gamefiles/archive.rpa
    echo "Patching done"
elif [ -d $GAMEDIR/game ]; then
    echo "Patching already done"
fi


# If using gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

pm_platform_helper "$GAMEDIR/renpy/lib/py3-linux-aarch64/startRENPY"
$GPTOKEYB "startRENPY" -c "milkinside.gptk"  &
bash "./$PORTEXEC"

pm_finish