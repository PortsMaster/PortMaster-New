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

# Adjust these to your paths and desired godot version
GAMEDIR=/$directory/ports/riseofthepenguinsgb
pck_filename="riseofthepenguinsgb.pck"
gptk_filename="riseofthepenguinsgb.gptk"

# Godot runtime selection with fallback (prefer 4.5, fallback to 4.4, then 4.3)
if [ -f "$controlfolder/libs/godot_4.5.squashfs" ]; then
    godot_runtime="godot_4.5"
    godot_executable="godot45.$DEVICE_ARCH"
elif [ -f "$controlfolder/libs/godot44.squashfs" ]; then
    godot_runtime="godot44"
    godot_executable="godot44.$DEVICE_ARCH"
elif [ -f "$controlfolder/libs/godot43.squashfs" ]; then
    godot_runtime="godot43"
    godot_executable="godot43.$DEVICE_ARCH"
else
    # Default to godot_4.5 and let harbourmaster try to download it
    godot_runtime="godot_4.5"
    godot_executable="godot45.$DEVICE_ARCH"
fi

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

# Mount Weston runtime
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
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# Mount Godot runtime
godot_dir=/tmp/godot
$ESUDO mkdir -p "${godot_dir}"
if [ ! -f "$controlfolder/libs/${godot_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${godot_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${godot_dir}"
fi
$ESUDO mount "$controlfolder/libs/${godot_runtime}.squashfs" "${godot_dir}"


# Change to the gamedata directory so Godot can find native plugins via relative paths
cd $GAMEDIR/gamedata

$GPTOKEYB "$godot_executable" -c "$GAMEDIR/$gptk_filename" &

# Start Westonpack and Godot
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
# WRAPPED_LIBRARY_PATH is used instead of LD_LIBRARY_PATH to pass libraries only to the app
# LD_PRELOAD is put here because Godot runtime links against libEGL.so, and crusty is interfering with that on some systems.
$ESUDO env WRAPPED_LIBRARY_PATH="$GAMEDIR/gamedata/addons/godot_boy:$GAMEDIR/gamedata/addons/godotsteam/linux64:$GAMEDIR/lib" \
$weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
LD_PRELOAD= XDG_DATA_HOME=$CONFDIR $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --main-pack $pck_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${godot_dir}"
fi

pm_finish
