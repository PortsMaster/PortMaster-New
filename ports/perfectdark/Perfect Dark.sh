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

GAMEDIR=/$directory/ports/perfectdark
CONFDIR="$GAMEDIR/conf/"
BINARY=pd.arm64

mkdir -p "$GAMEDIR/conf/data"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories ~/.local/share/perfectdark $GAMEDIR/conf

# Put ROM in correct place
rom_file="./conf/data/pd.ntsc-final.z64"
rom_md5=e03b088b6ac9e0080440efed07c1e40f
if [ -f "$rom_file" ]; then
  echo ROM is in correct location
else
  find . -maxdepth 2 -type f | while read file
  do
    checksum=$(md5sum "$file" | awk '{print $1}')
    if [ "$checksum" == "$rom_md5" ]; then
      echo Found ROM $file, moving it into place
      mv "$file" "$rom_file"
      break
    fi
  done
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

$GPTOKEYB "$BINARY" &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
