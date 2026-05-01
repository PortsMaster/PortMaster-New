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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/wizorb"
cd "$GAMEDIR/gamedata"

"$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patch game if bin installer is found
ZIPFILE=$(ls "$GAMEDIR/gamedata/wizorb"*"bin" 2>/dev/null | head -n 1)
if [ -n "$ZIPFILE" ]; then
    $controlfolder/7zzs.${DEVICE_ARCH} x "$ZIPFILE" "data/*" -o"$GAMEDIR/gamedata"
    mv "$GAMEDIR/gamedata/data/"* "$GAMEDIR/gamedata/"
    rmdir "$GAMEDIR/gamedata/data"
    rm -f "$ZIPFILE"
    rm -f "$GAMEDIR/gamedata/place humble linux installer here.txt"
fi

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir

if [ ! -L ~/.local/share/Tribute\ Games/Wizorb ]; then
  cp ~/.local/share/Tribute\ Games/Wizorb/* "$GAMEDIR/savedata"
  rm -rf ~/.local/share/Tribute\ Games/Wizorb
fi
if [ ! -d ~/.local/share/Tribute\ Games ]; then
  mkdir ~/.local/share/Tribute\ Games
fi
ln -sfv "$GAMEDIR/savedata" ~/.local/share/Tribute\ Games/Wizorb

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/config/emuelec/lib32:/usr/lib32:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$GAMEDIR/libs:$PATH"
#export MONO_LOG_LEVEL=debug

# Wizorb needs this due to hardcoded paths
export MONO_IOMAP=all

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export SDL_TOUCH_MOUSE_EVENTS=0   
export SDL_MOUSE_TOUCH_EVENTS=0  

isitarkos=$(grep "title=" /usr/share/plymouth/themes/text.plymouth)
if [[ $isitarkos == *"ArkOS"* ]]; then
  $ESUDO perfnorm
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "mono" &
$TASKSET mono Wizorb.exe
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"
unset LD_LIBRARY_PATH

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0