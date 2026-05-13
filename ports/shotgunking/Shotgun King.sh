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
GAMEDIR="/$directory/ports/shotgunking"
BINARY="gamedata/shotgun_king.app/Contents/MacOS/shotgun_king"

# Check for game files
if [ ! -f "$GAMEDIR/$BINARY" ]; then
    pm_message "Game files not found. See README.md for installation instructions."
    sleep 15
    exit 1
fi

# Audio optimization: re-encode OGG/WAV to 22050 Hz mono to reduce
# decoded PCM memory (Sugar engine decodes all audio at startup).
# Runs once on first launch via PortMaster's patcher framework. Re-runs
# when the stick count changes (SD card moved between devices) so the
# one-stick aim mutation gets added or removed accordingly. Suffix
# format must match WANT_VERSION composition in patch/patch.bash.
export ANALOGSTICKS
WANT_PATCH_VERSION="$(cat "$GAMEDIR/patch/version" 2>/dev/null).s${ANALOGSTICKS:-x}"
HAVE_PATCH_VERSION="$(cat "$GAMEDIR/gamedata/.patched" 2>/dev/null)"
if [ "$HAVE_PATCH_VERSION" != "$WANT_PATCH_VERSION" ]; then
    PATCHER_TIME="~2 minutes"
fi
if [ -n "${PATCHER_TIME:-}" ]; then
    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Shotgun King"
    export PATCHER_TIME
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi
    if [ "$(cat "$GAMEDIR/gamedata/.patched" 2>/dev/null)" != "$WANT_PATCH_VERSION" ]; then
        echo "Patching failed"
        sleep 5
        exit 1
    fi
fi

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Redirect game save data to port directory
mkdir -p "$GAMEDIR/userdata"

# Display loading splash while game initializes
[ "$CFW_NAME" == "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1
$ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 8000 &

# Run game via machismo (Mach-O loader)
# libsystem_shim redirects the macOS OpenGL.framework dlopen to libGL.so.1.
# `shaderless` skips the CRT post-process shader — on Adreno (Snapdragon)
# + Mesa the uniforms get silently eliminated and the final blit comes out
# black even though the scene underneath draws fine. Wider-compat default.
# All stick configurations use xbox360 controller passthrough now. Aim on
# stickless devices is handled by the DPAD-AIM Lua mutation in patch.bash
# (hold L2 + dpad L/R rotates aim) — no gptokeyb2 mouse overlay needed.
$GPTOKEYB "machismo" &
pm_platform_helper "$GAMEDIR/bin/machismo" > /dev/null
$ESUDO env \
    SDL_GAMEPADMAPPINGS="$sdl_controllerconfig" \
    LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}" \
    MACHISMO_CONFIG="$GAMEDIR/conf/machismo.conf" \
    MACHISMO_HOME="$GAMEDIR/userdata" \
    XDG_DATA_HOME="$GAMEDIR/userdata" \
    XDG_CONFIG_HOME="$GAMEDIR/userdata" \
    MESA_NO_ERROR=1 \
    "$GAMEDIR/bin/machismo" "$BINARY" shaderless

pm_finish
