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

GAMEDIR=/$directory/ports/yknytt

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# By default FRT sets Select as a Force Quit Hotkey, with this we disable that.
export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS 

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"


cp -u $monodir/lib/libmono-btls-shared.so $monodir/lib/libmono-native.so $monodir/lib/libMonoPosixHelper.so \
$monodir/lib/libmono-profiler-aot.so $monodir/lib/libmono-profiler-coverage.so $monodir/lib/libmono-profiler-log.so \
$monodir/lib/libMonoSupportW.so data_YKnytt/Mono/lib

export LD_LIBRARY_PATH="${monodir}/lib":$LD_LIBRARY_PATH

$GPTOKEYB YKnytt.arm64 -c "yknytt.gptk" &

pm_platform_helper "$GAMEDIR/YKnytt.arm64"
./YKnytt.arm64 --data $GAMEDIR --gptokeyb

pm_finish