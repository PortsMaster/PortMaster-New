#!/bin/bash
# Postal 2
# Porter: initdream

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

export PORT_32BIT="Y"

source $controlfolder/control.txt
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/$directory/ports/postal2"
CONFDIR="$GAMEDIR/conf"
BINARYNAME="postal2-bin"

REAL_XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/0}"
export HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
export XDG_CONFIG_HOME="$CONFDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$CONFDIR"

# "Postal 2 MP (first run).sh" passes "MP" so the multiplayer (promo build) 
# is used instead of the retail game files.

GAME_MODE="${1:-SP}"
if [[ "$GAME_MODE" == "MP" ]]; then
  GAME_SUBDIR="gamedatamp/System"
  echo "Mode: multiplayer (gamedatamp/System)"
else
  GAME_SUBDIR="gamedata/System"
  echo "Mode: single player (gamedata/System)"
fi

[ -f "$GAMEDIR/gamedatamp/System/postal2-bin" ] && chmod +x "$GAMEDIR/gamedatamp/System/postal2-bin"

if [ -d "$GAMEDIR/gamedatamp/System" ] && [ ! -f "$GAMEDIR/gamedata/System/.patched" ]; then
  if [ -f "$GAMEDIR/gamedatamp/System/postal2-bin" ]; then
    echo "Copying game binaries from MP to SP..."
    mkdir -p "$GAMEDIR/gamedata/System"
    rm -f "$GAMEDIR/gamedata/System"/*.so*
    rm -f "$GAMEDIR/gamedata/System/postal2-bin"
    if cp -L "$GAMEDIR/gamedatamp/System"/*.so* "$GAMEDIR/gamedata/System/" &&
       cp -L "$GAMEDIR/gamedatamp/System/postal2-bin" "$GAMEDIR/gamedata/System/" &&
       chmod +x "$GAMEDIR/gamedata/System/postal2-bin"; then
      touch "$GAMEDIR/gamedata/System/.patched"
    else
      echo "ERROR: copying MP binaries failed; .patched not set, will retry next run."
    fi
  else
    echo "WARNING: gamedatamp/System exists but has no postal2-bin (incomplete MP install); skipping copy."
  fi
fi

if [[ "$GAME_MODE" != "MP" ]] && [ ! -f "$GAMEDIR/gamedata/System/.patched" ]; then
  pm_message "Postal 2 setup incomplete: run 'Postal 2 MP (first run).sh' once (MP files required) before single player."
  sleep 5
  exit 1
fi

weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi

if [ ! -f "$GAMEDIR/libs.armhf/libSDL-1.2.so.0" ]; then
  pm_message "Postal 2 is missing libs.armhf/libSDL-1.2.so.0; reinstall the port."
  sleep 5
  exit 1
fi

chmod +x "$GAMEDIR/box86/box86"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}" 2>/dev/null
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

if [[ "$CFW_NAME" == "ROCKNIX" ]]; then
  use_westonwrap=0
  echo "Rocknix detected. Bypassing westonwrap."
else
  use_westonwrap=1
  echo "No native Wayland detected. Using westonwrap."
fi

use_gl4es=1
if [ "$use_westonwrap" -eq 0 ] && glxinfo 2>/dev/null | grep -q "OpenGL version string"; then
  use_gl4es=0
  echo "Native Desktop OpenGL detected. Bypassing GL4ES."
else
  echo "No native Desktop OpenGL detected. Falling back to GL4ES."
fi

if [[ "$CFW_NAME" == "ROCKNIX" ]] || [[ "$CFW_NAME" == "knulli" ]]; then
  pulse_path=/usr/lib32
  pulsecommon=$(ls $pulse_path/pulseaudio/libpulsecommon-*.0.so 2>/dev/null | head -n 1)
  audio_preload="$pulse_path/libpulse-simple.so:$pulsecommon"
else
  audio_preload=""
fi

WRAPPED_PRELOAD="$audio_preload"

NATIVE_WIDTH="${DISPLAY_WIDTH}"
NATIVE_HEIGHT="${DISPLAY_HEIGHT}"

if [ -z "$NATIVE_WIDTH" ] || [ -z "$NATIVE_HEIGHT" ]; then
  if command -v fbset >/dev/null 2>&1; then
    eval $(fbset | grep -o 'geometry [0-9]* [0-9]*' | awk '{print "NATIVE_WIDTH=" $2 "\nNATIVE_HEIGHT=" $3}')
  fi
fi

NATIVE_WIDTH="${NATIVE_WIDTH:-640}"
NATIVE_HEIGHT="${NATIVE_HEIGHT:-480}"

echo "Adjusting config viewport files to native display size: ${NATIVE_WIDTH}x${NATIVE_HEIGHT}"

for ini in "$GAMEDIR/gamedata/System/Postal2.ini" \
           "$GAMEDIR/gamedata/System/Postal2MP.ini" \
           "$CONFDIR/.lgp/postal2/System/Postal2.ini" \
           "$CONFDIR/.lgp/postal2/System/Postal2MP.ini"; do
  if [ -f "$ini" ]; then
    sed -i 's/master.gamespy.com/master.333networks.com/g' "$ini"
    sed -i "s/ViewportX=[0-9]*/ViewportX=${NATIVE_WIDTH}/g" "$ini"
    sed -i "s/ViewportY=[0-9]*/ViewportY=${NATIVE_HEIGHT}/g" "$ini"
    sed -i "s/FullscreenViewportX=[0-9]*/FullscreenViewportX=${NATIVE_WIDTH}/g" "$ini"
    sed -i "s/FullscreenViewportY=[0-9]*/FullscreenViewportY=${NATIVE_HEIGHT}/g" "$ini"
  fi
