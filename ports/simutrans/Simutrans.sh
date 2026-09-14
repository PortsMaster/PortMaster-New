#!/bin/bash
# PORTMASTER: simutrans.zip, Simutrans.sh

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

GAMEDIR="/$directory/ports/simutrans"
CONFDIR="$GAMEDIR/conf/"
BINARY="simutrans"
cd "$GAMEDIR"

# Reset locale to POSIX to prevent glibc sprintf decimal-comma buffer overflow crash in number_to_string
export LC_ALL=C
export LANG=C
export LANGUAGE=C

# Unset SDL_NOMOUSE so SDL2 recognizes gptokeyb uinput mouse on Knulli/Batocera
unset SDL_NOMOUSE

# Setup console and permissions
CUR_TTY=/dev/tty0
printf "\033c" > $CUR_TTY
echo "Starting Simutrans... Please wait." > $CUR_TTY
$ESUDO chmod 666 $CUR_TTY 2>/dev/null || true
$ESUDO chmod 666 /dev/uinput 2>/dev/null || true
$ESUDO chmod 666 /dev/input/event* 2>/dev/null || true

# Setup libraries and environment
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export SDL_RENDER_DRIVER=software

# Clean any existing gptokeyb
$ESUDO killall -9 gptokeyb 2>/dev/null || true

# Start gptokeyb controls in background
$GPTOKEYB "$BINARY.${DEVICE_ARCH}" -c "./$BINARY.gptk.$ANALOG_STICKS" &
sleep 0.5

# Run Simutrans (with fallback if starter save is provided)
if [ -f "save/default.sve" ]; then
  ./$BINARY.${DEVICE_ARCH} -load default.sve -screensize 640x480 -borderless -singleuser
else
  ./$BINARY.${DEVICE_ARCH} -screensize 640x480 -borderless -singleuser
fi

# Cleanup
pm_finish
