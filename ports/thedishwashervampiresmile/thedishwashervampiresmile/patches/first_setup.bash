#!/bin/bash

astc_quality=60.0
PATCHLOG="$GAMEDIR/patchlog.txt"
PATCH_BUFFER="/tmp/dvs_patch_buffer_$$.txt"
> "$PATCHLOG"
> "$PATCH_BUFFER"

if tee -p /dev/null < /dev/null 2>/dev/null; then
    exec > >(tee -p -a "$PATCHLOG") 2>&1
else
    exec > >(tee -a "$PATCHLOG") 2>&1
fi

TIMING_LOG="$GAMEDIR/timing.log"
echo "=== First Setup start: $(date '+%Y-%m-%d %H:%M:%S') ===" > "$TIMING_LOG"
SETUP_START=$(date +%s)

log() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$PATCHLOG"
}

fail() {
    echo ""
    echo "ERROR: $1"
    echo "PATCH_FAIL_MSG:$1 See patchlog.txt."
    log "FATAL: $1"
    echo ""
    echo "Patching process failed!"
    rm -f "$PATCH_BUFFER"
    exit 1
}

# Mac resource forks break the repacker
find "$GAMEDIR" \( -name "._*" -o -name ".DS_Store" \) -type f -delete 2>/dev/null

# Language selection (answer comes from patcher_questions.lua)
if [[ -n "$DVS_LANGUAGE" ]]; then
    if [[ "$DVS_LANGUAGE" == "en_US.UTF-8" ]]; then
        rm -f "$GAMEDIR/lang.txt"
    else
        echo "$DVS_LANGUAGE" > "$GAMEDIR/lang.txt"
    fi
    log "Language set to: $DVS_LANGUAGE"
fi

# MonoMod/FixTypeRef
patch_step() {
    if [[ -f "$GAMEDIR/gamedata/MONOMODDED_${ASSEMBLY}" ]] && sha1sum -c "$GAMEDIR/gamedata/.ver_checksum" > /dev/null 2>&1; then
        return 0
    fi
    echo "Applying game patches..." >> "$PATCH_BUFFER"
    export MONOMOD_MODS="$GAMEDIR/patches"
    export MONOMOD_DEPDIRS="${MONO_PATH}":"${GAMEDIR}/monomod":"${GAMEDIR}/dlls"
    (
        set -e
        mono "$GAMEDIR/monomod/MonoMod.exe" "$GAMEDIR/gamedata/${ASSEMBLY}" >> "$PATCHLOG" 2>&1
        (cd "$GAMEDIR/monomod" && mono FixTypeRef.exe "$GAMEDIR/gamedata/MONOMODDED_${ASSEMBLY}") >> "$PATCHLOG" 2>&1
    )
    if [[ $? -ne 0 ]]; then
        rm -f "$GAMEDIR/gamedata/MONOMODDED_${ASSEMBLY}" "$GAMEDIR/gamedata/.ver_checksum"
        echo "__FAILED__" >> "$PATCH_BUFFER"
        return 1
    fi
    sha1sum "$GAMEDIR/gamedata/${ASSEMBLY}" > "$GAMEDIR/gamedata/.ver_checksum"
    sha1sum "$GAMEDIR/patches/"*.dll >> "$GAMEDIR/gamedata/.ver_checksum"
    echo "Game patches applied. OK" >> "$PATCH_BUFFER"
    echo "MonoMod/FixTypeRef done: $(date '+%H:%M:%S') (Duration: $(( $(date +%s) - SETUP_START ))s)" >> "$TIMING_LOG"
    return 0
}

astc_step() {
    if [[ -f "$GAMEDIR/gamedata/.astc_done" ]]; then
        return 0
    fi
    echo "Let's go!"
    echo "Compressing textures, this takes the longest..."
    export ASTC_QUALITY="$astc_quality"

    local content_dir="$GAMEDIR/gamedata/Content"
    local total_files
    total_files=$(find "$content_dir" -type f -name "*.xnb" 2>/dev/null | wc -l)
    [[ "$total_files" -lt 1 ]] && total_files=1

    local marker="/tmp/dvs_astc_marker_$$"
    touch "$marker"

    mono "$GAMEDIR/FNARepacker.exe" "$content_dir/" >> "$PATCHLOG" 2>&1 &
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
                echo "INFO: A quarter done! Vampire Smile was released on Xbox Live Arcade on April 6, 2011."
                t25=1
            fi
            if [[ $pct -ge 50 && $t50 -eq 0 ]]; then
                echo "INFO: Halfway there! It takes about 4,5 hours to beat the main game."
                t50=1
            fi
            if [[ $pct -ge 75 && $t75 -eq 0 ]]; then
                echo "INFO: Almost done! Yuki and the Dishwasher are almost ready. The speedrun record for this game is only one hour. You'll need 6,5 hours to make it through the main game and the sidequests."
                t75=1
            fi
        fi
    done
    wait $astc_pid
    local astc_exit=$?
    rm -f "$marker"

    if [[ $astc_exit -ne 0 ]]; then
        rm -f "$GAMEDIR/gamedata/.astc_done"
        return 1
    fi
    touch "$GAMEDIR/gamedata/.astc_done"
    echo "Texture compression complete. OK"
    echo "ASTC-Repack done: $(date '+%H:%M:%S') (Duration: $(( $(date +%s) - SETUP_START ))s)" >> "$TIMING_LOG"
    return 0
}

# Button layout: Nintendo-style button colours via binary diff (xdelta)
if [[ "$DVS_BUTTONLAYOUT" == "nintendo" && ! -f "$GAMEDIR/gamedata/.astc_done" && ! -f "$GAMEDIR/gamedata/.nintendo_done" ]]; then
    xdelta_bin="$controlfolder/xdelta3"
    xdelta_file="$GAMEDIR/patches/sprites-nintendo.xdelta"
    target_list=$(find "$GAMEDIR/gamedata/Content" -type f -iname "sprites.xnb")
    target_count=$(printf '%s\n' "$target_list" | grep -c .)
    if [[ ! -f "$xdelta_bin" ]] || [[ ! -f "$xdelta_file" ]]; then
        echo "WARNING: xdelta3 or sprites-nintendo.xdelta not found - skipping Nintendo button colours."
        log "WARNING: xdelta3 ($xdelta_bin) or $xdelta_file missing - skipping."
    elif [[ "$target_count" -ne 1 ]]; then
        echo "WARNING: expected exactly 1 sprites.xnb, found ${target_count} - skipping Nintendo button colours."
        log "WARNING: expected exactly 1 sprites.xnb in Content, found ${target_count} - skipping."
    elif "$xdelta_bin" -d -s "$target_list" "$xdelta_file" "${target_list}.new" && mv "${target_list}.new" "$target_list"; then
        touch "$GAMEDIR/gamedata/.nintendo_done"
        log "Applied Nintendo-style button colours before ASTC repack: ${target_list}"
    else
        rm -f "${target_list}.new"
        echo "WARNING: Could not apply the Nintendo button colours - continuing with the original ones."
        log "WARNING: xdelta failed on ${target_list} - continuing with original colours."
    fi
fi

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