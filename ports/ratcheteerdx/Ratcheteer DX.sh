#!/bin/bash
# PORTMASTER: ratcheteerdx.zip, Ratcheteer DX.sh

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

# Set directories
GAMEDIR=/$directory/ports/ratcheteerdx
DATADIR=$GAMEDIR/gamedata
BINARY="RatcheteerDX"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
#if using Demo vesrsion mv to standard filename 
if [ -f "$DATADIR/RatcheteerDX-Demo" ]; then
  mv  $DATADIR/RatcheteerDX-Demo $DATADIR/$BINARY
fi

# Create XDG dirs and set premissions
CONFDIR="$GAMEDIR/conf/config"
$ESUDO mkdir -p "${CONFDIR}"
LOCALDIR="$GAMEDIR/conf/local"
$ESUDO mkdir -p "${LOCALDIR}"
bind_directories ~/.ratcheteerdx "$CONFDIR"
$ESUDO chmod a+x "$DATADIR/$BINARY"


# the default pulseaudio backend doesn't always work well
if [[ "$CFW_NAME" = "ROCKNIX" ]] || [[ "$CFW_NAME" = "AmberELEC" ]]; then
  audio_backend=alsa
fi

# Start game 
pushd $DATADIR/x86-64/

$GPTOKEYB "$BINARY" &
$GAMEDIR/box64/box64 ./gamedata/$BINARY

pm_finish
