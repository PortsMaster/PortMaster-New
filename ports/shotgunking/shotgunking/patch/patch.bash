#!/bin/bash
#
# Shotgun King install-time patch.
#
# Applies a small, idempotent mutation to code.lua inside data.sgr so the
# game's simulation tempo stays consistent with the developer's 60 Hz target
# on handhelds that render below that rate.
#
# Versioning: patch/version holds the current revision string. After a
# successful apply it's written to gamedata/.patched. On each run we:
#   1. If .patched matches $WANT_VERSION → nothing to do
#   2. Else, if $SGR.orig exists → restore it (covers partial previous runs
#      where .patched never got written)
#   3. Extract, mutate code.lua, repack, warm cache, stamp .patched
#
# The mutation uses awk landmark-matching and is idempotent — re-running
# against already-patched input is a no-op (we detect the sentinel comment
# and skip).
#
# Called by PortMaster's patcher.txt framework.

set -e

GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
SGR="$GAMEDIR/gamedata/shotgun_king.app/Contents/MacOS/data.sgr"
TOOLS="$GAMEDIR/tools"
PATCHDIR="$GAMEDIR/patch"
TMPDIR="$GAMEDIR/.patch_tmp"
PATCHLOG="$GAMEDIR/patchlog.txt"
STAMP="$GAMEDIR/gamedata/.patched"

# Throttle dirty page cache to prevent FUSE OOM on devices like TrimUI Smart
# Pro: the kernel can buffer more dirty data than the FUSE daemon can flush,
# starving it of memory when we repack an 82 MB data.sgr back out. Must run
# BEFORE we open the tee-to-log pipe or start any I/O, or the FUSE backlog
# can deadlock the pipeline.
throttle_writes() {
    if [ -w /proc/sys/vm/dirty_ratio ]; then
        ORIG_DIRTY_RATIO=$(cat /proc/sys/vm/dirty_ratio)
        ORIG_DIRTY_BG_RATIO=$(cat /proc/sys/vm/dirty_background_ratio)
        echo 5 > /proc/sys/vm/dirty_ratio
        echo 3 > /proc/sys/vm/dirty_background_ratio
    fi
}

restore_writes() {
    if [ -n "$ORIG_DIRTY_RATIO" ] && [ -w /proc/sys/vm/dirty_ratio ]; then
        echo "$ORIG_DIRTY_RATIO" > /proc/sys/vm/dirty_ratio
        echo "$ORIG_DIRTY_BG_RATIO" > /proc/sys/vm/dirty_background_ratio
    fi
}

cleanup() {
    restore_writes
    rm -rf "$TMPDIR"
}
trap cleanup EXIT
# Kill the whole process group on signal so the tee subshell doesn't linger
# holding the log pipe open after a ctrl-C / launcher timeout.
trap 'kill 0 2>/dev/null; exit 1' HUP INT TERM

throttle_writes

> "$PATCHLOG"
# Only our own `echo` status lines go through tee → UI. Bulk tool output is
# redirected directly to the log file at each call site so we can't deadlock
# the pipeline if the FUSE daemon stalls mid-write.
exec > >(tee -a "$PATCHLOG") 2>&1

VERSION_FILE="$PATCHDIR/version"
if [ ! -f "$VERSION_FILE" ]; then
    echo "patch version file missing at $VERSION_FILE"
    exit 1
fi
# Stick count is baked into the effective version so that moving the SD
# card between a 0-, 1-, or 2-stick device triggers a re-patch (the
# ONE-STICK / DPAD-AIM mutations are gated on stick count below). Launch
# script composes the same suffix when deciding whether to invoke the
# patcher — if these two formulas drift apart, the launcher sees stamp
# != want every boot and loops the patcher forever.
WANT_VERSION="$(cat "$VERSION_FILE").s${ANALOGSTICKS:-x}"

