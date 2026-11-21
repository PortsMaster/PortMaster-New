#!/bin/bash
# PortMaster launcher for DaytonaArm: Daytona USA (Sega Model 2) statically
# recompiled to ARM64 with an OpenGL ES 2.0 renderer.

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

GAMEDIR="/$directory/ports/daytonaarm"

export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# ROMs and the compiled game module are added by hand; say so in the log
# instead of launching into a game with no ROM.
if [ -z "$(ls -A roms/*.zip 2>/dev/null)" ] || [ -z "$(ls -A cache/*.so 2>/dev/null)" ]; then
  echo "daytonaarm: missing roms/*.zip or cache/*.so, see README.md"
  sleep 5
  exit 1
fi

chmod +x daytona.aarch64 # zip extraction drops the exec bit

# The H700 drops clocks during vblank waits; the port is tuned at full speed.
if [ -w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
  ORIG_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > "$g" 2>/dev/null || true
  done
fi

pm_platform_helper "$GAMEDIR/daytona.aarch64"
./daytona.aarch64 --data-dir "$GAMEDIR" --fullscreen "$@"
RC=$?

if [ -n "$ORIG_GOV" ] && [ -w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
  for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "$ORIG_GOV" > "$g" 2>/dev/null || true
  done
fi

pm_finish
exit $RC
