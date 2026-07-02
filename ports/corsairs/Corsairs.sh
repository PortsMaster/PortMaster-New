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

GAMEDIR="/$directory/ports/corsairs"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Mount JDK 11 runtime
export JAVA_HOME="/tmp/javaruntime/"
$ESUDO mkdir -p "${JAVA_HOME}"

java_runtime="zulu11.48.21-ca-jdk11.0.11-linux"
if [ ! -f "$controlfolder/libs/${java_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${java_runtime}.squashfs"
fi

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${JAVA_HOME}" 2>/dev/null
fi
$ESUDO mount "$controlfolder/libs/${java_runtime}.squashfs" "${JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$JAVA_HOME/lib:$JAVA_HOME/lib/server:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Find the original game JAR
GAME_JAR=""
EXPECTED_MD5="921bf6964df2d1668d75c946c2736062"

for f in "$GAMEDIR"/*.jar; do
  [ -f "$f" ] || continue
  [ "$(basename "$f")" = "corsairs-portmaster.jar" ] && continue
  if [ "$(md5sum "$f" | cut -d' ' -f1)" = "$EXPECTED_MD5" ]; then
    GAME_JAR="$f"
    break
  fi
done

if [ -z "$GAME_JAR" ] && [ -f "$GAMEDIR/corsairs.jar" ]; then
  GAME_JAR="$GAMEDIR/corsairs.jar"
fi

if [ -z "$GAME_JAR" ]; then
  pm_message "Game JAR not found. Place the original Corsairs JAR into ports/corsairs/"
  sleep 5
  $ESUDO umount "${JAVA_HOME}" 2>/dev/null
  pm_finish
  exit 1
fi

$GPTOKEYB "java" -c "$GAMEDIR/corsairs.gptk" &

pm_platform_helper "$JAVA_HOME/bin/java"

$JAVA_HOME/bin/java \
  -Djava.awt.headless=true \
  -Djava.library.path="$GAMEDIR/libs.${DEVICE_ARCH}" \
  -Dcorsairs.data.dir="$GAMEDIR/savedata" \
  -cp "$GAMEDIR/corsairs-portmaster.jar:$GAME_JAR" \
  CorsairsPortmaster

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "${JAVA_HOME}"
fi

pm_finish
