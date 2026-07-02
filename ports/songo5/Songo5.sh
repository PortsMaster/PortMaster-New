#!/bin/bash
# PORTMASTER: songo5.zip, Songo5.sh

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

runtime="sbc_4_3_rcv12"
#godot_executable="godot43.$DEVICE_ARCH"
pck_filename="Songo5.pck"
gptk_filename="songo5.gptk"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check for ROCKNIX running with libMali driver.
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
	GODOT_OPTS=${GODOT_OPTS//-f/}
    if ! glxinfo | grep "OpenGL version string"; then
		pck_filename="SongoLibmaliWarning.pck"
    fi
fi

echo "LOOKING FOR CFW_NAME ${CFW_NAME}"
export CFW_NAME
echo "LOOKING FOR DEVICE ID ${DEVICE_NAME}"
export DEVICE_NAME

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

# For knulli lid switch override
sh "${GAMEDIR}/runtime/setup_batocera_override" "${GAMEDIR}/runtime"

# Setup volume indicator
USE_SONGO_VOL_TCP_SERVER="0"
SONGO_CFW_NAME="NONE"
if [[ "$CFW_NAME" = "muOS" ]] || [[ "$CFW_NAME" = "knulli" ]] || [[ "$CFW_NAME" = "ROCKNIX" ]]; then
	SONGO_CFW_NAME="${CFW_NAME}"
elif [ -f /mnt/SDCARD/.system/version.txt ] && grep -q "NextUI" /mnt/SDCARD/.system/version.txt; then
	SONGO_CFW_NAME="NextUI"
elif [ -f /mnt/SDCARD/spruce/spruce ]; then
	SONGO_CFW_NAME="Spruce"
fi

if [[ "$SONGO_CFW_NAME" != "NONE" ]]; then
	USE_SONGO_VOL_TCP_SERVER="1"
	sh "${GAMEDIR}/runtime/volume-indicator/setup_vol_indicator" "${SONGO_CFW_NAME}"
fi

export SONGO_CFW_NAME
export USE_SONGO_VOL_TCP_SERVER

# Set up brightness commands (Based on IncognitoMans approach)
export SYSFS_BL_BRIGHTNESS="$(find /sys/class/backlight/*/ -name brightness 2>/dev/null | head -n 1)"
export SYSFS_BL_COMMAND="$(find /sys/kernel/debug/dispdbg/ -name command 2>/dev/null | head -n 1)"

if [ -n "${SYSFS_BL_BRIGHTNESS}" ]; then
  echo "Backlight TYPE2 detected! setting path/type."
  export BL_TYPE="TYPE2"
  export SYSFS_BL_POWER="$(find /sys/class/backlight/*/ -name bl_power )"
  export SYSFS_BL_MAX="$(find /sys/class/backlight/*/ -name max_brightness 2>/dev/null | head -n 1)"
elif [ -n "${SYSFS_BL_COMMAND}" ]; then
  echo "Backlight TYPE1 detected! setting path/type."
  export BL_TYPE="TYPE1"
  export SYSFS_BL_NAME="$(find /sys/kernel/debug/dispdbg/ -name name 2>/dev/null | head -n 1)"
  export SYSFS_BL_PARAM="$(find /sys/kernel/debug/dispdbg/ -name param 2>/dev/null | head -n 1)"
  export SYSFS_BL_START="$(find /sys/kernel/debug/dispdbg/ -name start 2>/dev/null | head -n 1)"
  export BL_COMMAND="setbl"
  export BL_NAME="lcd0"
else
  echo "Backlight objects not found!"
  export BL_TYPE="UNKNOWN"
fi

DEFAULT_GET_BRIGHTNESS_PATH="${GAMEDIR}/runtime/brightness/default/get_brightness"
DEFAULT_SET_BRIGHTNESS_PATH="${GAMEDIR}/runtime/brightness/default/set_brightness"
SONGO_GET_BRIGHTNESS_PATH="$DEFAULT_GET_BRIGHTNESS_PATH"
SONGO_SET_BRIGHTNESS_PATH="$DEFAULT_SET_BRIGHTNESS_PATH"
NO_BRIGHT_FADE_AVAILABLE='0'

if [[ "$BL_TYPE" = "TYPE1" ]] && [[ -e "${GAMEDIR}/runtime/brightness/${SONGO_CFW_NAME}/get_brightness" ]]; then
	# Type 2 updates the stored get value when cfw adjusts brightness, so for type 1 we have to explicitly check if
	# brightness has been adjusted by the user
	SONGO_GET_BRIGHTNESS_PATH="${GAMEDIR}/runtime/brightness/${SONGO_CFW_NAME}/get_brightness"
fi

if [ "$BL_TYPE" = "UNKNOWN" ]; then
	NO_BRIGHT_FADE_AVAILABLE='1'
fi

export SONGO_GET_BRIGHTNESS_PATH
export SONGO_SET_BRIGHTNESS_PATH
export NO_BRIGHT_FADE_AVAILABLE

export HIDE_MOUSE="true"

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

LD_LIBRARY_PATH="$GAMEDIR/runtime/ffmpeg:$LD_LIBRARY_PATH" "$GAMEDIR/runtime/$runtime" $GODOT_OPTS --main-pack "gamedata/$pck_filename"

if [ -f "${CONFDIR}godot/app_userdata/Songo #5/reset_values.sh" ]; then
	echo "reset_values.sh found, resetting cfw config options to user preference"
    sh "${CONFDIR}godot/app_userdata/Songo #5/reset_values.sh"
else
	echo "reset_values.sh not found"
fi


#if [[ "$PM_CAN_MOUNT" != "N" ]]; then
#$ESUDO umount "${godot_dir}"
#fi

if [[ "$SONGO_CFW_NAME" != "NONE" ]]; then
	# Teardown volume indicator
	sh "${GAMEDIR}/runtime/volume-indicator/teardown_vol_indicator" "${SONGO_CFW_NAME}"
fi


# Remove lid switch overrides if applied (EG: for rg35xx-SP)
TARGETS=(
	"/boot/boot/batocera.board.capability" # Knulli approach to lid inhibit
    "/sys/class/power_supply/axp2202-battery/hallkey" # RG35xx-SP, RG34xx-SP
    "/sys/devices/platform/hall-mh248/hallvalue"      # Miyoo Flip
)

for TARGET in "${TARGETS[@]}"; do
    # Skip if the target doesn't exist
    [ -e "$TARGET" ] || continue

    # Loop until no mounts remain at this target
    while mountpoint -q "$TARGET"; do
        # Lazy unmount to handle busy sysfs
        if umount -l "$TARGET" 2>/dev/null; then
            echo "Unmounted hallkey override: $TARGET"
        else
            echo "Failed to unmount (maybe not mounted or busy): $TARGET"
            break
        fi
    done
done

pm_finish
