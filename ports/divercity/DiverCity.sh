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

GAMEDIR=/$directory/ports/divercity
java_runtime="zulu11.48.21-ca-jdk11.0.11-linux"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf"
$ESUDO mkdir -p "$CONFDIR" "$GAMEDIR/saves"

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  pm_message "Downloading the Westonpack runtime, this can take a few minutes..."
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# Mali drivers exporting their own wl_* symbols break Weston unless Wayland is preloaded first
weston_prefix=""
gles_lib=$($weston_dir/tools/findlib libGLESv2.so.2)
if [ -n "$gles_lib" ] && grep -q wl_global_create "$gles_lib"; then
  weston_prefix="env LD_PRELOAD=$weston_dir/lib_aarch64/libwayland-client.so.0:$weston_dir/lib_aarch64/libwayland-server.so.0:$weston_dir/lib_aarch64/graphics/crusty_gbm/libcrusty.so"
fi

export JAVA_HOME="/tmp/javaruntime"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  pm_message "Downloading the Java runtime, this can take a few minutes..."
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}"
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "${JAVA_HOME}"

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/divercity.ini"
fi

ui_scale=$(( ${DISPLAY_HEIGHT:-480} / 480 ))
[ "$ui_scale" -lt 1 ] && ui_scale=1

$GPTOKEYB2 "java" -c "$GAMEDIR/divercity.ini" &
pm_platform_helper "$JAVA_HOME/bin/java"

$ESUDO env strace="$weston_prefix" CRUSTY_BLOCK_INPUT=1 LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH" \
$weston_dir/westonwrap.sh drm gl kiosk system \
_JAVA_AWT_WM_NONREPARENTING=1 JAVA_HOME="$JAVA_HOME" \
"$JAVA_HOME/bin/java" \
  -Dsun.java2d.uiScale="$ui_scale" \
  -Djava.util.prefs.userRoot="$CONFDIR" \
  -Ddivercity.savedir="$GAMEDIR/saves" \
  -Ddivercity.scenariodir="$GAMEDIR/scenarios" \
  -jar "$GAMEDIR/divercity.jar"

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
