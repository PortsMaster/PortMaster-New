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

gameassembly="TowerFall.exe"
gamedir="/$directory/ports/towerfall"
cd "$gamedir/gamedata"

exec > >(tee "$gamedir/log.txt") 2>&1

# extract the itch.io version if it's in gamedata
itch_file="$gamedir/gamedata/tfitch-07212016-bin"
if [ -f "$itch_file" ]; then
  echo "extracting itch.io version"
  unzip "$itch_file" -d "$gamedir/gamedata"
  rm -Rf "$gamedir/gamedata/guis" "$gamedir/gamedata/meta" "$gamedir/gamedata/scripts" && \
  mv $gamedir/gamedata/data/* "$gamedir/gamedata" && \
  rm -Rf "$gamedir/gamedata/data" "$itch_file"
fi

# extract the itch.io expansion if it's in gamedata 
itch_darkworld="$gamedir/gamedata/TowerFallDarkWorldExpansion.zip"
if [ -f "$itch_darkworld" ]; then
  unzip "$itch_darkworld" -d "$gamedir/gamedata"
  mv "$gamedir/gamedata/TowerFall Dark World Expansion/DarkWorldContent" "$gamedir/gamedata" && \
  rm -Rf "$gamedir/gamedata/TowerFall Dark World Expansion" "$itch_darkworld"
fi

# Process GOG version of the game
gog_game_file="$gamedir/gamedata/gog_towerfall_ascension_2.5.0.9.sh"
if [ -f "$gog_game_file" ]; then
    temporary="${gog_game_file%.sh}.gz"
    mv "$gog_game_file" "$temporary"
    unzip "$temporary" 'data/noarch/game/*' -d "$gamedir/gamedata"
    mv "$gamedir/gamedata/data/noarch/game"/* "$gamedir/gamedata"
    rm -rf "$gamedir/gamedata/data"  # Remove the extracted directory after moving if needed
    rm -f "$temporary"  # Remove the gz file after extraction if needed
fi

# Process GOG version of the DLC
gog_dlc_file="$gamedir/gamedata/gog_towerfall_ascension_dark_world_2.3.0.5.sh"
if [ -f "$gog_dlc_file" ]; then
    temporary="${gog_dlc_file%.sh}.gz"
    mv "$gog_dlc_file" "$temporary"
    unzip "$temporary" 'data/noarch/game/*' -d "$gamedir/gamedata"
    mv "$gamedir/gamedata/data/noarch/game"/* "$gamedir/gamedata"
    rm -rf "$gamedir/gamedata/data"  # Remove the extracted directory after moving if needed
    rm -f "$temporary"  # Remove the gz file after extraction if needed
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
$ESUDO rm -rf ~/.local/share/TowerFall
mkdir -p ~/.local/share
ln -sfv "$gamedir/savedata" ~/.local/share/TowerFall

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
# rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll
rm -f System*.dll Mono.*.dll mscorlib.dll FNA.dll

# Setup path and other environment variables
export MONO_PATH="$gamedir/dlls"
export LD_LIBRARY_PATH="$gamedir/libs":"$monodir/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

$GPTOKEYB "mono" &
$TASKSET mono --ffast-math -O=all ${gameassembly} 
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1

