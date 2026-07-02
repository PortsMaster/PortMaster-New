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

GAMEDIR="/$directory/ports/dungeoncrawlstonesoup"
CONFDIR="$GAMEDIR/conf/"
CUR_TTY="/dev/tty0"
BINARY="crawl"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib32/:$LD_LIBRARY_PATH"
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

if [ $DISPLAY_WIDTH -ge 720 ]; then
	sed -E -i 's/tile_font_crt_size\s*=\s*[0-9]+/tile_font_crt_size = 13/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_stat_size\s*=\s*[0-9]+/tile_font_stat_size = 15/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_msg_size\s*=\s*[0-9]+/tile_font_msg_size = 15/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_tip_size\s*=\s*[0-9]+/tile_font_tip_size = 14/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_lbl_size\s*=\s*[0-9]+/tile_font_lbl_size = 14/g' "$CONFDIR/init.lua"
else
	sed -E -i 's/tile_font_crt_size\s*=\s*[0-9]+/tile_font_crt_size = 11/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_stat_size\s*=\s*[0-9]+/tile_font_stat_size = 13/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_msg_size\s*=\s*[0-9]+/tile_font_msg_size = 12/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_tip_size\s*=\s*[0-9]+/tile_font_tip_size = 12/g' "$CONFDIR/init.lua"
	sed -E -i 's/tile_font_lbl_size\s*=\s*[0-9]+/tile_font_lbl_size = 12/g' "$CONFDIR/init.lua"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
	export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
	export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi 

$ESUDO chmod 666 $CUR_TTY
printf "\033c" > $CUR_TTY
printf "Starting game (first load can take a while)...\n" > $CUR_TTY

$GPTOKEYB $BINARY -c "$BINARY.gptk" &
./$BINARY -rc "$CONFDIR/init.lua" -macro "$CONFDIR"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > $CUR_TTY
