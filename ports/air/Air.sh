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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Set variables
GAMEDIR="/$directory/ports/air"
SAVEDIR="KEY_AIR_SE KEY_AIR_ME_ALL"
DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
runtime="rlvm"
rlvm_dir="$HOME/rlvm"
rlvm_file="$controlfolder/libs/${runtime}.squashfs"
font="--font $rlvm_dir/fonts/msgothic.ttc"

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
for SAVEDIR in "${SAVEDIR[@]}"; do
    rm -rf "$HOME/.rlvm/$SAVEDIR"
    ln -s "$GAMEDIR/saves" "$HOME/.rlvm/$SAVEDIR"
done

export LD_LIBRARY_PATH="$rlvm_dir/libs":$LD_LIBRARY_PATH
if [ "$LIBGL_FB" != "" ]; then
  export SDL_VIDEO_GL_DRIVER="$rlvm_dir/gl4es/libGL.so.1"
  export LD_LIBRARY_PATH="$rlvm_dir/gl4es:$LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH="$rlvm_dir/gl4es:$LD_LIBRARY_PATH"
fi

# Setup controls
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$runtime" -c "rlvm.gptk" & 

# Run the game
echo "Loading, please wait... (might take a while!)" > /dev/tty0
$runtime $font "$GAMEDIR/gamedata"
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO umount "$rlvm_file" || true
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0