#!/bin/bash
#
# Crypt of the NecroDancer — PortMaster patcher
#
# Sets up game files from either Steam depots or GOG .pkg installers.
# Supports GOG base game + any DLC .pkg files (Amplified, Synchrony, character DLCs, etc.).
# No symlinks used (compatible with exFAT SD cards).
#

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

set -eo pipefail

GAMEDIR="$(dirname "$0")/.."
GAMEDATA="$GAMEDIR/gamedata"
PATCHLOG="$GAMEDIR/patchlog.txt"

# --- Logging setup ---
> "$PATCHLOG"
if tee -p /dev/null < /dev/null 2>/dev/null; then
    exec > >(tee -p -a "$PATCHLOG") 2>&1
else
    exec > >(tee -a "$PATCHLOG") 2>&1
fi

log() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$PATCHLOG"
}

fail() {
    echo ""
    echo "ERROR: $1"
    log "FATAL: $1"
    exit 1
}

echo "=== Crypt of the NecroDancer Patcher ==="
echo "Started: $(date)"
echo ""

# --- Check if already set up ---

if [ -f "$GAMEDATA/.game_source" ]; then
    GAME_SOURCE="$(cat "$GAMEDATA/.game_source")"
    echo "Already set up (source: $GAME_SOURCE), skipping."
    echo ""
    echo "=== Patching complete ==="
    echo "Finished: $(date)"
    exit 0
fi

# --- Helper: extract a .pkg file ---
# Usage: extract_pkg <pkg_file> <output_dir>
# Extracts the payload from a macOS .pkg (xar → gzip → cpio) into output_dir.
# Single pipeline eliminates intermediate disk writes.

extract_pkg() {
    local PKG="$1"
    local OUTDIR="$2"

    rm -rf "$OUTDIR"
    mkdir -p "$OUTDIR"
    echo "  Extracting game files..."

    # Single pipeline: xar → gunzip → cpio extract. No intermediate disk writes.
    # We bundle GNU cpio because BusyBox cpio can't handle the odc format macOS uses.
    local CPIO="$GAMEDIR/tools/cpio"
    log "CMD: $SEVENZIP e -so $PKG package.pkg/Scripts | gunzip | $CPIO -idmu --no-absolute-filenames"
    "$SEVENZIP" e -so "$PKG" "package.pkg/Scripts" 2>>"$PATCHLOG" \
        | gunzip 2>>"$PATCHLOG" \
        | (cd "$OUTDIR" && "$CPIO" -idmu --no-absolute-filenames 2>>"$PATCHLOG")
    local PS=(${PIPESTATUS[@]})
    log "cpio pipeline finished (PIPESTATUS=${PS[*]})"
    if [ "${PS[0]}" -ne 0 ] || [ "${PS[2]}" -ne 0 ]; then
        fail "Extraction pipeline failed (7z=${PS[0]} gunzip=${PS[1]} cpio=${PS[2]}). Check patchlog.txt"
    fi

    # Resolve payload directory
    if [ -d "$OUTDIR/payload" ]; then
        EXTRACTED_PAYLOAD="$OUTDIR/payload"
    else
        EXTRACTED_PAYLOAD="$OUTDIR"
    fi

    # Verify extraction produced something
    if [ ! -d "$EXTRACTED_PAYLOAD" ] || [ -z "$(ls -A "$EXTRACTED_PAYLOAD" 2>/dev/null)" ]; then
        log "EXTRACTED_PAYLOAD=$EXTRACTED_PAYLOAD is empty or missing"
        fail "Extraction of $(basename "$PKG") produced no files. Check patchlog.txt"
    fi
    log "Extracted to $EXTRACTED_PAYLOAD: $(ls "$EXTRACTED_PAYLOAD" | head -5)"
}

# --- Detect game source ---

GAME_SOURCE=""

# Check for GOG .pkg files — separate base game from DLC
GOG_BASE_PKG=""
GOG_SYNCHRONY_PKG=""
GOG_DLC_PKGS=()

