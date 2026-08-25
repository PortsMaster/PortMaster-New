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

to_lower_case() {
    find "$1" -depth \( -name "*.PAK" -o -name "PAK0.pak" \) | while IFS= read -r SRC; do
        DST=$(dirname "$SRC")/$(basename "$SRC" | tr '[:upper:]' '[:lower:]')
        TMP_DST=$(dirname "$SRC")/temp_$(basename "$SRC" | tr '[:upper:]' '[:lower:]')
        if [ "$SRC" != "$DST" ]; then
            $ESUDO mv -vf "$SRC" "$TMP_DST"
            $ESUDO mv -vf "$TMP_DST" "$DST"
        fi
    done
}

GAMEDIR="/$directory/ports/quakespasm"

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ] && [ "${CFW_NAME^^}" != "KNULLI" ] && [ "${DEVICE_ARCH}" != "x86_64" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

to_lower_case "$GAMEDIR/mg3"
to_lower_case "$GAMEDIR/id1"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/quakespasm.${DEVICE_ARCH}"
$ESUDO chmod +x "$GAMEDIR/text_viewer.${DEVICE_ARCH}"

if [[ "${DEVICE_NAME^^}" == "X55" ]] || [[ "${DEVICE_NAME^^}" == "RG353P" ]] || [[ "${DEVICE_NAME^^}" == "RG40XX-H" ]] || [[ "${CFW_NAME^^}" == "RETRODECK" ]]; then
    GPTOKEYB_CONFIG="$GAMEDIR/quakespasmtriggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/quakespasm.gptk"
fi

# Scale menu, HUD, console, and status bar based on screen resolution
SSCALE=1.2
[ "${DISPLAY_WIDTH}" == "480" ] && SSCALE=1.1
[ "${DISPLAY_WIDTH}" == "512" ] && SSCALE=1.2
[ "${DISPLAY_WIDTH}" == "640" ] && SSCALE=1.5
[ "${DISPLAY_WIDTH}" == "720" ] && SSCALE=1.7
[ "${DISPLAY_WIDTH}" == "800" ] && SSCALE=1.9
[ "${DISPLAY_WIDTH}" == "854" ] && SSCALE=2.0
[ "${DISPLAY_WIDTH}" == "960" ] && SSCALE=2.2
[ "${DISPLAY_WIDTH}" == "1024" ] && SSCALE=2.4
[ "${DISPLAY_WIDTH}" == "1152" ] && SSCALE=2.7
[ "${DISPLAY_WIDTH}" == "1280" ] && SSCALE=3.0
[ "${DISPLAY_WIDTH}" == "1360" ] && SSCALE=3.2
[ "${DISPLAY_WIDTH}" == "1366" ] && SSCALE=3.2
[ "${DISPLAY_WIDTH}" == "1400" ] && SSCALE=3.3
[ "${DISPLAY_WIDTH}" == "1440" ] && SSCALE=3.4
[ "${DISPLAY_WIDTH}" == "1600" ] && SSCALE=3.8
[ "${DISPLAY_WIDTH}" == "1680" ] && SSCALE=3.8
[ "${DISPLAY_WIDTH}" == "1920" ] && SSCALE=4.5

if [ ! -f "$GAMEDIR/mg3/pak0.pak" ]; then
    ./text_viewer.${DEVICE_ARCH} -f 25 -w -t "Missing gamedata" -m "Please place your pak0.pak into the ports/quakespasm/mg3 directory and, optionally, the music tracks as track##.ogg in ports/quakespasm/mg3/music.  Press 'Select' to exit this text viewer."
    exit 1
fi

if [ ! -f "$GAMEDIR/id1/pak1.pak" ] && [ "$(stat -c %s "$GAMEDIR/id1/pak0.pak")" -lt 70000000 ]; then
    ./text_viewer.${DEVICE_ARCH} -f 25 -w -t "Missing gamedata" -m "Please place your registered pak1.pak or Nightdive pak0.pak into the ports/quakespasm/id1 directory (Dawn of the Machine requires the full registered copy of Quake to run).  Press 'Select' to exit this text viewer."
    exit 1
fi

# Sound fix for some devices running ArkOS and/or dArkOS
if [[ "${CFW_NAME^^}" == *"ARKOS"* ]]; then
    if [ ! -f ~/.asoundrc ] && [ -f ~/.asoundrcbak ]; then
        $ESUDO cp ~/.asoundrcbak ~/.asoundrc
        $ESUDO chmod ugo+rw ~/.asoundrc
        sleep 0.5
    fi
fi

# Load directly into an expansion, a map, or a mod
RUNMOD="-game mg3 +map start"

$GPTOKEYB "quakespasm.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
pm_platform_helper "$GAMEDIR/quakespasm.${DEVICE_ARCH}"

./quakespasm.${DEVICE_ARCH} -current +joy_enable 0 +r_oldwater 1 +r_particles 1 +r_shadows 0 +r_sky_quality 5 -noglsl \
   +scr_showfps 1 +scr_sbarscale $SSCALE +scr_menuscale $SSCALE +scr_conscale $SSCALE $RUNMOD

pm_finish
