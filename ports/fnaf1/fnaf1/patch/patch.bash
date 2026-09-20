#!/bin/bash

set -e

GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME="$GAMEDIR/chowdren-runtime"                  # mount point (empty folder)
RUNTIME_SQUASH="$GAMEDIR/chowdren-runtime.squashfs"  # the runtime image shipped in the port
BUILD="$GAMEDIR/build"
GAMEDATA="$GAMEDIR/gamedata"
STATE="$BUILD/.patch_state"
PATCHLOG="$GAMEDIR/patchlog.txt"

mkdir -p "$BUILD" "$STATE"

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
set +e
source "$controlfolder/control.txt"
set -e

PATCHLOG_FINAL=""
if [ "${CFW_NAME,,}" = "knulli" ] && [ -d /tmp ]; then
    PATCHLOG_FINAL="$PATCHLOG"
    PATCHLOG="/tmp/fnaf1_patchlog_$$.txt"
fi
cleanup() {
    if [ -n "$PATCHLOG_FINAL" ] && [ -f "$PATCHLOG" ]; then
        cp "$PATCHLOG" "$PATCHLOG_FINAL" 2>/dev/null
        rm -f "$PATCHLOG"
    fi
    # Make sure the runtime image is never left mounted
    $ESUDO umount "$RUNTIME" 2>/dev/null || true
}
trap cleanup EXIT
trap 'kill 0 2>/dev/null; exit 1' HUP INT TERM

> "$PATCHLOG"
exec > >(tee -a "$PATCHLOG") 2>&1

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$PATCHLOG"; }

fail() {
    echo ""
    echo "ERROR: $1"
    log "FATAL: $1"
    echo ""
    echo "Build failed! Check ${PATCHLOG_FINAL:-$PATCHLOG} for details."
    exit 1
}

step_done() { [ -f "$STATE/$1" ] && [ "$(cat "$STATE/$1")" = "$2" ]; }
mark_done() { echo "$2" > "$STATE/$1"; }

# --- mount the chowdren runtime image ---------------------------------------
if [ ! -f "$RUNTIME_SQUASH" ]; then
    fail "chowdren-runtime.squashfs not found in $GAMEDIR"
fi
$ESUDO mkdir -p "$RUNTIME"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "$RUNTIME" 2>/dev/null || true
fi
$ESUDO mount "$RUNTIME_SQUASH" "$RUNTIME" || fail "Could not mount chowdren-runtime.squashfs"
# the image is read-only, so don't let python try to write .pyc files into it
export PYTHONDONTWRITEBYTECODE=1

eval "$("$GAMEDIR/patch/detect_hw.bash")"
export CHOWDREN_WORKERS
export CHOWDREN_MAKE_JOBS

echo "=== Five Nights at Freddy's - build ==="
echo "Device: ${DEVICE_CPU:-unknown} / ${DEVICE_RAM:-?}GB RAM"
echo "Memory tier: $MEM_TIER  (workers=$CHOWDREN_WORKERS, compile jobs=$CHOWDREN_MAKE_JOBS)"
echo ""

GAME_EXE="$GAMEDATA/FiveNightsatFreddys.exe"
if [ ! -f "$GAME_EXE" ]; then
    fail "FiveNightsatFreddys.exe not found in gamedata/"
fi

EXE_STAMP=$(stat -c '%Y-%s' "$GAME_EXE" 2>/dev/null || echo "unknown")
BUILD_KEY="${MEM_TIER}-${EXE_STAMP}"

echo "=== Step 1/2: Converting + compiling ==="
if step_done "build" "$BUILD_KEY"; then
    echo "Already built for this tier and game file. OK"
else

    "$RUNTIME/bin/chowdren-build" \
        --game-dir "$GAMEDIR" \
        --exe FiveNightsatFreddys.exe \
        --title "Five Nights at Freddy's" \
        --no-launch \
        || fail "chowdren-build failed"
    mark_done "build" "$BUILD_KEY"
fi

if [ ! -x "$BUILD/Chowdren" ]; then
    fail "Build finished but binary not found at $BUILD/Chowdren"
fi

echo ""
echo "=== Step 2/2: Cleaning up directory ==="

mv "$BUILD/Chowdren" "$GAMEDIR/Chowdren" || $ESUDO mv "$BUILD/Chowdren" "$GAMEDIR/Chowdren" || fail "Failed to move Chowdren binary"
mv "$BUILD/Assets.dat" "$GAMEDIR/Assets.dat" || $ESUDO mv "$BUILD/Assets.dat" "$GAMEDIR/Assets.dat" || fail "Failed to move Assets.dat"
$ESUDO rm -rf "$BUILD"
$ESUDO umount "$RUNTIME" || true
$ESUDO rm -f "$RUNTIME_SQUASH"
$ESUDO rmdir "$RUNTIME" 2>/dev/null || true
$ESUDO rm -f "$GAME_EXE"
touch "$GAMEDATA/.patched_complete"
echo "Cleanup complete. OK"
echo ""
echo "Build complete. OK"
