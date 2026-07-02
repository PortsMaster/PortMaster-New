#!/bin/bash
# Nuclear Blaze PortMaster Patch Script
#
# Patches Nuclear Blaze for handheld Linux devices:
#   1. Bytecode patching (GLES, steam stubs, string fixes)
#   2. Aseprite sprite decode → ASTC compression
#   3. Font/image PNG → ASTC compression
#   4. Asset repacking
#
# Called by PortMaster patcher UI.

set -e

# --- Paths ---

GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS="$GAMEDIR/tools"
LIBS="$GAMEDIR/libs.aarch64"
GAMEDATA="$GAMEDIR/gamedata"
STATE="$GAMEDATA/.patch_state"
PATCHLOG="$GAMEDIR/patchlog.txt"

# Use tmpfs for intermediate files when available
if [ -d /dev/shm ]; then
    TMP="/dev/shm/nb_patch_$$"
else
    TMP="$GAMEDATA/.patch_tmp"
fi
mkdir -p "$TMP"

cleanup() {
    rm -rf "$TMP"
}
trap cleanup EXIT
trap 'kill 0 2>/dev/null; exit 1' HUP INT TERM

# --- Version markers ---
# Bump these to force a step to re-run on devices with stale markers.

V_COMPILE="5"          # Step 2: hl-substitute + nb-patch-all + hl2llvm
V_PAK_EXTRACT="1"
V_OGG="1"
V_ASEDECODE="1"
V_ASTC="2"            # ASTC output moved from launch/astc to astc
V_PAK_REPACK="1"

# --- Helpers ---

step_done() {
    local marker="$STATE/$1"
    [ -f "$marker" ] && [ "$(cat "$marker")" = "$2" ]
}

mark_done() {
    mkdir -p "$STATE"
    echo "$2" > "$STATE/$1"
}

fail() {
    echo "FATAL: $1" | tee -a "$PATCHLOG"
    exit 1
}

EXTRACTED="$GAMEDATA/res_extracted"

# --- Step 1: Verify input files ---

echo "=== Nuclear Blaze Patcher ==="
echo ""

[ -f "$GAMEDATA/hlboot.dat" ] || fail "hlboot.dat not found in gamedata/"
[ -f "$GAMEDATA/res.pak" ] || fail "res.pak not found in gamedata/"

# Detect variant: Steam bytecode references "?steam" native library, itch does not
if grep -q '?steam' "$GAMEDATA/hlboot.dat"; then
    NB_VARIANT="steam"
else
    NB_VARIANT="itch"
fi
echo "$NB_VARIANT" > "$GAMEDATA/.nb_variant"
echo "Detected variant: $NB_VARIANT"

# --- Step 2: Bytecode patching ---

if step_done "compile" "$V_COMPILE"; then
    echo "Step 2: Bytecode patching... already done. OK"
else
    echo "Step 2: Bytecode patching..."

    # Backup original bytecode if not already backed up
    [ -f "$GAMEDATA/hlboot.dat.orig" ] || cp "$GAMEDATA/hlboot.dat" "$GAMEDATA/hlboot.dat.orig"

    ORIG="$GAMEDATA/hlboot.dat.orig"
    SUBSTITUTED="$TMP/nuclear_blaze_substituted.hl"
    PATCHED="$TMP/nuclear_blaze_patched.hl"

    # Phase 1: Haxe function substitution
    "$TOOLS/hl-substitute" "$ORIG" "$TOOLS/nb_patches.hl" -o "$SUBSTITUTED" \
        "h3d.impl.\$$GlDriver.__constructor__" \
        "h3d.impl.GlDriver.resetStream" \
        "hxd.\$$Window.__constructor__" \
        "aseprite.res.Aseprite.toAseprite" \
        "dn.heaps.\$$Scaler.bestFit_f" \
        2>>"$PATCHLOG" || fail "hl-substitute failed"

    # Phase 2: Bytecode patches (steam stubs, debug annotations, string fixes)
    "$TOOLS/nb-patch-all" "$SUBSTITUTED" "$PATCHED" \
        2>>"$PATCHLOG" || fail "nb-patch-all failed"

    # Save patched bytecode for AOT compilation
    cp "$PATCHED" "$GAMEDATA/hlboot.dat"
    rm -f "$SUBSTITUTED"

    echo "Compiling game to native code..."
    echo "(This is the longest step, please wait)"
    rm -rf "$TMP/nuclearblaze" "$TMP/nuclearblaze.d"

    OBJ_DIR="$TMP/nuclearblaze.d"

    # Run hl2llvm in background so we can monitor progress
    LD_LIBRARY_PATH="$LIBS:$LD_LIBRARY_PATH" \
    "$TOOLS/hl2llvm" \
        --batch -O3 \
        --inline-threshold=5000 \
        --fast-math \
        --mcpu=cortex-a35 \
        --threads=2 \
        --link \
        -L "$LIBS" \
        "$PATCHED" \
        -o "$TMP/nuclearblaze" >> "$PATCHLOG" 2>&1 &
    HL2LLVM_PID=$!

    # Monitor batch .o files for progress
    # ~47 batches for Nuclear Blaze, then a link phase
    EST_BATCHES=47
    LAST_COUNT=0
    while kill -0 $HL2LLVM_PID 2>/dev/null; do
        if [ -d "$OBJ_DIR" ]; then
            COUNT=$(ls "$OBJ_DIR"/batch.*.o 2>/dev/null | wc -l)
            if [ "$COUNT" -gt "$LAST_COUNT" ]; then
                PCT=$((COUNT * 90 / EST_BATCHES))
                [ "$PCT" -gt 90 ] && PCT=90
                echo "  Compiling... ${PCT}%"
                LAST_COUNT=$COUNT
            fi
        fi
        sleep 2
    done

    set +e
    wait $HL2LLVM_PID
    HL2LLVM_EXIT=$?
    set -e
    if [ $HL2LLVM_EXIT -ne 0 ]; then
        fail "hl2llvm compilation failed (exit code $HL2LLVM_EXIT)"
    fi

    chmod +x "$TMP/nuclearblaze"
    mv "$TMP/nuclearblaze" "$GAMEDATA/nuclearblaze"
    rm -rf "$TMP/nuclearblaze.d"
    rm -f "$PATCHED"

    mark_done "compile" "$V_COMPILE"
    echo "Step 2: Compile... OK"