if [ -f "$STAMP" ]; then
    HAVE_VERSION="$(cat "$STAMP")"
    if [ "$HAVE_VERSION" = "$WANT_VERSION" ]; then
        echo "Patch already applied (v$HAVE_VERSION)"
        exit 0
    fi
    echo "Patch out of date (have v$HAVE_VERSION, want v$WANT_VERSION) — refreshing"
fi

# Partial-install recovery: if a previous run moved the pristine .sgr aside
# but failed before stamping (e.g. warmup crashed), the current $SGR on disk
# is the ALREADY-PATCHED one. Restoring from .orig gets us back to pristine
# so we always patch from a known-good base.
if [ -f "$SGR.orig" ]; then
    echo "Restoring pristine data.sgr from backup"
    mv -f "$SGR.orig" "$SGR"
fi

if [ ! -f "$SGR" ]; then
    echo "Game data not found"
    exit 1
fi

echo "Preparing game data..."
rm -rf "$TMPDIR"
"$TOOLS/sgr_extract" "$SGR" "$TMPDIR" >>"$PATCHLOG" 2>&1

# ------------------------------------------------------------------
# Apply the auto-pace mutation to code.lua.
#
# The game's main update runs `lp()` (sim tick) a variable number of times
# based on the `fst` (fast) flag. At 60 fps render, fst=1 and sim tempo
# matches. Below 60 fps render, sim tempo slows visibly. We insert a small
# block that sets `fst` to round(dt * 60) capped at 5, so sim ticks scale
# with real elapsed time.
#
# Landmark: line `\tlocal fst=fast` (unique in code.lua). Insert the block
# immediately after it. Idempotent — skipped if the sentinel "AUTO-PACE" is
# already present.
# ------------------------------------------------------------------
echo "Applying patch..."
CODE="$TMPDIR/code.lua"
if grep -q "AUTO-PACE" "$CODE"; then
    echo "  code.lua already patched — skipping mutation"
else
    # code.lua ships with CRLF line endings (Windows-built). Strip \r up
    # front so the landmark regex matches on any awk (busybox/mawk/gawk);
    # Lua is line-ending-agnostic so emitting LF-only is fine.
    tr -d '\r' < "$CODE" | awk '
    {
        print
        if (!done && /^\tlocal fst=fast$/) {
            print ""
            print "\t-- AUTO-PACE: lp() is sim-only (no drawing), so when render fps drops"
            print "\t-- below 60 we run extra sim ticks to keep game tempo consistent with"
            print "\t-- the developer'"'"'s 60 Hz target. dt() returns real wall-clock seconds"
            print "\t-- since the last _update. dt*60 = how many 60 Hz ticks the last frame"
            print "\t-- covered; at 30 fps render that'"'"'s 2, at 20 fps it'"'"'s 3, etc."
            print "\t-- Capped at 5 to survive one-off hitches (GC pauses, loading stalls)"
            print "\t-- without spiraling."
            print "\tif not fst then"
            print "\t\tlocal want=flr(dt()*60+0.5)"
            print "\t\tif want>1 then fst=min(want,5) end"
            print "\tend"
            done = 1
        }
    }
    END {
        if (!done) {
            print "ERROR: landmark not found in code.lua" > "/dev/stderr"
            exit 1
        }
    }
    ' > "$CODE.new"
    mv "$CODE.new" "$CODE"
    # Post-check
    if ! grep -q "AUTO-PACE" "$CODE"; then
        echo "  auto-pace insert failed — landmark 'local fst=fast' not found"
        exit 1
    fi
fi

