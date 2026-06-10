#!/bin/bash
# Mina the Hollower — PortMaster install-time setup.
#
# On first run this script unpacks the user's game bundle from a GOG macOS .pkg
# installer or a Steam Mac depot (a pre-copied .app bundle is used as-is), then
# generates the shader corpora.
#
# The port ships no game-derived data. On first run (and after a port update
# that bumps patch/corpus.version) this script regenerates the shader corpora
# from the USER'S OWN game copy — both encodings in one airlift pass:
#
#   gamedata/Mina the Hollower.app/Contents/Resources/data/shaders.pak.yc
#     │  tools/ycd_extract        (YCD container → per-shader .metallib)
#     ▼
#   117 Metal shader libraries
#     │  tools/airlift build      (AIR bitcode → SPIR-V, then GLSL ES 3.10 with
#     ▼  --spv-out                 Mali workaround markers stamped)
#   gamedata/shaders_spv/         (114 × .spv  + .refl.json)  ← Vulkan (preferred)
#   gamedata/shaders_gles/        (114 × .glsl + .refl.json)  ← GLES fallback
#
# Runs in seconds even on an RK3326. Called by the PortMaster patcher UI.

# --- PortMaster environment ---
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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

set -o pipefail

# --- Configuration ---
GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS="$GAMEDIR/tools"
GAMEDATA="$GAMEDIR/gamedata"
PATCHLOG="$GAMEDIR/patchlog.txt"
CORPUS_VERSION="$(cat "$GAMEDIR/patch/corpus.version")"

# Expected corpus shape — the guard against a wrong game version or an
# unmarked corpus (which renders fine on most GPUs but silently breaks the
# region-clip / composite passes on Mali devices).
# Clip markers = 8 cutteranim (hard, discard stripped) + 6 font (soft, discard
# retained — AIRLIFT_CLIP_VIA_SCISSOR_SOFT, the batched-clipped-text fix); the
# grep counts both since _SOFT is a superset of the AIRLIFT_CLIP_VIA_SCISSOR token.
# Coverage markers = 18 font frags whose per-glyph coverage discard was stripped
# (AIRLIFT_FONT_COVERAGE_OVER, the Modifiers-menu frozen-text fix — sparse text empties
# whole Mali tiles; premult over-blend keeps the image without the all-discard lock).
EXPECT_METALLIBS=117
EXPECT_SHADERS=114
EXPECT_CLIP_MARKERS=14
EXPECT_OVER_MARKERS=8
EXPECT_COVERAGE_MARKERS=18

# Intermediates in tmpfs: only the final ~1MB corpus copy touches the SD card.
if [ -d /dev/shm ]; then
    TMP="/dev/shm/mina_patch_$$"
else
    TMP="$GAMEDATA/.patch_tmp"
fi
# Throttle dirty page cache to prevent FUSE OOM on KNULLI-class firmware where
# /userdata is FUSE-backed exFAT: the kernel can buffer more dirty data than the
# FUSE daemon can flush, starving it of memory when we stream a multi-GB GOG .pkg
# to disk and move the .app bundle across the card. Must run BEFORE we open the
# tee-to-log pipe or start any I/O, or the FUSE backlog can deadlock the pipeline.
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

cleanup() { restore_writes; rm -rf "$TMP"; }
trap cleanup EXIT
trap 'kill 0 2>/dev/null; exit 1' HUP INT TERM

throttle_writes

exec > >(tee "$PATCHLOG") 2>&1

fail() {
    echo ""
    echo "PATCHING FAILED: $1"
    exit 1
}

echo "Mina the Hollower setup (corpus version $CORPUS_VERSION)"
echo ""

# --- Acquire the game bundle (GOG .pkg installer or Steam Mac depot) ---
# The port ships no game data. The user supplies it as a GOG macOS .pkg
# installer, a Steam Mac depot folder, or a pre-copied .app bundle. If a bundle
# is already installed at the top level of gamedata we skip straight to shaders.

