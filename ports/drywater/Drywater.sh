#!/bin/bash
# Drywater — PortMaster launch script (Sprint 33)
#
# TARGET: Anbernic RG35XX-H (Allwinner H700, ARM64) running muOS + PortMaster.
#
# SHARED-RUNTIME BUILD — this port ships only the .pck and runs on PortMaster's
# shared `godot_4.6.3` runtime, which matches this project's engine exactly.
# No engine binary is shipped. See the runtime block further down (~line 100)
# for the mount mechanics and why westonpack is mandatory alongside it.
#
# CORRECTED 2026-07-30 (bug #15). This header used to describe a SELF-CONTAINED
# port shipping its own ~62 MB ARM64 export template, on the belief that
# PortMaster's runtimes stopped at frt_4.1.3. That was true when the sprint
# started and false by the time it finished; the code below has been correct
# all along, and only this header lied. Acting on the old text would send the
# next reader hunting for a binary that is deliberately absent.
#
# NO GPTOKEYB — gptokeyb exists to fake a keyboard for games that only read
# keys. As of Sprint 33 every action has a real joypad binding in the
# InputMap, so SDL delivers gamepad input to Godot directly. Adding gptokeyb
# on top would double-fire every button.

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

[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"

get_controls

# muOS splits a port in two: the launch script lives in /roms/PORTS/ while the
# game files live in /ports/ — NOT together, which is how other firmware does
# it. So the script cannot assume the game sits beside it, and $directory
# resolves differently per firmware. Probe the known layouts and fail loudly
# rather than cd'ing into nothing.
GAMEDIR=""
for candidate in \
  "/$directory/ports/drywater" \
  "/mnt/mmc/ports/drywater" \
  "/mnt/sdcard/ports/drywater" \
  "/mnt/SDCARD/ports/drywater" \
  "/roms/ports/drywater" \
  "/roms2/ports/drywater"
do
  if [ -d "$candidate" ]; then
    GAMEDIR="$candidate"
    break
  fi
done

if [ -z "$GAMEDIR" ]; then
  echo "FATAL: could not locate the drywater game folder."
  echo "Tried: /$directory/ports/drywater /mnt/mmc/ports/drywater"
  echo "       /mnt/sdcard/ports/drywater /mnt/SDCARD/ports/drywater"
  echo "       /roms/ports/drywater /roms2/ports/drywater"
  echo "On muOS the game folder belongs in /ports/, and this script in /roms/PORTS/."
  sleep 5
  exit 1
fi

CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR"

# --- version handshake (Sprint 45 Phase 3) -----------------------------------
# This shell updates automatically via PortMaster; drywater.pck updates
# manually via itch, on the player's own schedule. Those two clocks WILL
# drift, and a mismatch used to fail looking like a crash with no clue why.
# EXPECTED_PCK_VERSION is stamped by execution/build-portmaster.ps1 to the
# exact version this shell shipped paired with, so a mismatch here means the
# player is missing a step, not that anything is broken.
EXPECTED_PCK_VERSION="1.4.1"
INSTALLED_PCK_VERSION="$(cat "$GAMEDIR/VERSION" 2>/dev/null)"
if [ -n "$INSTALLED_PCK_VERSION" ] && [ "$INSTALLED_PCK_VERSION" != "$EXPECTED_PCK_VERSION" ]; then
  echo "Your Drywater game data is v$INSTALLED_PCK_VERSION — this port needs v$EXPECTED_PCK_VERSION."
  echo "Re-download drywater.pck from https://rcadden.itch.io/drywater"
  sleep 10
  exit 1
fi

# DEBUG SWITCH (bug #14, 2026-07-30). Set DRYWATER_DEBUG=1 in the environment
# (or edit this line) to re-enable the bring-up diagnostics: the environment
# report, the SDL mapping dump, and the post-exit probe log. They default OFF
# because they were written for first-boot debugging and then shipped to
# players, who get no value from them.
#
# Everything on the FAILURE paths below stays unconditional. A port that dies
# silently is the thing this script exists to prevent — the diagnostics being
# quiet is not the same as the errors being quiet.
DRYWATER_DEBUG="${DRYWATER_DEBUG:-0}"

# Truncate the probe log so each run's diagnostics stand alone.
rm -f "$CONFDIR/godot/app_userdata/Drywater/input_probe.log"

cd "$GAMEDIR" || exit 1

# Everything below is captured. First-boot failures on a handheld are otherwise
# invisible — the screen returns to the menu with no explanation.
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Godot writes user:// (saves, config) under XDG_DATA_HOME. Pointing it at the
# port's own conf/ keeps saves with the port instead of loose in $HOME.
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# pm_platform_helper is NOT called.
#
# It had been pointed at $GAMEDIR/drywater.arm64 — a leftover from the
# self-contained build — so it was a silent no-op against a missing file for
# every run that worked. Repointing it at the live runtime binary coincided
# with the process aborting on "double free or corruption", so it is the other
# suspect alongside the early joypad query. Since it demonstrably did nothing
# on every successful launch so far, the safe move is not to call it at all.
# Revisit only if a device-specific tweak turns out to be missing.

# --- runtimes ----------------------------------------------------------------
# muOS provides NEITHER X11 NOR Wayland. A stock Godot 4 Linux binary tries X11,
# falls back to Wayland, and dies:
#   ERROR: Can't load XCursor dynamically.
#   WARNING: Can't load the Wayland client library.
#   ERROR: Unable to create DisplayServer, all display drivers failed.
# Westonpack supplies that missing display environment, so it is mandatory here,
# not optional.
#
# And because weston is needed regardless, this port uses PortMaster's shared
# Godot runtime rather than shipping its own binary: godot_4.6.3 matches this
# project's engine exactly. That runtime's binary also accepts --main-pack,
# which release export templates reject.
GODOT_RUNTIME="godot_4.6.3.${DEVICE_ARCH}"
WESTON_RUNTIME="weston_pkg_0.2.${DEVICE_ARCH}"

for rt in "$GODOT_RUNTIME" "$WESTON_RUNTIME"; do
  if [ ! -f "$controlfolder/libs/${rt}.squashfs" ]; then
    echo "Runtime ${rt}.squashfs missing — asking harbourmaster to fetch it."
    $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${rt}.squashfs" 2>&1
  fi
  if [ ! -f "$controlfolder/libs/${rt}.squashfs" ]; then
    echo "FATAL: ${rt}.squashfs is not installed and could not be downloaded."
    echo "Download it from https://portmaster.games/runtimes.html and place it in:"
    echo "  $controlfolder/libs/"
    sleep 10
    exit 1
  fi
done

godot_dir="/tmp/godot_drywater"
weston_dir="/tmp/weston_drywater"
$ESUDO mkdir -p "$godot_dir" "$weston_dir"
$ESUDO umount "$godot_dir" 2>/dev/null || true
$ESUDO umount "$weston_dir" 2>/dev/null || true
$ESUDO mount "$controlfolder/libs/${GODOT_RUNTIME}.squashfs"  "$godot_dir"
$ESUDO mount "$controlfolder/libs/${WESTON_RUNTIME}.squashfs" "$weston_dir"

# The runtime's binary name is not documented consistently across versions
# (godot422.aarch64, godot463.aarch64, ...), so discover it rather than guess.
GODOT_BIN="$(ls "$godot_dir"/godot* 2>/dev/null | head -n1)"

# --- environment report ------------------------------------------------------
# Bring-up on a handheld is blind without this, and the first attempt died on an
# unset $weston_dir expanding to "/westonwrap.sh". Gated behind DRYWATER_DEBUG
# since 2026-07-30 (bug #14) — it was printing unconditionally for every player.
if [ "$DRYWATER_DEBUG" = "1" ]; then
  echo "--- drywater environment ---"
  echo "CFW_NAME       : ${CFW_NAME:-<unset>}"
  echo "DEVICE_ARCH    : ${DEVICE_ARCH:-<unset>}"
  echo "directory      : ${directory:-<unset>}"
  echo "controlfolder  : ${controlfolder:-<unset>}"
  echo "GAMEDIR        : $GAMEDIR"
  echo "DISPLAY        : ${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
  echo "weston_dir     : ${weston_dir:-<unset>}"
  echo "ESUDO          : ${ESUDO:-<unset>}"
  echo "godot_dir      : $godot_dir"
  echo "GODOT_BIN      : ${GODOT_BIN:-<not found>}"
  echo "--- controlfolder/libs ---"
  ls -1 "$controlfolder/libs" 2>/dev/null | head -40 || echo "(cannot list)"
  echo "--- godot runtime contents ---"
  ls -1 "$godot_dir" 2>/dev/null | head -20 || echo "(cannot list)"
fi

WESTONWRAP="$weston_dir/westonwrap.sh"

if [ -z "$GODOT_BIN" ] || [ ! -f "$GODOT_BIN" ]; then
  echo "FATAL: no godot binary found inside the mounted runtime at $godot_dir."
  # Print the listing here even when diagnostics are off — on THIS path it is
  # the whole diagnosis, not background noise.
  echo "--- godot runtime contents ---"
  ls -1 "$godot_dir" 2>/dev/null | head -20 || echo "(cannot list)"
  echo "Re-run with DRYWATER_DEBUG=1 for the full environment report."
  sleep 10
  exit 1
fi

if [ ! -f "$WESTONWRAP" ]; then
  echo "FATAL: westonwrap.sh not found at $WESTONWRAP after mounting the runtime."
  echo "muOS provides no X11 or Wayland, so there is no usable fallback —"
  echo "a direct launch fails with 'Unable to create DisplayServer'."
  sleep 10
  exit 1
fi

$ESUDO chmod +x "$GODOT_BIN" 2>/dev/null || true

if [ "$DRYWATER_DEBUG" = "1" ]; then
  echo "--- SDL controller mapping supplied by PortMaster ---"
  echo "${SDL_GAMECONTROLLERCONFIG:-<unset>}"
fi

# RAW JOYPAD MODE — set to 1 to suppress SDL's controller mapping.
#
# WHY. PortMaster supplies a mapping named "Deeplay-keys", and the device
# confirms SDL is applying it (Input.is_joy_known() == true). Two consequences,
# both measured on an RG35XX-H:
#
#   1. It is WRONG. It declares a:b3, but that button is physically X. Every
#      binding written against SDL's nominal layout lands somewhere arbitrary.
#   2. It HIDES buttons. When a mapping is applied, SDL reports only the
#      buttons that mapping names and discards the rest — which is why
#      physical A, B and Y produced no events of any kind.
#
# With both variables cleared, SDL treats the pad as a generic joystick and
# passes every button through with its true raw index. The d-pad (a hat) and
# the analog sticks (axes 0-3) are handled natively by Godot either way.
DRYWATER_RAW_JOYPAD=1

if [ "$DRYWATER_RAW_JOYPAD" = "1" ]; then
  SDL_MAP_ARG="SDL_GAMECONTROLLERCONFIG="
  SDL_MAPFILE_ARG="SDL_GAMECONTROLLERCONFIG_FILE="
  echo "--- raw joypad mode: SDL mapping suppressed ---"
else
  SDL_MAP_ARG="SDL_GAMECONTROLLERCONFIG=$sdl_controllerconfig"
  SDL_MAPFILE_ARG="SDL_GAMECONTROLLERCONFIG_FILE=$SDL_GAMECONTROLLERCONFIG_FILE"
  echo "--- using PortMaster's SDL mapping ---"
fi

# SPRINT 44 PHASE 3 - THE FRAMERATE READOUT. Set DRYWATER_SHOW_FPS=1 (here, or
# in the environment) to boot with the on-screen fps/min/light-count overlay.
#
# THIS IS THE MECHANISM FOR THE PHASE 3 MEASUREMENT, and it is an env var
# rather than a button on purpose. The gamepad layout is bound to RAW indices
# and is only correct while DRYWATER_RAW_JOYPAD=1 above suppresses SDL mapping;
# the only unclaimed indices are the stick-clicks, which this hardware may not
# even have. An env var needs no buttons and cannot be mis-guessed from a
# machine that has none of this hardware. On the desk, F3 toggles it instead.
#
# ⚠️ BACK TO 0 (2026-09-02). THE MEASUREMENT SESSION IS OVER.
#
# The note below explains why it was temporarily 1 and is kept because it is the
# reasoning, not because it is current. Set DRYWATER_SHOW_FPS=1 in the
# environment for another measurement run; the default is now what a player gets.
#
# ⚠️ IT ALSO MATTERS TO BUG #70. All five recorded occurrences of that crash are
# in builds carrying PerfReadout with this switch ON, and it was first filed the
# day that autoload was introduced. If the instrument is the cause, a default of
# 0 means no player build was ever affected — which is exactly what a normal
# play session on this default is meant to find out.
#
# PREVIOUSLY (2026-09-01), AND SUPERSEDED:
#
# It shipped defaulting to 0, which meant the one build cut specifically to
# take the Phase 3 measurement booted with the instrument silent. Ricky loaded
# it, saw no overlay, and the trip was wasted. A tool that is off by default is
# off for the person who needed it.
#
# The PortMaster build currently goes to Ricky and to named testers only, and
# the whole visual-quality arc is under a release hold, so nothing public sees
# this.
#
# >>> FLIP THIS BACK TO 0 BEFORE SPRINT 45 (PortMaster Distribution) SHIPS. <<<
# That sprint puts the port in front of a paying public. Set DRYWATER_SHOW_FPS=0
# in the environment to override without editing this file.
# BUG #71 A/B ARM — set DRYWATER_NO_NORMALS=1 to run with the orientation
# channel switched off (sprites light flat-facing-viewer, the documented
# no-map behaviour, so nothing breaks visually beyond losing the shading).
#
# WHY: the handheld measured 60fps with no fire lit and 14fps with one, then
# FLAT at 14 for two, three and four. The scene is already lit at 60 - the
# day/night sun is a DirectionalLight2D that is always on - so the first
# PointLight2D switches something on. Either the light pass itself, or
# per-pixel normal-mapped lighting. Those lead to opposite decisions about
# Phase 4, and this switch is what tells them apart.
#
# Run the same eight-fire walk-down twice, once with 0 and once with 1. If
# the framerate comes back with normals off, the orientation channel is the
# cost. The perf log prints which arm it is running.
# BUG #71 SECOND ARM — set DRYWATER_NO_POINT_LIGHTS=1 to build fires with no
# PointLight2D at all. Warmth is unaffected: survival reads the fire's warmth
# curve, never its light, so this changes how the game LOOKS and never how it
# plays. Use it to judge whether firelight is worth ~85% of the framerate on
# this hardware - that decision has not been made.
DRYWATER_NO_POINT_LIGHTS="${DRYWATER_NO_POINT_LIGHTS:-0}"
echo "--- point lights disabled: $DRYWATER_NO_POINT_LIGHTS ---"

# SPRINT 44 - WHICH MECHANISM DRAWS THE FIRE'S GLOW.
#
#   none    (default HERE, and only here) no glow at all.
#   light             the real PointLight2D - the default everywhere else.
#   sprite            an additive stand-in. NOT cheaper; kept as a third option.
#
# MEASURED ON THE RG35XX-H, one fire burning:
#     no fire at all ......  57-60 fps
#     glow = none .........  35-38 fps   <- this default
#     glow = sprite .......  11.6 fps
#     glow = light ........  12.0 fps
#
# The glow costs ~24fps WHICHEVER WAY IT IS DRAWN, so the expense is painting a
# large translucent circle over the scene, not the light object. That makes this
# a hardware call rather than a taste one: 12fps is unplayable and 35 is not.
#
# THIS FILE IS THE HANDHELD-ONLY SURFACE. Nothing else ships it, so the default
# here reaches exactly the hardware that needs it - phones and desktops keep
# real firelight with no platform sniffing in game code.
#
# WARMTH IS UNAFFECTED BY ALL THREE. Survival reads the fire's warmth curve and
# never its light, so this changes how the game LOOKS and never how it plays.
#
# DRYWATER_NO_POINT_LIGHTS=1 above still wins over this and still means "none";
# it is the fallback lever and a lever that could be overridden is not a lever.
DRYWATER_FIRE_GLOW="${DRYWATER_FIRE_GLOW:-none}"
echo "--- fire glow: $DRYWATER_FIRE_GLOW ---"

DRYWATER_NO_NORMALS="${DRYWATER_NO_NORMALS:-0}"
echo "--- normal maps disabled: $DRYWATER_NO_NORMALS ---"

DRYWATER_SHOW_FPS="${DRYWATER_SHOW_FPS:-0}"
echo "--- fps readout: $DRYWATER_SHOW_FPS ---"

# BUG #70 ARM - set DRYWATER_MALLOC_CHECK=1 to run the game under glibc's own
# heap checker.
#
# WHY THIS AND NOT MORE GODOT LOGGING: the abort message is
# `double free or corruption (!prev)`, which is glibc reporting that the heap
# METADATA around a block was already wrong when free() went to touch it. free()
# is where glibc VALIDATES; it is not necessarily where the damage was done. So
# "both crashes happened while freeing something" is a statement about when the
# check runs, not about what is guilty - and no amount of instrumenting the
# teardown paths can distinguish the two.
#
# MALLOC_CHECK_=3 makes glibc validate on EVERY malloc and free and abort at the
# first inconsistency instead of at the next unlucky free. MALLOC_PERTURB_ fills
# freed memory with a poison byte, so a use-after-free reads garbage loudly
# rather than reading plausible stale data. Between them:
#
#   - aborts EARLIER, nearer the real corruption
#   - a true double free is named as such
#   - if it stops reproducing entirely, that is itself a result: timing-
#     sensitive, which points at the allocator under pressure rather than at a
#     specific call site
#
# COST: malloc gets meaningfully slower, so DO NOT take a framerate measurement
# in this arm. It is a crash-hunting arm and nothing else. Default 0.
DRYWATER_MALLOC_CHECK="${DRYWATER_MALLOC_CHECK:-0}"
if [ "$DRYWATER_MALLOC_CHECK" = "1" ]; then
  MALLOC_ARGS="MALLOC_CHECK_=3 MALLOC_PERTURB_=165"
  echo "--- glibc heap checking ON (framerate is INVALID in this arm) ---"
else
  MALLOC_ARGS="MALLOC_CHECK_=0"
fi

# --main-pack IS valid here. It was rejected by the release export template
# ("compiled without support for path overrides"), but the PortMaster runtime
# binary is built with overrides enabled — that is the whole mechanism by which
# every Godot port loads its .pck.
# BUG #70 REPRODUCER - set DRYWATER_SOAK=1 to drive the two operations the crash
# has actually landed in, on a loop, instead of waiting for ordinary play to
# wander into them.
#
# It teleports the player back and forth across four chunks (wider than
# UNLOAD_DISTANCE, so every cycle forces real evictions) and builds+frees six
# Fires per cycle. Run 2 aborted on the first eviction; run 3 aborted while
# demolishing a fire. Those are the two.
#
# WHY IT IS AN ENV VAR AND NOT A DEBUG SCENARIO: DebugBootstrap does not stage
# on a release build - s44_lighting_lights could not, which is why the eight
# fires had to be built by hand - and the crash has only ever been seen on a
# release build.
#
# COST: the game is unplayable while this runs and every framerate number taken
# during it is meaningless. Pair it with DRYWATER_MALLOC_CHECK=1 and read the
# log. The heartbeat prints a cycle count; the LAST line before the abort is the
# evidence, so note whether that number repeats across runs. Default 0.
DRYWATER_SOAK="${DRYWATER_SOAK:-0}"
echo "--- crash soak: $DRYWATER_SOAK ---"

echo "LAUNCH: $GODOT_BIN via $WESTONWRAP"
$ESUDO env "$WESTONWRAP" headless noop kiosk crusty_x11egl \
  XDG_DATA_HOME="$CONFDIR" \
  DRYWATER_SHOW_FPS="$DRYWATER_SHOW_FPS" \
  DRYWATER_NO_NORMALS="$DRYWATER_NO_NORMALS" \
  DRYWATER_NO_POINT_LIGHTS="$DRYWATER_NO_POINT_LIGHTS" \
  DRYWATER_FIRE_GLOW="$DRYWATER_FIRE_GLOW" \
  $MALLOC_ARGS \
  DRYWATER_SOAK="$DRYWATER_SOAK" \
  "$SDL_MAP_ARG" \
  "$SDL_MAPFILE_ARG" \
  "$GODOT_BIN" \
  --main-pack "$GAMEDIR/drywater.pck" \
  --resolution "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" \
  --rendering-driver opengl3_es \
  --audio-driver ALSA

status=$?
echo "--- exited with status $status ---"

# The game writes input diagnostics to user://input_probe.log, which with
# XDG_DATA_HOME pointed at CONFDIR resolves to the path below. Echoed here so
# everything needed is in one file, and because it SURVIVES A CRASH — the
# previous run aborted and took all buffered stdout with it.
#
# Note the game only writes that file in DEBUG builds now (bug #14), so on a
# release .pck this block finds nothing even with DRYWATER_DEBUG=1 — you need a
# debug export to get the probe back.
if [ "$DRYWATER_DEBUG" = "1" ]; then
  PROBE_LOG="$CONFDIR/godot/app_userdata/Drywater/input_probe.log"
  echo "--- input probe ($PROBE_LOG) ---"
  if [ -f "$PROBE_LOG" ]; then
    cat "$PROBE_LOG"
  else
    echo "(no probe log written — release build, or the game died before reaching it)"
  fi
fi

$ESUDO umount "$godot_dir" 2>/dev/null || true
$ESUDO umount "$weston_dir" 2>/dev/null || true

# KEEP A PER-ARM COPY OF THE LOG (bug #71 A/B).
#
# log.txt is TRUNCATED on every launch (the redirect near the top), so
# running the A arm then the B arm would destroy the A result.
#
# ⚠️ THIS MUST STAY AT THE END OF THE SCRIPT, AND THAT IS NOT A STYLE
# PREFERENCE. The first version of this line was anchored on the $ESUDO
# umount pair — which appears TWICE, and the first occurrence is in the
# SETUP block. It therefore copied the PREVIOUS session log, before
# DRYWATER_NO_NORMALS was even assigned, producing one file named
# "perf-normals.txt" with no arm digit and last run's contents. Anchor on
# something unique, and put teardown in the teardown.
# ⚠️ THE NAME MUST CARRY EVERY ARM, NOT JUST ONE (corrected 2026-09-02).
# It was keyed on DRYWATER_NO_NORMALS alone, which was right while that was the
# only thing being varied. The four-arm session varies GLOW, SOAK and
# MALLOC_CHECK and does NOT vary normals — so all four runs would have written
# "perf-normals0.txt" and clobbered each other, which is the exact failure this
# copy exists to prevent. Key it on the whole arm.
ARM_TAG="glow-$DRYWATER_FIRE_GLOW-n$DRYWATER_NO_NORMALS-soak$DRYWATER_SOAK-mc$DRYWATER_MALLOC_CHECK"
cp "$GAMEDIR/log.txt" "$GAMEDIR/perf-$ARM_TAG.txt" 2>/dev/null || true
echo "--- kept a copy at $GAMEDIR/perf-$ARM_TAG.txt ---"

pm_finish
