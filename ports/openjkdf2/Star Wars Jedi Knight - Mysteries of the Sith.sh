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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/openjkdf2"
CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR/openjkdf2" "$CONFDIR/openjkmots"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
bind_directories "$HOME/.local/share/openjkdf2" "$CONFDIR/openjkdf2"
bind_directories "$HOME/.local/share/openjkmots" "$CONFDIR/openjkmots"

export OPENJKDF2_MOTS=1
export OPENJKDF2_HANDHELD=1
export OPENJKDF2_CHEATS_MENU=1
export OPENJKDF2_HUD_SCALE=2.0
export OPENJKDF2_ROOT="$GAMEDIR/jk1"
export OPENJKMOTS_ROOT="$GAMEDIR/mots"

# --- CFW tweaks (ROCKNIX / Wayland) ---
[ -z "${OPENJKDF2_SWAY_FULLSCREEN+x}" ] && [ "${CFW_NAME^^}" = "ROCKNIX" ] && export OPENJKDF2_SWAY_FULLSCREEN=0
[ "${CFW_NAME^^}" = "ROCKNIX" ] && export SDL_HINT_APP_NAME="${SDL_HINT_APP_NAME:-OpenJKDF2}"
[ "${CFW_NAME^^}" = "ROCKNIX" ] && export SDL_OPENGL_ES_DRIVER="${SDL_OPENGL_ES_DRIVER:-1}"

# --- Gamepad (external pad ignores built-in handheld controller) ---
. "$GAMEDIR/helpers/gamepad.inc"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

openjkdf2_ignore_handheld_if_external

# --- Low-RAM swap (< 2 GB; script from Slayer366 / PortMaster DEVICE_RAM) ---
# Ensure swap space is prepared or MOTS may crash on level load.
if [[ $DEVICE_RAM -lt "2" ]]; then
  if [[ $CFW_NAME == *"ArkOS"* ]] || [[ $CFW_NAME == *"ODROID"* ]]; then
    if [[ $CFW_NAME == *"dArkOS"* ]]; then
      [ -e /dev/zram0 ] && $ESUDO swapoff -a
      [ -e /dev/zram0 ] && $ESUDO zramctl --reset /dev/zram0
      [ -e /dev/zram1 ] && $ESUDO zramctl --reset /dev/zram1
      [ -e /dev/zram2 ] && $ESUDO zramctl --reset /dev/zram2
      modprobe zram
      $ESUDO zramctl --find --size 420M
      $ESUDO mkswap /dev/zram0
      $ESUDO swapon /dev/zram0
    else
      [ -f /swapfile ] && $ESUDO swapoff -v /swapfile
      [ -f /swapfile ] && $ESUDO rm -f /swapfile
      $ESUDO fallocate -l 420M /swapfile
      $ESUDO chmod 600 /swapfile
      $ESUDO mkswap /swapfile
      $ESUDO swapon /swapfile
    fi
  elif [[ "${CFW_NAME^^}" == "KNULLI" ]]; then
    [ -f /media/SHARE/swapfile ] && $ESUDO swapoff -v /media/SHARE/swapfile
    [ -f /media/SHARE/swapfile ] && $ESUDO rm -f /media/SHARE/swapfile
    $ESUDO fallocate -l 420M /media/SHARE/swapfile
    $ESUDO chmod 600 /media/SHARE/swapfile
    $ESUDO mkswap /media/SHARE/swapfile
    $ESUDO swapon /media/SHARE/swapfile
  fi
fi

$ESUDO chmod +x "$GAMEDIR/openjkdf2.${DEVICE_ARCH}"

$GPTOKEYB "openjkdf2.${DEVICE_ARCH}" -c "./openjkdf2.gptk" &
pm_platform_helper "$GAMEDIR/openjkdf2.${DEVICE_ARCH}"
./openjkdf2.${DEVICE_ARCH} -motsCompat

pm_finish
