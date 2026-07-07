#!/bin/bash
# PORTMASTER: lisathetimeless.zip, LISA The Timeless.sh

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
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/lisathetimeless
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$GAMEDATA"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

[ -d gamedata/lib ] && rm -rf data/ meta/ scripts/ gamedata/lib gamedata/lib64
[ -f falcon_mkxp.bin ] && mv falcon_mkxp.bin gamedata/falcon_mkxp.bin
cp conf/mkxp.conf gamedata/

# Apply the Main-script FrozenError fix (self==nil in falcon-mkxp's rgss_main)
# Pure-stdlib Python, safe to re-run every launch - it no-ops once patched.
if [ -f "$GAMEDIR/fix_lisa_timeless.py" ] && [ -f "$GAMEDIR/gamedata/Game.rgss3a" ]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 "$GAMEDIR/fix_lisa_timeless.py" "$GAMEDIR/gamedata/Game.rgss3a"
  else
    echo "python3 not found - skipping Main script patch, game may crash with FrozenError"
  fi
fi

$GPTOKEYB "falcon_mkxp.bin" -c "./lisathetimeless.gptk" &
$GAMEDIR/gamedata/falcon_mkxp.bin

$ESUDO kill -9 $(pidof gptokeyb)
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
