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
source $controlfolder/tasksetter

get_controls

gamedir="/$directory/ports/daikatana"
cd "$gamedir/"

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

export SDL_VIDEO_GL_DRIVER="$gamedir/libs/libGL.so.1"
export LIBGL_FB=1

$GPTOKEYB "daikatana" &
$TASKSET ./daikatana +set game gamedata |& tee "$gamedir/log.txt" /dev/tty0
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> /dev/tty1

