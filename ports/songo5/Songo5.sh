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
GAMEDIR=/$directory/ports/songo5

runtime="sbc_4_3_rcv7"
#godot_executable="godot43.$DEVICE_ARCH"
pck_filename="Songo5.pck"
gptk_filename="songo5.gptk"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check for ROCKNIX running with libMali driver.
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
	GODOT_OPTS=${GODOT_OPTS//-f/}
    if ! glxinfo | grep "OpenGL version string"; then
    pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
    sleep 5
    exit 1
    fi
fi

echo "LOOKING FOR CFW_NAME ${CFW_NAME}"
export CFW_NAME

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

cd $GAMEDIR

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

echo "XDG_DATA_HOME"
echo $XDG_DATA_HOME

export SONGO_BINARIES_DIR="$GAMEDIR/runtime"

#  If XDG Path does not work
# Use _directories to reroute that to a location within the ports folder.
#bind_directories ~/.portfolder $GAMEDIR/conf/.portfolder 

# Setup Godot

#godot_dir="$HOME/godot"
#godot_file="runtime/${runtime}.squashfs"
#$ESUDO mkdir -p "$godot_dir"
#$ESUDO umount "$godot_file" || true
#$ESUDO mount "$godot_file" "$godot_dir"
#PATH="$godot_dir:$PATH"

# By default FRT sets Select as a Force Quit Hotkey, with this we disable that.
# export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS 

$GPTOKEYB "$GAMEDIR/runtime/$runtime" -c "$GAMEDIR/$gptk_filename" &
sleep 0.6 # For TSP only, do not move/modify this line.
pm_platform_helper "$GAMEDIR/runtime/$runtime"
"$GAMEDIR/runtime/$runtime" $GODOT_OPTS --main-pack "gamedata/Songo5.pck"

if [ -f "${CONFDIR}godot/app_userdata/Songo #5/reset_values.sh" ]; then
	echo "reset_values.sh found, resetting cfw config options to user preference"
    sh "${CONFDIR}godot/app_userdata/Songo #5/reset_values.sh"
else
	echo "reset_values.sh not found"
fi

3
#if [[ "$PM_CAN_MOUNT" != "N" ]]; then
#$ESUDO umount "${godot_dir}"
#fi

pm_finish