fi

# --- Step 3: Unpack res.pak ---

if step_done "pak_extract" "$V_PAK_EXTRACT"; then
    echo "Step 3: Unpack res.pak... already done. OK"
else
    echo "Step 3: Unpack res.pak..."

    # Backup original if not already backed up
    [ -f "$GAMEDATA/res.pak.orig" ] || cp "$GAMEDATA/res.pak" "$GAMEDATA/res.pak.orig"

    rm -rf "$EXTRACTED"
    "$TOOLS/hl-paktool" unpack "$GAMEDATA/res.pak.orig" -o "$EXTRACTED" \
        2>>"$PATCHLOG" || fail "hl-paktool unpack failed"

    mark_done "pak_extract" "$V_PAK_EXTRACT"
    echo "Step 3: Unpack res.pak... OK"
fi

# --- Step 4: Optimize audio (OGG downsample to 96kbps mono) ---

if step_done "ogg_done" "$V_OGG"; then
    echo "Step 4: Optimize audio... already done. OK"
else
    echo "Step 4: Optimize audio..."

    OGG_WORKLIST="$TMP/ogg_worklist.txt"
    find "$EXTRACTED" -name "*.ogg" -type f -size +50k > "$OGG_WORKLIST"
    OGG_TOTAL=$(wc -l < "$OGG_WORKLIST")

    if [ "$OGG_TOTAL" -eq 0 ]; then
        echo "  No OGG files to optimize."
    else
        echo "  Optimizing $OGG_TOTAL audio files (96kbps mono)..."

        OGG_PROGRESS="$TMP/ogg_progress"
        OGG_FAILURES="$TMP/ogg_failures"
        echo 0 > "$OGG_PROGRESS"
        echo 0 > "$OGG_FAILURES"
        export OGG_PROGRESS OGG_FAILURES OGG_TOTAL PATCHLOG TOOLS LIBS

        ogg_worker() {
            local ogg="$1"
            local OK=0
            LD_LIBRARY_PATH="$LIBS:$LD_LIBRARY_PATH" \
            "$TOOLS/oggdec" -Q -o - "$ogg" 2>/dev/null | \
            LD_LIBRARY_PATH="$LIBS:$LD_LIBRARY_PATH" \
                "$TOOLS/oggenc" -Q -b 96 --downmix -o "$ogg.tmp" - 2>/dev/null
            if [ -f "$ogg.tmp" ] && [ -s "$ogg.tmp" ]; then
                mv "$ogg.tmp" "$ogg"
                OK=1
            else
                rm -f "$ogg.tmp"
                echo "OGG FAIL: $ogg" >> "$PATCHLOG"
            fi

            local COUNT PCT
            COUNT=$(cat "$OGG_PROGRESS")
            COUNT=$((COUNT + 1))
            echo "$COUNT" > "$OGG_PROGRESS"
            if [ "$OK" -eq 0 ]; then
                local FAILS
                FAILS=$(cat "$OGG_FAILURES")
                FAILS=$((FAILS + 1))
                echo "$FAILS" > "$OGG_FAILURES"
            fi
            PCT=$((COUNT * 100 / OGG_TOTAL))
            echo "  Optimizing audio... ${PCT}%"
        }
        export -f ogg_worker

        cat "$OGG_WORKLIST" | xargs -P 4 -I {} bash -c 'ogg_worker "$@"' _ {}

        OGG_FAIL_COUNT=$(cat "$OGG_FAILURES")
        rm -f "$OGG_WORKLIST" "$OGG_PROGRESS" "$OGG_FAILURES"

        if [ "$OGG_FAIL_COUNT" -gt 0 ]; then
            echo "  Warning: $OGG_FAIL_COUNT of $OGG_TOTAL files failed (kept originals)"
        fi

        echo "  Audio optimization complete."
    fi

    mark_done "ogg_done" "$V_OGG"
    echo "Step 4: Optimize audio... OK"
