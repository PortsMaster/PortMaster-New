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
export controlfolder

source $controlfolder/control.txt
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

export GAMEDIR="/$directory/ports/thedishwashervampiresmile"
export ASSEMBLY="VampireSmile.exe"
cd "$GAMEDIR/gamedata"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ ! -f "$ASSEMBLY" ] || [ ! -f "Content/sfx/music.xsb" ] || [ ! -f "Content/sfx/music.xwb" ]; then
  pm_show_error "Copy the Windows depot of The Dishwasher: Vampire Smile (download_depot 268990 268991) into ports/thedishwashervampiresmile/gamedata." --title "Game files missing"
  exit 1
fi

# Mono runtime
monodir="$HOME/mono"
mono_runtime="mono-6.12.0.122-aarch64"
monofile="$controlfolder/libs/${mono_runtime}.squashfs"
if [ ! -f "$monofile" ]; then
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${mono_runtime}.squashfs"
fi
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

mkdir -p "$GAMEDIR/savedata"
bind_directories ~/.local/share/VampireSmile "$GAMEDIR/savedata"
bind_directories ~/.config/VampireSmile "$GAMEDIR/savedata"

rm -f System*.dll Mono.*.dll mscorlib.dll FNA.dll
cp "$GAMEDIR/dlls/SDL2-CS.dll.config" "$GAMEDIR/gamedata/"
cp "$GAMEDIR/dlls/FNA.dll.config" "$GAMEDIR/gamedata/"
cp "$GAMEDIR/dlls/FNA.Steamworks.dll" "$GAMEDIR/gamedata/"
echo "268990" > steam_appid.txt

export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$monodir/lib:$LD_LIBRARY_PATH"
export PATH="$monodir/bin:$PATH"
export MONO_GC_PARAMS="nursery-size=128m,major=marksweep"
export MONO_GENERIC_SHARING=none
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0
export SteamAppId=268990
export STEAMID=268990

if [ ! -f "MONOMODDED_$ASSEMBLY" ] || [ ! -f .astc_done ] || ! sha1sum -c .ver_checksum > /dev/null 2>&1; then
  export PATCHER_FILE="$GAMEDIR/patches/first_setup.bash"
  export PATCHER_GAME="The Dishwasher: Vampire Smile"
  export PATCHER_TIME="about 20 minutes"
  export PATCHER_QUESTIONS="$GAMEDIR/patches/patcher_questions.lua"
  $ESUDO chmod a+x "$PATCHER_FILE"
  source "$controlfolder/utils/patcher.txt"
  [ -f "MONOMODDED_$ASSEMBLY" ] && [ -f .astc_done ] || exit 1
fi

# Optional language override: put a locale like de_DE.UTF-8 into thedishwashervampiresmile/lang.txt
if [ -f "$GAMEDIR/lang.txt" ]; then
  DVS_LANG="$(head -n 1 "$GAMEDIR/lang.txt" | tr -d '[:space:]')"
  if [ -n "$DVS_LANG" ]; then
    export LANG="$DVS_LANG" LC_ALL="$DVS_LANG"
  fi
fi
echo "Language override: ${DVS_LANG:-none}"

$GPTOKEYB2 "mono" &
pm_platform_helper "$monodir/bin/mono"
$TASKSET mono --ffast-math -O=all ../MMLoader.exe "MONOMODDED_$ASSEMBLY"

$ESUDO umount "$monodir"
pm_finish