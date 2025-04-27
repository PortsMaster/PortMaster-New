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

GAMEDIR=/$directory/ports/canabalt-hf
DATADIR=$GAMEDIR/gamedata
BINARY="canabalt"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create XDG dirs
CONFDIR="$GAMEDIR/conf/config"
$ESUDO mkdir -p "${CONFDIR}"
LOCALDIR="$GAMEDIR/conf/local"
$ESUDO mkdir -p "${LOCALDIR}"

cd $DATADIR

# Get assets if necessary and possible (they are under an non-redistributable license)
if [ ! -d assets ]; then
  zipfile=`find . -name "*.zip"`
  if [ -z $zipfile ]; then
    wget https://github.com/ninjamuffin99/canabalt-assets/archive/refs/heads/main.zip
    zipfile="main.zip"
  fi
  unzip ${zipfile}
  rm ${zipfile}
  mv canabalt-assets-main assets
  mv assets/sounds/ogg/* assets/sounds/
  rm -r assets/sounds/mp3
  mv assets/music/ogg/* assets/music/
  rm -r assets/music/mp3
fi

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

# rocknix mode on rocknix panfrost; libmali not supported
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  export rocknix_mode=1
fi

if [ ${DISPLAY_WIDTH} -lt 1920 ]; then
  cp ./canabalt-lores ./canabalt
else
  cp ./canabalt-hires ./canabalt
fi

$GPTOKEYB "$BINARY" -c "$GAMEDIR/$BINARY.gptk" &

# Start Westonpack
$ESUDO env \
SDL_AUDIODRIVER=alsa \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
XDG_CONFIG_HOME=$CONFDIR \
XDG_DATA_HOME=$LOCALDIR \
./$BINARY

# Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi

pm_finish
