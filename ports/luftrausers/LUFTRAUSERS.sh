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

# Set directories
GAMEDIR=/$directory/ports/luftrausers
DATADIR=$GAMEDIR/gamedata
BINARY="luftrausers"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check for patchlog and start first-time installation if needed.
if [ ! -f patchlog.txt ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    export PATCHER_FILE="$GAMEDIR/tools/patchscript"
    export PATCHER_TIME="2 to 5 minutes"
    export PATCHER_GAME="$(basename "${0%.*}")"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest version of PortMaster."
    exit 0
  fi
fi

# Create XDG dirs and set premissions
CONFDIR="$GAMEDIR/conf/config"
$ESUDO mkdir -p "${CONFDIR}"
LOCALDIR="$GAMEDIR/conf/local"
$ESUDO mkdir -p "${LOCALDIR}"
bind_directories ~/.LUFTRAUSERS "$CONFDIR"
$ESUDO chmod a+x "$DATADIR/x86-64/$BINARY"

# Mount Weston runtime
weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"


# rocknix mode on rocknix panfrost/freedreno; libmali not supported
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  export rocknix_mode=1
  if ! glxinfo | grep "OpenGL version string"; then
    pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
    sleep 5
    exit 1
  fi
fi

# the default pulseaudio backend doesn't always work well
if [[ "$CFW_NAME" = "ROCKNIX" ]] || [[ "$CFW_NAME" = "AmberELEC" ]]; then
  audio_backend=alsa
fi

# Start game 
pushd $DATADIR/x86-64/

$GPTOKEYB "$BINARY" -c "$GAMEDIR/$BINARY.gptk" &

# Start Westonpack
$ESUDO env \
CRUSTY_BLOCK_INPUT=1 \
SDL_AUDIODRIVER=$audio_backend \
BOX64_LD_LIBRARY_PATH="./":"$GAMEDIR/box64/box64-x86_64-linux-gnu" \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
XDG_CONFIG_HOME=$CONFDIR \
XDG_DATA_HOME=$LOCALDIR \
$GAMEDIR/box64/box64 ./$BINARY

popd

# Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi

pm_finish
