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

GAMEDIR=/$directory/ports/diceydungeons
DATADIR=$GAMEDIR/gamedata
BINARY="diceydungeons"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f $DATADIR/$BINARY ]; then
  # Extract gog installer if necessary and possible
  export PATCHER_FILE="$GAMEDIR/tools/patchscript"
  export PATCHER_TIME="2 minutes"
    
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod a+x "$GAMEDIR/tools/patchscript"
    source "$controlfolder/utils/patcher.txt"
    $ESUDO kill -9 $(pidof gptokeyb)
  else
    echo "This port requires the latest version of PortMaster." > $CUR_TTY
  fi
fi

# Clean up data dir
rm -r $DATADIR/*.sh

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

# Calculate deadzone_scale based on DISPLAY_WIDTH
value=$((4*DISPLAY_WIDTH/480))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/${BINARY}.ini

# rocknix mode on rocknix panfrost; libmali not supported
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  export rocknix_mode=1
fi

$GPTOKEYB2 "$BINARY" -x &

cd $DATADIR

# Start Westonpack
$ESUDO env \
BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/box64-x86_64-linux-gnu" \
LIBGL_SHRINK=4 \
LIBGL_FORCE16BITS=1 \
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
