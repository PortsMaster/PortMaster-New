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

GAMEDIR="/${directory#/}/ports/gunslugs"
GAMEDATADIR="$GAMEDIR/gamedata"
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

SAVEDIR="$GAMEDIR/saves/"
CACHEDIR="$GAMEDIR/cache/"
$ESUDO mkdir -p "$SAVEDIR" "$CACHEDIR"

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
     { pm_message "Gunslugs: This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info. See gunslugs/log.txt."; sleep 5; exit 1; }
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}" 2>/dev/null || true
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "$weston_dir" \
  || { pm_message "Gunslugs: Cannot mount Weston. See gunslugs/log.txt."; sleep 5; exit 1; }

export JAVA_HOME="/tmp/javaruntime/"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    { pm_message "Gunslugs: This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info. See gunslugs/log.txt."; sleep 5; exit 1; }
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}" 2>/dev/null || true
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "$JAVA_HOME" \
  || { pm_message "Gunslugs: Cannot mount Java. See gunslugs/log.txt."; sleep 5; exit 1; }
export PATH="$JAVA_HOME/bin:$PATH"

prepare_game_data() (
  set -eo pipefail
  if [[ ! -x "$JAVA_HOME/bin/java" ]]; then
      echo "Launch Gunslugs from Ports to load its Java runtime first."
      exit 1
  fi
  prepare_cp="$GAMEDIR/runtime/prepare/*"
  if "$JAVA_HOME/bin/java" -Xmx128m -cp "$prepare_cp" PrepareDevice --check "$GAMEDIR/gamedata"; then
      echo "Prepared Gunslugs game data found."
      exit 0
  fi
  echo "Preparing Gunslugs game data. Please wait and do not power off."
  if [[ -n "${controlfolder:-}" && -f "$controlfolder/PortMasterDialog.txt" ]]; then
      source "$controlfolder/PortMasterDialog.txt"
      PortMasterDialogInit "no-harbour"
      PortMasterDialog "messages_begin"
      PortMasterDialog "message" "Preparing Gunslugs. Please do not power off."
      PortMasterDialog "progress" "Preparing game data" 0 100
  fi

  status=0
  "$JAVA_HOME/bin/java" -Xmx128m -XX:+UseSerialGC \
      "-Djava.io.tmpdir=$GAMEDIR/cache" -cp "$prepare_cp" PrepareDevice "$GAMEDIR" 2>&1 |
      while IFS= read -r line; do
          printf '%s\n' "$line"
          if [[ "$line" == $'GUNSLUGS_PROGRESS\t'* ]] && declare -F PortMasterDialog >/dev/null; then
              IFS=$'\t' read -r marker percent message <<< "$line"
              PortMasterDialog "progress" "$message" "$percent" 100
          fi
      done || status=$?

  if declare -F PortMasterDialogExit >/dev/null; then
      PortMasterDialog "progress_clear"
      PortMasterDialogExit
  fi
  exit "$status"
)
prepare_game_data || { pm_message "Game data preparation failed. See log.txt."; sleep 5; exit 1; }
game_build=$("$JAVA_HOME/bin/java" -Xmx32m -cp "$GAMEDIR/runtime/prepare/*" PrepareDevice --mode "$GAMEDATADIR") || exit 1
game_main=org.portmaster.gunslugs.Main
game_controls="$GAMEDIR/gunslugs.ini"
gunslugs_audio_env=()
[[ -n "${XDG_RUNTIME_DIR:-}" ]] && gunslugs_audio_env=("XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR")
source "$GAMEDIR/display.inc"
gunslugs_display_setup || { pm_message "Use auto or WIDTHxHEIGHT in resolution.txt."; sleep 5; exit 1; }
GAME_JAR="$GAMEDATADIR/GAME.JAR"
[[ -f "$GAME_JAR" ]] || GAME_JAR="$GAMEDATADIR/game.jar"
if [[ "$game_build" == pc ]]; then
  GAME_JAR="$GAMEDATADIR/pc/GAME.JAR"
  game_main=org.portmaster.gunslugs.PcMain
  game_controls="$GAMEDIR/gunslugs-pc.ini"
  SAVEDIR="$GAMEDIR/saves/pc/"
  $ESUDO mkdir -p "$SAVEDIR"
fi
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig:-}"
export HOTKEY=back
$GPTOKEYB2 "java" -c "$game_controls" &
pm_platform_helper "$JAVA_HOME/bin/java"
printf 'Firmware: %s; build: %s; display: %s\n' "$CFW_NAME" "$game_build" "$gunslugs_display_description"

$ESUDO env "${display_env[@]}" "LD_LIBRARY_PATH=$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH" "$weston_dir/westonwrap.sh" headless noop kiosk crusty_glx_gl4es \
  "PATH=$JAVA_HOME/bin:$PATH" "JAVA_HOME=$JAVA_HOME" "HOME=$SAVEDIR" \
  "XDG_DATA_HOME=$SAVEDIR" "XDG_CONFIG_HOME=$SAVEDIR/config" \
  "XDG_CACHE_HOME=$CACHEDIR" \
  "${gunslugs_audio_env[@]}" "WAYLAND_DISPLAY=" \
  "$JAVA_HOME/bin/java" -Xms32m -Xmx256m -XX:+UseSerialGC \
  "-Duser.home=$SAVEDIR" "-Djava.io.tmpdir=$CACHEDIR" \
  "-Dgunslugs.assets=$GAMEDATADIR/assets" "-Dgunslugs.saves=$SAVEDIR" \
  -Dgunslugs.fullscreen=true -Dgunslugs.lockDisplay=true "${display_java[@]}" \
  -cp "$GAMEDIR/runtime/lib/*:$GAME_JAR" "$game_main"

$ESUDO "$weston_dir/westonwrap.sh" cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}"
  $ESUDO umount "${JAVA_HOME}"
fi

pm_finish
