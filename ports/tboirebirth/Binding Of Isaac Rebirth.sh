#!/bin/bash

# PortMaster preamble
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

GAMEDIR=/$directory/ports/tboirebirth

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check for game files
if [ ! -f "$GAMEDIR/gamefiles/isaac.x64" ]; then
    echo "Game files are not installed correctly!"
    pm_message "Game files are not installed correctly. Please put your game files directly into to the 'gamefiles' folder. Check the instructions for more info"
    sleep 5
    exit 1
fi

# Installation and patching
if [ ! -f "$GAMEDIR/gamefiles/isaac.x64.hack" ]; then
    # This binary hack patches out a couple of instructions that clamp scaling values to integers
    echo "Applying scaling hack to isaac.x64"
    python3 -c "open('$GAMEDIR/gamefiles/isaac.x64.hack','wb').write(open('$GAMEDIR/gamefiles/isaac.x64','rb').read().replace(b'\x0f\x2e\xc8\x0f\x87\xf0\x01\x00\x00', b'\x0f\x28\xd0\x48\xe9\x10\x00\x00\x00').replace(b'\xf3\x0f\x59\xc2\xe8\x81\xfe\xe6\xff\xf3\x0f\x10\x54\x24\x10', b'\xf3\x0f\x59\xc2\xf2\x48\x90\x48\x90\xf3\x0f\x10\x54\x24\x10'))"
    # Just in case
    chmod 777 $GAMEDIR/gamefiles/isaac.x64
    chmod 777 $GAMEDIR/gamefiles/isaac.x64.hack
    chmod -R 777 $GAMEDIR/libs.x64/* 
    chmod -R 777 $GAMEDIR/gamefiles/lib64/*
fi

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

# Copy over default options.ini
if [ ! -f "$CONFDIR/the binding of isaac rebirth/options.ini" ]; then
    mkdir -p "$CONFDIR/binding of isaac rebirth"
    cp $GAMEDIR/patch/options.ini "$CONFDIR/binding of isaac rebirth/options.ini"
    # patch the device resolution into it
    python3 -c "import os; f='$CONFDIR/binding of isaac rebirth/options.ini'; d=open(f).read().replace('640', '$DISPLAY_WIDTH').replace('480', '$DISPLAY_HEIGHT'); open(f, 'w').write(d)"
fi

# Copy over default inputconfigs.dat (with switched wasd and arrow keys)
if [ ! -f "$CONFDIR/the binding of isaac rebirth/inputconfigs.dat" ]; then
    cp $GAMEDIR/patch/inputconfigs.dat "$CONFDIR/binding of isaac rebirth/inputconfigs.dat"
fi


# Start Launcher
cd $GAMEDIR
source $controlfolder/runtimes/love_11.5/love.txt
$GPTOKEYB "love.${DEVICE_ARCH}" -c "$GAMEDIR/launcher.gptk" &
XDG_DATA_HOME=$CONFDIR $LOVE_RUN "launcher"
if [ $? -ne 0 ]; then
   echo "Launcher did not exit normally, aborting"
   exit 1
fi
$ESUDO pkill -9 -f "gptokeyb"

# Apply config
source "$CONFDIR/love/launcher/config.cfg"

if [ $scale_hack -eq 1 ]; then
   game_executable="isaac.x64.hack"
else
   game_executable="isaac.x64"
fi

if [ $disable_effects -eq 1 ]; then
   cp $GAMEDIR/patch/config.ini $GAMEDIR/gamefiles/resources/config.ini
else
   rm -f $GAMEDIR/gamefiles/resources/config.ini
fi

if [ $disable_fog_overlays -eq 1 ]; then
   if [ ! -d "$GAMEDIR/gamefiles/resources/gfx/" ]; then
      cp -r "$GAMEDIR/patch/gfx/" "$GAMEDIR/gamefiles/resources/gfx/"
   fi
else
   rm -r "$GAMEDIR/gamefiles/resources/gfx/"
fi
   
gl4es_params="LIBGL_ALPHAHACK=1 LIBGL_NOHIGHP=1 "
if [ $reduce_quality -eq 1 ]; then
   gl4es_params="$gl4es_params LIBGL_LIBGL_FORCE16BITS=1"
fi

box_preload=""
if [ $x11_hack -eq 1 ]; then
   box_preload="$GAMEDIR/libs.x64/libx11_cache.so:"
fi

if [ $xkb_fix -eq 1 ]; then
   box_preload="$box_preload""$GAMEDIR/libs.x64/libxkb_fix.so:"
fi

gptk_file="$GAMEDIR/isaac.gptk"
if [ $swap_ab -eq 1 ]; then
   gptk_file="$GAMEDIR/isaac_ab_swap.gptk"
fi

if [ $swap_abxy -eq 1 ]; then
   gptk_file="$GAMEDIR/isaac_abxy_swap.gptk"
fi


# Mount Weston runtime
weston_dir=/tmp/weston
$ESUDO mkdir -p "${weston_dir}"
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "${weston_dir}"

# Start game
cd $GAMEDIR/gamefiles
$GPTOKEYB2 "$game_executable" -c "$gptk_file" &

# Detect Rocknix Panfrost/Adreno and add back the input blocker (since westonpack is bypassed)
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if glxinfo | grep "OpenGL version string"; then
	input_blocker_preload=$GAMEDIR/libs.aarch64/libcrusty_inputblocker.so    
    fi
fi

$ESUDO env $gl4es_params WRAPPED_PRELOAD=$input_blocker_preload CRUSTY_BLOCK_INPUT=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es \
XDG_DATA_HOME=$CONFDIR BOX64_DYNAREC_CALLRET=1 BOX64_LD_PRELOAD=$box_preload BOX64_LD_LIBRARY_PATH=$GAMEDIR/libs.x64/:$GAMEDIR/gamefiles/lib64/ \
$GAMEDIR/box64 $game_executable

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
