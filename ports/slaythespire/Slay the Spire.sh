#!/bin/bash

# PortMaster preamble
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
get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
# Adjust these to your paths and desired java version
GAMEDIR=/$directory/ports/slaythespire
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"
jar_filename="desktoppatched.jar"
gptk_filename="slay.gptk"

# Logging (early, so display-fix diagnostics appear in log)
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1


_phys_w=${DISPLAY_WIDTH:-1280}
_phys_h=${DISPLAY_HEIGHT:-720}
_game_w=$_phys_w
_game_h=$_phys_h
echo "[DisplayFix] Physical: ${_phys_w}x${_phys_h} -> Game: ${_game_w}x${_game_h}"


# Rewrite info.displayconfig so crusty reports the 16:9-fitted resolution
# via its fake XRandR — this aligns the controller cursor with button positions.
# Use tee via $ESUDO so it works even if the file is root-owned.
printf '%d\n%d\n24\nfalse\ntrue\nfalse\n' $_game_w $_game_h \
    | $ESUDO tee "$GAMEDIR/info.displayconfig" > /dev/null \
    && echo "[DisplayFix] info.displayconfig written OK" \
    || echo "[DisplayFix] WARNING: failed to write info.displayconfig"

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"


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

check_patch() {
	if [ -f "$GAMEDIR/desktop-1.0.jar" ]; then
		if [ -f "$controlfolder/utils/patcher.txt" ]; then
			set -o pipefail
            export controlfolder
			# Setup and execute the Portmaster Patcher utility with our patch file
			export PATCHER_FILE="$GAMEDIR/tools/patch.txt"
			export PATCHER_GAME="$(basename "${0%.*}")"
			export PATCHER_TIME="10 minutes"
			source "$controlfolder/utils/patcher.txt"
		else
			pm_message "This port requires the latest version of PortMaster."
			pm_finish
			exit 1
		fi
	fi
}

cd $GAMEDIR
check_patch
$GPTOKEYB "java" -c "slay.gptk" &

pm_platform_helper "java"
$ESUDO env LIBGL_ES=3 LIBGL_MIPMAP=3 LIBGL_FORCE16BITS=1 TEXCOMPRESS_FORCE=astc CRUSTY_BLOCK_INPUT=1 WRAPPED_PRELOAD=./libwrap.so WRAPPED_LIBRARY_PATH=./ \
WESTON_HEADLESS_WIDTH=$_game_w WESTON_HEADLESS_HEIGHT=$_game_h \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
PATH="$PATH" JAVA_HOME="$JAVA_HOME" XDG_DATA_HOME="$GAMEDIR" WAYLAND_DISPLAY= \
java -javaagent:./controller-injector.jar -Dsts.width=$_game_w -Dsts.height=$_game_h -Dfont.multiplier=1.6 -Xms128M -Xmx140M -Xss512k -XX:MaxDirectMemorySize=60M -Dorg.lwjgl.opengl.Window.undecorated=true -XX:+UnlockExperimentalVMOptions -XX:+UseSerialGC  -javaagent:$(pwd)/texcompress-agent.jar=native=$(pwd)/libtexcompress.so -Dtexcompress.scale=1 -Dtexcompress.cache=/$GAMEDIR/texcache -jar $GAMEDIR/$jar_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
