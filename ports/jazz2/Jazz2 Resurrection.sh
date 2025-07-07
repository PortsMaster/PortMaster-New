#!/bin/bash
# Ported by Maciej Suminski <orson at orson dot net dot pl>
# Built from https://github.com/deathkiller/jazz2-native
# cmake .. -DCMAKE_BUILD_TYPE=Release -DDEATH_TRACE=OFF -DNCINE_PREFERRED_BACKEND=SDL2 -DNCINE_LINUX_PACKAGE=jazz2 -DNCINE_PACKAGED_CONTENT_PATH=ON

PORTNAME="Jazz Jackrabbit 2"

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

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

GAMEDIR="/$directory/ports/jazz2"
cd $GAMEDIR

# Symbolic link will not work
cp "$SDL_GAMECONTROLLERCONFIG_FILE" "$GAMEDIR/Content/gamecontrollerdb.txt"
export XDG_CONFIG_HOME="/$directory/ports"
export XDG_DATA_HOME="/$directory/ports"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "jazz2.${DEVICE_ARCH}" &
pm_platform_helper "$GAMEDIR/jazz2.${DEVICE_ARCH}"
./jazz2.${DEVICE_ARCH} 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> $CUR_TTY

