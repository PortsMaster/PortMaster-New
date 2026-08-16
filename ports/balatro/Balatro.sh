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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/balatro"

export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"

mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"

LAUNCHER="$0"
case "$LAUNCHER" in
  /*) ;;
  *) LAUNCHER="$PWD/$LAUNCHER" ;;
esac

cd "$GAMEDIR" || exit 1

source "$controlfolder/runtimes/love_11.5/love.txt"
$ESUDO chmod a+x ./bin/7za.* ./tools/patchscript

GAMEFILE=""
if [ -f "Balatro.exe" ]; then
  GAMEFILE="Balatro.exe"
elif [ -f "balatro.exe" ]; then
  GAMEFILE="balatro.exe"
elif [ -f "Balatro.love" ]; then
  GAMEFILE="Balatro.love"
elif [ -f "balatro.love" ]; then
  GAMEFILE="balatro.love"
fi

FORCE_DISPLAY_SETUP=0
SETUP_FILE="$GAMEDIR/saves/display-setup.txt"
export BALATRO_PM_SETUP_FILE="$SETUP_FILE"

read_setting() {
  local key="$1" fallback="$2" value=""
  if [ -f "$SETUP_FILE" ]; then
    value=$(sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*\([^[:space:]]*\).*/\1/p" \
      "$SETUP_FILE" | tail -n 1)
  fi
  if [ -n "$value" ]; then echo "$value"; else echo "$fallback"; fi
}

PERF_HUD=0
export BALATRO_PM_PERF_HUD="$PERF_HUD"

# Particle leak cleanup is always applied in the patched build. Set to 1 to
# keep stock Blind:defeat particle behaviour (orphaned emitters stay alive).
# export BALATRO_PM_SKIP_PARTICLE_CLEANUP=1

# CPU opts that do not change desktop visuals (idle deck/discard updates,
# pile align cache, aggressive GC, FPS cap). Set to 1 for stock behaviour.
# export BALATRO_PM_SKIP_CPU_OPT=1
# Frame rate is chosen in display setup / Settings → Video (60, 40, or 30).
# export BALATRO_PM_FPS_CAP=60

# Controller rumble (Settings → Game → Controller Vibration). Needs a pad/CFW
# that exposes SDL vibration. Set to 1 to leave rumble disabled like stock Linux.
# export BALATRO_PM_SKIP_RUMBLE=1
# Optional intensity (Switch uses 0.7): export BALATRO_PM_RUMBLE=0.7

# In-game achievements menu (Options / Stats). Set to 1 to hide it.
# export BALATRO_PM_SKIP_ACHIEVEMENTS_MENU=1

FORCE_BUTTON_SETUP=0
BUTTON_MAP_FILE="$GAMEDIR/saves/controller-map.txt"
export BALATRO_PM_BUTTON_MAP_FILE="$BUTTON_MAP_FILE"

OUTPUT_GAME="Balatro_pm"
BUILD_STAMP="$GAMEDIR/.balatro-build.txt"

PATCHSCRIPT="$GAMEDIR/tools/patchscript"

build_signature() {
  echo "layout=$LAYOUT performance=$PERFORMANCE font=$FONT"
}

needs_build() {
  [ -z "$GAMEFILE" ] && return 1
  [ ! -f "$OUTPUT_GAME" ] && return 0
  [ ! -f "$BUILD_STAMP" ] && return 0
  [ "$(cat "$BUILD_STAMP")" != "$(build_signature)" ] && return 0
  for source in "$LAUNCHER" "$PATCHSCRIPT" "$GAMEDIR/patches/small_screen.lua" \
                "$GAMEDIR/patches/options.lua" "$GAMEDIR/patches/perf.lua" \
                "$GAMEDIR/patches/controls.lua" \
                "$GAMEDIR/patches/particle_cleanup.lua" \
                "$GAMEDIR/patches/cpu_opt.lua" \
                "$GAMEDIR/patches/rumble.lua" \
                "$GAMEDIR/patches/achievements.lua" \
                "$GAMEDIR/resources/fonts/Nunito-Black.ttf" "$GAMEDIR/$GAMEFILE"; do
    if [ -f "$source" ] && [ "$source" -nt "$OUTPUT_GAME" ]; then
      return 0
    fi
  done
  return 1
}