for f in "$GAMEDATA"/*.pkg; do
    [ -f "$f" ] || continue
    fname="$(basename "$f")"
    case "$fname" in
        dlc_*synchrony*) GOG_SYNCHRONY_PKG="$f" ;;
        dlc_*) GOG_DLC_PKGS+=("$f") ;;
        crypt_of_the_necrodancer*|Crypt*) GOG_BASE_PKG="$f" ;;
        *)
            # Unknown .pkg — treat as base game if no base found yet
            if [ -z "$GOG_BASE_PKG" ]; then
                GOG_BASE_PKG="$f"
            fi
            ;;
    esac
done

HAVE_GOG_PKG=false
if [ -n "$GOG_BASE_PKG" ]; then
    HAVE_GOG_PKG=true
fi

# Check for Steam depots
DEPOT_MAC="$GAMEDATA/depot_247082"
DEPOT_SP="$GAMEDATA/depot_247086"
HAVE_STEAM=false
if [ -d "$DEPOT_MAC" ] && [ -d "$DEPOT_SP" ]; then
    HAVE_STEAM=true
fi

# Check for already-extracted app bundles (GOG pre-extracted on PC)
HAVE_GOG_APPS=false
if [ -d "$GAMEDATA/NecroDancerMP.app" ] && [ -d "$GAMEDATA/NecroDancer.app" ]; then
    HAVE_GOG_APPS=true
fi

# Locate PortMaster's static 7z (aarch64-only port)
SEVENZIP=""
if [ -n "$controlfolder" ] && [ -x "${controlfolder}/7zzs.aarch64" ]; then
    SEVENZIP="${controlfolder}/7zzs.aarch64"
fi

# --- GOG .pkg extraction ---

if $HAVE_GOG_PKG; then
    GAME_SOURCE="gog"
    HAS_SYNCHRONY=false

    if [ -z "$SEVENZIP" ]; then
        fail "7zzs not found. Please upgrade to the latest version of PortMaster."
    fi
    # Count what we have
    PKG_COUNT=$((1 + ${#GOG_DLC_PKGS[@]}))
    [ -n "$GOG_SYNCHRONY_PKG" ] && PKG_COUNT=$((PKG_COUNT + 1))
    echo "Found $PKG_COUNT GOG .pkg file(s):"
    echo "  Base game: $(basename "$GOG_BASE_PKG")"
    for DLC_PKG in "${GOG_DLC_PKGS[@]}"; do
        echo "  DLC: $(basename "$DLC_PKG")"
    done
    [ -n "$GOG_SYNCHRONY_PKG" ] && echo "  Synchrony DLC: $(basename "$GOG_SYNCHRONY_PKG")"
    echo ""
    echo "NOTE: Extraction may take several minutes on handheld devices."
    echo ""

    # --- Extract base game ---
    echo "=== [1/$PKG_COUNT] Extracting base game ==="
    OUTDIR="$GAMEDATA/.extracted"
    rm -rf "$OUTDIR"
    extract_pkg "$GOG_BASE_PKG" "$OUTDIR"

    if [ ! -d "$EXTRACTED_PAYLOAD/NecroDancerMP.app" ]; then
        rm -rf "$OUTDIR"
        fail "NecroDancerMP.app not found in extracted payload"
    fi

    echo "  Moving NecroDancerMP.app (arm64 binary + dylibs)..."
    mv "$EXTRACTED_PAYLOAD/NecroDancerMP.app" "$GAMEDATA/"

    if [ -d "$EXTRACTED_PAYLOAD/NecroDancer.app" ]; then
        echo "  Moving NecroDancer.app (game assets)..."
        mv "$EXTRACTED_PAYLOAD/NecroDancer.app" "$GAMEDATA/"
    fi

    # Preserve goggame-*.info for Galaxy DLC ownership checking
    if ls "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info >/dev/null 2>&1; then
        mkdir -p "$GAMEDATA/Contents/Resources"
        cp -f "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info "$GAMEDATA/Contents/Resources/"
    fi

    rm -rf "$OUTDIR"
    rm -f "$GOG_BASE_PKG"
    echo "  Base game extraction complete."
    echo ""

    # --- Extract DLC .pkg files (asset overlays) ---
    PKG_NUM=1
    for DLC_PKG in "${GOG_DLC_PKGS[@]}"; do
        PKG_NUM=$((PKG_NUM + 1))
        echo "=== [$PKG_NUM/$PKG_COUNT] Extracting DLC: $(basename "$DLC_PKG") ==="
        OUTDIR="$GAMEDATA/.extracted"
        rm -rf "$OUTDIR"
        extract_pkg "$DLC_PKG" "$OUTDIR"

        # DLC packages contain a NecroDancer.app with additional assets
        if [ -d "$EXTRACTED_PAYLOAD/NecroDancer.app" ]; then
            echo "  Merging DLC assets into NecroDancer.app..."
            cp -rf "$EXTRACTED_PAYLOAD/NecroDancer.app/." "$GAMEDATA/NecroDancer.app/"
            echo "  DLC installed."
        else
            echo "  WARNING: NecroDancer.app not found in DLC, skipping."
        fi

        # Preserve goggame-*.info for Galaxy DLC ownership checking
        if ls "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info >/dev/null 2>&1; then
            mkdir -p "$GAMEDATA/Contents/Resources"
            cp -f "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info "$GAMEDATA/Contents/Resources/"
        fi

        rm -rf "$OUTDIR"
        rm -f "$DLC_PKG"
        echo ""
    done

    # --- Extract Synchrony DLC (binary + necromods overlay) ---
    if [ -n "$GOG_SYNCHRONY_PKG" ]; then
        PKG_NUM=$((PKG_NUM + 1))
        echo "=== [$PKG_NUM/$PKG_COUNT] Extracting Synchrony DLC ==="
        OUTDIR="$GAMEDATA/.extracted"
        rm -rf "$OUTDIR"
        extract_pkg "$GOG_SYNCHRONY_PKG" "$OUTDIR"

        # Synchrony DLC contains a complete NecroDancerMP.app replacement
        # with different binary (shifted addresses) + additional necromods
        if [ -d "$EXTRACTED_PAYLOAD/NecroDancerMP.app" ]; then
            echo "  Merging Synchrony DLC into NecroDancerMP.app..."
            cp -rf "$EXTRACTED_PAYLOAD/NecroDancerMP.app/." "$GAMEDATA/NecroDancerMP.app/"
            HAS_SYNCHRONY=true
            echo "  Synchrony DLC installed."
        else
            echo "  WARNING: NecroDancerMP.app not found in Synchrony DLC, skipping."
        fi

        # Preserve goggame-*.info for Galaxy DLC ownership checking
        if ls "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info >/dev/null 2>&1; then
            mkdir -p "$GAMEDATA/Contents/Resources"
            cp -f "$EXTRACTED_PAYLOAD/Contents/Resources/goggame-"*.info "$GAMEDATA/Contents/Resources/"
        fi

        rm -rf "$OUTDIR"
        rm -f "$GOG_SYNCHRONY_PKG"
        echo ""
    fi

    # Set game source based on DLC state
    if $HAS_SYNCHRONY; then
        GAME_SOURCE="gog-synchrony"
    fi

    echo "GOG extraction complete."

# --- GOG pre-extracted (user ran extract script on PC) ---

elif $HAVE_GOG_APPS; then
    GAME_SOURCE="gog"
    echo "Found pre-extracted GOG app bundles."

    # Check if Synchrony DLC was applied (binary size distinguishes them)
    BINARY="$GAMEDATA/NecroDancerMP.app/Contents/MacOS/NecroDancer"
    if [ -f "$BINARY" ]; then
        BINARY_SIZE=$(stat -c%s "$BINARY" 2>/dev/null || stat -f%z "$BINARY" 2>/dev/null)
        # Synchrony binary is 28882992 bytes vs base 28882064
        if [ "$BINARY_SIZE" = "28882992" ]; then
            GAME_SOURCE="gog-synchrony"
            echo "Detected Synchrony DLC binary."
        fi
    fi

# --- Steam depot merge ---

elif $HAVE_STEAM; then
    GAME_SOURCE="steam"
    echo "Found Steam depots."
    echo ""

    # Verify expected app bundles exist in depots
    if [ ! -d "$DEPOT_MAC/NecroDancer.app" ]; then
        fail "NecroDancer.app not found in depot_247082/"
    fi

    if [ ! -d "$DEPOT_SP/NecroDancerSP.app" ]; then
        fail "NecroDancerSP.app not found in depot_247086/"
    fi

    # Verify the arm64 binary exists
    SP_BINARY="$DEPOT_SP/NecroDancerSP.app/Contents/MacOS/NecroDancer"
    if [ ! -f "$SP_BINARY" ]; then
        fail "NecroDancer binary not found in SP depot"
    fi

    echo "=== Merging depots ==="

    echo "Moving NecroDancerSP.app (arm64 binary + dylibs)..."
    mv "$DEPOT_SP/NecroDancerSP.app" "$GAMEDATA/"

    echo "Moving NecroDancer.app (game assets)..."
    mv "$DEPOT_MAC/NecroDancer.app" "$GAMEDATA/"

    # Clean up empty depot directories
    rm -rf "$DEPOT_MAC" "$DEPOT_SP"
    echo "Depots merged successfully."

# --- Nothing found ---

else
    fail "No game files found in gamedata/. Place GOG .pkg files or Steam depots in necrodancer/gamedata/"
fi

# --- Create userdata directory for game saves ---

case "$GAME_SOURCE" in
    gog|gog-synchrony)
        mkdir -p "$GAMEDATA/NecroDancerMP.app/Contents/MacOS/userdata"
        ;;
    steam)
        mkdir -p "$GAMEDATA/NecroDancerSP.app/Contents/MacOS/userdata"
        ;;
esac
echo "Created userdata/ directory for saves."

# --- Mark as complete ---

echo "$GAME_SOURCE" > "$GAMEDATA/.game_source"

echo ""
echo "=== Patching complete (source: $GAME_SOURCE) ==="
echo "Finished: $(date)"
