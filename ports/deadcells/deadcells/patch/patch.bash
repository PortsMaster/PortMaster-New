#!/bin/bash
# Dead Cells PortMaster Patch Script
#
# Patches Dead Cells for handheld Linux devices.
# Called by PortMaster patcher UI.
# Hardware detected automatically via detect_hw.bash.

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

set -e

# --- Configuration ---

GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS="$GAMEDIR/tools"
LIBS="$GAMEDIR/libs.aarch64"
GAMEDATA="$GAMEDIR/gamedata"
STATE="$GAMEDATA/.patch_state"
PATCHLOG="$GAMEDIR/patchlog.txt"

# On KNULLI, /userdata is FUSE (exFAT). Frequent small writes and O_TRUNC
# can deadlock the FUSE daemon, freezing the OS. Write the patchlog to tmpfs
# and copy it back on exit.
PATCHLOG_FINAL=""
if [ "${CFW_NAME,,}" = "knulli" ] && [ -d /tmp ]; then
    PATCHLOG_FINAL="$PATCHLOG"
    PATCHLOG="/tmp/dc_patchlog_$$.txt"
fi

# On KNULLI FUSE, lower dirty thresholds to prevent writeback cliff that
# can deadlock the FUSE daemon under memory pressure.
DIRTY_RATIO_ORIG=""
if [ "${CFW_NAME,,}" = "knulli" ]; then
    DIRTY_RATIO_ORIG=$(cat /proc/sys/vm/dirty_ratio)
    DIRTY_BG_ORIG=$(cat /proc/sys/vm/dirty_background_ratio)
    echo 5 > /proc/sys/vm/dirty_background_ratio
    echo 10 > /proc/sys/vm/dirty_ratio
fi

# Use tmpfs for intermediate files to avoid slow SD card I/O.
# Falls back to gamedata if /dev/shm is unavailable.
if [ -d /dev/shm ]; then
    TMP="/dev/shm/dc_patch_$$"
else
    TMP="$GAMEDATA/.patch_tmp"
fi
cleanup() {
    rm -rf "$TMP"
    rm -f /var/run/battery-saver/deadcells_patcher.pause
    # Restore dirty page thresholds
    if [ -n "$DIRTY_RATIO_ORIG" ]; then
        echo "$DIRTY_BG_ORIG" > /proc/sys/vm/dirty_background_ratio
        echo "$DIRTY_RATIO_ORIG" > /proc/sys/vm/dirty_ratio
    fi
    # Copy tmpfs patchlog back to persistent storage
    if [ -n "$PATCHLOG_FINAL" ] && [ -f "$PATCHLOG" ]; then
        cp "$PATCHLOG" "$PATCHLOG_FINAL" 2>/dev/null
        rm -f "$PATCHLOG"
    fi
}
trap cleanup EXIT
trap 'kill 0 2>/dev/null; exit 1' HUP INT TERM

# MD5 checksums for known good hlboot.dat files
GOG_MD5="83acca99d927b3fee939df98146bb152"
STEAM_MD5="185147915f30d7ef9e6123bb0c69efbf"

# Step version constants — bump when behavior/tools change to force re-run
V_COMPILE="3"          # Step 2: hl-substitute + dc-patch-all + hl2llvm
V_PAK_EXTRACT="1"      # Step 3a: dc-paktool unpack
V_GUIDES="2"           # Step 3b: guide extraction (v2: mixed block sizes)
V_OGG="1"              # Step 4: oggdec/oggenc
V_COMBINE="2"          # Step 5: dc-combine-textures (v2: model whitelist)
V_ASTC="3"             # Step 6: astcenc-batch (v3: single-process batch encoder)
V_PAK_REPACK="1"       # Step 7: dc-paktool pack

# Hardware detection (automatic — no user questionnaire)
# Executed (not sourced) to avoid FUSE deadlocks on KNULLI exFAT.
eval "$("$GAMEDIR/patch/detect_hw.bash")"

# --- Substitution patterns for hl-substitute ---

