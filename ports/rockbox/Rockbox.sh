#!/bin/bash

### Portmaster spec ###

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

GAMEDIR=/$directory/ports/rockbox

cd $GAMEDIR

### Set env vars ###

# Panel detect
DISPLAY_MIN=$(( DISPLAY_WIDTH < DISPLAY_HEIGHT ? DISPLAY_WIDTH : DISPLAY_HEIGHT ))
ZOOM_VAL=$(echo "$DISPLAY_MIN 240" | awk '{printf "%.2f \n", $1/$2}')

### Set Backlight/Battery sysfs paths ###

# Find battery status
export BATTERY_STATUS="$(find /sys/class/power_supply/*/ -name status -print -quit 2>/dev/null)"
if [ ! -f "${BATTERY_STATUS}" ]; then
  echo "ERROR: There is no BATTERY_STATUS object to manage, setting fallback."
  export BATTERY_STATUS="/tmp/rb_charge"
  if [ ! -f "/tmp/rb_charge" ]; then
    echo "Discharging" > "/tmp/rb_charge"
  fi
fi
# Find power status
export POWER_STATUS="$(find /sys/class/power_supply/*/ -name online -print -quit 2>/dev/null)"
if [ ! -f "${POWER_STATUS}" ]; then
  echo "ERROR: There is no POWER_STATUS object to manage, setting fallback."
  export POWER_STATUS="/tmp/rb_usb"
  if [ ! -f "/tmp/rb_usb" ]; then
    echo "0" > "/tmp/rb_usb"
  fi
fi
# Find capacity status
export CAPACITY_STATUS="$(find /sys/class/power_supply/*/ -name capacity -print -quit 2>/dev/null)"
if [ ! -f "${CAPACITY_STATUS}" ]; then
  echo "ERROR: There is no CAPACITY_STATUS object to manage, setting fallback."
  export CAPACITY_STATUS="/tmp/rb_batt"
  if [ ! -f "/tmp/rb_batt" ]; then
    echo "0" > "/tmp/rb_batt"
  fi
fi

# Find backlight paths
export SYSFS_BL_BRIGHTNESS="$(find /sys/class/backlight/*/ -name brightness -print -quit 2>/dev/null)"
export SYSFS_BL_COMMAND="$(find /sys/kernel/debug/dispdbg/ -name command -print -quit 2>/dev/null)"

if [ -n "${SYSFS_BL_BRIGHTNESS}" ]; then
  echo "Backlight TYPE2 detected! setting path/type."
  export BL_TYPE="TYPE2"
  export SYSFS_BL_POWER="$(find /sys/class/backlight/*/ -name bl_power )"
  export SYSFS_BL_MAX="$(find /sys/class/backlight/*/ -name max_brightness -print -quit 2>/dev/null)"
elif [ -n "${SYSFS_BL_COMMAND}" ]; then
  echo "Backlight TYPE1 detected! setting path/type."
  export BL_TYPE="TYPE1"
  export SYSFS_BL_NAME="$(find /sys/kernel/debug/dispdbg/ -name name -print -quit 2>/dev/null)"
  export SYSFS_BL_PARAM="$(find /sys/kernel/debug/dispdbg/ -name param -print -quit 2>/dev/null)"
  export SYSFS_BL_START="$(find /sys/kernel/debug/dispdbg/ -name start -print -quit 2>/dev/null)"
  export BL_COMMAND="setbl"
  export BL_NAME="lcd0"
else
  echo "Backlight objects not found! Setting fallback."
  export BL_TYPE="TYPE2"
  export SYSFS_BL_BRIGHTNESS="/tmp/rb_brightness"
  export SYSFS_BL_POWER="/tmp/rb_bl_power"
  export SYSFS_BL_MAX="255"
fi

### Setup bind and patch themes ###

# bind RBDIR to rootfs.
if [ ! -f "/tmp/rockbox/rockbox" ]; then
bind_directories /tmp/rockbox $GAMEDIR
fi

# Check and patch themes to use /tmp/rockbox path.
for theme in "themes/*.cfg"; do
  sed -i 's#/.rockbox#/tmp/rockbox#g' $theme
done

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# For log
echo "Display: $DISPLAY_WIDTH x $DISPLAY_HEIGHT"
echo "Aspect Ratio: $ASPECT_X : $ASPECT_Y"
echo "Zoom: $ZOOM_VAL"
echo "CPU: $DEVICE_CPU"
echo "Firmware: $CFW_NAME"
echo "Battery Paths:"
echo "$BATTERY_STATUS"
echo "$POWER_STATUS"
echo "$CAPACITY_STATUS"
echo "Backlight Type/Paths:"
echo "$BL_TYPE"
if [[ "$BL_TYPE" == "TYPE1" ]]; then
  echo "$SYSFS_BL_COMMAND"
  echo "$SYSFS_BL_NAME"
  echo "$SYSFS_BL_PARAM"
  echo "$SYSFS_BL_START"
  echo "$BL_COMMAND"
  echo "$BL_NAME"
elif [[ "$BL_TYPE" == "TYPE2" ]]; then
  echo "$SYSFS_BL_BRIGHTNESS"
  echo "$SYSFS_BL_POWER"
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

### CFW specific prelaunch env ###
RB_STATE="BOOT"
if [[ -f "$GAMEDIR/firmware/$CFW_NAME" ]]; then
  . "$GAMEDIR/firmware/$CFW_NAME"
else
  . "$GAMEDIR/firmware/fallback"
fi

export SDL_DEVICE_WIDTH=$DISPLAY_WIDTH
export SDL_DEVICE_HEIGHT=$DISPLAY_HEIGHT
export LD_PRELOAD="$GAMEDIR/lib/libsdl2_scaler.so"

$GPTOKEYB2 "rockbox" -c "./rockbox.gptk" &
pm_platform_helper "$GAMEDIR/rockbox"
sleep 1 # Seems like TUI Smart Pro needs a 1 sec delay... for reasons...
./rockbox --zoom $ZOOM_VAL

# CFW specific restore commands
RB_STATE="EXIT"
if [[ -f "$GAMEDIR/firmware/$CFW_NAME" ]]; then
  . "$GAMEDIR/firmware/$CFW_NAME"
else
  . "$GAMEDIR/firmware/fallback"
fi

pm_finish
