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
GAMEDIR=/$directory/ports/bellablood
godot_runtime="godot_4.3"
godot_executable="godot43.$DEVICE_ARCH"
pck_filename="BellaWantsBlood-patched.pck"
gptk_filename="controls.ini"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if ! glxinfo | grep "OpenGL version string"; then
    pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
    sleep 5
    exit 1
    fi
fi

# Apply a patch to fix controls
  if [ -f "$GAMEDIR/gamedata/BellaWantsBlood.pck" ]; then
     echo "Applying patch, please wait."
     $controlfolder/xdelta3 -d -s "$GAMEDIR/gamedata/BellaWantsBlood.pck" "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/gamedata/BellaWantsBlood-patched.pck"
     if [ $? -eq 0 ]; then
     echo "Patch applied successfully"
        echo "$output"
        rm "$GAMEDIR/gamedata/BellaWantsBlood.pck"
     else
        echo "Failed to apply patch"
        echo "$output"
        exit 1
     fi
     else
        echo "No compatible game file found to patch!"
  fi

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


cd $GAMEDIR

$GPTOKEYB2 "$godot_executable" -c "$GAMEDIR/$gptk_filename" &

# Start Westonpack and Godot
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
# LD_PRELOAD is put here because Godot runtime links against libEGL.so, and crusty is interfering with that on some systems.
$ESUDO env CRUSTY_BLOCK_INPUT=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
LD_PRELOAD= XDG_DATA_HOME=$CONFDIR $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --main-pack $GAMEDIR/gamedata/$pck_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
$ESUDO umount "${weston_dir}"	$ESUDO umount "${godot_dir}"
fi

pm_finish