done

cd "$GAMEDIR/$GAME_SUBDIR"

box86_env=(
  CRUSTY_BLOCK_INPUT=1
  SDL_JOYSTICK_DISABLE=1
  SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
  TEXTINPUTINTERACTIVE="Y"
  BOX86_DYNAREC=1
  BOX86_DYNAREC_BIGBLOCK=0
  BOX86_ALLOWMISSINGLIBS=1
)

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_TOUCH_MOUSE_EVENTS=0

$GPTOKEYB2 "postal2-bin" -c "$GAMEDIR/postal2.ini" &
pm_platform_helper "$GAMEDIR/box86/box86"

if [ "$use_westonwrap" -eq 1 ]; then
  $ESUDO env "${box86_env[@]}" \
  LD_LIBRARY_PATH="$GAMEDIR/gl4es:/usr/lib/arm-linux-gnueabihf:/usr/lib32:$GAMEDIR/libs.armhf:$LD_LIBRARY_PATH" \
  BOX86_LD_LIBRARY_PATH="$GAMEDIR/libs.armhf/x86:$GAMEDIR/box86/x86:$GAMEDIR/gamedata/System" \
  WRAPPED_PRELOAD="$WRAPPED_PRELOAD" \
  $weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es \
  XDG_RUNTIME_DIR="$REAL_XDG_RUNTIME_DIR" \
  HOME="$CONFDIR" \
  XDG_DATA_HOME="$CONFDIR" \
  XDG_CONFIG_HOME="$CONFDIR" \
  $GAMEDIR/box86/box86 \
  ./$BINARYNAME -windowed
else
  if [ "$use_gl4es" -eq 1 ]; then
    LD_PATH="$GAMEDIR/gl4es:/usr/lib/arm-linux-gnueabihf:/usr/lib32:$GAMEDIR/libs.armhf:/tmp/weston/lib_armhf:$LD_LIBRARY_PATH"
  else
    LD_PATH="/usr/lib/arm-linux-gnueabihf:/usr/lib32:$GAMEDIR/libs.armhf:/tmp/weston/lib_armhf:$LD_LIBRARY_PATH"
  fi

  $ESUDO env "${box86_env[@]}" \
  DISPLAY=":0" \
  LD_LIBRARY_PATH="$LD_PATH" \
  BOX86_LD_LIBRARY_PATH="$GAMEDIR/libs.armhf/x86:$GAMEDIR/box86/x86:$GAMEDIR/$GAME_SUBDIR:$GAMEDIR/gamedata/System" \
  LD_PRELOAD="$WRAPPED_PRELOAD" \
  HOME="$CONFDIR" \
  XDG_DATA_HOME="$CONFDIR" \
  XDG_CONFIG_HOME="$CONFDIR" \
  $GAMEDIR/box86/box86 \
  ./$BINARYNAME
fi

if [ "$use_westonwrap" -eq 1 ]; then
  $ESUDO $weston_dir/westonwrap32.sh cleanup
fi

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi

pm_finish