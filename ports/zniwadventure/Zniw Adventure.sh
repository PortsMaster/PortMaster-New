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
get_controls

# Adjust these to your paths
GAMEDIR=/$directory/ports/zniwadventure
game_executable="ags.$DEVICE_ARCH"
demo_rom="zniw.demo"
ags_fullgame_dir="data"
ags_demo_dir="demo"
gptk_filename="controls.gptk"
game_libs=$GAMEDIR/libs.${DEVICE_ARCH}/:$LD_LIBRARY_PATH

selected_game=$ags_fullgame

# Temporary: force executable because this flag keeps getting unset.
chmod +x "$GAMEDIR/$game_executable"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "Demo or fullgame? ========================================================="

# check if fullgame directory exists.
# if not, mount the demo package.
# else directly pass in fullgame.

if [ -d "$GAMEDIR/$ags_fullgame_dir" ]; then
  echo "Full game directory $ags_fullgame_dir found. Attempting to use as AGS game data directory."
  selected_game="$GAMEDIR/$ags_fullgame_dir"
else
  demo_mnt_dir="/tmp/$ags_demo_dir/"
  $ESUDO mkdir -p $demo_mnt_dir
  $ESUDO mount "$GAMEDIR/$demo_rom" "$demo_mnt_dir"
  echo "Mounted demo data to $demo_mnt_dir."

  selected_game="$demo_mnt_dir"
fi

echo "Selected game path: $selected_game ========================================================="

# Back to your regularly scheduled Portmaster

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

cd $GAMEDIR
$GPTOKEYB "$game_executable" -c "$GAMEDIR/$gptk_filename" &

if [[ "$CFW_NAME" = "ROCKNIX" ]] && glxinfo | grep "OpenGL version string"; then
	export SDLVID="x11"
fi


# Start Westonpack
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
$ESUDO env WRAPPED_LIBRARY_PATH=$game_libs \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
XDG_DATA_HOME=$CONFDIR SDL_VIDEODRIVER=$SDLVID $GAMEDIR/$game_executable "$selected_game"


# I too am responsible and [trying to] cleaning up after myself
# Unmount demo package, if it exists, and clear demo directory from tmp.
if [ -d "$demo_mnt_dir" ]; then
  $ESUDO umount "$demo_mnt_dir"
  $ESUDO rmdir "$demo_mnt_dir"
  pm_message "Find more info at https://zidandzniw.pl/"
  sleep 5
fi

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
