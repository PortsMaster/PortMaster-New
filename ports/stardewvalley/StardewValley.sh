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
source $controlfolder/device_info.txt
source $controlfolder/tasksetter

get_controls

gamedir="/$directory/ports/stardewvalley"
cd "$gamedir/"

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

# Setup path and other environment variables
export MONOGAME_PATCH="$gamedir/dlls/StardewPatches.dll"
export MONO_PATH="$gamedir/dlls":"$gamedir"
export PATH="$monodir/bin":"$PATH"
export LD_LIBRARY_PATH="$gamedir/libs"

# Delete older GL4ES installs...
rm -f $gamedir/libs/libGL.so.1 $gamedir/libs/libEGL.so.1

# Request libGL from Portmaster
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_ES" != "" ]]; then
	export SDL_VIDEO_GL_DRIVER="libGL.so.1"
	export SDL_VIDEO_EGL_DRIVER="libEGL.so.1"
fi

# Jump into the gamedata dir now
cd "$gamedir/gamedata"

# Fix for the Linux builds, use mono-provided libraries instead.
rm -f MonoGame.Framework.* System.dll

# Check if it's the Windows or Linux version
if [[ -f "Stardew Valley.exe" ]]; then
	gameassembly="Stardew Valley.exe"

	# Copy the Windows Stardew Valley WinAPI workarounds
	cp "${gamedir}/dlls/Stardew Valley.exe.config" "${gamedir}/gamedata/Stardew Valley.exe.config"
else
	gameassembly="StardewValley.exe"
fi

$GPTOKEYB "mono" &
$TASKSET mono ../SVLoader.exe "${gameassembly}" 2>&1 | tee "${gamedir}/log.txt"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1
