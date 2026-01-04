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
# For newer Rocknix versions
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls


# The initial game path. Change 'mygame' to your game. It's not my game.
GAMEDIR=/$directory/ports/dragondragonfirefire/
# Portmaster Godot runtime source.
# Examples of vanilla Godot are "godot_4.4.1", "godot_4.5", etc
# For Mono/C# runtimes, try "godot_4.4.1.mono", "godot_4.5", etc
godot_runtime="godot_4.5"
# The executable itself, usually packed into a squashfs.
# Examples include "godot411.$DEVICE_ARCH", "godot45.$DEVICE_ARCH"
# For Mono/C# runtimes, try "godot415.$DEVICE_ARCH", etc.
godot_executable="godot45.$DEVICE_ARCH"
# Your primary Godot game PCK. Again, it's your game. Not mygame.
pck_filename="dragondragonfirefire.pck"
# Control mapper
gptk_filename="controls.gptk"
# If your game uses extra arguments, drop them here.
godot_args=""


# v===== Here be dragons. Your warranty's void below =====v


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

# ========= Branch for C# mono

# for handling stupid dumb niche arm64 naming inconsistency
map_arch_names() {
  arch_id="$1"
  if [[ $arch_id = "aarch64" ]]; then
    echo "arm64"
  else
    echo "$1"
  fi
}

# Figure out default mono directory based on arch and pck name.
get_mono_dir_name() {
  gamename_pck=$(echo "$1")
  STRIPPED_GAMENAME="${gamename_pck%.pck}"
  ARCH=$(map_arch_names "$2")
  out="data_"
  out+=$STRIPPED_GAMENAME
  out+="_linuxbsd_"
  out+=$ARCH
  echo $out
}

do_mono() {
  gamename_pck=$1
  arch=$2
  data_dir=$(get_mono_dir_name $gamename_pck $arch)
  gdmono_root=$(echo "/tmp/gdcs/")

  $ESUDO mkdir -p "$gdmono_root"
  $ESUDO mkdir -p "$gdmono_root/$data_dir"
  $ESUDO touch "$gdmono_root/$godot_executable"
  
  $ESUDO mount --bind $godot_dir/$godot_executable $gdmono_root/$godot_executable
  $ESUDO mount --bind "$GAMEDIR/$data_dir" "$gdmono_root/$data_dir"
  
  echo "$gdmono_root"
}


# Finally, assign whether we're mono or normal runtime.
GD_DIR=$(
    if [[ $godot_executable == *"mono"* ]]; then
        do_mono $pck_filename $DEVICE_ARCH;
    else
    echo "$godot_dir";
fi)

# ========= End Mono BS


cd $GAMEDIR
$GPTOKEYB "$godot_executable" -c "$GAMEDIR/$gptk_filename" &

$ESUDO env CRUSTY_BLOCK_INPUT=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
XDG_DATA_HOME=$CONFDIR $GD_DIR/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --main-pack $GAMEDIR/$pck_filename \
$godot_args

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${godot_dir}"
fi
pm_finish
