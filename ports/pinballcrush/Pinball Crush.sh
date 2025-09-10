#!/bin/bash

# portmaster preamble
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

# adjust these to your paths and desired godot version
GAMEDIR=/$directory/ports/pinballcrush
godot_runtime="godot_4.3"
godot_executable="godot43.$DEVICE_ARCH"
pck_filename="PinballCrush.exe"
gptk_filename="pinballcrush.gptk"

# logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

# mount weston runtime
weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "this port requires the latest portmaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# mount godot runtime
godot_dir=/tmp/godot
$ESUDO mkdir -p "${godot_dir}"
if [ ! -f "$controlfolder/libs/${godot_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "this port requires the latest portmaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${godot_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${godot_dir}"
fi
$ESUDO mount "$controlfolder/libs/${godot_runtime}.squashfs" "${godot_dir}"

cd $GAMEDIR
$GPTOKEYB "$godot_executable" -c "$GAMEDIR/$gptk_filename" &

# extract .apk
if [ -f "assets/PinballCrushV2.apk" ]; then
  pm_message "found assets/PinballCrushV2.apk. extracting ..."
  mkdir -p "PinballCrush_unzipped"
  unzip -o "assets/PinballCrushV2.apk" -d "PinballCrush_unzipped" || exit 1
  pm_message "moving extracted assets ..."
  rm -rf "assets"
  mv -f "PinballCrush_unzipped/assets" "assets"
  pm_message "cleaning up ..."
  rm -rf "PinballCrush_unzipped"
  pm_message "done."
else
  echo "file not found: assets/PinballCrushV2.apk"
fi

# start westonpack and godot
# put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
# ld_preload is put here because godot runtime links against libegl.so, and crusty is interfering with that on some systems.
$ESUDO env CRUSTY_SHOW_CURSOR=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
LD_PRELOAD= XDG_DATA_HOME=$CONFDIR $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --path $GAMEDIR/assets

# clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}"
  $ESUDO umount "${godot_dir}"
fi
pm_finish

