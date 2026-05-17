#!/bin/bash
# Rising Dusk - PortMaster launcher
# Requires: Wine + Box64 + Gamescope (available in ROCKNIX and JELOS/KNULLI).

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

GAMEDIR="/$directory/ports/risingdusk"
EXEC="Rising Dusk.exe"

cd "$GAMEDIR"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# ---- Dependency checks ----
if ! command -v wine >/dev/null 2>&1; then
  pm_message "Rising Dusk requires Wine. Install ROCKNIX or JELOS/KNULLI."
  pm_finish
  exit 1
fi
if ! command -v gamescope >/dev/null 2>&1; then
  pm_message "Rising Dusk requires Gamescope. Install ROCKNIX or JELOS/KNULLI."
  pm_finish
  exit 1
fi
if [ ! -f "$GAMEDIR/$EXEC" ]; then
  pm_message "Game files missing. Copy Rising Dusk.exe and assets/ into ports/risingdusk/."
  pm_finish
  exit 1
fi

export DISPLAY=":0.0"

# Wine prefix must be on a filesystem that supports symlinks (ext4/f2fs).
# $HOME is ext4 on ROCKNIX (/storage), JELOS, and most CFWs.
export WINEPREFIX="$HOME/risingdusk_wine"
export WINEDEBUG=-all
export WINEDLLOVERRIDES="steam_api=n,b;steamwrap=n,b"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1

if [ ! -f "$WINEPREFIX/system.reg" ]; then
  pm_message "Setting up Wine prefix (first run, takes ~30 s)..."
  DISPLAY=":0.0" wineboot -i 2>/dev/null
fi

# ---- InputPlumber profile (ROCKNIX only, safe to skip) ----
if command -v inputplumber >/dev/null 2>&1; then
  IPDEV=$(inputplumber devices list 2>/dev/null | grep -oE '[0-9]+' | head -1)
  IPDEV=${IPDEV:-0}
  if inputplumber device "$IPDEV" profile load "$GAMEDIR/risingdusk_profile.yaml" 2>/dev/null; then
    echo "[risingdusk] InputPlumber profile loaded (device $IPDEV)"
  else
    echo "[risingdusk] Warning: could not load InputPlumber profile"
  fi
fi

# ---- Audio: PipeWire preferred, ALSA fallback ----
_pw_sock="${PIPEWIRE_RUNTIME_DIR:-/run/pipewire}/pipewire-0"
if [ -S "$_pw_sock" ]; then
  AUDIO_ENV=(
    SDL_AUDIODRIVER=pipewire
    "PIPEWIRE_RUNTIME_DIR=${PIPEWIRE_RUNTIME_DIR:-/run/pipewire}"
    SDL_AUDIO_SAMPLES=4096
    PIPEWIRE_LATENCY=4096/44100
  )
  echo "[risingdusk] Audio: PipeWire"
else
  AUDIO_ENV=(
    SDL_AUDIODRIVER=alsa
    SDL_AUDIO_SAMPLES=4096
  )
  echo "[risingdusk] Audio: ALSA (PipeWire not found)"
fi

$GPTOKEYB "$EXEC" -c "$GAMEDIR/risingdusk.gptk" &
pm_platform_helper "$GAMEDIR/$EXEC" >/dev/null

gamescope -f -w "$DISPLAY_WIDTH" -h "$DISPLAY_HEIGHT" -- \
  env WINEPREFIX="$HOME/risingdusk_wine" \
      WINEDEBUG=-all \
      WINEDLLOVERRIDES="steam_api=n,b;steamwrap=n,b" \
      BOX64_EMULATED_LIBS="SDL2" \
      SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" \
      SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1 \
      "${AUDIO_ENV[@]}" \
  wine "$EXEC"

# ---- Restore InputPlumber default profile ----
if command -v inputplumber >/dev/null 2>&1; then
  inputplumber device "$IPDEV" profile load \
    /usr/share/inputplumber/profiles/default.yaml 2>/dev/null || true
fi

pm_finish
