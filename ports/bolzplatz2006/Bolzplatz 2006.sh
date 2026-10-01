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

GAMEDIR=/$directory/ports/bolzplatz2006
java_runtime="zulu17.54.21-ca-jre17.0.13-linux"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

CONFDIR="$GAMEDIR/conf"
$ESUDO mkdir -p "$CONFDIR/.bolzplatz"
bind_directories ~/.bolzplatz "$CONFDIR/.bolzplatz"

ARCHIVE_FILES=("data-part1.tar.gz" "data-part2.tar.gz")
if [[ -f "${ARCHIVE_FILES[0]}" || -f "${ARCHIVE_FILES[1]}" ]]; then
    pm_message "Extracting game data, this can take a few minutes..."
    if gunzip -c "${ARCHIVE_FILES[0]}" | tar --no-same-owner -xf - && gunzip -c "${ARCHIVE_FILES[1]}" | tar --no-same-owner -xf -; then
        pm_message "Extraction successful."
        $ESUDO rm -f "${ARCHIVE_FILES[@]}"
    else
        pm_message "Error: Extraction failed."
        sleep 5
        exit 1
    fi
elif [ ! -f 'data/teams/vschielefeld.xml' ] || [ ! -f 'data/music/mainmenu.ogg' ]; then
    pm_message "Error: No game data present and archive files not found."
    sleep 5
    exit 1
fi

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

export JAVA_HOME="/tmp/javaruntime"
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

CLASSPATH="game.jar:lib/irrlicht.jar:lib/vecmath.jar:lib/lwjgl.jar:lib/sdljava.jar:lib/jogg-0.0.7.jar:lib/jorbis-0.0.15.jar:lib/tritonus_share.jar:lib/vorbisspi1.0.2.jar"

$GPTOKEYB2 "java" -c "$GAMEDIR/bolzplatz2006.ini" &
pm_platform_helper "$JAVA_HOME/bin/java"

$ESUDO env CRUSTY_BLOCK_INPUT=1 CRUSTY_SHOW_CURSOR=0 \
$weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
JAVA_HOME="$JAVA_HOME" WAYLAND_DISPLAY= \
"$JAVA_HOME/bin/java" \
  -Duser.home="$HOME" \
  -Djava.library.path="$GAMEDIR/libs.${DEVICE_ARCH}" \
  -Dbp2k6.width="$DISPLAY_WIDTH" \
  -Dbp2k6.height="$DISPLAY_HEIGHT" \
  -Dbp2k6.logfile="$CONFDIR/game.log" \
  -cp "$CLASSPATH" \
  com.xenoage.bp2k6.Main

$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
    $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
