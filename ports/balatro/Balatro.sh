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

# Keep the existing PortMaster identity so installs update the original Balatro port.
GAMEDIR="/$directory/ports/balatro"

export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"

mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"

## Uncomment the following line to log output for debugging.
# > "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Resolved before the cd below, which is what a relative $0 would be relative to.
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

# The layout and the performance changes are the player's to choose, and both
# decide how the patched build is put together rather than anything the running
# game could switch, so they are asked before it starts and the build is made to
# the answers. The first launch asks; after that the answers are read from this
# file. The game's options menu offers to ask again, which it does by marking
# the file; deleting it by hand or setting this to 1 has the same effect.
FORCE_DISPLAY_SETUP=0
SETUP_FILE="$GAMEDIR/saves/display-setup.txt"
# The game is told where the answers live, because its options menu is what
# marks them to be asked again.
export BALATRO_PM_SETUP_FILE="$SETUP_FILE"

# Read back one `key=value` from the answers, or the port's own default when the
# setup has not run or did not get that far.
read_setting() {
  local key="$1" fallback="$2" value=""
  if [ -f "$SETUP_FILE" ]; then
    value=$(sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*\([^[:space:]]*\).*/\1/p" \
      "$SETUP_FILE" | tail -n 1)
  fi
  if [ -n "$value" ]; then echo "$value"; else echo "$fallback"; fi
}

# Set to 1 to draw a small readout in the top-left corner: frame rate, Lua heap
# size, and how many live objects each frame has to walk. Worth turning on if
# the game slows down over a long run -- a climbing heap and a climbing object
# count have different causes and different fixes.
PERF_HUD=0
export BALATRO_PM_PERF_HUD="$PERF_HUD"

# Which physical button is A is decided by the handheld, not by the game. Some
# devices print the Xbox arrangement and some the Nintendo one, and the SDL
# mapping a device ships with does not always agree with its own case lettering,
# so the button under the player's thumb can report itself as another letter or
# as nothing at all. The first launch asks for each button by the letter printed
# beside it and keeps the answer in the saves folder. The game's options menu
# offers to ask again, which it does by removing that file; deleting it by hand
# or setting this to 1 has the same effect.
FORCE_BUTTON_SETUP=0
BUTTON_MAP_FILE="$GAMEDIR/saves/controller-map.txt"
# The game is told where the answer lives too: its options menu offers to ask
# again, which means removing this file for the next launch to act on.
export BALATRO_PM_BUTTON_MAP_FILE="$BUTTON_MAP_FILE"

# One patched build serves every device. The handheld layout reads the panel's
# real dimensions at startup, and which face button is which is settled below
# the game, in the mapping handed to SDL, rather than inside the build.
OUTPUT_GAME="Balatro_pm"
# What the build in hand was made from, so answering the setup differently is
# noticed and rebuilt for rather than silently ignored.
BUILD_STAMP="$GAMEDIR/.balatro-build.txt"

PATCHSCRIPT="$GAMEDIR/tools/patchscript"

# The build is made once and kept, so an updated port would otherwise keep
# launching the archive the previous version produced -- the layout, the options
# menu, and everything else patched in would silently stay at the old revision.
# Rebuild when anything that goes into it is newer than it is, and when the
# answers it was made for are no longer the answers in force.
build_signature() {
  echo "layout=$LAYOUT performance=$PERFORMANCE"
}

needs_build() {
  [ -z "$GAMEFILE" ] && return 1
  [ ! -f "$OUTPUT_GAME" ] && return 0
  [ ! -f "$BUILD_STAMP" ] && return 0
  [ "$(cat "$BUILD_STAMP")" != "$(build_signature)" ] && return 0
  for source in "$LAUNCHER" "$PATCHSCRIPT" "$GAMEDIR/patches/small_screen.lua" \
                "$GAMEDIR/patches/options.lua" "$GAMEDIR/patches/perf.lua" \
                "$GAMEDIR/patches/controls.lua" \
                "$GAMEDIR/resources/fonts/Nunito-Black.ttf" "$GAMEDIR/$GAMEFILE"; do
    if [ -f "$source" ] && [ "$source" -nt "$OUTPUT_GAME" ]; then
      return 0
    fi
  done
  return 1
}

build_if_needed() {
  # A build cannot be remade from a game file that is no longer there, so an
  # answer that asks for a different one has nothing to act on. Say so rather
  # than start the build in hand as though it were what was asked for.
  if [ -z "$GAMEFILE" ] && [ -f "$OUTPUT_GAME" ] &&
     [ "$(cat "$BUILD_STAMP" 2>/dev/null)" != "$(build_signature)" ]; then
    echo "The Balatro game file is missing, so ${OUTPUT_GAME} cannot be rebuilt."
    echo "It is being launched as it was last built. Copy the game file back to apply the display setup."
  fi
  needs_build || return 0
  echo "Preparing the ${OUTPUT_GAME} handheld build..."
  # Removed first, so a build that fails halfway is never mistaken on the next
  # launch for one that matches the answers.
  rm -f "$BUILD_STAMP"
  if [ ! -f "$controlfolder/utils/patcher.txt" ]; then
    echo "PortMaster's patcher is unavailable. Update PortMaster and try again."
    return 1
  fi

  export GAMEDIR GAMEFILE OUTPUT_GAME BUILD_STAMP LAYOUT PERFORMANCE
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

# A run of the button setup that ends without an answer -- skipped, timed out,
# or no controller attached -- still leaves its file behind, holding comments
# and no mapping, so the questions are asked once rather than on every launch.
#
# SDL reads this before anything opens the pad, and a mapping given here
# outranks both the device's own database entry and the one LOVE bundles.
# Balatro then sees the buttons under the names the player gave them, which is
# also what its on-screen prompts are drawn from. Appended last: SDL keeps the
# final mapping for a given controller.
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

# Nothing below can produce a game out of nothing, so say so before spending a
# platform helper and a build on it.
if [ -z "$GAMEFILE" ] && [ ! -f "$OUTPUT_GAME" ] && [ ! -f "Balatro" ]; then
  echo "Balatro game file not found. Copy Balatro.exe or Balatro.love into the balatro folder, then launch again."
  pm_message "Balatro game file not found. Copy Balatro.exe or Balatro.love into the balatro folder, then launch again."
  pm_finish
  exit 0
fi

pm_platform_helper "$LOVE_BINARY"

# Everything from here sits after the platform helper, so the questions are
# asked on the display the game is about to use and under the same environment,
# and nothing the helper sets up can overwrite the mapping afterwards. They sit
# before gptokeyb because it is started to watch the game: the setup screens
# bring their own ways out instead -- each gives up on its own if it is left
# alone, and quits rather than stopping on an error.

# Before the display setup rather than after it, so that screen is answered
# through the buttons the player has already described. On a first launch there
# is nothing to apply yet, and it reads the pad raw instead.
apply_button_map

# First, because the answers decide what is built, and the build has to be the
# one the rest of this launch runs.
#
# The mark the game's options menu leaves is taken out before the questions are
# asked rather than after, because it means "ask on the next launch" and this is
# that launch. Removing it afterwards would be left undone by a setup screen
# that could not run, and the port would then ask again on every launch and
# report itself as waiting for a restart forever. Removing the button map has
# the same shape and needs no such care: running the setup is what puts it back.
if [ "$FORCE_DISPLAY_SETUP" -eq 1 ] || [ ! -f "$SETUP_FILE" ] ||
   grep -q '^[[:space:]]*ask[[:space:]]*=[[:space:]]*1' "$SETUP_FILE" 2>/dev/null; then
  if [ -f "$SETUP_FILE" ]; then
    sed -i '/^[[:space:]]*ask[[:space:]]*=[[:space:]]*1[[:space:]]*$/d' "$SETUP_FILE"
  fi
  echo "Asking about the layout and performance..."
  BALATRO_PM_SETUP_FONT="$GAMEDIR/resources/fonts/Nunito-Black.ttf" \
    $LOVE_RUN "$GAMEDIR/displaysetup"
fi

# Anything but the one word that means otherwise is the port's own default, so a
# file that was edited by hand into something unreadable is a working port with
# the usual answers rather than a broken one. Normalised rather than merely
# tested, because these two words are also the build's signature.
LAYOUT=$(read_setting layout small)
PERFORMANCE=$(read_setting performance on)
[ "$LAYOUT" = "original" ] || LAYOUT="small"
[ "$PERFORMANCE" = "off" ] || PERFORMANCE="on"

if [ "$PERFORMANCE" = "off" ]; then PERF_OPTIMIZATIONS=0; else PERF_OPTIMIZATIONS=1; fi
# The runtime half of the same answer: the module the build injects reads this
# and leaves the game alone when the answer was no.
export BALATRO_PM_PERF_OPTIMIZATIONS="$PERF_OPTIMIZATIONS"

build_if_needed

LAUNCH_GAME="$OUTPUT_GAME"

# Preserve the documented extensionless-file bypass when no source archive is
# present, so an unpatched build can still be provided by hand.
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