build_if_needed() {
  if [ -z "$GAMEFILE" ] && [ -f "$OUTPUT_GAME" ] &&
     [ "$(cat "$BUILD_STAMP" 2>/dev/null)" != "$(build_signature)" ]; then
    echo "The Balatro game file is missing, so ${OUTPUT_GAME} cannot be rebuilt."
    echo "It is being launched as it was last built. Copy the game file back to apply the display setup."
  fi
  needs_build || return 0
  echo "Preparing the ${OUTPUT_GAME} handheld build..."
  rm -f "$BUILD_STAMP"
  if [ ! -f "$controlfolder/utils/patcher.txt" ]; then
    echo "PortMaster's patcher is unavailable. Update PortMaster and try again."
    return 1
  fi

  export GAMEDIR GAMEFILE OUTPUT_GAME BUILD_STAMP LAYOUT PERFORMANCE FONT
  export PERF_OPTIMIZATIONS DEVICE_ARCH
  export PATCHER_FILE="$PATCHSCRIPT"
  export PATCHER_GAME="$(basename "${0%.*}")"
  export PATCHER_TIME="about a minute"
  export PATCHER_QUESTIONS=""
  export controlfolder ESUDO
  source "$controlfolder/utils/patcher.txt"

  if [ -f "$OUTPUT_GAME" ] &&
     [ "$(cat "$BUILD_STAMP" 2>/dev/null)" = "$(build_signature)" ]; then
    for stale in Balatro_4x3 Balatro_1x1; do
      [ -f "$stale" ] && echo "An older ${stale} build is still here and can be deleted."
    done
  else
    echo "Patch failed; no partial build was installed and the purchased game was not modified."
    return 1
  fi
  cd "$GAMEDIR" || exit 1
}

apply_button_map() {
  BUTTON_MAP=""
  if [ -f "$BUTTON_MAP_FILE" ]; then
    BUTTON_MAP=$(grep -v '^[[:space:]]*#' "$BUTTON_MAP_FILE" | grep -m 1 '[^[:space:]]')
  fi
  [ -z "$BUTTON_MAP" ] && return 0
  if [ -n "$SDL_GAMECONTROLLERCONFIG" ]; then
    export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG}
${BUTTON_MAP}"
  else
    export SDL_GAMECONTROLLERCONFIG="$BUTTON_MAP"
  fi
}

if [ -z "$GAMEFILE" ] && [ ! -f "$OUTPUT_GAME" ] && [ ! -f "Balatro" ]; then
  echo "Balatro game file not found. Copy Balatro.exe or Balatro.love into the balatro folder, then launch again."
  pm_message "Balatro game file not found. Copy Balatro.exe or Balatro.love into the balatro folder, then launch again."
  pm_finish
  exit 0
fi

pm_platform_helper "$LOVE_BINARY"

apply_button_map

if [ "$FORCE_DISPLAY_SETUP" -eq 1 ] || [ ! -f "$SETUP_FILE" ] ||
   grep -q '^[[:space:]]*ask[[:space:]]*=[[:space:]]*1' "$SETUP_FILE" 2>/dev/null; then
  if [ -f "$SETUP_FILE" ]; then
    sed -i '/^[[:space:]]*ask[[:space:]]*=[[:space:]]*1[[:space:]]*$/d' "$SETUP_FILE"
  fi
  echo "Asking about the layout, font, performance and frame rate..."
  BALATRO_PM_SETUP_FONT="$GAMEDIR/resources/fonts/Nunito-Black.ttf" \
    $LOVE_RUN "$GAMEDIR/displaysetup"
fi

LAYOUT=$(read_setting layout small)
PERFORMANCE=$(read_setting performance on)
FPS_CAP=$(read_setting fps 60)
[ "$LAYOUT" = "original" ] || LAYOUT="small"
if [ "$LAYOUT" = "original" ]; then
  FONT=$(read_setting font original)
else
  FONT=$(read_setting font nunito)
fi
[ "$FONT" = "original" ] || FONT="nunito"
[ "$PERFORMANCE" = "off" ] || PERFORMANCE="on"
case "$FPS_CAP" in 30|40|60) ;; *) FPS_CAP=60 ;; esac

if [ "$PERFORMANCE" = "off" ]; then PERF_OPTIMIZATIONS=0; else PERF_OPTIMIZATIONS=1; fi
export BALATRO_PM_PERF_OPTIMIZATIONS="$PERF_OPTIMIZATIONS"
export BALATRO_PM_FPS_CAP="$FPS_CAP"

build_if_needed

LAUNCH_GAME="$OUTPUT_GAME"

if [ ! -f "$LAUNCH_GAME" ] && [ -f "Balatro" ]; then
  LAUNCH_GAME="Balatro"
fi

if [ -f "$LAUNCH_GAME" ]; then
  if [ "$FORCE_BUTTON_SETUP" -eq 1 ] || [ ! -f "$BUTTON_MAP_FILE" ]; then
    echo "Checking which button is which..."
    BALATRO_PM_BUTTON_FONT="$GAMEDIR/resources/fonts/Nunito-Black.ttf" \
      $LOVE_RUN "$GAMEDIR/buttonsetup"
    apply_button_map
  fi

  $GPTOKEYB "$LOVE_GPTK" &
  $LOVE_RUN "$LAUNCH_GAME"
else
  echo "The handheld build could not be made, so there is nothing to launch."
fi

pm_finish
