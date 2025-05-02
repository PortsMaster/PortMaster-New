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


GAMEDIR="/$directory/ports/steamworlddig/"
SAVEDIR="$GAMEDIR/savedata/"
CONFDIR="$GAMEDIR/savedata/"
mkdir -p "$GAMEDIR/savedata/"
cd "$GAMEDIR/"

# Warn about Panfrost incompatability on ROCKNIX
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if glxinfo | grep "OpenGL version string"; then
    pm_message "This Port only supports the libMali graphics driver. Switch to from Panfrost to libMali to continue."
    sleep 5
    exit 1
    fi
fi

# Unpack GOG Files
$ESUDO chmod 777 "$GAMEDIR/unzip"
LD_LIBRARY_PATH="$GAMEDIR/tools/libs.aarch64"
if ls $GAMEDIR/installer/*.sh 1> /dev/null 2>&1; then
  pm_message "Unpacking GOG installer. This will take a minute or two...."
  sleep 5
  # extract
  LD_LIBRARY_PATH=$GAMEDIR/libs.${DEVICE_ARCH} "$GAMEDIR/unzip" "$GAMEDIR/installer/*.sh" "data/noarch/game/*" -d "$GAMEDIR"
  rm -rf "$GAMEDIR/installer/" 
  mv "$GAMEDIR/data/noarch/game/"* "$GAMEDIR/"
  rm -rf "$GAMEDIR/data/" 
fi

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$GAMEDIR/savedata/"

# Logging
> "${GAMEDIR}/log.txt" && exec > >(tee "${GAMEDIR}/log.txt") 2>&1

#Delete install.sh from the gog game files
if ls $GAMEDIR/install.sh 1> /dev/null 2>&1; then
 rm -rf "$GAMEDIR/install.sh"
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


$GPTOKEYB2 "SteamWorldDig" -c ./Dig.gptk &
pm_platform_helper "$GAMEDIR/box86.${DEVICE_ARCH}"

$ESUDO env WRAPPED_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}/":"$GAMEDIR/box86/native":"/usr/lib":"/usr/lib32" $weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es \
BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32/:./:lib/:lib32/:x86/" \
LIBGL_NOBANNER=1 BOX86_DYNAREC=1 BOX86_DLSYM_ERROR=1 BOX86_SHOWSEGV=1 BOX86_SHOWBT=1 \
XDG_DATA_HOME=$CONFDIR "$GAMEDIR/box86/box86" "$GAMEDIR/SteamWorldDig"


#Clean up after ourselves
$ESUDO $weston_dir/westonwrap32.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish

                                           