#!/bin/bash

set -e

GAMEDIR="$(cd "${0%/*}/.." && pwd)"
RUNTIME="$GAMEDIR/decompiler-cache"
RUNTIME_7Z="$GAMEDIR/patch/decompiler.7z"
BUILD="$GAMEDIR/build"
GAMEDATA="$GAMEDIR/gamedata"
STATE="$GAMEDIR/.patch_state"
PATCHLOG="$GAMEDIR/patchlog.txt"

EXE_STD="FiveNightsatFreddys4.exe"
EXE_HE="FiveNightsatFreddys4 HalloweenEdition.exe"

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
    PATCHLOG="/tmp/fnaf4_patchlog_$$.txt"
fi
cleanup() {
    if [ -n "$PATCHLOG_FINAL" ] && [ -f "$PATCHLOG" ]; then
        while IFS= read -r line; do echo "$line"; done < "$PATCHLOG" > "$PATCHLOG_FINAL" 2>/dev/null
        rm -f "$PATCHLOG"
    fi
}
trap cleanup EXIT
trap 'kill 0 2>/dev/null; exit 1' HUP INT TERM

> "$PATCHLOG"
exec > >(tee -a "$PATCHLOG") 2>&1

log() { echo "$*" >> "$PATCHLOG"; }

fail() {
    echo ""
    echo "ERROR: $1"
    log "FATAL: $1"
    echo ""
    echo "Build failed! Check ${PATCHLOG_FINAL:-$PATCHLOG} for details."
    exit 1
}

step_done() { [ -f "$STATE/$1" ] && [ ! "$2" -nt "$STATE/$1" ]; }
mark_done() { : > "$STATE/$1"; }

remove_guides_dir() {
    if [ "$1" = std ]; then
        rm -rf "$GAMEDIR/patch/guides"
    else
        rm -rf "$GAMEDIR/patch/guides_he"
    fi
}

remove_game_exe() {
    if [ "$1" = std ]; then
        rm -f "$GAMEDIR/gamedata/FiveNightsatFreddys4.exe"
    else
        rm -f "$GAMEDIR/gamedata/FiveNightsatFreddys4 HalloweenEdition.exe"
    fi
}

SEVENZIP="${controlfolder}/7zzs.${DEVICE_ARCH:-aarch64}"
if [ ! -x "$SEVENZIP" ]; then
    fail "7zzs not found at $SEVENZIP (PortMaster needs to provide this)"
fi
if [ ! -f "$RUNTIME_7Z" ]; then
    fail "decompiler.7z not found in $GAMEDIR/patch"
fi

HAVE_STD=0; HAVE_HE=0
if [ -f "$GAMEDATA/$EXE_STD" ] && [ ! -f "$GAMEDATA/.patched_std" ]; then HAVE_STD=1; fi
if [ -f "$GAMEDATA/$EXE_HE" ]  && [ ! -f "$GAMEDATA/.patched_he" ];  then HAVE_HE=1;  fi

WANT=""
case "${FNAF4_VERSION:-auto}" in
    both)
        if [ "$HAVE_STD" = 1 ]; then WANT="std"; fi
        if [ "$HAVE_HE" = 1 ];  then WANT="$WANT he"; fi
        ;;
    std) if [ "$HAVE_STD" = 1 ]; then WANT="std"; fi ;;
    he)  if [ "$HAVE_HE" = 1 ];  then WANT="he"; fi ;;
    *)
        if   [ "$HAVE_STD" = 1 ]; then WANT="std"
        elif [ "$HAVE_HE" = 1 ];  then WANT="he"
        fi
        ;;
esac
WANT="${WANT# }"
log "Version choice: ${FNAF4_VERSION:-auto} -> '${WANT}'"

if [ -z "$WANT" ]; then
    fail "No unpatched FNaF4 exe found in gamedata/ ($EXE_STD or $EXE_HE)"
fi

if step_done "runtime_extract" "$RUNTIME_7Z" && [ -x "$RUNTIME/bin/chowdren-build" ]; then
    echo "Runtime already extracted. OK"
else
    echo "Extracting decompiler..."
    rm -rf "$GAMEDIR/decompiler-cache"
    mkdir -p "$RUNTIME"
    "$SEVENZIP" x "$RUNTIME_7Z" -o"$RUNTIME" -y >> "$PATCHLOG" 2>&1 \
        || fail "Could not extract decompiler.7z"
    mark_done "runtime_extract"
fi

export PYTHONDONTWRITEBYTECODE=1

eval "$("$GAMEDIR/patch/detect_hw.bash")"
export CHOWDREN_WORKERS
export CHOWDREN_MAKE_JOBS

echo "=== Five Nights at Freddy's 4 - build ($WANT) ==="
echo "Device: ${DEVICE_CPU:-unknown} / ${DEVICE_RAM:-?}GB RAM"
echo "Memory tier: $MEM_TIER  (workers=$CHOWDREN_WORKERS, compile jobs=$CHOWDREN_MAKE_JOBS)"
echo ""

build_edition() {
    local ed="$1" exe_name guides_name title
    if [ "$ed" = std ]; then
        exe_name="$EXE_STD";  guides_name="guides";    title="Five Nights at Freddy's 4"
    else
        exe_name="$EXE_HE";   guides_name="guides_he"; title="Five Nights at Freddy's 4 Halloween Edition"
    fi

    local game_exe="$GAMEDATA/$exe_name"
    local outdir="$GAMEDIR/fnaf4_$ed"
    local guides_7z="$GAMEDIR/patch/$guides_name.7z"
    local guides_dir="$GAMEDIR/patch/$guides_name"

    if [ ! -f "$game_exe" ]; then
        fail "$exe_name not found in gamedata/"
    fi

    echo "=== [$ed] Step 1/2: Converting + compiling ($title) ==="

    unset CHOWDREN_GUIDES_DIR
    if [ -f "$guides_7z" ]; then
        if step_done "guides_$ed" "$guides_7z" && [ -d "$guides_dir" ]; then
            echo "Guides already extracted. OK"
        else
            echo "Extracting ASTC guides..."
            remove_guides_dir "$ed"
            "$SEVENZIP" x "$guides_7z" -o"$GAMEDIR/patch" -y >> "$PATCHLOG" 2>&1 \
                || fail "Could not extract $guides_name.7z"
            mark_done "guides_$ed"
        fi
    fi
    if [ -d "$guides_dir" ]; then
        export CHOWDREN_GUIDES_DIR="$guides_dir"
    fi

    if step_done "build_${ed}_${MEM_TIER}" "$game_exe" && [ -x "$BUILD/Chowdren" ]; then
        echo "Already built for this tier and game file. OK"
    else
        export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        export LDFLAGS="-Wl,-rpath-link,$GAMEDIR/libs.aarch64 $LDFLAGS"

        "$RUNTIME/bin/chowdren-build" \
            --game-dir "$GAMEDIR" \
            --exe "$exe_name" \
            --title "$title" \
            --no-launch \
            || fail "chowdren-build failed ($ed)"
        mark_done "build_${ed}_${MEM_TIER}"
    fi

    if [ ! -x "$BUILD/Chowdren" ]; then
        fail "Build finished but binary not found at $BUILD/Chowdren ($ed)"
    fi

    echo ""
    echo "=== [$ed] Step 2/2: Moving output ==="

    mkdir -p "$outdir"
    mv "$GAMEDIR/build/Chowdren"   "$outdir/Chowdren"   || $ESUDO mv "$GAMEDIR/build/Chowdren"   "$outdir/Chowdren"   || fail "Failed to move Chowdren binary ($ed)"
    mv "$GAMEDIR/build/Assets.dat" "$outdir/Assets.dat" || $ESUDO mv "$GAMEDIR/build/Assets.dat" "$outdir/Assets.dat" || fail "Failed to move Assets.dat ($ed)"

    rm -rf "$GAMEDIR/build"
    mkdir -p "$BUILD"
    remove_guides_dir "$ed"
    remove_game_exe "$ed"
    : > "$GAMEDATA/.patched_$ed"

    log "[$ed] done"
    echo "[$ed] complete. OK"
    echo ""
}

for ed in $WANT; do
    build_edition "$ed"
done

rm -rf "$GAMEDIR/decompiler-cache"
rm -rf "$GAMEDIR/build"
rm -rf "$GAMEDIR/.patch_state"

if [ -f "$GAMEDATA/.patched_std" ] && [ -f "$GAMEDATA/.patched_he" ]; then

    rm -f "$GAMEDIR/patch/decompiler.7z"
    rm -f "$GAMEDIR/patch/guides.7z"
    rm -f "$GAMEDIR/patch/guides_he.7z"
    echo "Both editions built, installer files removed."
else

    echo "Kept decompiler.7z so another edition can be added later."
fi

echo "Cleanup complete. OK"
echo ""
echo "Build complete. OK"

: > "$GAMEDIR/.patch_ok"
