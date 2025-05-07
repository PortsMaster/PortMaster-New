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

GAMEDIR=/$directory/ports/papersplease
DATADIR=$GAMEDIR/gamedata
BINARY="PapersPlease"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Tidy up gamedata
find "$DATADIR" -name "*.sh" | xargs rm
$ESUDO chmod a+x "$DATADIR/PapersPlease"

# Create XDG dirs
CONFDIR="$GAMEDIR/conf/config"
$ESUDO mkdir -p "${CONFDIR}"
LOCALDIR="$GAMEDIR/conf/local"
$ESUDO mkdir -p "${LOCALDIR}"

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

# Calculate deadzone_scale based on DISPLAY_HEIGHT
value=$((4*DISPLAY_HEIGHT/360))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/${BINARY}.gptk

# rocknix mode on rocknix panfrost/freedreno; libmali not supported
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  export rocknix_mode=1
fi

# the default pulseaudio backend doesn't always work well
if [[ "$CFW_NAME" = "ROCKNIX" ]] || [[ "$CFW_NAME" = "AmberELEC" ]]; then
  audio_backend=alsa
fi

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/$BINARY.gptk" &

cd $DATADIR

# Start Westonpack
$ESUDO env \
SDL_AUDIODRIVER=$audio_backend \
BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/box64-x86_64-linux-gnu" \
BOX64_LD_PRELOAD="$GAMEDIR/steamstub/libsteam_api.so" \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
XDG_CONFIG_HOME=$CONFDIR \
XDG_DATA_HOME=$LOCALDIR \
$GAMEDIR/box64/box64 ./$BINARY

# Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi

pm_finish
