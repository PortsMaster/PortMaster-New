#!/bin/bash

# Setup PortMaster
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
source $controlfolder/device_info.txt
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Define constants
readonly PORT_PREFIX="$directory/ports/risk_of_rain"
readonly CONFIG_PREFIX="$PORT_PREFIX/config"
readonly LOG_PREFIX="$PORT_PREFIX/log"
readonly GAME_PREFIX="$PORT_PREFIX/game"
readonly LIB_PREFIX="$PORT_PREFIX/lib"
readonly BIN_PREFIX="$PORT_PREFIX/bin"

# Setup logging
mkdir -p "$LOG_PREFIX"
exec {LOG_FD}>"$LOG_PREFIX/$(basename "$0").log"
exec 1>&$LOG_FD # stdout
exec 2>&$LOG_FD # stderr
export BASH_XTRACEFD=$LOG_FD
set -x

# Define alias
_sudo () { $ESUDO "$@" ; }
_gptokeyb () { "$(echo "${GPTOKEYB//" -1"/}" | xargs)" "$@" ; } # I want to use -k option!!!
_box86 () { "$BIN_PREFIX/box86" "$@" ; }

# Setup game config
rm -rf "$HOME/.config/Risk_of_Rain"
mkdir -p "$CONFIG_PREFIX" "$HOME/.config"
ln -sf "$CONFIG_PREFIX/Risk_of_Rain" "$HOME/.config/Risk_of_Rain"

# Setup Box86
export BOX86_LOG=1
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_LD_LIBRARY_PATH="$LIB_PREFIX/i386-linux-gnu"
export BOX86_PATH="$GAME_PREFIX"
[ "$LIBGL_FB" != "" ] && export BOX86_LIBGL="$LIB_PREFIX/arm-linux-gnueabihf/gl4es/libGL.so.1"
export LD_LIBRARY_PATH="/lib32:/usr/lib32:$LIB_PREFIX/arm-linux-gnueabihf:$LD_LIBRARY_PATH"

# Setup controls
#_sudo chmod 666 /dev/uinput
#export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
#_gptokeyb -k Risk_of_Rain xbox360 &
_gptokeyb -k Risk_of_Rain -c "$CONFIG_PREFIX/Risk_of_Rain.gptk" &

# Run game
_box86 Risk_of_Rain
