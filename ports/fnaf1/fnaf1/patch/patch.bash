#!/bin/bash

set -e

GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME="$GAMEDIR/decompiler-cache"
RUNTIME_7Z="$GAMEDIR/patch/decompiler.7z"
GUIDES_DIR="$GAMEDIR/patch/guides"
GUIDES_7Z="$GAMEDIR/patch/guides.7z"
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

SEVENZIP="${controlfolder}/7zzs.${DEVICE_ARCH:-aarch64}"
if [ ! -x "$SEVENZIP" ]; then
    fail "7zzs not found at $SEVENZIP (PortMaster needs to provide this)"
fi
if [ ! -f "$RUNTIME_7Z" ]; then
    fail "decompiler.7z not found in $GAMEDIR/patch"
fi

RUNTIME_STAMP=$(stat -c '%Y-%s' "$RUNTIME_7Z" 2>/dev/null || echo "unknown")
if step_done "runtime_extract" "$RUNTIME_STAMP"; then
    echo "Runtime already extracted. OK"
else
    echo "Extracting decompiler..."
    rm -rf "$GAMEDIR/decompiler-cache"
    mkdir -p "$RUNTIME"
    "$SEVENZIP" x "$RUNTIME_7Z" -o"$RUNTIME" -y >> "$PATCHLOG" 2>&1 \
        || fail "Could not extract decompiler.7z"
    mark_done "runtime_extract" "$RUNTIME_STAMP"
fi

export PYTHONDONTWRITEBYTECODE=1

if [ -f "$GUIDES_7Z" ]; then
    GUIDES_STAMP=$(stat -c '%Y-%s' "$GUIDES_7Z" 2>/dev/null || echo "unknown")
    if step_done "guides_extract" "$GUIDES_STAMP"; then
        echo "Guides already extracted. OK"
    else
        echo "Extracting ASTC guides..."
        rm -rf "$GAMEDIR/patch/guides"
        mkdir -p "$GUIDES_DIR"
        "$SEVENZIP" x "$GUIDES_7Z" -o"$GAMEDIR/patch" -y >> "$PATCHLOG" 2>&1 \
            || fail "Could not extract guides.7z"
        mark_done "guides_extract" "$GUIDES_STAMP"
    fi
fi
if [ -d "$GUIDES_DIR" ]; then
    export CHOWDREN_GUIDES_DIR="$GUIDES_DIR"
fi

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

    export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export LDFLAGS="-Wl,-rpath-link,$GAMEDIR/libs.aarch64 $LDFLAGS"

    "$RUNTIME/bin/chowdren-build" \
        --game-dir "$GAMEDIR" \
        --exe FiveNightsatFreddys.exe \
        --title "Five Nights at Freddy's" \
        --no-launch \
        || fail "chowdren-build failed"
    mark_done "build" "$BUILD_KEY"
fi

if [ ! -x "$GAMEDIR/build/Chowdren" ]; then
    fail "Build finished but binary not found at $GAMEDIR/build/Chowdren"
fi

echo ""
echo "=== Step 2/2: Cleaning up directory ==="

mv "$GAMEDIR/build/Chowdren" "$GAMEDIR/Chowdren" || $ESUDO mv "$GAMEDIR/build/Chowdren" "$GAMEDIR/Chowdren" || fail "Failed to move Chowdren binary"
mv "$GAMEDIR/build/Assets.dat" "$GAMEDIR/Assets.dat" || $ESUDO mv "$GAMEDIR/build/Assets.dat" "$GAMEDIR/Assets.dat" || fail "Failed to move Assets.dat"
rm -rf "$GAMEDIR/build"
rm -rf "$GAMEDIR/decompiler-cache"
rm -f "$GAMEDIR/patch/decompiler.7z"
rm -rf "$GAMEDIR/patch/guides"
rm -f "$GAMEDIR/patch/guides.7z"
rm -f "$GAMEDIR/gamedata/FiveNightsatFreddys.exe"
touch "$GAMEDIR/gamedata/.patched_complete"
echo "Cleanup complete. OK"
echo ""
echo "Build complete. OK"
