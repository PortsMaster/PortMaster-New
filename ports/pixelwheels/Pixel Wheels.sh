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
GAMEDIR=/$directory/ports/pixelwheels
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"
jar_filename="gamefiles/*.jar"
gptk_filename="pixelwheels.gptk"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"


# Game data setup 
# This is left here in case someone wants to update the game

# If there are any zip files in "gamefiles", unzip them, then remove
for zip in "$GAMEDIR"/gamefiles/*.zip; do
  unzip -o "$zip" -d "$GAMEDIR"/gamefiles && rm "$zip"
done

# Move everything from the folder starting with "pixelwheels" (from the zip we just extracted) to the gamefiles folder
PIXEL_DIR=$(find "$GAMEDIR/gamefiles/" -maxdepth 1 -type d -name "pixelwheels*" | head -n 1)
if [ -n "$PIXEL_DIR" ]; then
  mv "$PIXEL_DIR"/* "$GAMEDIR"/gamefiles/
fi

# Remove unneccessary files
rm -r "$GAMEDIR"/gamefiles/jre/
find "$GAMEDIR"/gamefiles -type f ! -name '*.jar' -delete
find "$GAMEDIR"/gamefiles -type d -empty -delete

# Check if game files are installed correctly
if ! ls "$GAMEDIR"/gamefiles/*.jar 1> /dev/null 2>&1; then
  echo "Jar file not found, game not installed correctly."
  pm_message "Jar file not found, game not installed correctly."
  sleep 5
  exit 1
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
$ESUDO env $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
PATH="$PATH" JAVA_HOME="$JAVA_HOME" HOME="$CONFDIR" XDG_DATA_HOME="$CONFDIR" WAYLAND_DISPLAY= \
java -jar $GAMEDIR/$jar_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
