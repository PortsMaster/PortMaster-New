#!/bin/bash

astc_quality=60.0
PATCHLOG="$gamedir/patchlog.txt"
PATCH_BUFFER="/tmp/cm_patch_buffer_$$.txt"
> "$PATCHLOG"
> "$PATCH_BUFFER"

# Tee all output to patchlog for debugging, while it still reaches the patcher UI live.
if tee -p /dev/null < /dev/null 2>/dev/null; then
    exec > >(tee -p -a "$PATCHLOG") 2>&1
else
    exec > >(tee -a "$PATCHLOG") 2>&1
fi

TIMING_LOG="$gamedir/timing.log"
echo "=== First Setup start: $(date '+%Y-%m-%d %H:%M:%S') ===" > "$TIMING_LOG"
SETUP_START=$(date +%s)

log() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$PATCHLOG"
}

fail() {
    echo ""
    echo "ERROR: $1"
    log "FATAL: $1"
    echo ""
    echo "Patching process failed!"
    echo "Check patchlog.txt for details."
    rm -f "$PATCH_BUFFER"
    exit 1
}

# Buttonlayout Fix
if [[ "$CM_BUTTONLAYOUT" == "nintendo" ]]; then
    if [[ -f "${gamedir}/patches/sprites.xnb" ]]; then
        cp "${gamedir}/patches/sprites.xnb" "${gamedir}/gamedata/Content/gfx/sprites.xnb"
        log "Applied Nintendo-style button-color sprites.xnb before ASTC repack."
    else
        log "WARNING: CM_BUTTONLAYOUT=nintendo but patches/sprites.xnb not found — skipping."
    fi
    if [[ -f "${gamedir}/patches/attribs.xnb" ]]; then
        cp "${gamedir}/patches/attribs.xnb" "${gamedir}/gamedata/Content/gfx/attribs.xnb"
        log "Applied Nintendo-style button-color attribs.xnb before ASTC repack."
    else
        log "WARNING: CM_BUTTONLAYOUT=nintendo but patches/attribs.xnb not found — skipping."
    fi
    if [[ -f "${gamedir}/patches/text.xnb" ]]; then
        cp "${gamedir}/patches/text.xnb" "${gamedir}/gamedata/Content/gfx/text.xnb"
        log "Applied Nintendo-style button-color text.xnb before ASTC repack."
    else
        log "WARNING: CM_BUTTONLAYOUT=nintendo but patches/text.xnb not found — skipping."
    fi
fi

# MonoMod/FixTypeRef
patch_step() {
    if [[ ! -f "${gamedir}/gamedata/.patch_done" ]]; then
        echo "Applying game patches..." >> "$PATCH_BUFFER"
        export MONOMOD_MODS="$gamedir/patches"
        export MONOMOD_DEPDIRS="${MONO_PATH}":"${gamedir}/monomod":"${gamedir}/dlls"
        (
            set -e
            mono "${gamedir}/monomod/MonoMod.exe" "${gamedir}/gamedata/${gameassembly}" >> "$PATCHLOG" 2>&1
            (cd "${gamedir}/monomod" && mono FixTypeRef.exe "${gamedir}/gamedata/MONOMODDED_${gameassembly}") >> "$PATCHLOG" 2>&1
        )
        if [[ $? -ne 0 ]]; then
            rm -f "${gamedir}/gamedata/.patch_done"
            echo "__FAILED__" >> "$PATCH_BUFFER"
            return 1
        fi
        sha1sum "${gamedir}/gamedata/${gameassembly}" > "${gamedir}/gamedata/.ver_checksum"
        sha1sum "${gamedir}/patches/"*.dll >> "${gamedir}/gamedata/.ver_checksum"
        touch "${gamedir}/gamedata/.patch_done"
        echo "Game patches applied. OK" >> "$PATCH_BUFFER"

echo "MonoMod/FixTypeRef done: $(date '+%H:%M:%S') (Duration: $(( $(date +%s) - SETUP_START ))s)" >> "$TIMING_LOG"

    fi
    return 0
}

astc_step() {
    if [[ -f "${gamedir}/gamedata/.astc_done" ]]; then
        return 0
    fi
    echo "Let's go!"
    echo "Compressing textures, this takes the longest..."
    export ASTC_QUALITY="$astc_quality"

    local content_dir="${gamedir}/gamedata/Content"
    local total_files
    total_files=$(find "$content_dir" -type f -name "*.xnb" 2>/dev/null | wc -l)
    [[ "$total_files" -lt 1 ]] && total_files=1

    local marker="/tmp/cm_astc_marker_$$"
    touch "$marker"

    mono "${gamedir}/FNARepacker.exe" "$content_dir/" >> "$PATCHLOG" 2>&1 &
    local astc_pid=$!

    local last_pct=-1
    local t25=0 t50=0 t75=0
    while kill -0 $astc_pid 2>/dev/null; do
        sleep 3
        local done_count pct
        done_count=$(find "$content_dir" -type f -name "*.xnb" -newer "$marker" 2>/dev/null | wc -l)
        pct=$((done_count * 100 / total_files))
        [[ $pct -gt 99 ]] && pct=99
        if [[ $pct -ne $last_pct ]]; then
            echo "  Compressing textures... ${pct}%"
            last_pct=$pct
            if [[ $pct -ge 25 && $t25 -eq 0 ]]; then
                echo "  A quarter done! Charlie Murder was released on August 14, 2013 by Ska Studios."
                t25=1
            fi
            if [[ $pct -ge 50 && $t50 -eq 0 ]]; then
                echo "  Halfway there! The game has about 8 hours -- the speedrun record is around 28 minutes, faster than this patch."
                t50=1
            fi
            if [[ $pct -ge 75 && $t75 -eq 0 ]]; then
                echo "  Almost done! Hope you're ready to rock."
                t75=1
            fi
        fi
    done
    wait $astc_pid
    local astc_exit=$?
    rm -f "$marker"

    if [[ $astc_exit -ne 0 ]]; then
        rm -f "${gamedir}/gamedata/.astc_done"
        return 1
    fi
    touch "${gamedir}/gamedata/.astc_done"
    echo "Texture compression complete. OK"
echo "ASTC-Repack done: $(date '+%H:%M:%S') (Duration: $(( $(date +%s) - SETUP_START ))s)" >> "$TIMING_LOG"
    return 0
}

(patch_step) & pid_patch=$!
(astc_step)  & pid_astc=$!

wait $pid_astc;  astc_status=$?
wait $pid_patch; patch_status=$?

patch_failed=0
while IFS= read -r line; do
    if [[ "$line" == "__FAILED__" ]]; then
        patch_failed=1
        continue
    fi
    echo "$line"
    sleep 0.5
done < "$PATCH_BUFFER"
rm -f "$PATCH_BUFFER"

if [[ $astc_status -ne 0 ]] || [[ $patch_status -ne 0 ]] || [[ $patch_failed -eq 1 ]]; then
    fail "Patching or texture compression failed."
fi

echo "=== First Setup done: $(date '+%H:%M:%S') (Duration: $(( $(date +%s) - SETUP_START ))s) ===" >> "$TIMING_LOG"

exit 0