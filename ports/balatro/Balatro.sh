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
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

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

$ESUDO chmod a+x ./bin/*

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

PATCHDIR="$GAMEDIR/patch-work"
WORKFILE="$GAMEDIR/.balatro-patching.${GAMEFILE##*.}"
SEVENZIP="$GAMEDIR/bin/7za.${DEVICE_ARCH}"

cleanup_patch_work() {
  # Only remove files created inside our known work directory.
  rm -f "$WORKFILE"
  rm -f "$PATCHDIR/globals.lua" "$PATCHDIR/main.lua" "$PATCHDIR/game.lua"
  rm -f "$PATCHDIR/cardarea.lua" "$PATCHDIR/engine/text.lua"
  rm -f "$PATCHDIR/portmaster/small_screen.lua"
  rm -f "$PATCHDIR/portmaster/options.lua" "$PATCHDIR/portmaster/perf.lua"
  rm -f "$PATCHDIR/portmaster/controls.lua"
  rm -f "$PATCHDIR/resources/fonts/m6x11plus.ttf"
  rm -f "$PATCHDIR/resources/shaders/CRT.fs"
  rm -f "$PATCHDIR/resources/shaders/background.fs"
  rmdir "$PATCHDIR/engine" "$PATCHDIR/portmaster" "$PATCHDIR/resources/fonts" \
    "$PATCHDIR/resources/shaders" "$PATCHDIR/resources" "$PATCHDIR" 2>/dev/null
}

build_patched_game() {
  mkdir -p "$PATCHDIR" || return 1
  cp "$GAMEFILE" "$WORKFILE" || return 1
  cd "$PATCHDIR" || return 1

  if [ "$PERF_OPTIMIZATIONS" -eq 1 ]; then
    # Defaults for new profiles. These are the effects half of the performance
    # answer, so they follow it rather than the layout: the performance module
    # reapplies the same values after a saved profile loads, and hands them back
    # when the answer changes. Neither is touched when the answer is no.
    "$SEVENZIP" x -aoa "$WORKFILE" globals.lua >/dev/null || return 1
    sed -i 's/crt = 70,/crt = 0,/g' globals.lua || return 1
    sed -i 's/bloom = 1/bloom = 0/g' globals.lua || return 1
    sed -i "s/shadows = 'On'/shadows = 'Off'/g" globals.lua || return 1
    "$SEVENZIP" u -aoa "$WORKFILE" globals.lua >/dev/null || return 1
  fi

  # The options-menu entry, the handheld pause-menu fix and the performance work
  # all go in whichever layout was chosen -- none of them is about how the
  # screen is arranged. The responsive room and HUD, readable descriptions and
  # screen-clamped tooltips are the small screen layout itself and go in only
  # when it was asked for.
  MODULES="portmaster/options.lua portmaster/controls.lua portmaster/perf.lua"
  [ "$LAYOUT" = "small" ] && MODULES="$MODULES portmaster/small_screen.lua"

  # game.lua, cardarea.lua and engine/text.lua are only rewritten by the
  # performance work, so with it off they are left in the archive untouched.
  SOURCES="main.lua"
  if [ "$PERF_OPTIMIZATIONS" -eq 1 ]; then
    SOURCES="main.lua game.lua cardarea.lua engine/text.lua"
  fi

  "$SEVENZIP" x -aoa "$WORKFILE" $SOURCES >/dev/null || return 1
  mkdir -p portmaster || return 1
  for module in $MODULES; do
    cp "$GAMEDIR/patches/${module#portmaster/}" "$module" || return 1
  done
  # Inserted one at a time and in reverse, because each lands directly after the
  # line it is anchored to: the layout is read after the modules it does not
  # touch, and the performance work last, so its wrappers sit outermost.
  for module in portmaster/perf portmaster/small_screen portmaster/controls \
                portmaster/options; do
    case " $MODULES " in *" $module.lua "*) ;; *) continue ;; esac
    grep -q "$module" main.lua && continue
    sed -i "/require \"challenges\"/a require \"$module\"" main.lua || return 1
  done

  # Reduced motion used to multiply animation expressions by zero after their
  # sin/cos calls had already run. Guard the expensive terms themselves. These
  # counts intentionally pin the rewrite to the purchased 1.0.1o source: an
  # incompatible archive is left untouched instead of being partly patched.
  expect_occurrences() {
    local expected="$1" file="$2" needle="$3" actual
    actual=$(grep -F -o "$needle" "$file" | wc -l)
    if [ "$actual" -ne "$expected" ]; then
      echo "Patch mismatch in $file: expected $expected occurrences of $needle, found $actual."
      return 1
    fi
  }

  if [ "$PERF_OPTIMIZATIONS" -eq 1 ]; then
    # At zero CRT intensity the stock draw path still submits the completed
    # screen through a full-resolution fragment shader. Draw the Canvas
    # directly in that case; selecting any non-zero CRT setting restores the
    # original shader path. The replacement is pinned to one source match.
    expect_occurrences 1 game.lua "love.graphics.setShader( G.SHADERS['CRT'])" || return 1
    sed -i "s|love.graphics.setShader( G.SHADERS\['CRT'\])|if G.SETTINGS.GRAPHICS.crt > 0 then love.graphics.setShader( G.SHADERS['CRT']) else love.graphics.setShader() end|" game.lua || return 1
    expect_occurrences 1 game.lua "if G.SETTINGS.GRAPHICS.crt > 0 then love.graphics.setShader( G.SHADERS['CRT']) else love.graphics.setShader() end" || return 1

    expect_occurrences 11 cardarea.lua '(G.SETTINGS.reduced_motion and 0 or 1)*' || return 1
    sed -i \
      -e 's|(G.SETTINGS.reduced_motion and 0 or 1)\*0\.02\*math\.sin(2\*G\.TIMERS\.REAL+card\.T\.x)|(G.SETTINGS.reduced_motion and 0 or 0.02*math.sin(2*G.TIMERS.REAL+card.T.x))|g' \
      -e 's|(G.SETTINGS.reduced_motion and 0 or 1)\*0\.02\*math\.sin(2\*G\.TIMERS\.REAL+card\.T\.x+card\.T\.y)|(G.SETTINGS.reduced_motion and 0 or 0.02*math.sin(2*G.TIMERS.REAL+card.T.x+card.T.y))|g' \
      -e 's|(G.SETTINGS.reduced_motion and 0 or 1)\*0\.1\*math\.sin(0\.666\*G\.TIMERS\.REAL+card\.T\.x)|(G.SETTINGS.reduced_motion and 0 or 0.1*math.sin(0.666*G.TIMERS.REAL+card.T.x))|g' \
      -e 's|(G.SETTINGS.reduced_motion and 0 or 1)\*0\.03\*math\.sin(0\.666\*G\.TIMERS\.REAL+card\.T\.x)|(G.SETTINGS.reduced_motion and 0 or 0.03*math.sin(0.666*G.TIMERS.REAL+card.T.x))|g' \
      -e 's|(G.SETTINGS.reduced_motion and 0 or 1)\*0\.05\*math\.sin(2\*1\.666\*G\.TIMERS\.REAL+card\.T\.x)|(G.SETTINGS.reduced_motion and 0 or 0.05*math.sin(2*1.666*G.TIMERS.REAL+card.T.x))|g' \
      cardarea.lua || return 1
    expect_occurrences 0 cardarea.lua '(G.SETTINGS.reduced_motion and 0 or 1)*' || return 1
    expect_occurrences 11 cardarea.lua '(G.SETTINGS.reduced_motion and 0 or 0.' || return 1

    expect_occurrences 1 engine/text.lua 'if self.config.quiver then' || return 1
    expect_occurrences 1 engine/text.lua 'if self.config.rotate then letter.r =' || return 1
    expect_occurrences 1 engine/text.lua 'if self.config.float then letter.offset.y =' || return 1
    expect_occurrences 1 engine/text.lua 'if self.config.bump then letter.offset.y =' || return 1
    sed -i \
      -e 's|if self.config.quiver then|if self.config.quiver and not G.SETTINGS.reduced_motion then|' \
      -e 's|(G.SETTINGS.reduced_motion and 0 or 1)\*0\.02\*math\.sin(2\*G\.TIMERS\.REAL+k)|(G.SETTINGS.reduced_motion and 0 or 0.02*math.sin(2*G.TIMERS.REAL+k))|' \
      -e 's|if self.config.float then letter.offset.y = .*|if self.config.float then letter.offset.y = (G.SETTINGS.reduced_motion and 0 or math.sqrt(self.scale)*(2+(self.font.FONTSCALE/G.TILESIZE)*2000*math.sin(2.666*G.TIMERS.REAL+200*k))) + 60*(letter.scale-1) end|' \
      -e 's|if self.config.bump then letter.offset.y = .*|if self.config.bump then letter.offset.y = (G.SETTINGS.reduced_motion and 0 or self.bump_amount*math.sqrt(self.scale)*7*math.max(0, (5+self.bump_rate)*math.sin(self.bump_rate*G.TIMERS.REAL+200*k) - 3 - self.bump_rate)) end|' \
      engine/text.lua || return 1
    expect_occurrences 1 engine/text.lua 'if self.config.quiver and not G.SETTINGS.reduced_motion then' || return 1
    expect_occurrences 1 engine/text.lua '(G.SETTINGS.reduced_motion and 0 or 0.02*math.sin(2*G.TIMERS.REAL+k))' || return 1
    expect_occurrences 1 engine/text.lua 'if self.config.float then letter.offset.y = (G.SETTINGS.reduced_motion and 0 or math.sqrt' || return 1
    expect_occurrences 1 engine/text.lua 'if self.config.bump then letter.offset.y = (G.SETTINGS.reduced_motion and 0 or self.bump_amount' || return 1
  fi

  "$SEVENZIP" u -aoa "$WORKFILE" $SOURCES $MODULES >/dev/null || return 1

  # Both of these run over every pixel of every frame regardless of the settings
  # that are meant to turn them off, which is the largest single cost on a
  # handheld GPU -- and both are left stock when the performance answer was no.
  if [ "$PERF_OPTIMIZATIONS" -eq 1 ]; then
    "$SEVENZIP" x -aoa "$WORKFILE" resources/shaders/CRT.fs \
      resources/shaders/background.fs >/dev/null || return 1

    # Every frame the finished screen is drawn through CRT.fs, whether or not
    # the CRT effect is on. With it off the shader still evaluates six trig
    # calls of scanline pattern, a noise chain, and a chromatic aberration
    # branch for each of the ~786k pixels, then multiplies them all by zero.
    # Take the same result -- the bulge, the edge mask, and the contrast
    # correction, which are the parts that survive at zero intensity -- and
    # return it before any of that. The full path is untouched for anyone who
    # turns the effect back on.
    sed -i '/^vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)/{n;s|^{|{ if (crt_intensity <= 0.000001 \&\& noise_fac <= 0.000001 \&\& glitch_intensity <= 0.000001) { MY_HIGHP_OR_MEDIUMP vec2 ftc = (tc*2.0 - vec2(1.0))*scale_fac; ftc += (ftc.yx*ftc.yx)*ftc*(distortion_fac - 1.0); MY_HIGHP_OR_MEDIUMP number fmask = (1.0 - smoothstep(1.0-feather_fac,1.0,abs(ftc.x) - BUFF))*(1.0 - smoothstep(1.0-feather_fac,1.0,abs(ftc.y) - BUFF)); ftc = (ftc + vec2(1.0))/2.0; MY_HIGHP_OR_MEDIUMP vec4 fcol = Texel(tex, ftc); fcol.rgb = (fcol.rgb - vec3(0.55))*1.14 + vec3(0.5); fcol.a = 1.0; return fcol*fmask; }|;}' \
      resources/shaders/CRT.fs || return 1
    grep -q 'crt_intensity <= 0.000001' resources/shaders/CRT.fs || return 1

    # The animated table underneath everything is a procedural paint pattern:
    # five iterations of five trig calls each, per pixel, per frame. Two
    # iterations keep the broad swirl and colours while dropping three fifths
    # of that loop work. Reduced motion also caches the settled result in Lua.
    expect_occurrences 1 resources/shaders/background.fs 'i < 5; i++' || return 1
    sed -i 's/i < 5; i++/i < 2; i++/' resources/shaders/background.fs || return 1
    expect_occurrences 1 resources/shaders/background.fs 'i < 2; i++' || return 1

    "$SEVENZIP" u -aoa "$WORKFILE" resources/shaders/CRT.fs \
      resources/shaders/background.fs >/dev/null || return 1
  fi

  if [ "$LAYOUT" = "small" ]; then
    # Nunito is substantially clearer than the pixel font at handheld sizes.
    # The original layout keeps the game's own font, the same as everything
    # else about the way it looks.
    mkdir -p resources/fonts || return 1
    cp "$GAMEDIR/resources/fonts/Nunito-Black.ttf" resources/fonts/m6x11plus.ttf || return 1
    "$SEVENZIP" u -aoa "$WORKFILE" resources/fonts/m6x11plus.ttf >/dev/null || return 1
  fi

  # Test the complete archive before installing the generated output.
  "$SEVENZIP" t "$WORKFILE" >/dev/null || return 1
  for module in $MODULES; do
    "$SEVENZIP" l "$WORKFILE" | grep -q "$module" || return 1
  done

  cd "$GAMEDIR" || return 1
  mv -f "$WORKFILE" "$OUTPUT_GAME" || return 1
  return 0
}

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
  for source in "$LAUNCHER" "$GAMEDIR/patches/small_screen.lua" \
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
  if build_patched_game; then
    build_signature > "$BUILD_STAMP"
    echo "Handheld build ready."
    for stale in Balatro_4x3 Balatro_1x1; do
      [ -f "$stale" ] && echo "An older ${stale} build is still here and can be deleted."
    done
  else
    echo "Patch failed; no partial build was installed and the purchased game was not modified."
  fi
  cd "$GAMEDIR" || exit 1
  cleanup_patch_work
}

if [ "${DEVICE_NAME}" = "TrimUI Smart Pro" ] || [ "${DEVICE_NAME}" = "TrimUI Brick" ]; then
  # The bundled versions of these libraries conflict with TrimUI's runtime.
  LIBDIR="$GAMEDIR/libs.${DEVICE_ARCH}"
  [ -f "$LIBDIR/libfontconfig.so.1" ] && $ESUDO rm -f "$LIBDIR/libfontconfig.so.1"
  [ -f "$LIBDIR/libtheoradec.so.1" ] && $ESUDO rm -f "$LIBDIR/libtheoradec.so.1"
fi

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
  pm_finish
  exit 0
fi

pm_platform_helper "./bin/love.${DEVICE_ARCH}"

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
    ./bin/love.${DEVICE_ARCH} ./displaysetup
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
      ./bin/love.${DEVICE_ARCH} ./buttonsetup
    apply_button_map
  fi

  $GPTOKEYB "love.${DEVICE_ARCH}" &
  ./bin/love.${DEVICE_ARCH} "$LAUNCH_GAME"
else
  echo "The handheld build could not be made, so there is nothing to launch."
fi

pm_finish
