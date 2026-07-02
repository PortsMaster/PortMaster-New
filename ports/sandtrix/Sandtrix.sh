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

# Adjust these to your paths and desired java version
GAMEDIR=/$directory/ports/sandtrix
GAMEFILES=$GAMEDIR/gamefiles/
java_runtime="zulu23.32.11-ca-jre23.0.2-linux"
gptk_filename="sandtrix.gptk"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Untar and install game files
tarfile=$(find "$GAMEFILES" -maxdepth 1 -type f -name '*.tar.gz' | head -n 1)
if [ -n "$tarfile" ]; then
    jar_in_tar=$(gunzip -c "$tarfile" | tar -tf - | grep -E '^[^/]+\.jar' | head -1)
    if [ -n "$jar_in_tar" ]; then
  	gunzip -c "$tarfile" | tar -xf - -C "$GAMEFILES" "$jar_in_tar"
    	echo "Extracted: $jarfile"
        rm -f "$tarfile"
    fi
fi

jar_filename=$(find $GAMEFILES -maxdepth 1 -name '*.jar' -print | sort | head -n 1)
if [ ! -n "$jar_filename" ]; then
    echo "Jar file not found. This game is not installed correctly."
    pm_message "Jar file not found. This game is not installed correctly."
    sleep 5
    exit 1
fi

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

# Mount Java runtime
export JAVA_HOME="/tmp/javaruntime/"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}"
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "${JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"


cd $GAMEDIR
$GPTOKEYB "java" -c "$GAMEDIR/$gptk_filename" &

# Start Westonpack and Java
# Put CRUSTY_SHOW_CURSOR=1 after "env" if you need a mouse cursor
$ESUDO env CRUSTY_BLOCK_INPUT=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
PATH="$PATH" JAVA_HOME="$JAVA_HOME" XDG_DATA_HOME="$GAMEDIR" WAYLAND_DISPLAY= \
java -jar $jar_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
