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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/ut99
DATADIR="$GAMEDIR/gamedata"
RUNDIR="$DATADIR/SystemARM64"
CONFDIR="$GAMEDIR/conf"
GAME_WIDTH=${DISPLAY_WIDTH:-1280}
GAME_HEIGHT=${DISPLAY_HEIGHT:-720}

if [ "$GAME_WIDTH" -ge 1200 ]; then
  GUI_SCALE=2.000000
elif [ "$GAME_WIDTH" -ge 960 ]; then
  GUI_SCALE=1.500000
elif [ "$GAME_WIDTH" -ge 800 ]; then
  GUI_SCALE=1.250000
else
  GUI_SCALE=1.000000
fi

cd "$GAMEDIR" || exit 1
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ "${DEVICE_HAS_AARCH64:-N}" != "Y" ] && [ "$DEVICE_ARCH" != "aarch64" ]; then
  pm_message "Unreal Tournament 99 requires a 64-bit ARM device."
  exit 1
fi

if [ -z "$(find "$DATADIR/Maps" -maxdepth 1 -type f -iname '*.unr' -print -quit 2>/dev/null)" ]; then
  pm_message "Game data is missing. Copy Maps, Music, and Sounds from a legal UT99 installation into ports/ut99/gamedata, then merge its Textures folder without replacing the included patch fonts. Do not copy the original System folder."
  exit 1
fi

mkdir -p "$CONFDIR"
[ -f "$CONFDIR/UnrealTournament.ini" ] || cp "$GAMEDIR/config/UnrealTournament.ini" "$CONFDIR/UnrealTournament.ini"
[ -f "$CONFDIR/User.ini" ] || cp "$GAMEDIR/config/User.ini" "$CONFDIR/User.ini"

sed -i -E \
  -e "s/^(WindowedViewportX|FullscreenViewportX)=.*/\1=${GAME_WIDTH}/" \
  -e "s/^(WindowedViewportY|FullscreenViewportY)=.*/\1=${GAME_HEIGHT}/" \
  -e 's/^(WindowedColorBits|FullscreenColorBits)=.*/\1=32/' \
  -e 's/^(GameRenderDevice|WindowedRenderDevice|RenderDevice)=.*/\1=NOpenGLESDrv.NOpenGLESRenderDevice/' \
  -e 's/^ViewportManager=.*/ViewportManager=SDLDrv.SDLClient/' \
  -e 's/^StartupFullscreen=.*/StartupFullscreen=True/' \
  -e 's/^ContextType=.*/ContextType=Compatibility/' \
  -e 's/^ColorCorrectionMode=.*/ColorCorrectionMode=InShader/' \
  -e 's/^UseLightmapAtlas=.*/UseLightmapAtlas=False/' \
  -e 's/^UseStaticGeometry=.*/UseStaticGeometry=False/' \
  -e 's/^UseDrawGouraud469=.*/UseDrawGouraud469=False/' \
  -e 's/^UseVAO=.*/UseVAO=False/' \
  -e 's/^UseBGRA=.*/UseBGRA=False/' \
  -e "s/^ConfiguredGUIScale=.*/ConfiguredGUIScale=${GUI_SCALE}/" \
  -e 's/^AutoGUIScale=.*/AutoGUIScale=False/' \
  -e 's/^(OutputRate|SampleRate)=.*/\1=48000Hz/' \
  "$CONFDIR/UnrealTournament.ini"

bind_files "$RUNDIR/UnrealTournament.ini" "$CONFDIR/UnrealTournament.ini"
bind_files "$RUNDIR/User.ini" "$CONFDIR/User.ini"

export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$RUNDIR:$LD_LIBRARY_PATH"

# Supply the encodings required by UT469 on every firmware.
if [ -d "$GAMEDIR/gconv" ]; then
  export GCONV_PATH="$GAMEDIR/gconv${GCONV_PATH:+:$GCONV_PATH}"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export UT99_GUI_SCALE="$GUI_SCALE"

if [ "${CFW_NAME:-}" = "ROCKNIX" ]; then
  export SDL_HINT_APP_NAME="${SDL_HINT_APP_NAME:-Unreal Tournament}"
  export SDL_OPENGL_ES_DRIVER="${SDL_OPENGL_ES_DRIVER:-1}"
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
fi

# Keep relative aim centered instead of allowing SDL's virtual cursor to hit
# the edge of its internal window.
export SDL_MOUSE_RELATIVE_MODE_WARP=1
export SDL_MOUSE_RELATIVE_MODE_CENTER=1

chmod +x "$RUNDIR/ut-bin-arm64"
cd "$RUNDIR" || exit 1

$GPTOKEYB2 "ut-bin-arm64" -c "$GAMEDIR/ut99.gptk" &
pm_platform_helper "$RUNDIR/ut-bin-arm64" >/dev/null

echo "UT99 PortMaster build=gconv-all-v3: device=${DEVICE_NAME:-unknown} cfw=${CFW_NAME:-unknown} cpu=${DEVICE_CPU:-unknown} display=${GAME_WIDTH}x${GAME_HEIGHT} gui=${GUI_SCALE}"
./ut-bin-arm64

pm_finish
