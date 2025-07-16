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

# Set variables
GAMEDIR="/$directory/ports/tomoyo_after"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
runtime="rlvm"
rlvm_dir="$HOME/rlvm"
rlvm_file="$controlfolder/libs/${runtime}.squashfs"
font="--font $rlvm_dir/fonts/sazanami-gothic.ttf"
font2="--font $rlvm_dir/fonts/DejaVuSans.ttf"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Check for runtime
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Setup RLVM
$ESUDO mkdir -p "$rlvm_dir"
$ESUDO umount "$rlvm_file" || true
$ESUDO mount "$rlvm_file" "$rlvm_dir"
PATH="$rlvm_dir:$PATH"

# Create the config folders
mkdir -p "$GAMEDIR/saves/KEY\智代アフター"
mkdir -p "$GAMEDIR/saves/KEY_智代アフター_EN_ALL"

bind_directories "$HOME/.rlvm/KEY\智代アフター" "$GAMEDIR/saves/KEY\智代アフター"
bind_directories "$HOME/.rlvm/KEY_智代アフター_EN_ALL" "$GAMEDIR/saves/KEY_智代アフター_EN_ALL"

# Check and modify Gameexe.ini
INI="$GAMEDIR/gamedata/Gameexe.ini"
if grep -q '#REGNAME = "KEY\智代アフター_EN_ALL"' $INI; then
    sed -i 's/#WAKU.001.TYPE=0/#WAKU.001.TYPE=5/' $INI
    sed -i 's/#WAKU.001.000.NAME="s_mw00d_convertible"/#WAKU.001.000.NAME="s_mw00d"/' $INI
    sed -i 's/#WAKU.001.000.BACK="s_mw00e_convertible"/#WAKU.001.000.BACK="s_mw00e"/' $INI
fi

# Export libs
export LD_LIBRARY_PATH="$rlvm_dir/libs":$LD_LIBRARY_PATH
if [ "$LIBGL_FB" != "" ]; then
  export SDL_VIDEO_GL_DRIVER="$rlvm_dir/gl4es/libGL.so.1"
  export LD_LIBRARY_PATH="$rlvm_dir/gl4es:$LD_LIBRARY_PATH"
fi
  
# Setup controls
$GPTOKEYB "$runtime" -c "rlvm.gptk" & 

# Disable touchscreen
modprobe -r edt_ft5x06

# Run the game
pm_message "Loading, please wait... (might take a while!)"
pm_platform_helper "$rlvm_dir/$runtime"
$runtime $font "$GAMEDIR/gamedata"

# Cleanup
pm_finish

# Re-enable touchscreen
modprobe edt_ft5x06