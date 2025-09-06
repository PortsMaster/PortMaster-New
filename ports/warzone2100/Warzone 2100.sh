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

GAMEDIR=/$directory/ports/warzone2100
CONFDIR=$GAMEDIR/conf
RUNDIR=$GAMEDIR/game/bin
BINARY="warzone2100"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "Device architecture is $DEVICE_ARCH"
echo "Glibc version is $CFW_GLIBC"
echo "Screen resolution $DISPLAY_WIDTH x $DISPLAY_HEIGHT"

# Check if display meets the minimum resolution requirements
if [ $DISPLAY_WIDTH -lt 640 ] || [ $DISPLAY_HEIGHT -lt 480 ]; then
  pm_message "This game requires a minimum resolution of 640x480, exiting"
  sleep 5
  exit 1
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

mkdir -p $CONFDIR
bind_directories ~/.local/share/warzone2100-master "$CONFDIR"

cd "$RUNDIR"

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/warzone2100.ini" >/dev/null &

pm_platform_helper "$BINARY" >/dev/null

if [ "$CFW_NAME" != "ROCKNIX" ]; then
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

  GAMELIBS="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/libs_extra.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

  # Start Westonpack
  $ESUDO env CRUSTY_SHOW_CURSOR=1 WRAPPED_LIBRARY_PATH=$GAMELIBS \
  $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
  ./$BINARY

  # Clean up after ourselves
  $ESUDO $weston_dir/westonwrap.sh cleanup
  if [[ "$PM_CAN_MOUNT" != "N" ]]; then
      $ESUDO umount "${weston_dir}"
  fi
else
  export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
  ./$BINARY
fi

pm_finish
