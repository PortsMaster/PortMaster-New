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

GAMEDIR="/$directory/ports/mazemice"
CONFDIR="$GAMEDIR/conf"
godot_runtime="godot_4.3"
godot_executable="godot43.${DEVICE_ARCH}"
pck_filename="mazemice.pck"
gptk_filename="godot.gptk"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO mkdir -p "$CONFDIR"

# Mount Weston runtime
weston_dir="/tmp/weston"
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

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
[ "$CFW_NAME" = "AmberELEC" ] && AMBERELEC_ENV="SDL_JOYSTICK_HIDAPI=0"

cd "$GAMEDIR"
$GPTOKEYB "$godot_executable" -c "$GAMEDIR/$gptk_filename" &

[ -f "$GAMEDIR/Maze Mice.pck" ] && mv "Maze Mice.pck" mazemice.pck

if [ ! -f "$CONFDIR/godot/app_userdata/Maze Mice/firstlaunch.no" ]; then
    cd "$CONFDIR/godot/app_userdata/Maze Mice"
    if [ -f "./Settings.${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" ]; then
        $ESUDO cp "./Settings.${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" ./Settings.ini
        $ESUDO touch "$CONFDIR/godot/app_userdata/Maze Mice/firstlaunch.no"
        cd $GAMEDIR
    elif [ ! -f "./Settings.${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" ] && [[ "$DISPLAY_WIDTH" -lt '960' ]]; then
        $ESUDO cp ./Settings.640x480 ./Settings.ini
        $ESUDO touch "$CONFDIR/godot/app_userdata/Maze Mice/firstlaunch.no"
        cd $GAMEDIR
    else
        $ESUDO touch "$CONFDIR/godot/app_userdata/Maze Mice/firstlaunch.no"
        cd $GAMEDIR
    fi
fi

# Start Westonpack and Godot
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
# LD_PRELOAD is put here because Godot runtime links against libEGL.so, and crusty is interfering with that on some systems.
#   $ESUDO env CRUSTY_BLOCK_INPUT=1 $AMBERELEC_ENV $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
#   export XDG_DATA_HOME="$CONFDIR"
$ESUDO env $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
LD_PRELOAD= XDG_DATA_HOME=$CONFDIR $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--rendering-driver opengl3_es --audio-driver ALSA --main-pack $GAMEDIR/$pck_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${godot_dir}"
fi

pm_finish
