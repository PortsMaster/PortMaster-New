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

get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR=/$directory/ports/freecol
jar_filename="FreeCol.jar"
gptk_filename="FreeCol.gptk"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

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

# JRE load runtime
runtime="zulu17.54.21-ca-jre17.0.13-linux"
export JAVA_HOME="$HOME/zulu17.54.21-ca-jre17.0.13-linux.aarch64"
$ESUDO mkdir -p "${JAVA_HOME}"

if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}"
fi

$ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "${JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"

cd $GAMEDIR

ARCHIVE_FILE="data.tar.gz"

# Check if the archive file exists
if [[ -f "$ARCHIVE_FILE" ]]; then
   pm_message "Extracting game data, this can take a few minutes..."
   
   # Extract the archive and check if the extraction was successful
   if [ "$CFW_NAME" = "muOS" ]; then
       if gunzip -c "$ARCHIVE_FILE" | tar xf -; then
           pm_message "Extraction successful."
           $ESUDO rm -f "$ARCHIVE_FILE"
       else
           pm_message "Error: Extraction failed."
           sleep 5
           exit 1
       fi
   else
       if tar -xzf "$ARCHIVE_FILE"; then
           pm_message "Extraction successful."
           $ESUDO rm -f "$ARCHIVE_FILE"
       else
           pm_message "Error: Extraction failed."
           sleep 5
           exit 1
       fi
   fi
elif [ ! -d 'data/' ]; then
   pm_message "Error: No data directory present and Archive file $ARCHIVE_FILE not found."
   sleep 5
   exit 1  # Exit the script if no data directory and no archive file
fi

$GPTOKEYB "java" -c "$GAMEDIR/$gptk_filename" &
pm_platform_helper "$JAVA_HOME/bin/java"

$ESUDO env WRAPPED_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}/:$LD_LIBRARY_PATH" $weston_dir/westonwrap.sh drm gl kiosk system \
PATH="$PATH" JAVA_HOME="$JAVA_HOME" XDG_DATA_HOME="$CONFDIR" WAYLAND_DISPLAY= \
java -Xmx724M -jar $GAMEDIR/$jar_filename

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi

pm_finish