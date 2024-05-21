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
source $controlfolder/device_info.txt
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

gamedir="/$directory/ports/daikatana"
cd "$gamedir/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Create the symlinks
mkdir -p "$HOME/.local/share"
mkdir -p "$gamedir/savedata/gamedata"
$ESUDO rm -rf "$HOME/.local/share/Daikatana"
$ESUDO ln -s "$gamedir/savedata" "$HOME/.local/share/Daikatana"

# We want to avoid stale .cfg files from Desktop daikatana installs...
rm -f "$gamedir/gamedata/"*.cfg
cp "$gamedir/cfgs/"* "$gamedir/savedata/gamedata"

# Ensure bin is executable
chmod +x "$gamedir/daikatana"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
export LIBGL_FB=1
fi 


$GPTOKEYB "daikatana" &
$TASKSET ./daikatana +set game gamedata
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> /dev/tty1