# Plain shell glob, not find: BusyBox find (KNULLI/ArkOS) lacks -mindepth/
# -maxdepth/-quit, so the find form errored out on those firmwares.
INSTALLED_APP=""
for d in "$GAMEDATA"/*.app; do
    if [ -d "$d" ] && [ -f "$d/Contents/MacOS/MinaTheHollower" ]; then
        INSTALLED_APP="$d"
        break
    fi
done

if [ -z "$INSTALLED_APP" ]; then
    # Locate PortMaster's static 7z (same one the NecroDancer port uses).
    SEVENZIP=""
    if [ -n "$controlfolder" ] && [ -x "${controlfolder}/7zzs.aarch64" ]; then
        SEVENZIP="${controlfolder}/7zzs.aarch64"
    fi
    # We bundle GNU cpio because BusyBox cpio can't handle the odc format macOS
    # .pkg payloads use.
    CPIO="$TOOLS/cpio"

    # extract_pkg <pkg> <outdir>: stream the macOS .pkg payload
    # (xar -> gunzip -> cpio) with no intermediate disk writes. Sets
    # EXTRACTED_PAYLOAD to the resolved payload directory.
    extract_pkg() {
        local PKG="$1" OUTDIR="$2"
        rm -rf "$OUTDIR"; mkdir -p "$OUTDIR"
        echo "  Extracting game files (this can take several minutes)..."
        "$SEVENZIP" e -so "$PKG" "package.pkg/Scripts" 2>>"$PATCHLOG" \
            | gunzip 2>>"$PATCHLOG" \
            | (cd "$OUTDIR" && "$CPIO" -idmu --no-absolute-filenames 2>>"$PATCHLOG")
        local PS=(${PIPESTATUS[@]})
        if [ "${PS[0]}" -ne 0 ] || [ "${PS[2]}" -ne 0 ]; then
            fail "Extraction pipeline failed (7z=${PS[0]} gunzip=${PS[1]} cpio=${PS[2]}). See patchlog.txt"
        fi
        if [ -d "$OUTDIR/payload" ]; then
            EXTRACTED_PAYLOAD="$OUTDIR/payload"
        else
            EXTRACTED_PAYLOAD="$OUTDIR"
        fi
        [ -d "$EXTRACTED_PAYLOAD" ] && [ -n "$(ls -A "$EXTRACTED_PAYLOAD" 2>/dev/null)" ] || \
            fail "Extraction of $(basename "$PKG") produced no files. See patchlog.txt"
    }

    GOG_PKG="$(ls "$GAMEDATA"/*.pkg 2>/dev/null | head -1)"

    if [ -n "$GOG_PKG" ]; then
        # --- GOG: extract the macOS .pkg installer ---
        echo "=== Extracting GOG installer: $(basename "$GOG_PKG") ==="
        [ -n "$SEVENZIP" ] || \
            fail "7zzs not found. Please upgrade to the latest version of PortMaster."
        OUTDIR="$GAMEDATA/.extracted"
        extract_pkg "$GOG_PKG" "$OUTDIR"

        SRC_APP=""
        for d in "$EXTRACTED_PAYLOAD"/*.app; do
            [ -d "$d" ] && { SRC_APP="$d"; break; }
        done
        [ -n "$SRC_APP" ] || { rm -rf "$OUTDIR"; fail "No .app bundle found in the GOG payload."; }
        echo "  Installing $(basename "$SRC_APP")..."
        rm -rf "$GAMEDATA/$(basename "$SRC_APP")"
        mv "$SRC_APP" "$GAMEDATA/"

        # Preserve goggame-*.info for GOG Galaxy ownership checks (harmless if absent).
        if ls "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info >/dev/null 2>&1; then
            mkdir -p "$GAMEDATA/Contents/Resources"
            cp -f "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info "$GAMEDATA/Contents/Resources/"
        fi

        rm -rf "$OUTDIR"
        rm -f "$GOG_PKG"
        echo "  GOG extraction complete."
    else
        # --- Steam depot (or a user-nested copy): move the bundle to the top level ---
        NESTED_APP=""
        for d in "$GAMEDATA"/*/*.app; do
            if [ -d "$d" ] && [ -f "$d/Contents/MacOS/MinaTheHollower" ]; then
                NESTED_APP="$d"
                break
            fi
        done
        if [ -n "$NESTED_APP" ]; then
            echo "=== Installing bundle: $(basename "$NESTED_APP") ==="
            rm -rf "$GAMEDATA/$(basename "$NESTED_APP")"
            mv "$NESTED_APP" "$GAMEDATA/"
            rm -rf "$GAMEDATA"/depot_*
            echo "  Bundle installed."
        else
            fail "No game files found. Copy your 'Mina the Hollower.app' (Apple Silicon macOS build), a GOG .pkg installer, or a Steam Mac depot folder into the gamedata folder."
        fi
    fi
fi

# --- Locate the user's app bundle ---
APP="$GAMEDATA/Mina the Hollower.app"
if [ ! -d "$APP" ]; then
    APP=""
    for d in "$GAMEDATA"/*.app "$GAMEDATA"/*/*.app; do
        [ -d "$d" ] && { APP="$d"; break; }
    done
fi
[ -n "$APP" ] && [ -d "$APP" ] || \
    fail "No .app bundle found. Copy your 'Mina the Hollower.app' (Apple Silicon macOS version) into the gamedata folder."

PAK="$APP/Contents/Resources/data/shaders.pak.yc"
[ -s "$PAK" ] || \
    fail "shaders.pak.yc not found inside '$APP'. The .app copy is incomplete — re-copy the whole app bundle, including Contents/Resources/data."

