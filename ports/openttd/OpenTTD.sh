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

GAMEDIR="/$directory/ports/openttd"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Extract game files on 1st run
if [ ! -d "$GAMEDIR/gm" ]; then
    "$GAMEDIR/7zzs" x "$GAMEDIR/gamedata.7z" -o"$GAMEDIR/"
    sleep 1
    rm -f "$GAMEDIR/gamedata.7z"
fi

# Game config and display scaling
if [[ "$DISPLAY_WIDTH" != '480' ]]; then
    sed -i 's/^small_font =.*/small_font = DejaVu Sans/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^medium_font =.*/medium_font = DejaVu Sans, Bold/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^large_font =.*/large_font = DejaVu Serif, Bold/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^mono_font =.*/mono_font = DejaVu Sans Mono, Bold/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^small_size =.*/small_size = 13/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^medium_size =.*/medium_size = 13/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^large_size =.*/large_size = 17/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^mono_size =.*/mono_size = 13/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^last_newgrf_count =.*/last_newgrf_count = 1/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^gui_zoom =.*/gui_zoom = 1/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^font_zoom =.*/font_zoom = 1/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^blitter =.*/blitter = 8bpp-optimized/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^sprite_cache_size_px =.*/sprite_cache_size_px = 128/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^settings_restriction_mode =.*/settings_restriction_mode = 2/' "$GAMEDIR/conf/openttd/openttd.cfg"
else
    sed -i 's/^small_font =.*/small_font = /' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^medium_font =.*/medium_font = /' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^large_font =.*/large_font = /' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^mono_font =.*/mono_font = /' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^small_size =.*/small_size = 9/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^medium_size =.*/medium_size = 9/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^large_size =.*/large_size = 12/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^mono_size =.*/mono_size = 9/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^last_newgrf_count =.*/last_newgrf_count = 0/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^gui_zoom =.*/gui_zoom = -1/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^font_zoom =.*/font_zoom = -1/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^blitter =.*/blitter = 8bpp-optimized/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^sprite_cache_size_px =.*/sprite_cache_size_px = 128/' "$GAMEDIR/conf/openttd/openttd.cfg"
    sed -i 's/^settings_restriction_mode =.*/settings_restriction_mode = 0/' "$GAMEDIR/conf/openttd/openttd.cfg"
fi

# Fix mouse disappearing on ROCKNIX
if [[ "${CFW_NAME^^}" == 'ROCKNIX' ]] || [[ "${CFW_NAME^^}" == 'JELOS' ]]; then
    sed -i 's/^seat \* hide_cursor.*/seat * hide_cursor 300000/' ~/.config/sway/config
    swaymsg reload
    sleep 1
fi

# Set mouse speed based on screen resolution
if [[ "$DISPLAY_WIDTH" == '480' ]] || [[ "$DISPLAY_WIDTH" == '640' ]] || [[ "$DISPLAY_WIDTH" == '720' ]]; then
    sed -i 's/^mouse_scale =.*/mouse_scale = 5800/' "$GAMEDIR/openttd.gptk.$ANALOGSTICKS"
elif [[ "$DISPLAY_WIDTH" == '854' ]] || [[ "$DISPLAY_WIDTH" == '960' ]] || [[ "$DISPLAY_WIDTH" == '1280' ]]; then
    sed -i 's/^mouse_scale =.*/mouse_scale = 4400/' "$GAMEDIR/openttd.gptk.$ANALOGSTICKS"
elif [[ "$DISPLAY_WIDTH" == '1920' ]]; then
    sed -i 's/^mouse_scale =.*/mouse_scale = 2800/' "$GAMEDIR/openttd.gptk.$ANALOGSTICKS"
else
    sed -i 's/^mouse_scale =.*/mouse_scale = 6000/' "$GAMEDIR/openttd.gptk.$ANALOGSTICKS"
fi

bind_directories ~/.config/openttd $GAMEDIR/conf/openttd

$GPTOKEYB "openttd.${DEVICE_ARCH}" -c "$GAMEDIR/openttd.gptk.$ANALOGSTICKS" &
pm_platform_helper "$GAMEDIR/openttd.${DEVICE_ARCH}"
./openttd.${DEVICE_ARCH} -m fluidsynth:driver=pulseaudio,soundfont=$GAMEDIR/gm/TimGM6mb.sf2

pm_finish