SUBS_CORE=(
    "h3d.impl.\$GlDriver.__constructor__"
    "h3d.impl.GlDriver.resetStream"
    "hxd.res.Image.loadTexture"
    "hxd.fmt.pak.FileSystem.addPak"
    "Main.onResize"
    "pr.LogoSplashscreen.onResize"
    "pr.LogoSplashscreen.onDispose"
    "pr.LogoSplashscreen.next"
    "@pr.SplashState.**"
    "@gl.Debug.**"
    "Entity.setColorMap"
    "en.Hero.initColorMap"
    "h3d.impl.GlDriver.present"
    "en.UsableBody.initGfx"
    "en.HeroDeadCorpse.initGfx"
    "en.KingSkin.initColorMap"
    "hxsl.CacheFile.load"
    "ui.hud.LevelLogos.initLogoTexture"
    "ui.hud.LevelLogos.getLevelLogo"
    "ui.hud.LevelLogos.preventAutoDispose"
)

# Scaling: applied for slow + fast, skipped for ultra (native resolution)
SUBS_SCALING=(
    "@scaling.RTT.**"
)

# Lighting disable: slow + fast (>4 MRT crashes on rk3566 etc.)
SUBS_LIGHTING_DISABLE=(
    "light.\$LightedLayers.__constructor__"
    "light.LightedLayers.setState"
    "h2d.Drawable.addShader"
    "level.disp.Bridge.render"
)

# Low-memory minimap: detach from scene graph, collision-based fullscreen map
# Applied on all slow systems + 1gig fast systems (only fast+ultra with >=2GB keep minimap)
SUBS_LOWMEM=(
    "pr.Level.loadMinimap"
    "ui.HUD.initMap"
    "ui.HUD.fullscreenMap"
    "ui.hud.map.MapMask.drawRec"
)

# Models that call setColorMap at runtime — only these get combined _c textures.
# Others keep their original index textures (encoded as ASTC directly).
COMBINE_MODELS="beheaded*,king,Adele,AdeleSythe,AdeleSytheProjectile,behemoth,Gardener,DookuHumanoid,HotK,Queen,ServanteC,ShopMimic,timeKeeper,werewolf"

# Tools need libstdc++ from our libs
export LD_LIBRARY_PATH="$LIBS:${LD_LIBRARY_PATH:-}"

# --- Logging setup ---
# Tee all output to patchlog so user-visible messages are captured for debugging.
# On KNULLI, PATCHLOG points to /tmp (see above) to avoid FUSE deadlocks.
> "$PATCHLOG"
if tee -p /dev/null < /dev/null 2>/dev/null; then
    exec > >(tee -p -a "$PATCHLOG") 2>&1
else
    exec > >(tee -a "$PATCHLOG") 2>&1
fi

log() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$PATCHLOG"
}

# Run a command, capturing all output to the log only.
# Shows nothing on screen — caller prints the friendly message.
run() {
    log "CMD: $*"
    "$@" >> "$PATCHLOG" 2>&1
}

# --- Helper functions ---

step_done() {
    [ -f "$STATE/$1" ] && [ "$(cat "$STATE/$1")" = "$2" ]
}

mark_done() {
    echo "$2" > "$STATE/$1"
}

fail() {
    echo ""
    echo "ERROR: $1"
    log "FATAL: $1"
    echo ""
    echo "Patching process failed!"
    echo "Check patchlog.txt for details."
    exit 1
}

# Mid-patch upgrade: if a new zip was deployed while patching is still in
# progress, the compile markers are stale (built with old tools). Clear them
# so the compilation step re-runs with the updated tools.
if [ -f "$GAMEDATA/.patch-needs-recompile" ] && [ -d "$STATE" ]; then
    rm -f "$STATE/compiled"
    log "Mid-patch upgrade detected — clearing compile marker for recompile"
fi

# --- Pre-flight checks ---

# 7zzs from PortMaster (needed for guide extraction).
# Availability is checked in Dead Cells.sh before the patcher starts.
SEVENZIP="${controlfolder}/7zzs.${DEVICE_ARCH}"