echo "Using game shaders: $PAK"

# --- Tool sanity (catches wrong-arch / too-old-firmware exec failures) ---
"$TOOLS/ycd_extract" >/dev/null 2>&1
[ $? -ge 126 ] && fail "ycd_extract cannot run on this device/firmware."
"$TOOLS/airlift" >/dev/null 2>&1
[ $? -ge 126 ] && fail "airlift cannot run on this device/firmware (needs a recent CFW; ArkOS support requires the release build)."

# --- Disk space (the corpus is ~1MB; 50MB is a generous safety margin) ---
FREE_KB=$(df -k "$GAMEDATA" | tail -1 | awk '{print $4}')
[ "$FREE_KB" -ge 51200 ] || fail "Less than 50MB free on the ports partition."

# --- Extract the Metal shader libraries from the user's pak ---
mkdir -p "$TMP"
"$TOOLS/ycd_extract" "$PAK" "$TMP/metallibs" || \
    fail "Could not read shaders.pak.yc — corrupt copy or unsupported game version."
N_MLIB=$(ls "$TMP/metallibs"/*.metallib 2>/dev/null | wc -l)
[ "$N_MLIB" -eq "$EXPECT_METALLIBS" ] || \
    fail "Expected $EXPECT_METALLIBS shader libraries, found $N_MLIB — unsupported game version?"

# --- Lift to GLSL ES (+ raw SPIR-V) ---
# One airlift pass emits both corpora: GLSL ES 3.10 for the GLES fallback and
# raw SPIR-V (+ matching reflections) for the Vulkan backend, which
# libgothic_patches auto-prefers on the new-libmali fleet. Same translation, two
# encodings — keep them in lockstep so a backend switch never sees a stale corpus.
"$TOOLS/airlift" build "$TMP/metallibs" "$TMP/shaders_gles" --spv-out "$TMP/shaders_spv" || \
    fail "Shader translation failed (see patchlog.txt)."

N_GLSL=$(ls "$TMP/shaders_gles"/*.glsl 2>/dev/null | wc -l)
N_REFL=$(ls "$TMP/shaders_gles"/*.refl.json 2>/dev/null | wc -l)
N_CLIP=$(grep -l AIRLIFT_CLIP_VIA_SCISSOR "$TMP/shaders_gles"/*.glsl 2>/dev/null | wc -l)
N_OVER=$(grep -l AIRLIFT_COMPOSITE_OVER "$TMP/shaders_gles"/*.glsl 2>/dev/null | wc -l)
N_COV=$(grep -l AIRLIFT_FONT_COVERAGE_OVER "$TMP/shaders_gles"/*.glsl 2>/dev/null | wc -l)
N_SPV=$(ls "$TMP/shaders_spv"/*.spv 2>/dev/null | wc -l)
N_SPV_REFL=$(ls "$TMP/shaders_spv"/*.refl.json 2>/dev/null | wc -l)
echo "Corpus: $N_GLSL GLSL ES + $N_SPV SPIR-V shaders, $N_REFL reflections, $N_CLIP clip + $N_OVER composite + $N_COV coverage markers"
[ "$N_GLSL" -eq "$EXPECT_SHADERS" ] && [ "$N_REFL" -eq "$EXPECT_SHADERS" ] && \
[ "$N_SPV" -eq "$EXPECT_SHADERS" ] && [ "$N_SPV_REFL" -eq "$EXPECT_SHADERS" ] && \
[ "$N_CLIP" -eq "$EXPECT_CLIP_MARKERS" ] && [ "$N_OVER" -eq "$EXPECT_OVER_MARKERS" ] && \
[ "$N_COV" -eq "$EXPECT_COVERAGE_MARKERS" ] || \
    fail "Generated corpus doesn't match the expected shape — unsupported game version?"

# --- Install (no symlinks, near-atomic: exFAT/FUSE-safe) ---
rm -rf "$GAMEDATA/shaders_gles.new" "$GAMEDATA/shaders_gles"
cp -r "$TMP/shaders_gles" "$GAMEDATA/shaders_gles.new" || fail "Copy to SD card failed."
mv "$GAMEDATA/shaders_gles.new" "$GAMEDATA/shaders_gles"

rm -rf "$GAMEDATA/shaders_spv.new" "$GAMEDATA/shaders_spv"
cp -r "$TMP/shaders_spv" "$GAMEDATA/shaders_spv.new" || fail "Copy to SD card failed."
mv "$GAMEDATA/shaders_spv.new" "$GAMEDATA/shaders_spv"

echo "$CORPUS_VERSION" > "$GAMEDATA/.shaders_ready"
echo ""
echo "Shader setup complete."
exit 0
