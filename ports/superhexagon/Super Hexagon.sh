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

GAMEDIR=/$directory/ports/superhexagon
CONFDIR="$GAMEDIR/conf/"
mkdir -p "$GAMEDIR/conf"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd $GAMEDIR/gamefiles

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

# Try to install Itch version
if ls $GAMEDIR/gamefiles/itch/superhexagon-*-bin 1> /dev/null 2>&1; then
  pm_message "Unpacking Itch.io installer"
  LD_LIBRARY_PATH=$GAMEDIR/libs.${DEVICE_ARCH} "$GAMEDIR/unzip" "$GAMEDIR/gamefiles/itch/superhexagon-*-bin" "data/*" -d "$GAMEDIR/gamefiles/"
  mv "$GAMEDIR/gamefiles/data/" "$GAMEDIR/gamefiles/data1/"
  mv "$GAMEDIR/gamefiles/data1/"* "$GAMEDIR/gamefiles/"
  rm -rf "$GAMEDIR/gamefiles/data1/" "$GAMEDIR/gamefiles/x86/" 
  find "$GAMEDIR/gamefiles/" -name "libSDL2*.so*" -type f -delete
  rm -rf "$GAMEDIR/gamefiles/itch/" "$GAMEDIR/gamefiles/gog/" "$GAMEDIR/gamefiles/steam/"
fi

# Try to install GOG version
if ls $GAMEDIR/gamefiles/gog/gog_super_hexagon_*.sh 1> /dev/null 2>&1; then
  pm_message "Unpacking GOG installer"
  LD_LIBRARY_PATH=$GAMEDIR/libs.${DEVICE_ARCH} "$GAMEDIR/unzip" $GAMEDIR/gamefiles/gog/gog_super_hexagon_*.sh "data/noarch/game/*" -d "$GAMEDIR/gamefiles/"
  mv "$GAMEDIR/gamefiles/data/" "$GAMEDIR/gamefiles/data1/"
  mv "$GAMEDIR/gamefiles/data1/noarch/game/"* "$GAMEDIR/gamefiles/"
  rm -rf "$GAMEDIR/gamefiles/data1/" "$GAMEDIR/gamefiles/x86/"
  find "$GAMEDIR/gamefiles/" -name "libSDL2*.so*" -type f -delete
  rm -rf "$GAMEDIR/gamefiles/itch/" "$GAMEDIR/gamefiles/gog/" "$GAMEDIR/gamefiles/steam/"
fi

# Try to install Steam version
if ls $GAMEDIR/gamefiles/steam/SuperHexagon 1> /dev/null 2>&1; then
  mv "$GAMEDIR/gamefiles/steam/"* "$GAMEDIR/gamefiles/"
  rm "$GAMEDIR/gamefiles/lib64/libsteam_api.so"
  chmod -R 777 "$GAMEDIR/gamefiles/"*
  touch "$GAMEDIR/gamefiles/steam_install.txt"
  find "$GAMEDIR/gamefiles/" -name "libSDL2*.so*" -type f -delete
  rm -rf "$GAMEDIR/gamefiles/itch/" "$GAMEDIR/gamefiles/gog/" "$GAMEDIR/gamefiles/steam/"
fi

# Steam version has a different folder structure
gamefile="superhexagon.x86_64"
gamelocation="$GAMEDIR/gamefiles/x86_64"
gamelibs="$GAMEDIR/gamefiles/x86_64"
if [ -f "$GAMEDIR/gamefiles/steam_install.txt" ]; then
  echo "This is a steam installation"
  gamefile="SuperHexagon"
  gamelocation="$GAMEDIR/gamefiles"
  gamelibs="$GAMEDIR/libs.x64/steamstub/:$GAMEDIR/gamefiles/lib64"
fi


if [ ! -f "$gamelocation/$gamefile" ]; then
  pm_message "This port is not installed correctly. Please place 'superhexagon-05282015-bin' inside superhexagon/gamefiles/itch/."
  sleep 5
  exit 1
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


$GPTOKEYB "$gamefile" -c "$GAMEDIR/superhexagon.gptk" &
unset SDL_GAMECONTROLLERCONFIG
pm_platform_helper "$GAMEDIR/box64.${DEVICE_ARCH}"
if [ "$rocknix_mode" -eq 0 ]; then 
	$ESUDO env WRAPPED_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libSDL2-2.0.so.0" WRAPPED_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}/:$LD_LIBRARY_PATH" $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es XDG_DATA_HOME=$CONFDIR HACKSDL_NO_GAMECONTROLLER=1 BOX64_LD_PRELOAD="$GAMEDIR/libs.x64/hacksdl.x86_64.so" BOX64_LD_LIBRARY_PATH="$GAMEDIR/libs.x64:$gamelibs" "$GAMEDIR/box64" "$gamelocation/$gamefile"
	$ESUDO $weston_dir/westonwrap.sh cleanup
else
	$ESUDO env XDG_DATA_HOME=$CONFDIR HACKSDL_NO_GAMECONTROLLER=1 BOX64_LD_PRELOAD="$GAMEDIR/libs.x64/hacksdl.x86_64.so" BOX64_LD_LIBRARY_PATH="$GAMEDIR/libs.x64:$gamelibs" "$GAMEDIR/box64" "$gamelocation/$gamefile"
fi
$ESUDO pkill -9 box64
$ESUDO pkill -9 superhexagon.x86_64
pm_finish