# Extract GOG installer if present
gog_installer=$(ls "$GAMEDATA"/dead_cells_1_*.sh 2>/dev/null | head -n 1)
if [ -n "$gog_installer" ]; then
    echo "Extracting GOG installer..."
    log "Extracting GOG installer: $gog_installer"
    cd "$GAMEDATA"
    # Use 7zip with explicit zip type — some handheld firmwares ship busybox
    # unzip which chokes on the prepended shell script in GOG installers.
    # Extract into temp dir so cleanup is easy —
    # GOG installers vary between data/noarch/game/ and noarch/game/.
    GOG_TMP="$GAMEDATA/.gog_extract"
    rm -rf "$GOG_TMP"
    mkdir -p "$GOG_TMP"
    "$SEVENZIP" x -tzip "$gog_installer" -o"$GOG_TMP" -y >> "$PATCHLOG" 2>&1 || true
    GOG_HLBOOT=$(find "$GOG_TMP" -name hlboot.dat -path "*/noarch/game/*" | head -1)
    GOG_RESPAK=$(find "$GOG_TMP" -name res.pak -path "*/noarch/game/*" | head -1)
    [ -n "$GOG_HLBOOT" ] || { rm -rf "$GOG_TMP"; fail "Failed to extract hlboot.dat from GOG installer"; }
    [ -n "$GOG_RESPAK" ] || { rm -rf "$GOG_TMP"; fail "Failed to extract res.pak from GOG installer"; }
    mv "$GOG_HLBOOT" "$GAMEDATA/"
    mv "$GOG_RESPAK" "$GAMEDATA/"
    rm -rf "$GOG_TMP" "$gog_installer"
    echo "GOG installer extracted. OK"
fi

# Extract GOG DLC key files (goggame-*.hashdb/.info unlock shipped DLC content)
for dlc_installer in "$GAMEDATA"/dead_cells_[a-z]*.sh; do
    [ -f "$dlc_installer" ] || continue
    DLC_TMP="$GAMEDATA/.dlc_extract"
    rm -rf "$DLC_TMP"
    mkdir -p "$DLC_TMP"
    "$SEVENZIP" x -tzip "$dlc_installer" -o"$DLC_TMP" -y 'data/noarch/game/goggame-*' >> "$PATCHLOG" 2>&1 || true
    if ls "$DLC_TMP"/data/noarch/game/goggame-* > /dev/null 2>&1; then
        cp "$DLC_TMP"/data/noarch/game/goggame-* "$GAMEDATA/"
        DLC_NAME=$(basename "$dlc_installer" .sh | sed 's/^dead_cells_//; s/_[0-9][0-9_]*$//; s/_/ /g')
        echo "Installed DLC: $DLC_NAME"
        log "Installed DLC from $dlc_installer"
    fi
    rm -rf "$DLC_TMP" "$dlc_installer"
done

if [ ! -f "$GAMEDATA/hlboot.dat" ]; then
    fail "hlboot.dat not found in gamedata/"
fi

if [ ! -f "$GAMEDATA/res.pak" ]; then
    fail "res.pak not found in gamedata/"
fi

mkdir -p "$STATE" "$TMP"
rm -f "$GAMEDATA/shaders_gles.cache" "$GAMEDATA/shaders_gles.cache.gl"

# ==========================================
echo "=== Step 1/7: Verifying game files ==="
# ==========================================

ACTUAL_MD5=$(md5sum "$GAMEDATA/hlboot.dat" | cut -d' ' -f1)
log "hlboot.dat MD5: $ACTUAL_MD5"

if [ "$ACTUAL_MD5" = "$GOG_MD5" ]; then
    echo "GOG version detected. OK"
elif [ "$ACTUAL_MD5" = "$STEAM_MD5" ]; then
    echo "Steam version detected. OK"
else
    echo ""
    echo "WARNING: UNRECOGNIZED HLBOOT.DAT"
    echo "This may be an unsupported version."
    log "Unknown MD5: $ACTUAL_MD5 (expected GOG=$GOG_MD5 or Steam=$STEAM_MD5)"
    sleep 15
    fail "Unrecognized hlboot.dat version"
fi

case "$PERF_TIER" in
    slow)  echo "Profile: Slow (lighting disabled, scaled down)" ;;
    fast)  echo "Profile: Fast (lighting disabled, scaled down)" ;;
    ultra) echo "Profile: Ultra (full lighting, native resolution)" ;;
esac
echo "Memory: $MEM_TIER"
echo ""

# ==========================================
echo "=== Step 2/7: Compiling game ==="
# ==========================================

if step_done "compiled" "${V_COMPILE}-${PERF_TIER}-${MEM_TIER}"; then
    echo "Already done, skipping. OK"
