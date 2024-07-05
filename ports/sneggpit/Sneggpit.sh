#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# Below we assign the source of the control folder (which is the PortMaster folder) based on the distro:
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# We source the control.txt file contents here
source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls

GAMEDIR="/$directory/ports/sneggpit"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod 666 /dev/uinput

EXECUTABLE="$GAMEDIR/arcajs.${DEVICE_ARCH}"
chmod +x "$EXECUTABLE"

cd "$GAMEDIR"

$GPTOKEYB "$EXECUTABLE" -c "./sneggpit.gptk" &
$EXECUTABLE -j -1 ../sneggpit

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
