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
GAMEDIR=/$directory/ports/ambidextro
godot_runtime="godot_4.3"
godot_executable="godot43.$DEVICE_ARCH"
game_launcher_setup="Ambidextro.$DEVICE_ARCH"
pck_filename="Ambidextro.pck"

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

cd $GAMEDIR

echo RELEASE
cat $GAMEDIR/RELEASE

# Setup godot mod loader
if [ ! -d "godot" ]; then
    cp $godot_dir/$godot_executable $game_launcher_setup
    rm -rf addons/ mods/ override.cfg
    unzip -o ambidextro_loader.zip
    ./$game_launcher_setup --headless --script addons/mod_loader/mod_loader_setup.gd --setup-create-override-cfg --only-setup --mods-path="mods"
    rm $game_launcher_setup
fi

md5sum $GAMEDIR/$pck_filename

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -n "$ESUDO" ]; then
  ESUDO="${ESUDO},SDL_GAMECONTROLLERCONFIG"
fi

$ESUDO chmod +x $GAMEDIR/controller_info.$DEVICE_ARCH
$ESUDO chmod +x $GAMEDIR/menu/launch_menu.$DEVICE_ARCH

echo INFO CONTROLLER
$GAMEDIR/controller_info.$DEVICE_ARCH
echo $SDL_GAMECONTROLLERCONFIG

# MENU
$GPTOKEYB2 "launch_menu" -c "./menu/controls.ini" &
$GAMEDIR/menu/launch_menu.$DEVICE_ARCH $GAMEDIR/menu/menu.items $GAMEDIR/menu/FiraCode-Regular.ttf

# Capture the exit code
selection=$?

if [ -f "$GAMEDIR/controller.map" ]; then
    echo load controller.map
    export SDL_GAMECONTROLLERCONFIG="$(cat $GAMEDIR/controller.map)"
    echo $SDL_GAMECONTROLLERCONFIG
fi

env_vars=""

# Check what was selected
case $selection in
    0)
        pm_finish
        exit 2
        ;;
    1)
        echo "[MENU] ERROR"
        pm_finish
        exit 1
        ;;
    2)
        echo "[MENU] Native Control"
        control_subfix="native"
        ;;
    3)
        echo "[MENU] Virtual Control"
        env_vars="$env_vars CRUSTY_BLOCK_INPUT=1"
        control_subfix="virtual"
        ;;
    4)
        echo "[MENU] Lightweight Native Control"
        env_vars="$env_vars SHADER_PASSTHROUGH="
        ;;
    5)
        echo "[MENU] Lightweight Virtual Control"
        env_vars="$env_vars CRUSTY_BLOCK_INPUT=1"
        env_vars="$env_vars SHADER_PASSTHROUGH="
        control_subfix="virtual"
        ;;
    *)
        echo "[MENU] Unknown option: $selection"
        pm_finish
        exit 3
        ;;
esac

__pids=$(ps aux | grep '[g]ptokeyb2' | grep '\-Z launch_menu' | awk '{print $2}')

if [ -n "$__pids" ]; then
  echo "KILL: $__pids"
  $ESUDO kill $__pids
fi

sleep 3

echo ESUDO=$ESUDO
echo env_vars=$env_vars

if [[ -n "$control_subfix" ]]; then
    $GPTOKEYB2 "$godot_executable" -c "./controls.$control_subfix.ini" &
fi

# Start Westonpack and Godot
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
$ESUDO env $weston_dir/westonwrap.sh headless noop kiosk crusty_x11egl \
XDG_DATA_HOME=$CONFDIR $env_vars $godot_dir/$godot_executable \
--resolution ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} -f \
--script addons/mod_loader/mod_loader_setup.gd \
--setup-create-override-cfg \
--mods-path="mods" \
--rendering-driver opengl3_es --audio-driver ALSA \
--main-pack $GAMEDIR/$pck_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${godot_dir}"
fi
pm_finish
