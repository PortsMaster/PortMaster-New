#!/bin/bash

# PortMaster preamble
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

# Port variables
GAMEDIR=/$directory/ports/environmentalstationalpha
GAME="Chowdren"

# Set up logging. log.txt will be overwritten with each new launch of the game.
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check for/install the game files
if [ -d "$GAMEDIR/gamedata" ]; then
  REQUIRED_FILES=(
    "Data:Data"
    "Assets.dat:Assets.dat"
    "$GAME:bin64/Chowdren"
    "icon.bmp:icon.bmp"
  )
  for ENTRY in "${REQUIRED_FILES[@]}"; do
    # Split the pair: Left side of colon is DEST, right side is SRC
    DEST_NAME="${ENTRY%%:*}"
    SRC_NAME="${ENTRY##*:}"
    if [ ! -e "$GAMEDIR/$DEST_NAME" ]; then
      echo "$GAMEDIR/$DEST_NAME missing! Checking $GAMEDIR/gamedata/ ..."
      if [ -e "$GAMEDIR/gamedata/$SRC_NAME" ]; then
        mv -fv "$GAMEDIR/gamedata/$SRC_NAME" "$GAMEDIR/$DEST_NAME"
      else
        echo "$GAMEDIR/gamedata/$SRC_NAME not found!"
        pm_message "Game files not found. Please provide your copy of the game as described by the instructions."
        sleep 5
        exit 1
      fi
    fi
  done
  # Clean up the leftover game installation files if we made it this far
  echo "Game installed! Purging $GAMEDIR/gamedata/..."
  rm -rfv "$GAMEDIR/gamedata"
fi

# Prepare the westonpack runtime
weston_dir="/tmp/weston"
$ESUDO mkdir -pv "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# This is required on ROCKNIX-panfrost, when westonpack bypasses itself
if [[ "${CFW_NAME^^}" == *"ROCKNIX"* ]] && glxinfo | grep "OpenGL version string"; then
  echo "ROCKNIX-Panfrost detected! Enabling fixes..."
  sdl_vid="x11"
  focus_fix=1
fi

# Enter the port directory and log the state of said directory
echo "entering $GAMEDIR"
cd $GAMEDIR
echo "ls -lAh $GAMEDIR:"
ls -lAh $GAMEDIR

# Ensure executable permissions
$ESUDO chmod -v +x "$GAMEDIR/$GAME"
$ESUDO chmod -v +x "$GAMEDIR/box64"

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Launch the game
$GPTOKEYB2 "$GAME" -c "$GAMEDIR/$GAME.ini" &>/dev/null &
pm_platform_helper "$GAME"
$ESUDO env CRUSTY_BLOCK_INPUT=1 WRAPPED_PRELOAD_PANFROST="$GAMEDIR/libs.aarch64/libcrusty_inputblocker.so" \
  $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
  BOX64_LD_LIBRARY_PATH="$GAMEDIR/libs.x64" BOX64_DYNAREC=1 BOX64_DYNAREC_CALLRET=1 \
  BOX64_LD_PRELOAD="$GAMEDIR/libs.x64/esa-chowdren-shim.so" \
  SDL_VIDEODRIVER="$sdl_vid" ESA_SHIM_FOCUS=$focus_fix ESA_SHIM_SAVEDATA=1 \
  ./box64 "./$GAME"

# Cleanup
sleep 2s # unmounts are sometimes missed, otherwise
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${weston_dir}"
fi
pm_finish
