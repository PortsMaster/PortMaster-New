#!/bin/bash

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
get_controls

# Variables
GAMEDIR="/$directory/ports/mina"
BUNDLE="$GAMEDIR/gamedata/Mina the Hollower.app"
BINARY="$BUNDLE/Contents/MacOS/MinaTheHollower"

# Resolve an already-installed bundle. Accept the bundle anywhere one level
# under gamedata so a renamed/nested copy (e.g. a Steam depot folder) still
# works; the patcher uses the same search.
resolve_bundle() {
    if [ ! -f "$BINARY" ]; then
        # Plain shell glob, not find: BusyBox find lacks -maxdepth/-quit on some
        # firmwares. Check the top level and one dir down (e.g. a Steam depot).
        for d in "$GAMEDIR/gamedata"/*.app "$GAMEDIR/gamedata"/*/*.app; do
            if [ -d "$d" ] && [ -f "$d/Contents/MacOS/MinaTheHollower" ]; then
                BUNDLE="$d"
                BINARY="$BUNDLE/Contents/MacOS/MinaTheHollower"
                break
            fi
        done
    fi
}
resolve_bundle

# Decide whether the patcher must run. The patcher unpacks the game from a GOG
# .pkg installer or a Steam Mac depot (when no bundle is in place yet) and then
# generates the GLSL ES shader corpus from the user's own game copy. Runs before
# the log redirect (FUSE/exFAT O_TRUNC caution, same as Dead Cells).
WANT_VER="$(cat "$GAMEDIR/patch/corpus.version")"
HAVE_VER="$(cat "$GAMEDIR/gamedata/.shaders_ready" 2>/dev/null)"
RUN_PATCHER=""

if [ ! -f "$BINARY" ]; then
    # No installed bundle yet — only proceed if there's a GOG installer to
    # unpack (a Steam depot's nested .app is already found by resolve_bundle).
    if ls "$GAMEDIR/gamedata/"*.pkg >/dev/null 2>&1; then
        echo "GOG installer found. Running patcher..."
        RUN_PATCHER=1
    else
        pm_message "Game files not found. See README.md for installation instructions."
        sleep 15
        exit 1
    fi
elif [ "$HAVE_VER" != "$WANT_VER" ]; then
    RUN_PATCHER=1
fi

if [ -n "$RUN_PATCHER" ]; then
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Mina the Hollower"

    # GOG extraction needs temporary space: the installer (~0.8GB) and the
    # extracted bundle (~0.8GB) coexist briefly before the .pkg is removed.
    # Subtracting current folder size accounts for the installer already on disk.
    if ls "$GAMEDIR/gamedata/"*.pkg >/dev/null 2>&1; then
        export PATCHER_TIME="5-10 minutes"
        PEAK_KB=$((2 * 1024 * 1024))
        CURRENT_KB=$(du -sk "$GAMEDIR/gamedata" | cut -f1)
        FREE_KB=$(df -k "$GAMEDIR/gamedata" | tail -1 | awk '{print $4}')
        NEEDED_KB=$((PEAK_KB - CURRENT_KB))
        if [ "$NEEDED_KB" -gt 0 ] && [ "$FREE_KB" -lt "$NEEDED_KB" ]; then
            FREE_GB=$(awk "BEGIN {printf \"%.1f\", $FREE_KB / 1048576}")
            NEEDED_GB=$(awk "BEGIN {printf \"%.1f\", $NEEDED_KB / 1048576}")
            pm_message "Not enough disk space to extract the GOG installer. Need ${NEEDED_GB}GB free but only ${FREE_GB}GB available. Free up space and try again."
            sleep 15
            exit 1
        fi
    else
        export PATCHER_TIME="1-2 minutes"
    fi

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
    else
        pm_message "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi

    # The patcher may have just installed the bundle — re-resolve.
    resolve_bundle

    HAVE_VER="$(cat "$GAMEDIR/gamedata/.shaders_ready" 2>/dev/null)"
    if [ ! -f "$BINARY" ] || [ "$HAVE_VER" != "$WANT_VER" ]; then
        pm_message "Setup failed — see patchlog.txt in the port folder."
        sleep 5
        exit 1
    fi
fi

# Final sanity: the bundle must include its data dir.
if [ ! -s "$BUNDLE/Contents/Resources/data/shaders.pak.yc" ]; then
    pm_message "The app copy is incomplete (missing Contents/Resources/data). Re-copy the whole 'Mina the Hollower.app'."
    sleep 15
    exit 1
fi

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Run the game via machismo (Mach-O loader). The Apple-Silicon arm64 binary
# runs natively; libgothic_patches.so replaces the Metal renderer with GLES and
# provides the objc_msgSend / Metal-device shim. SDL2 (statically linked in the
# game) is trampolined to the device's native libSDL2 (KMSDRM + Mali GLES).
#
#   GOTHIC_BASE_PATH  — overrides SDL_GetBasePath so the engine finds Resources/data.
#   GOTHIC_SHADER_DIR — our SPIRV-Cross GLSL ES corpus, loaded by logical key.
#
# We intentionally let SDL install its SIGINT/SIGTERM handlers (do NOT set
# SDL_NO_SIGNAL_HANDLERS): the exit hotkey's SIGTERM must reach SDL so it posts
# SDL_QUIT and the engine runs its clean shutdown, which closes the SDL/ALSA
# audio device (SDL_CloseAudioDevice → snd_pcm_close). Skipping that close leaves
# the handheld's audio device wedged for every other app until reboot. (The
# shutdown used to stall joining the game thread; libgothic_patches now wakes it
# so the close completes — see objc_shim.c -isFinished.)
$GPTOKEYB "machismo" &
pm_platform_helper "$GAMEDIR/bin/machismo" > /dev/null

