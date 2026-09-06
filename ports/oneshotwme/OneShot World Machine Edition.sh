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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls
source $controlfolder/tasksetter

gameassembly="OneShotMG.exe"
export GAMEDIR="/$directory/ports/oneshotwme"
CONFDIR="$GAMEDIR/savedata"

mkdir -p "$CONFDIR"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

export XDG_CONFIG_HOME="$CONFDIR"
export MONO_PATH="$GAMEDIR/dlls":"$GAMEDIR/gamedata":"$GAMEDIR/monomod"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$PATH"
export MONO_IOMAP=all
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [[ "$LIBGL_ES" != "" ]]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es/libEGL.so.1"
fi

cp "$GAMEDIR/dlls/OneShotMG.exe.config" "$GAMEDIR/gamedata/OneShotMG.exe.config"
cp "$GAMEDIR/dlls/OneShotMG.exe.config" "$GAMEDIR/gamedata/MONOMODDED_${gameassembly}.config"

needs_setup=yes
if grep -qx "Setup complete." "$GAMEDIR/install_log.txt" 2>/dev/null && \
   sha1sum -c "$GAMEDIR/gamedata/.ver_checksum" >/dev/null 2>&1; then
  needs_setup=no
fi

if [[ "$needs_setup" == yes ]]; then
  echo "Performing setup..." 2>&1 | tee /dev/tty0 "$GAMEDIR/install_log.txt"

  rm -f "$GAMEDIR/gamedata/Steamworks.NET.dll" "$GAMEDIR/gamedata/steam_api64.dll" "$GAMEDIR/gamedata/steam_appid.txt"
  cp "$GAMEDIR/dlls/Steamworks.NET.dll" "$GAMEDIR/gamedata/Steamworks.NET.dll"

  export MONOMOD_MODS="$GAMEDIR/patches"
  export MONOMOD_DEPDIRS="${MONO_PATH}":"$GAMEDIR/monomod"

  mono "$GAMEDIR/monomod/MonoMod.exe" "$GAMEDIR/gamedata/$gameassembly" 2>&1 | tee -a /dev/tty0 "$GAMEDIR/install_log.txt"
  if [ $? -ne 0 ]; then
    echo "Failure performing setup, report this." 2>&1 | tee -a /dev/tty0 "$GAMEDIR/install_log.txt"
    exit 1
  fi

  sha1sum "$GAMEDIR/gamedata/$gameassembly" > "$GAMEDIR/gamedata/.ver_checksum"
  sha1sum "$GAMEDIR/patches/"*.dll "$GAMEDIR/dlls/Steamworks.NET.dll" >> "$GAMEDIR/gamedata/.ver_checksum"
  echo "Setup complete." | tee -a /dev/tty0 "$GAMEDIR/install_log.txt" > /dev/null
fi

cd "$GAMEDIR/gamedata"

$GPTOKEYB "mono" &
pm_platform_helper "mono"
$TASKSET mono "MONOMODDED_${gameassembly}"

pm_finish
