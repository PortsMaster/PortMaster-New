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
GAMEDIR=/$directory/ports/switchfin
game_executable="Switchfin"
gptk_filename="Switchfin.gptk"
game_libs=$GAMEDIR/libs/:$LD_LIBRARY_PATH

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

cd $GAMEDIR



if [ "$CFW_NAME" = "ROCKNIX" ]; then
    $GPTOKEYB "Switchfin.Rocknix" -c "$GAMEDIR/$gptk_filename" &
    $ESUDO env CRUSTY_BLOCK_INPUT=1 WRAPPED_LIBRARY_PATH=$game_libs \
    $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
    XDG_DATA_HOME=$CONFDIR XDG_CONFIG_HOME=$CONFDIR dbus-run-session -- $GAMEDIR/Switchfin.Rocknix -d -t
else
    $GPTOKEYB "$game_executable" -c "$GAMEDIR/$gptk_filename" &
    $ESUDO env CRUSTY_BLOCK_INPUT=1 WRAPPED_LIBRARY_PATH=$game_libs \
    $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
    XDG_DATA_HOME=$CONFDIR XDG_CONFIG_HOME=$CONFDIR dbus-run-session -- $GAMEDIR/$game_executable -d -t
fi


#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
