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

GAMEDIR="/$directory/ports/owlboy"
cd "$GAMEDIR/gamedata"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="/$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir and configdir
$ESUDO rm -rf ~/.local/share/Owlboy
$ESUDO rm -rf ~/.config/Owlboy
mkdir -p ~/.config

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  # Fix a problem with savedata
  mkdir -p ~/.local/share/Owlboy
  cp -r "$GAMEDIR/savedata/Saves/" ~/.local/share/Owlboy
else
  ln -sfv "$GAMEDIR/savedata" ~/.local/share/Owlboy
fi
ln -sfv "$GAMEDIR/savedata" ~/.config/Owlboy

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono*.dll

# Setup path and other environment variables
# export FNA_PATCH="$GAMEDIR/dlls/OwlboyPatches.dll"
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"$monodir/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "mono" &
$TASKSET mono Owlboy.exe 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"
unset LD_LIBRARY_PATH

if [[ $whichos == *"RetroOZ"* ]]; then
  # Fix a problem with savedata
  $ESUDO rm -rf "$GAMEDIR/savedata/Saves-old/"
  $ESUDO mv "$GAMEDIR/savedata/Saves/" "$GAMEDIR/savedata/Saves-old/"
  cp -r ~/.local/share/Owlboy/Saves/ "$GAMEDIR/savedata/"
fi

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0

