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

GAMEDIR=/$directory/ports/hammerwatch
CONFDIR="$GAMEDIR/conf/"
mkdir -p "$GAMEDIR/conf"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR

if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if ! glxinfo | grep "OpenGL version string"; then
    pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
    sleep 5
    exit 1
    fi
    rocknix_mode=1
else
    rocknix_mode=0
fi


> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

if [ ! -f "$GAMEDIR/gamefiles/Hammerwatch.exe" ]; then
  pm_message "This port is not installed correctly. Please place your gamefiles directly inside hammerwatch/gamefiles/."
  sleep 5
  exit 1
fi

if [ ! -f "$GAMEDIR/gamefiles/patched.txt" ]; then
  pm_message "Copying additional files into the game directory"
  cp -f "$GAMEDIR/patch/"* "$GAMEDIR/gamefiles/"
  if [ "$rocknix_mode" -eq 1 ]; then
	rm -f "$GAMEDIR/gamefiles/libSDL2-2.0.so.0" # X11 compatibility SDL that isn't needed on Rocknix Panfrost
  fi
  touch "$GAMEDIR/gamefiles/patched.txt"
fi


if [ "$rocknix_mode" -eq 0 ]; then 
# Mount Weston
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
fi

# Mount Mono
mono_dir=/tmp/mono
$ESUDO mkdir -p "${mono_dir}"
mono_runtime="mono-6.12.0.122-aarch64"
if [ ! -f "$controlfolder/libs/${mono_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi

  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${mono_runtime}.squashfs"
fi
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${mono_dir}"
fi
$ESUDO mount "$controlfolder/libs/${mono_runtime}.squashfs" "${mono_dir}"

export PATH="$mono_dir/bin":"$PATH"

$GPTOKEYB "mono" -c "$GAMEDIR/hammerwatch.gptk" &
# unset SDL_GAMECONTROLLERCONFIG
#pm_platform_helper "$GAMEDIR/box64.${DEVICE_ARCH}"

if [ "$rocknix_mode" -eq 0 ]; then
	# Temporary fix for older ArkOS devices until westonpack is updated
	for lib in libSDL2.so libSDL2.so.0 libSDL2-2.0.so libSDL2-2.0.so.0; do
    		output="$($weston_dir/tools/findlib "$lib" 2>/dev/null)"
	   	 if [ $? -eq 0 ] && [ -n "$output" ]; then
		        export CRUSTY_LIBSDL="$(echo "$output" | tail -n 1)"
		        break
		 fi
	done 
	$ESUDO env CRUSTY_LIBSDL="$CRUSTY_LIBSDL" $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es "cd $GAMEDIR/gamefiles/; PATH=\"$PATH\" XDG_DATA_HOME="$CONFDIR" SDL_NO_SIGNAL_HANDLERS=1 mono Hammerwatch.exe"
	$ESUDO $weston_dir/westonwrap.sh cleanup
else
	cd $GAMEDIR/gamefiles/
	$ESUDO env PATH="$PATH" XDG_DATA_HOME="$CONFDIR" SDL_NO_SIGNAL_HANDLERS=1 mono Hammerwatch.exe
fi
$ESUDO pkill -9 mono
pm_finish



