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
GAMEDIR=/$directory/ports/thelastgame
godot_runtime="godot_4.5"
godot_executable="godot45.$DEVICE_ARCH"
pck_filename="TheLastGamePatched.pck"
gptk_filename="thelastgame.gptk"

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

# Apply the patch
if [ -f ./gamedata/TheLastGame.pck ]; then
	# get TheLastGame.pck checksum
	checksum=$(md5sum "gamedata/TheLastGame.pck" | awk '{ print $1 }')
	
	# Check for Full version
	if [ "$checksum" == "7951f594922a44fb54bc1a2ca26f8853" ]; then
		$controlfolder/xdelta3 -d -s "$GAMEDIR/gamedata/TheLastGame.pck" -f "$GAMEDIR/tools/patch.xdelta" "$GAMEDIR/gamedata/TheLastGamePatched.pck" 2>&1
		rm -Rf ./gamedata/TheLastGame.pck
	
	# Check for demo version
	elif [ "$checksum" == "397901239e1406d214a77925e03a19e3" ]; then
		$controlfolder/xdelta3 -d -s "$GAMEDIR/gamedata/TheLastGame.pck" -f "$GAMEDIR/tools/patchdemo.xdelta" "$GAMEDIR/gamedata/TheLastGamePatched.pck" 2>&1
		rm -Rf ./gamedata/TheLastGame.pck
	fi
fi

$GPTOKEYB "$godot_executable" -c "$GAMEDIR/$gptk_filename" &

# Start Westonpack and Godot
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
$ESUDO env $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
XDG_DATA_HOME=$CONFDIR $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --main-pack $GAMEDIR/gamedata/$pck_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
$ESUDO umount "${weston_dir}"	$ESUDO umount "${godot_dir}"
fi

pm_finish