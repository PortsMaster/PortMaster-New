#!/bin/bash
# PortMaster launcher for audiofilus: opens the UI, which starts the audio
# service (audiofilus daemon) from its own folder. The service outlives the UI
# only when "Go to background" was chosen; otherwise the music stops on exit.

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

GAMEDIR="/$directory/ports/audiofilus"

# The binary for this machine: audiofilus.aarch64 or .x86_64. It is the UI, the
# service and the command line in one: the UI starts the service by running
# itself again (named audiofilusd, so gptokeyb's exit hotkey, which kills by
# command line, leaves the music playing).
ARCH="${DEVICE_ARCH:-$(uname -m)}"
case "$ARCH" in
  x86_64 | amd64) ARCH=x86_64 ;;
  *) ARCH=aarch64 ;;
esac
BINARY="audiofilus.${ARCH}"

cd "$GAMEDIR"
chmod +x "$BINARY" 2>/dev/null
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# The settings and the library cache live next to the binaries
# (audiofilus.json and data/); the service logs to data/audiofilus.log.
export AUDIOFILUS_HOME="$GAMEDIR"
# The console model (PortMaster's DEVICE_NAME), the network name when the
# system keeps its default hostname.
export AUDIOFILUS_DEVICE="$DEVICE_NAME"

# ArkOS and dArkOS have no PulseAudio: audio goes through ALSA, which takes the
# output device from ~/.asoundrc, and some ports remove it.
if [[ "${CFW_NAME^^}" == *"ARKOS"* ]]; then
  if [ ! -f ~/.asoundrc ] && [ -f ~/.asoundrcbak ]; then
    $ESUDO cp ~/.asoundrcbak ~/.asoundrc
    $ESUDO chmod ugo+rw ~/.asoundrc
    sleep 0.5
  fi
fi

# The UI presents through SDL2 (KMS/DRM) and reads the gamepad with
# PortMaster's mapping for this device; so does the service, which inherits
# this environment.
export EBITENGINE_UI_BACKEND=sdl2
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
echo "SDL_GAMECONTROLLERCONFIG=$SDL_GAMECONTROLLERCONFIG"

# gptokeyb only provides PortMaster's exit hotkey (Select+Start).
$GPTOKEYB "$BINARY" &
pm_platform_helper "$GAMEDIR/$BINARY"
./"$BINARY" "$@"

pm_finish
