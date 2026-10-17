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

GAMEDIR="/$directory/ports/lostflame"
CONFDIR="$GAMEDIR/conf"
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"
export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$GAMEDIR/LostFlame.jar" ]; then
  pm_message "LostFlame.jar not found. Copy it from your Steam install into ports/lostflame."
  sleep 5
  exit 1
fi

# Patch the jar
if [ ! -f "$GAMEDIR/gamepatch.jar" ] && [ ! -d "$GAMEDIR/gamepatch" ]; then
  $ESUDO chmod +x "$GAMEDIR/patch/patchscript"
  export PATCH_GAMEDIR="$GAMEDIR"
  export PATCHER_FILE="$GAMEDIR/patch/patchscript"
  export PATCHER_GAME="Lost Flame"
  export PATCHER_TIME="under a minute"
  export controlfolder DEVICE_ARCH
  if [ ! -f "$controlfolder/utils/patcher.txt" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  source "$controlfolder/utils/patcher.txt"
  if [ ! -f "$GAMEDIR/gamepatch.jar" ] && [ ! -d "$GAMEDIR/gamepatch" ]; then
    pm_message "Patching failed. See patchlog.txt in ports/lostflame."
    sleep 5
    exit 1
  fi
else
  echo "patch: already there, patcher skipped"
fi

$ESUDO mkdir -p "$CONFDIR"

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

# Mount Java runtime
export JAVA_HOME="/tmp/javaruntime/"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}"
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "${JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"

# Check runtime
if [ ! -x "$JAVA_HOME/bin/java" ] || [ ! -f "$weston_dir/westonwrap.sh" ]; then
  echo "runtimes: java=$JAVA_HOME/bin/java weston=$weston_dir/westonwrap.sh"
  pm_message "Runtimes are missing. Update PortMaster with the device online, then launch again."
  sleep 5
  exit 1
fi

GAME_W=${DISPLAY_WIDTH:-640}
GAME_H=${DISPLAY_HEIGHT:-480}
GAME_ZOOM=${GAME_ZOOM:-0.9}
# A kill mid-write truncates settings, and the game boots black on a truncated file.
if [ -f "$CONFDIR/settings" ] && [ "$(wc -c < "$CONFDIR/settings")" -lt 44 ]; then
  echo "settings: truncated ($(wc -c < "$CONFDIR/settings") bytes), reseeding"
  rm -f "$CONFDIR/settings"
fi
if [ ! -f "$CONFDIR/settings" ]; then
  $ESUDO "$JAVA_HOME/bin/java" -cp "$GAMEDIR/tools" MakeSettings "$CONFDIR/settings" $GAME_W $GAME_H $GAME_ZOOM
fi

# Saves, settings and logs are written to the working directory
cd "$CONFDIR"

pm_platform_helper "java"

# Jamepad natives with the jar's JNI surface and a newer SDL; on the classpath ahead
# of the jar, whose own freeze on trigger axis events.
JAMEPAD_JAR="$GAMEDIR/jamepad-natives-2.30.0.0.jar"
PAD_ENV="SDL_GAMECONTROLLERCONFIG_FILE=$SDL_GAMECONTROLLERCONFIG_FILE"
PAD_LOG_ENV=""

# Asks the game's own pad stack whether it sees a pad; returns 0 if it does.
probe_pads() {
  PROBE_OUT=$(env "$PAD_ENV" "$JAVA_HOME/bin/java" -cp "$GAMEDIR/tools:$JAMEPAD_JAR:$GAMEDIR/LostFlame.jar" ProbePads 2>&1)
  echo "$PROBE_OUT"
  case "$PROBE_OUT" in *pads=[1-9]*) return 0 ;; esac
  return 1
}

# jamepad's udev-less SDL takes an event device only with ABS_X/ABS_Y, which a
# stickless pad lacks, so gptokeyb mirrors the hardware into one that has them.
PAD_IGNORE=""
echo "=== pad probe ==="
if ! probe_pads && [ -n "$GPTOKEYB" ]; then
  # IDs of gptokeyb's xbox360 mirror: Microsoft's wired Xbox 360 controller.
  MIRROR_VID=0x045e
  MIRROR_PID=0x028e
  # gptokeyb2 must skip the mirror, or every press arrives twice.
  PAD_IGNORE="SDL_GAMECONTROLLER_IGNORE_DEVICES=$MIRROR_VID/$MIRROR_PID"
  env "$PAD_ENV" $GPTOKEYB "java" xbox360 > "$GAMEDIR/gptokeyb-x360.log" 2>&1 &
  sleep 1
  echo "=== pad probe, mirrored ==="
  probe_pads
fi

# The game reads its L2/R2 as the F7/F8 keys.
env $PAD_IGNORE "$PAD_ENV" $GPTOKEYB2 "java" -c "$GAMEDIR/lostflame.gptk" > "$GAMEDIR/gptokeyb2.log" 2>&1 &

# GL4ES churns the native heap: large blocks go to mmap, so frees return memory.
# The pad mapping goes before westonwrap, which joins and evals its own arguments.
$ESUDO env MALLOC_ARENA_MAX=2 MALLOC_MMAP_THRESHOLD_=65536 MALLOC_TRIM_THRESHOLD_=131072 \
"$PAD_ENV" \
WESTON_HEADLESS_WIDTH=$GAME_W WESTON_HEADLESS_HEIGHT=$GAME_H \
LOSTFLAME_W=$GAME_W LOSTFLAME_H=$GAME_H \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
PATH="$PATH" JAVA_HOME="$JAVA_HOME" HOME="$CONFDIR" WAYLAND_DISPLAY= \
$PAD_LOG_ENV \
java -Xmx144M -Xss512k -XX:MaxDirectMemorySize=60M -XX:+UseSerialGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -cp "$GAMEDIR/steamstub.jar:$GAMEDIR/gamepatch.jar:$GAMEDIR/gamepatch:$JAMEPAD_JAR:$GAMEDIR/LostFlame.jar" com.lostflame.DesktopLauncher

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
