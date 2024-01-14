#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
 elif [ -d "/roms2/ports" ]; then
  controlfolder="/roms2/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls

gamedir="/$directory/ports/stardewvalley"
cd "$gamedir/gamedata"

# Check if it's the Windows or Linux version
if [[ -f "Stardew Valley.exe" ]]; then
	gameassembly="Stardew Valley.exe"

	# Copy the Windows Stardew Valley WinAPI workarounds
	cp "${gamedir}/dlls/Stardew Valley.exe.config" "${gamedir}/gamedata/Stardew Valley.exe.config"
else
	gameassembly="StardewValley.exe"
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
$ESUDO rm -rf ~/.config/StardewValley
ln -sfv "$gamedir/savedata" ~/.config/StardewValley

# Remove all the dependencies in favour of system libs - e.g. the included
# newer version of MonoGame with fixes for SDL2
rm -f System*.dll MonoGame*.dll mscorlib.dll

# Setup path and other environment variables
export MONOGAME_PATCH="$gamedir/dlls/StardewPatches.dll"
export MONO_PATH="$gamedir/dlls":"$gamedir"
export PATH="$monodir/bin":"$PATH"
export LD_LIBRARY_PATH="$gamedir/libs"
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export SDL_VIDEO_GL_DRIVER="$gamedir/libs/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$gamedir/libs/libEGL.so.1"

$GPTOKEYB "mono" &
$TASKSET mono ../SVLoader.exe "${gameassembly}" 2>&1 | tee "${gamedir}/log.txt"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1
