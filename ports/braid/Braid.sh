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
export PORT_32BIT="Y"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# Set paths
GAMEDIR="/$directory/ports/braid"
GAMEDATA="$GAMEDIR/gamedata"
game_executable="Braid.bin.x86"
game_libs="$GAMEDATA/lib":$LD_LIBRARY_PATH
x11sdl="$GAMEDIR/libs.armhf/libSDL2-2.0.so.0.16.0"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# rocknix mode on rocknix panfrost; libmali not supported
if [[ "$CFW_NAME" == "ROCKNIX" ]]; then
  export rocknix_mode=1
fi

# Create directory for save files
CONFDIR="$GAMEDIR/conf"
$ESUDO mkdir -p "$CONFDIR"
bind_directories ~/.Braid "$CONFDIR"

# Extract game data
if [ ! -f "$GAMEDATA/$game_executable" ]; then
  echo Extracting game data...
  mkdir "$GAMEDATA/tmp"
  cd "$GAMEDATA/tmp"

  if ls "$GAMEDATA"/BraidSetup-*.sh >/dev/null 2>&1; then
    # Humble bundle installer.
    mv "$GAMEDATA"/BraidSetup*.sh "$GAMEDATA/braid_installer.zip"

    unzip "$GAMEDATA/braid_installer.zip"

    mv data/noarch/* "$GAMEDATA/"
    mv data/x86/* "$GAMEDATA/"
  else
    # Gog installer.
    mv "$GAMEDATA"/gog_braid*.sh "$GAMEDATA/braid_installer.zip"

    unzip "$GAMEDATA/braid_installer.zip"

    mv data/noarch/game/* "$GAMEDATA/"
  fi

  cd $GAMEDIR
  rm -r "$GAMEDATA/tmp"
  rm "$GAMEDATA/*.sh" "$GAMEDATA/braid_installer.zip" \
    "$GAMEDATA/launcher.bin.x86"
fi

# Patch binary (not on rocknix)
if [ -f "$GAMEDATA/$game_executable" ]; then
  res=`grep GL_ARB_draw_buffers "$GAMEDATA/$game_executable" 2>&1`
  if [ ! "$rocknix_mode" == 1 ] && [ ! -z "$res" ]; then
    echo Patching binary
    mv "$GAMEDATA/$game_executable" "$GAMEDATA/$game_executable.orig"
    sed "s/GL_ARB_draw_buffers/GL_XXX_draw_buffers/" \
      "$GAMEDATA/$game_executable.orig" > "$GAMEDATA/$game_executable"
    chmod a+x "$GAMEDATA/$game_executable"
    rm "$GAMEDATA/$game_executable.orig"
  fi
fi

# Run language selection GUI if necessary
LANGUAGE="$(cat $GAMEDIR/selected_language.txt)"
if [ -z "$LANGUAGE" ]; then
  export LD_LIBRARY_PATH="$GAMEDIR/launcher/libs":$LD_LIBRARY_PATH
  # Temporary fix for crossmix
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$controlfolder/runtimes/love_11.5/libs.aarch64":
  chmod +x ./love
  $GPTOKEYB "love" &
  ./love launcher
fi

# see what language they selected
LANGUAGE="$(cat $GAMEDIR/selected_language.txt)"
if [ -z "$LANGUAGE" ]; then
  LANGUAGE=english
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

# Audio setup
if [ "$CFW_NAME" == "ROCKNIX" ] || [ "$CFW_NAME" == "knulli" ]; then
  # rocknix, knulli
  pulse_path=/usr/lib32
  pulsecommon=`echo $pulse_path/pulseaudio/libpulsecommon-*.0.so`

  audiodriver=pulseaudio
  audio_preload="$pulse_path/libpulse-simple.so:$pulsecommon"

else
  # muos, arkos
  audiodriver=alsa
  audio_preload=

fi

$GPTOKEYB2 "$game_executable" -c "$GAMEDIR/$game_executable.gptk" &

pm_platform_helper "$GAMEDATA/$game_executable"

# Start Westonpack
$ESUDO env \
CRUSTY_BLOCK_INPUT=1 \
SDL_AUDIODRIVER=$audiodriver \
BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/box86-i386-linux-gnu" \
WRAPPED_PRELOAD="$x11sdl":"$audio_preload" \
$weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es \
HOME=$HOME \
$GAMEDIR/box86/box86 \
$GAMEDATA/$game_executable -no_launcher \
  -width $DISPLAY_WIDTH -height $DISPLAY_HEIGHT -language $LANGUAGE

# Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi

pm_finish