# ------------------------------------------------------------------
# Apply the one-stick aim mutation to code/gamepad.lua.
#
# The shotgun is aimed with the right analog stick only. On single-stick
# handhelds (RG40xx-v etc.) the player has no way to aim. We fold the
# physical left stick into the aim vector so any lstick deflection drives
# aim. Dpad still drives move_ctrl from its own path, so movement is
# unaffected.
#
# The game's existing "leftStickX+/-" logical buttons are bound to BOTH
# c:lstick:* AND c:dpad:* (see INPUT_ASSIGNEMENT), so reading those would
# let the dpad trigger aim mode. We define lsxp/lsxn/lsyp/lsyn bound to
# only c:lstick:* via a lazy defbtn at the aim site, and read those.
#
# Only applied on single-stick devices ($ANALOGSTICKS = 1). On 2-stick
# devices the right stick already aims natively; on 0-stick devices the
# DPAD-AIM Lua patch below handles aim instead.
#
# Idempotent — sentinel "ONE-STICK".
# ------------------------------------------------------------------
GAMEPAD="$TMPDIR/code/gamepad.lua"
if [ ! -f "$GAMEPAD" ]; then
    echo "  code/gamepad.lua missing from extracted .sgr"
    exit 1
fi
if [ "$ANALOGSTICKS" != "1" ]; then
    echo "  code/gamepad.lua: skipping one-stick mutation (ANALOGSTICKS=${ANALOGSTICKS:-unset})"
elif grep -q "ONE-STICK" "$GAMEPAD"; then
    echo "  code/gamepad.lua already patched — skipping mutation"