else
    # Build substitution list based on performance tier
    SUBS=("${SUBS_CORE[@]}")
    if [ "$PERF_TIER" != "ultra" ]; then
        SUBS+=("${SUBS_SCALING[@]}")
    fi
    if [ "$PERF_TIER" != "ultra" ]; then
        SUBS+=("${SUBS_LIGHTING_DISABLE[@]}")
    fi
    if [ "$MEM_TIER" = "1gig" ] || [ "$PERF_TIER" = "slow" ]; then
        SUBS+=("${SUBS_LOWMEM[@]}")
    fi

    echo "Applying Haxe function patches..."
    run "$TOOLS/hl-substitute" \
        "$GAMEDATA/hlboot.dat" \
        "$TOOLS/dc_patches.hl" \
        -o "$TMP/substituted.hl" \
        "${SUBS[@]}"
    echo "  Haxe function patches applied. OK"

    PATCH_FLAGS=()
    if [ "$PERF_TIER" = "ultra" ]; then
        PATCH_FLAGS+=(--skip-lighting)
    fi

    echo "Applying bytecode patches (single pass)..."
    run "$TOOLS/dc-patch-all" \
        "$TMP/substituted.hl" \
        "$TMP/patched.hl" \
        "${PATCH_FLAGS[@]}"
    rm -f "$TMP/substituted.hl"
    mv "$TMP/patched.hl" "$GAMEDATA/dead_cells_patched.hl"
    echo "  All bytecode patches applied. OK"

    echo "Compiling game to native code..."
    echo "(This is the longest step, please wait)"
    rm -rf "$TMP/deadcells" "$TMP/deadcells.d"

    OBJ_DIR="$TMP/deadcells.d"

    # Run hl2llvm in background so we can monitor progress
    log "CMD: $TOOLS/hl2llvm --batch -O3 --inline-threshold=5000 --fast-math --mcpu=cortex-a35 --threads=2 --link -L $LIBS $GAMEDATA/dead_cells_patched.hl -o $TMP/deadcells"
    "$TOOLS/hl2llvm" \
        --batch -O3 \
        --inline-threshold=5000 \
        --fast-math \
        --mcpu=cortex-a35 \
        --threads=2 \
        --link \
        -L "$LIBS" \
        "$GAMEDATA/dead_cells_patched.hl" \
        -o "$TMP/deadcells" >> "$PATCHLOG" 2>&1 &
    HL2LLVM_PID=$!

    # Monitor batch .o files for progress
    # ~187 batches for Dead Cells, then a link phase
    EST_BATCHES=187
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

    # Check exit status
    set +e
    wait $HL2LLVM_PID
    HL2LLVM_EXIT=$?
    set -e
    if [ $HL2LLVM_EXIT -ne 0 ]; then
        fail "hl2llvm compilation failed (exit code $HL2LLVM_EXIT)"
    fi

    chmod +x "$TMP/deadcells"
    mv "$TMP/deadcells" "$GAMEDATA/deadcells"
    rm -rf "$TMP/deadcells.d"

    # Save config so tier is visible for debugging
    cat > "$GAMEDATA/.patch-config" <<HWEOF
PERF_TIER="$PERF_TIER"
MEM_TIER="$MEM_TIER"
HWEOF

    mark_done "compiled" "${V_COMPILE}-${PERF_TIER}-${MEM_TIER}"
    echo "Compilation complete! OK"
fi
echo ""

# --- Asset cascade invalidation ---
# Steps 3-7 are coupled because res_extracted/ is transient (deleted in step 7).
# If ANY asset step version mismatches, all asset markers must be cleared.
check_asset_versions() {
    step_done "pak_extracted" "$V_PAK_EXTRACT" &&
    step_done "guides_extracted" "$V_GUIDES" &&
    step_done "ogg_done" "$V_OGG" &&
    step_done "combine_done" "$V_COMBINE" &&
    step_done "astc_done" "${V_ASTC}-${PERF_TIER}" &&
    step_done "pak_repacked" "$V_PAK_REPACK"
}