# Shader corpus directories, both generated at install time from the user's own
# game copy (see patch/patch.bash). libgothic_patches auto-prefers the Vulkan
# backend and loads SPIR-V from GOTHIC_VK_SHADER_DIR; if Vulkan is unavailable it
# falls back to GLES and loads GLSL ES from GOTHIC_SHADER_DIR (each by logical
# key — see gl_program.cpp / vk_program.cpp).
: "${GOTHIC_SHADER_DIR:=$GAMEDIR/gamedata/shaders_gles}"
: "${GOTHIC_VK_SHADER_DIR:=$GAMEDIR/gamedata/shaders_spv}"
echo "gothic: corpus=$GOTHIC_SHADER_DIR vk_corpus=$GOTHIC_VK_SHADER_DIR"

# Mali driver selection: strip EmulationStation's stale g13 libmali dir from the
# path (it appends /opt/emulationstation/lib so it can shadow a good system g24).
#
# Vulkan now renders directly on the device's g24+ libmali (libgothic_patches
# auto-prefers the Vulkan backend — see gothic_rhi.cpp select_backend), so it
# sidesteps the GLES tiler defects that forced the old workarounds entirely. The
# former GLES-via-/opt/vulkan/libmali.so soname-symlink farm (which redirected
# EGL/GLES/GBM to the Vulkan blob on rk3566 dArkOS, whose GLES stack defaults to
# the frozen-region g13) is therefore GONE. The ES-strip stays as cheap insurance
# for the GLES fallback path on devices where ES's g13 shadows the system g24.
LD_LIBRARY_PATH=$(printf '%s' "${LD_LIBRARY_PATH:-}" | tr ':' '\n' \
    | grep -vxF '/opt/emulationstation/lib' | paste -sd: -)

# Optional frame-rate logging (diagnostic). machismo prints fps to log.txt when
# MACHISMO_FPS is set, but it must be forwarded explicitly below — $ESUDO (sudo)
# scrubs the environment, so an exported value would not survive to the loader.
# Off by default; enable on-device without editing this script:
#   touch "$GAMEDIR/fps.on"          # report every 1s
#   echo 2 > "$GAMEDIR/fps.on"       # report every 2s (file contents = interval)
#   rm "$GAMEDIR/fps.on"             # disable
MACHISMO_FPS="${MACHISMO_FPS:-}"
if [ -f "$GAMEDIR/fps.on" ]; then
    MACHISMO_FPS="$(cat "$GAMEDIR/fps.on" 2>/dev/null)"
    [ -z "$MACHISMO_FPS" ] && MACHISMO_FPS=1
fi

# PowerVR Vulkan ICD for the TrimUI A133P (Smart Pro / Brick). libgothic_patches
# auto-prefers the Vulkan backend and reaches the IMG DDK through the Khronos loader
# (libvulkan.so.1), but the A133P firmware ships no ICD manifest, so the loader finds
# no driver and the probe would fall back to GLES. Write a minimal manifest pointing
# at libVK_IMG and hand it to the loader via VK_ICD_FILENAMES. Gated on DEVICE_CPU so
# every other device keeps its own ICD / GLES path untouched. /tmp is tmpfs (recreated
# each boot, so this is rebuilt every launch). api_version MUST be "1.0.0" — libVK_IMG
# is rejected by the loader if the manifest advertises a higher version.
VK_ICD_ARG=()
if [ "$DEVICE_CPU" = "a133plus" ]; then
    printf '%s\n' '{ "file_format_version": "1.0.0", "ICD": { "library_path": "/usr/lib/libVK_IMG.so.1", "api_version": "1.0.0" } }' > /tmp/img_icd.json
    VK_ICD_ARG=(VK_ICD_FILENAMES="/tmp/img_icd.json")
    echo "gothic: TrimUI A133P — registered PowerVR Vulkan ICD (libVK_IMG)"
fi

## rg52-mini has a portrait screen which rotates vulkan so we force gles
if [ "$DEVICE_NAME" = "RG52MINI" ]; then
    export GOTHIC_BACKEND = "gles"
fi

## uncomment this if you have rendering issues on high end hardware on rocknix
#export GOTHIC_BACKEND = "gles"

$ESUDO env \
    "${SDLVID_ARG[@]}" \
    "${VK_ICD_ARG[@]}" \
    SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" \
    MALLOC_ARENA_MAX=2 \
    MACHISMO_FPS="$MACHISMO_FPS" \
    LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH" \
    MACHISMO_CONFIG="$GAMEDIR/conf/machismo.conf" \
    MACHISMO_HOME="$GAMEDIR/userdata" \
    HOME="$GAMEDIR/userdata" \
    XDG_DATA_HOME="$GAMEDIR/userdata" \
    XDG_CONFIG_HOME="$GAMEDIR/userdata" \
    GOTHIC_BASE_PATH="$BUNDLE/Contents/Resources/" \
    GOTHIC_SHADER_DIR="$GOTHIC_SHADER_DIR" \
    GOTHIC_VK_SHADER_DIR="$GOTHIC_VK_SHADER_DIR" \
    "$GAMEDIR/bin/machismo" "$BINARY"

$ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
pm_finish
