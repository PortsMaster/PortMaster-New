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

GAMEDIR="/$directory/ports/mindustry"
LIBARCDIR="${GAMEDIR}/patch/libarc"
CLASSDIR="${GAMEDIR}/patch/classes"
CONFDIR="$GAMEDIR/conf/"

cd "${GAMEDIR}"

> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

JAR_PACKAGE="${GAMEDIR}/Mindustry.jar"

if [[ ! -f $JAR_PACKAGE ]]; then
    echo "Mindustry jar package missing. Get one from https://github.com/Anuken/Mindustry/releases/ and put it in the mindustry folder" 
    exit 1
fi

# patch the package with arm64 libs if needed
unzip -l "${JAR_PACKAGE}" > /tmp/mindustry_jar_content.txt
for reqlib in libarcarm64.so libarc-filedialogsarm64.so libarc-freetypearm64.so libsdl-arcarm64.so; do
    grep $reqlib /tmp/mindustry_jar_content.txt || zip -j "${JAR_PACKAGE}" "${LIBARCDIR}/${reqlib}"
done

# patch in the patched classes for the SDL backend and GLES init
cd "${CLASSDIR}"
zip -ur "${JAR_PACKAGE}" ./
cd "${GAMEDIR}"

# load runtime
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

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export PATH="$JAVA_HOME/bin:$PATH"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

#Only add the X11 libs if there aren't any on the system, avoids incompatibility with Rocknix
if ! $GAMEDIR/libs.${DEVICE_ARCH}/findlib libX11.so.6; then 
    echo "System does not have X11 libraries. Adding ours to LD_LIBRARY_PATH."
    x11libs="$GAMEDIR/libs.${DEVICE_ARCH}/x11_libs/"
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$x11libs:$LD_LIBRARY_PATH"

export HOTKEY=back
$GPTOKEYB "java" -c "./mindustry.gptk" &

pm_platform_helper "$JAVA_HOME/bin/java"

preload="$GAMEDIR/libs.aarch64/nosignals.so" # SDL will register a segfault handler, but java needs its own segfault handler to exist to function. This library prevents SDL from registering its signal handlers.
if [[ "$CFW_NAME" != "ROCKNIX" ]]; then
    preload="$preload $GAMEDIR/libs.aarch64/sdl_cursor.so" # No need for software cursor on platforms with hardware cursor support through Wayland
fi

# Hack to allow Panfrost (which only supports GL ES 3.1) to run the game.
export MESA_GLES_VERSION_OVERRIDE=3.2

$ESUDO env LD_PRELOAD="$preload" PATH="$PATH" JAVA_HOME="$JAVA_HOME" XDG_DATA_HOME="$CONFDIR" java -jar "${JAR_PACKAGE}" 

if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${JAVA_HOME}"
fi

pm_finish