if ! check_asset_versions; then
    log "Asset version mismatch — clearing all asset markers for clean re-run"
    rm -f "$STATE/pak_extracted" "$STATE/guides_extracted" \
          "$STATE/ogg_done" "$STATE/combine_done" \
          "$STATE/astc_done" "$STATE/pak_repacked"
    rm -rf "$GAMEDATA/astc"
    # Restore original res.pak if backup exists
    if [ -f "$GAMEDATA/res.pak.orig" ]; then
        cp "$GAMEDATA/res.pak.orig" "$GAMEDATA/res.pak"
    fi
fi

# ==========================================
echo "=== Step 3/7: Unpacking game assets ==="
# ==========================================

if step_done "pak_extracted" "$V_PAK_EXTRACT"; then
    echo "Unpacking res.pak: already done, skipping. OK"
else
    # Back up original res.pak before first extraction
    if [ ! -f "$GAMEDATA/res.pak.orig" ]; then
        cp "$GAMEDATA/res.pak" "$GAMEDATA/res.pak.orig"
    fi
    echo "Unpacking res.pak..."
    rm -rf "$GAMEDATA/res_extracted"
    run "$TOOLS/dc-paktool" unpack \
        "$GAMEDATA/res.pak" \
        -o "$GAMEDATA/res_extracted"
    echo "  res.pak unpacked. OK"
    mark_done "pak_extracted" "$V_PAK_EXTRACT"
fi

if step_done "guides_extracted" "$V_GUIDES"; then
    echo "Extracting guides: already done, skipping. OK"
else
    # Extract ASTC guide files (speeds up exhaustive recompression).
    # Optional — astcenc works without guides, just slower/lower quality.
    if [ -f "$GAMEDIR/patch/guides.7z.split.001" ]; then
        echo "Extracting ASTC guide files..."
        mkdir -p "$GAMEDATA/guides"
        if ! "$SEVENZIP" x "$GAMEDIR/patch/guides.7z.split.001" -o"$GAMEDATA/guides" -y >> "$PATCHLOG" 2>&1; then
            echo "  WARNING: guide extraction failed, continuing without guides."
            rm -rf "$GAMEDATA/guides"
        fi
    fi
    mark_done "guides_extracted" "$V_GUIDES"
fi
echo ""

# ==========================================
echo "=== Step 4/7: Optimizing audio ==="
# ==========================================

if step_done "ogg_done" "$V_OGG"; then
    echo "Already done, skipping. OK"
