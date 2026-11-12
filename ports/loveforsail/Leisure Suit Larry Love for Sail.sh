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

GAMEDIR=/$directory/ports/loveforsail
java_runtime="zulu11.48.21-ca-jdk11.0.11-linux"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

GAMEJAR=""
for f in "$GAMEDIR"/*.jar; do
  [ "$(basename "$f")" = "lovesail-portmaster.jar" ] && continue
  [ -f "$f" ] && GAMEJAR="$f" && break
done
if [ -z "$GAMEJAR" ]; then
  pm_show_error "Copy your Leisure Suit Larry: Love for Sail! game file (.jar, any phone version) into ports/loveforsail, then launch again." --title "Game file missing"
  exit 1
fi

SAVEDIR="$GAMEDIR/savedata/$(basename "$GAMEJAR" .jar)"
$ESUDO mkdir -p "$SAVEDIR" "$GAMEDIR/conf"

export JAVA_HOME="/tmp/javaruntime"
$ESUDO mkdir -p "${JAVA_HOME}"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
    exit 1
  fi
  pm_message "Downloading the Java runtime, this can take a few minutes..." --title "Please wait"
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${JAVA_HOME}"
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "${JAVA_HOME}"

$GPTOKEYB2 "java" -c "$GAMEDIR/loveforsail.ini" &
pm_platform_helper "$JAVA_HOME/bin/java"

"$JAVA_HOME/bin/java" \
  -Djava.awt.headless=true \
  -Djava.library.path="$GAMEDIR" \
  -Dmidp.rms.dir="$SAVEDIR" \
  -Dmidp.soundfont="$GAMEDIR/TimGM6mb.sf2" \
  -Djava.util.prefs.userRoot="$GAMEDIR/conf" \
  -cp "$GAMEDIR/lovesail-portmaster.jar" \
  LarryPortmaster "$GAMEJAR"

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${JAVA_HOME}"
fi
pm_finish
