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

source "$controlfolder/control.txt"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/${directory#/}/ports/residual"
GAMEDATADIR="$GAMEDIR/gamedata"
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"
jar_filename="Residual.jar"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

SAVEDIR="$GAMEDIR/saves/"
CACHEDIR="$GAMEDIR/cache/"
$ESUDO mkdir -p "$SAVEDIR" "$CACHEDIR"

[ -f "$GAMEDATADIR/$jar_filename" ] || { pm_message "Residual: Copy your owned Residual.jar to residual/gamedata/Residual.jar. See residual/log.txt."; sleep 5; exit 1; }

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    { pm_message "Residual: This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info. See residual/log.txt."; sleep 5; exit 1; }
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}" 2>/dev/null || true
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "$weston_dir" 

export JAVA_HOME="/tmp/javaruntime/"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    { pm_message "Residual: This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info. See residual/log.txt."; sleep 5; exit 1; }
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}" 2>/dev/null || true
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "$JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

"$JAVA_HOME/bin/java" -Xmx64m -cp runtime/residual-host.jar org.portmaster.residual.VerifyGame "$GAMEDATADIR/$jar_filename" || { pm_message "Residual: Unsupported or damaged game JAR. Check the README checksum. See residual/log.txt."; sleep 5; exit 1; }
source "$GAMEDIR/display.inc" || { pm_message "Residual: Display helper missing. See residual/log.txt."; sleep 5; exit 1; }
residual_display_setup || { pm_message "Residual: Use auto or WIDTHxHEIGHT in resolution.txt. See residual/log.txt."; sleep 5; exit 1; }
printf 'Firmware: %s; display: %s\n' "$CFW_NAME" "$residual_display_description"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HOTKEY=back
$GPTOKEYB2 java -x &
pm_platform_helper "$JAVA_HOME/bin/java"

$ESUDO env "${display_env[@]}" "CRUSTY_BLOCK_INPUT=1" "LD_LIBRARY_PATH=$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH" "$weston_dir/westonwrap.sh" headless noop kiosk crusty_glx_gl4es \
  "PATH=$JAVA_HOME/bin:$PATH" "JAVA_HOME=$JAVA_HOME" "HOME=$SAVEDIR" \
  "XDG_DATA_HOME=$SAVEDIR" "XDG_CONFIG_HOME=$SAVEDIR/config" \
  "XDG_CACHE_HOME=$CACHEDIR" "WAYLAND_DISPLAY=" \
  "$JAVA_HOME/bin/java" -Xms32m -Xmx256m -XX:+UseSerialGC \
  "-Duser.home=$SAVEDIR" "-Djava.io.tmpdir=$CACHEDIR" \
  "-Dresidual.jar=$GAMEDATADIR/$jar_filename" "-Dresidual.saves=$SAVEDIR" \
  -Dresidual.fullscreen=true "${display_java[@]}" \
  -cp "$GAMEDIR/runtime/residual-host.jar:$GAMEDATADIR/$jar_filename" org.portmaster.residual.Main

$ESUDO "$weston_dir/westonwrap.sh" cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}"
  $ESUDO umount "${JAVA_HOME}"
fi

pm_finish