else
    # Build work list: OGG files > 50KB
    OGG_WORKLIST="$TMP/ogg_worklist.txt"
    find "$GAMEDATA/res_extracted" -name "*.ogg" -type f -size +50k > "$OGG_WORKLIST"

    OGG_TOTAL=$(wc -l < "$OGG_WORKLIST")
    echo "Optimizing $OGG_TOTAL audio files..."

    # Worker: decode then re-encode at 96kbps mono, atomic mv
    export PATCHLOG TOOLS
    OGG_PROGRESS="$TMP/ogg_progress"
    OGG_FAILURES="$TMP/ogg_failures"
    echo 0 > "$OGG_PROGRESS"
    echo 0 > "$OGG_FAILURES"
    export OGG_PROGRESS OGG_FAILURES OGG_TOTAL

    ogg_worker() {
        local ogg="$1"
        local OK=0
        "$TOOLS/oggdec" -Q -o - "$ogg" 2>/dev/null | \
            "$TOOLS/oggenc" -Q -b 96 --downmix -o "$ogg.tmp" - 2>/dev/null
        if [ -f "$ogg.tmp" ] && [ -s "$ogg.tmp" ]; then
            mv "$ogg.tmp" "$ogg"
            OK=1
        else
            rm -f "$ogg.tmp"
            echo "OGG FAIL: $ogg" >> "$PATCHLOG"
        fi

        # Racy counter is fine — progress display is cosmetic and with only
        # 4 workers a lost failure increment is negligible.
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
        fail "OGG encoding failed for $OGG_FAIL_COUNT of $OGG_TOTAL files. Check patchlog.txt and disk space."
    fi

    echo "Audio optimization complete. OK"
    mark_done "ogg_done" "$V_OGG"
fi
echo ""

# ==========================================
echo "=== Step 5/7: Combining textures ==="
# ==========================================

if step_done "combine_done" "$V_COMBINE"; then
    echo "Already done, skipping. OK"
else
    echo "Combining sprite textures..."
    rm -rf "$GAMEDATA/res_combined"
    log "CMD: $TOOLS/dc-combine-textures --models $COMBINE_MODELS -i $GAMEDATA/res_extracted/atlas -o $GAMEDATA/res_combined/atlas"
    "$TOOLS/dc-combine-textures" \
        --models "$COMBINE_MODELS" \
        -i "$GAMEDATA/res_extracted/atlas" \
        -o "$GAMEDATA/res_combined/atlas" 2>>"$PATCHLOG"

    echo "Texture combining complete! OK"
    mark_done "combine_done" "$V_COMBINE"
fi
echo ""

# ==========================================
echo "=== Step 6/7: Compressing textures ==="
# ==========================================

if step_done "astc_done" "${V_ASTC}-${PERF_TIER}"; then
    echo "Already done, skipping. OK"
else
    mkdir -p "$GAMEDATA/astc"

    # Build manifest: pipe-delimited "input|output|colorspace|block_size"
    ASTC_MANIFEST="$TMP/astc_manifest.txt"
    > "$ASTC_MANIFEST"

    # Build skip list for atlas index textures whose models are in the combine whitelist.
    # Only whitelisted models get _c textures; others keep their index textures.
    ATLAS_DIR="$GAMEDATA/res_extracted/atlas"
    SKIP_LIST="$TMP/atlas_skip.txt"
    > "$SKIP_LIST"

    # Helper: check if a model name matches the combine whitelist
    model_in_whitelist() {
        local model="$1"
        local IFS=',' entry
        set -f  # disable globbing so beheaded* isn't expanded
        for entry in $COMBINE_MODELS; do
            case "$entry" in
                *'*')
                    local prefix="${entry%'*'}"
                    case "$model" in "$prefix"*) set +f; return 0 ;; esac
                    ;;
                *)
                    [ "$model" = "$entry" ] && { set +f; return 0; }
                    ;;
            esac
        done
        set +f
        return 1
    }

    if [ -d "$ATLAS_DIR" ]; then
        for swap in "$ATLAS_DIR"/*_s.png; do
            [ -f "$swap" ] || continue
            SWAP_BASE="${swap##*/}"              # Model_skin_s.png
            SWAP_BASE="${SWAP_BASE%.png}"         # Model_skin_s
            SWAP_BASE="${SWAP_BASE%_s}"           # Model_skin
            MODEL="${SWAP_BASE%_*}"               # Model
            # Only skip index textures for whitelisted models
            model_in_whitelist "$MODEL" || continue
            # Index textures: Model.png, Model0.png, Model1.png, ...
            for idx in "$ATLAS_DIR/${MODEL}".png "$ATLAS_DIR/${MODEL}"[0-9].png "$ATLAS_DIR/${MODEL}"[0-9][0-9].png; do
                [ -f "$idx" ] || continue
                echo "$idx" >> "$SKIP_LIST"
            done
        done
        sort -u "$SKIP_LIST" -o "$SKIP_LIST"
    fi

    # Select ASTC block size by asset type:
    #   fonts → 6x6 (sharp edges need more detail)
    #   fx* atlases → 12x12 (soft particles tolerate aggressive compression)
    #   everything else → 8x8
    block_size_for() {
        local rel="$1"
        case "$rel" in
            fonts/*) echo "6x6" ;;
            atlas/fx*) echo "12x12" ;;
            *) echo "8x8" ;;
        esac
    }

    # All PNGs from res_extracted, skipping:
    #   - *_s.png palette/swap textures (only used during combining)
    #   - *_n.png normal maps (skipped on slow tier, included with linear on fast/ultra)
    #   - index textures for whitelisted models (replaced by combined _c versions)
    FIND_EXCLUDES=(-not -name "*_s.png")
    if [ "$PERF_TIER" != "ultra" ]; then
        FIND_EXCLUDES+=(-not -name "*_n.png")
    fi
    find "$GAMEDATA/res_extracted" -name "*.png" -type f \
        "${FIND_EXCLUDES[@]}" \
        | sort | while read -r png; do
        # Skip index textures that have been combined
        if grep -qxF "$png" "$SKIP_LIST" 2>/dev/null; then
            continue
        fi
        REL="${png#$GAMEDATA/res_extracted/}"
        ASTC_OUT="$GAMEDATA/astc/${REL%.png}.astc"
        [ -f "$ASTC_OUT" ] && continue
        # Normal maps use linear colorspace
        case "$png" in
            *_n.png) CS="linear" ;;
            *)       CS="srgb" ;;
        esac
        BS=$(block_size_for "$REL")
        echo "$png|$ASTC_OUT|$CS|$BS" >> "$ASTC_MANIFEST"
    done
    rm -f "$SKIP_LIST"

    # Combined colormaps
    if [ -d "$GAMEDATA/res_combined" ]; then
        find "$GAMEDATA/res_combined" -name "*_c.png" -type f | sort | while read -r png; do
            REL="${png#$GAMEDATA/res_combined/}"
            ASTC_OUT="$GAMEDATA/astc/${REL%.png}.astc"
            [ -f "$ASTC_OUT" ] && continue
            BS=$(block_size_for "$REL")
            echo "$png|$ASTC_OUT|srgb|$BS" >> "$ASTC_MANIFEST"
        done
    fi

    # PortMaster logo
    if [ -f "$TOOLS/PortMaster.png" ] && [ ! -f "$GAMEDATA/astc/PortMaster.astc" ]; then
        echo "$TOOLS/PortMaster.png|$GAMEDATA/astc/PortMaster.astc|srgb|8x8" >> "$ASTC_MANIFEST"
    fi

    PNG_TOTAL=$(wc -l < "$ASTC_MANIFEST")

    echo "ASTC encoding $PNG_TOTAL textures..."
    echo "(This will take a while)"

    # Single-process batch encoder — eliminates concurrent FUSE writers,
    # fork+exec overhead, flock contention, and sync calls.
    GUIDE_ARGS=""
    [ -d "$GAMEDATA/guides" ] && GUIDE_ARGS="-guide-dir $GAMEDATA/guides"
    log "CMD: $TOOLS/astcenc-batch $ASTC_MANIFEST -quality medium -silent $GUIDE_ARGS"
    set +e
    "$TOOLS/astcenc-batch" "$ASTC_MANIFEST" -quality medium -silent $GUIDE_ARGS \
        2>>"$PATCHLOG"
    ASTC_EXIT=$?
    set -e

    ASTC_ACTUAL=$(find "$GAMEDATA/astc" -name "*.astc" -type f | wc -l)
    rm -f "$ASTC_MANIFEST"

    if [ "$ASTC_EXIT" -ne 0 ]; then
        fail "ASTC encoding failed (exit code $ASTC_EXIT, encoded $ASTC_ACTUAL of $PNG_TOTAL). Check patchlog.txt and disk space."
    fi

    # Clean up intermediates
    rm -rf "$GAMEDATA/res_combined"
    rm -rf "$GAMEDATA/guides"

    echo "Encoded $ASTC_ACTUAL textures. OK"
    mark_done "astc_done" "${V_ASTC}-${PERF_TIER}"
    echo "Texture compression complete! OK"
fi
echo ""

# ==========================================
echo "=== Step 7/7: Repacking game assets ==="
# ==========================================

if step_done "pak_repacked" "$V_PAK_REPACK"; then
    echo "Already done, skipping. OK"
else
    # Inject PortMaster logo into pak tree
    if [ -f "$TOOLS/PortMaster.png" ]; then
        cp "$TOOLS/PortMaster.png" "$GAMEDATA/res_extracted/"
    fi

    echo "Repacking res.pak..."
    run "$TOOLS/dc-paktool" pack \
        "$GAMEDATA/res_extracted" \
        -o "$GAMEDATA/res.pak.tmp"
    mv "$GAMEDATA/res.pak.tmp" "$GAMEDATA/res.pak"

    # Clean up extracted assets (patch_state kept for upgrade re-runs)
    rm -rf "$GAMEDATA/res_extracted"
    rm -rf "$TMP"

    mark_done "pak_repacked" "$V_PAK_REPACK"
    echo "Repacking complete! OK"
fi
echo ""

rm -f "$GAMEDATA/.patch-needs-recompile"
touch "$GAMEDATA/.patched_complete"
echo "Patching completed successfully!"