fi

# --- Step 5: Decode Aseprite sprites to PNG ---

if step_done "asedecode" "$V_ASEDECODE"; then
    echo "Step 5: Decode Aseprite sprites... already done. OK"
else
    echo "Step 5: Decode Aseprite sprites..."

    "$TOOLS/hl-asedecode" "$EXTRACTED/atlas" "$EXTRACTED/atlas" \
        2>>"$PATCHLOG" || fail "hl-asedecode failed"

    mark_done "asedecode" "$V_ASEDECODE"
    echo "Step 5: Decode Aseprite sprites... OK"
fi

# --- Step 6: ASTC texture compression ---

if step_done "astc" "$V_ASTC"; then
    echo "Step 6: ASTC compression... already done. OK"
else
    echo "Step 6: ASTC compression..."

    # Clean up old launch/ layout if upgrading from previous patch version
    rm -rf "$GAMEDATA/launch"

    ASTC_MANIFEST="$TMP/astc_manifest.txt"
    > "$ASTC_MANIFEST"
    ASTC_OUT="$GAMEDATA/astc"
    mkdir -p "$ASTC_OUT"

    # Hero spritesheet: 4x4 (main character, sharpest detail)
    if [ -f "$EXTRACTED/atlas/hero.png" ]; then
        echo "$EXTRACTED/atlas/hero.png|$ASTC_OUT/atlas/hero.astc|srgb|4x4" >> "$ASTC_MANIFEST"
    fi

    # Other sprite spritesheets: 6x6 (pixel art needs small blocks)
    find "$EXTRACTED/atlas" -name "*.png" ! -name "hero.png" -type f | sort | while read -r png; do
        REL="${png#$EXTRACTED/}"
        echo "$png|$ASTC_OUT/${REL%.png}.astc|srgb|6x6"
    done >> "$ASTC_MANIFEST"

    # Font PNGs: 4x4 (sharp glyph edges)
    find "$EXTRACTED/fonts" -name "*.png" -type f | sort | while read -r png; do
        REL="${png#$EXTRACTED/}"
        echo "$png|$ASTC_OUT/${REL%.png}.astc|srgb|4x4"
    done >> "$ASTC_MANIFEST"

    # Other images: 6x6
    find "$EXTRACTED/images" -name "*.png" -type f | sort | while read -r png; do
        REL="${png#$EXTRACTED/}"
        echo "$png|$ASTC_OUT/${REL%.png}.astc|srgb|6x6"
    done >> "$ASTC_MANIFEST"

    TOTAL=$(wc -l < "$ASTC_MANIFEST")
    echo "  Encoding $TOTAL textures..."

    "$TOOLS/astcenc-batch" "$ASTC_MANIFEST" -quality medium -silent \
        2>>"$PATCHLOG" || fail "astcenc-batch failed"

    mark_done "astc" "$V_ASTC"
    echo "Step 6: ASTC compression... OK ($TOTAL textures)"
fi

# --- Step 7: Repack res.pak ---

if step_done "pak_repack" "$V_PAK_REPACK"; then
    echo "Step 7: Repack res.pak... already done. OK"
else
    echo "Step 7: Repack res.pak..."

    "$TOOLS/hl-paktool" pack "$EXTRACTED" -o "$GAMEDATA/res.pak.tmp" \
        2>>"$PATCHLOG" || fail "hl-paktool pack failed"
    mv "$GAMEDATA/res.pak.tmp" "$GAMEDATA/res.pak"

    # Clean up extracted files and original backup
    rm -rf "$EXTRACTED"
    rm -f "$GAMEDATA/res.pak.orig"

    mark_done "pak_repack" "$V_PAK_REPACK"
    echo "Step 7: Repack res.pak... OK"
fi

echo "3" > "$GAMEDATA/.patched_complete"

echo ""
echo "=== Patching complete ==="