else
    tr -d '\r' < "$GAMEPAD" | awk '
    {
        print
        if (!done && /^\t\t\t\tlocal normR = sqrt\(smoothAim/) {
            print "\t\t\t\t"
            print "\t\t\t\t-- ONE-STICK: fold the physical left stick into aim so single-stick"
            print "\t\t\t\t-- handhelds (RG40xx-v etc.) can aim. The default leftStickX+/- buttons"
            print "\t\t\t\t-- are dpad-merged, so we lazy-bind lsxp/lsxn/lsyp/lsyn to JUST c:lstick:*"
            print "\t\t\t\t-- and read those — dpad presses leave _Lx/_Ly at zero so movement is"
            print "\t\t\t\t-- unaffected."
            print "\t\t\t\tif not _ONE_STICK_INIT then"
            print "\t\t\t\t\tdefbtn(\"lsxp\", 0, \"c:lstick:right\")"
            print "\t\t\t\t\tdefbtn(\"lsxn\", 0, \"c:lstick:left\")"
            print "\t\t\t\t\tdefbtn(\"lsyp\", 0, \"c:lstick:down\")"
            print "\t\t\t\t\tdefbtn(\"lsyn\", 0, \"c:lstick:up\")"
            print "\t\t\t\t\t_ONE_STICK_INIT = true"
            print "\t\t\t\tend"
            print "\t\t\t\tlocal _Lx = btnv(\"lsxp\") - btnv(\"lsxn\")"
            print "\t\t\t\tlocal _Ly = btnv(\"lsyp\") - btnv(\"lsyn\")"
            print "\t\t\t\tif _Lx ~= 0 or _Ly ~= 0 then"
            print "\t\t\t\t\tlocal _xm = (btnv(\"rightStickX+\") - btnv(\"rightStickX-\")) + _Lx"
            print "\t\t\t\t\tlocal _ym = (btnv(\"rightStickY+\") - btnv(\"rightStickY-\")) + _Ly"
            print "\t\t\t\t\tlocal _nm = sqrt(_xm*_xm + _ym*_ym)"
            print "\t\t\t\t\tif _nm > 1 then _xm, _ym = _xm/_nm, _ym/_nm end"
            print "\t\t\t\t\tsmoothAim.x = lerp(smoothAim.x, _xm, 0.5)"
            print "\t\t\t\t\tsmoothAim.y = lerp(smoothAim.y, _ym, 0.5)"
            print "\t\t\t\t\tnormR = sqrt(smoothAim.x*smoothAim.x + smoothAim.y*smoothAim.y)"
            print "\t\t\t\t\tnormL = 0"
            print "\t\t\t\tend"
            done = 1
        }
    }
    END {
        if (!done) {
            print "ERROR: landmark not found in code/gamepad.lua" > "/dev/stderr"
            exit 1
        }
    }
    ' > "$GAMEPAD.new"
    mv "$GAMEPAD.new" "$GAMEPAD"
    if ! grep -q "ONE-STICK" "$GAMEPAD"; then
        echo "  one-stick insert failed — landmark 'local normR = sqrt(smoothAim' not found"
        exit 1
    fi
fi

# ------------------------------------------------------------------
# Apply the dpad-aim patch.
#
# On dpad-only handhelds (no analog sticks at all) neither rstick aim nor
# the existing ONE-STICK lstick fold work. Hold L2 + dpad L/R rotates the
# aim direction like clock hands; releasing L2 returns to normal movement.
# Dpad U/D do nothing while L2 is held.
#
# The bulk of the logic lives in patch/dpad_aim.lua (clean Lua source, no
# awk-escaping) which we inject as a new entry into the .sgr archive. We
# then add a one-line require to code.lua and a one-line tick call to
# code/gamepad.lua. The new file's btn() override globally suppresses
# unsafe→wild semantics once dpad-aim has been used during the current
# L2-hold (reset on next L2 press) — stick controllers are unaffected.
#
# Only applied on stickless devices ($ANALOGSTICKS = 0). On 2-stick
# devices the rstick aims natively; on 1-stick devices ONE-STICK above
# folds the lstick into aim. Applying DPAD-AIM on stick devices would
# steal L2+dpad from movement and is not wanted.
#
# Idempotent — sentinel "DPAD-AIM" in the inserted lines and the manifest
# entry presence check.
# ------------------------------------------------------------------
if [ "$ANALOGSTICKS" != "0" ]; then
    echo "  skipping dpad-aim mutation (ANALOGSTICKS=${ANALOGSTICKS:-unset})"
else
DPAD_AIM_SRC="$PATCHDIR/dpad_aim.lua"
DPAD_AIM_DST="$TMPDIR/code/dpad_aim.lua"
MANIFEST="$TMPDIR/.sgr_manifest"
if [ ! -f "$DPAD_AIM_SRC" ]; then
    echo "  patch/dpad_aim.lua missing"
    exit 1
fi
cp -f "$DPAD_AIM_SRC" "$DPAD_AIM_DST"

# Append manifest entry if not already present.
if ! grep -q $'^ENTRY\t0\tcode/dpad_aim.lua$' "$MANIFEST"; then
    printf 'ENTRY\t0\tcode/dpad_aim.lua\n' >> "$MANIFEST"
fi

# Insert require line into code.lua right after the existing
# require("code/gamepad.lua") line. Sentinel: "DPAD-AIM-REQUIRE".
if grep -q "DPAD-AIM-REQUIRE" "$CODE"; then
    echo "  code.lua require already present — skipping"
else
    tr -d '\r' < "$CODE" | awk '
    {
        print
        if (!done && /^require\("code\/gamepad\.lua"\)$/) {
            print "require(\"code/dpad_aim.lua\")  -- DPAD-AIM-REQUIRE"
            done = 1
        }
    }
    END {
        if (!done) {
            print "ERROR: require landmark not found in code.lua" > "/dev/stderr"
            exit 1
        }
    }
    ' > "$CODE.new"
    mv "$CODE.new" "$CODE"
    if ! grep -q "DPAD-AIM-REQUIRE" "$CODE"; then
        echo "  dpad-aim require insert failed"
        exit 1
    fi
fi

# Insert tick call into code/gamepad.lua right after the smoothAim.y lerp.
# Sentinel: the trailing "-- DPAD-AIM" comment on the inserted line.
if grep -q "DPAD-AIM" "$GAMEPAD"; then
    # ONE-STICK doesn't write "DPAD-AIM"; safe to rely on this sentinel.
    echo "  code/gamepad.lua dpad-aim tick already present — skipping"
else
    tr -d '\r' < "$GAMEPAD" | awk '
    {
        print
        if (!done && /^\t\t\t\tsmoothAim\.y = lerp\(smoothAim\.y, yR, 0\.5\)$/) {
            print "\t\t\t\txL, yL = dpad_aim_tick(xL, yL)  -- DPAD-AIM"
            done = 1
        }
    }
    END {
        if (!done) {
            print "ERROR: smoothAim.y lerp landmark not found in code/gamepad.lua" > "/dev/stderr"
            exit 1
        }
    }
    ' > "$GAMEPAD.new"
    mv "$GAMEPAD.new" "$GAMEPAD"
    if ! grep -q "DPAD-AIM" "$GAMEPAD"; then
        echo "  dpad-aim tick insert failed"
        exit 1
    fi
fi
fi  # ANALOGSTICKS == 0

# Pre-seed the lang files into SDL's PrefPath. Sugar's file() stats the
# bundle path to confirm existence but then always opens from PrefPath —
# so every non-English lang file fails unless it's been copied there.
# safe_english.txt is the only one that's pre-populated by the engine
# itself, which is why English renders but nothing else does. Doing this
# at install time rather than game-launch time keeps the launcher lean.
PREFPATH="$GAMEDIR/userdata/PUNKCAKE Delicieux/Shotgun King - The Final Checkmate"
LANGDIR="$GAMEDIR/gamedata/shotgun_king.app/Contents/MacOS/lang"
if [ -d "$LANGDIR" ]; then
    mkdir -p "$PREFPATH/lang"
    cp -f "$LANGDIR"/*.txt "$PREFPATH/lang/" 2>>"$PATCHLOG"
fi

echo "Finalizing..."
"$TOOLS/sgr_repack" "$TMPDIR" "$SGR.new" >>"$PATCHLOG" 2>&1

mv "$SGR" "$SGR.orig"
mv "$SGR.new" "$SGR"

# Pre-populate the PCM cache so first real launch doesn't pay the OGG decode
# cost mid-boot. oggdec decodes each music file to raw S16 stereo PCM; the
# pcm_cache_write tool builds the SGPC cache file using per-file metadata
# (sample_t snapshot + expected pcm_bytes) from the shipped manifest — which
# was generated once on the dev host from a real engine-produced cache.
# Non-fatal on any failure: runtime fallback still decodes lazily.
CACHE_META="$PATCHDIR/cache_meta.txt"
CACHEDIR="$GAMEDIR/gamedata/shotgun_king.app/Contents/MacOS/.machismo-pcm-cache"
if [ -f "$CACHE_META" ] && [ -x "$TOOLS/oggdec" ] && [ -x "$TOOLS/pcm_cache_write" ]; then
    echo "Pre-populating audio cache..."
    mkdir -p "$CACHEDIR"
    warmed=0
    failed=0
    while read -r key freq pcm_bytes ogg_fn sample_t_hex; do
        case "$key" in '' | '#'*) continue ;; esac
        ogg_path="$TMPDIR/assets/music/$ogg_fn"
        out_path="$CACHEDIR/$key.pcm"
        if [ ! -f "$ogg_path" ]; then
            echo "  $ogg_fn: source missing, skipping" >>"$PATCHLOG"
            failed=$((failed + 1))
            continue
        fi
        if "$TOOLS/oggdec" --raw --quiet -o - "$ogg_path" 2>>"$PATCHLOG" |
           "$TOOLS/pcm_cache_write" "$out_path" "$freq" "$pcm_bytes" "$sample_t_hex" 2>>"$PATCHLOG"
        then
            warmed=$((warmed + 1))
        else
            echo "  $ogg_fn: build failed" >>"$PATCHLOG"
            failed=$((failed + 1))
        fi
    done < "$CACHE_META"
    if [ $failed -eq 0 ]; then
        echo "Audio cache populated ($warmed files)"
    else
        echo "Audio cache: $warmed ok, $failed failed — first boot of failed tracks will decode lazily"
    fi
else
    echo "Audio cache pre-population skipped (missing tool or manifest)"
fi

printf '%s' "$WANT_VERSION" > "$STAMP"
echo "Patch applied (v$WANT_VERSION)"
