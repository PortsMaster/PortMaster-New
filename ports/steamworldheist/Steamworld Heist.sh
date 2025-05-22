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


GAMEDIR="/$directory/ports/steamworldheist/"
SAVEDIR="$GAMEDIR/savedata/"
CONFDIR="$GAMEDIR/savedata/"
mkdir -p "$GAMEDIR/savedata/"
cd "$GAMEDIR/"

# Figure out of the User OS has working XBOX controls on GPTOKEY2 or not
if [[ "$CFW_NAME" = "AmberELEC" ]]; then
    badgptokey_mode=1
elif [[ "$CFW_NAME" = "ArkOS AeUX" ]]; then
    badgptokey_mode=1
else
    badgptokey_mode=0
fi

# Performance Warning on ROCKNIX
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if glxinfo | grep "OpenGL version string"; then
    pm_message "Its recommended to use libmali on lower end devices, as performance is worse on Panfrost."
    sleep 5
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
  mv "$GAMEDIR/data/noarch/game/"* "$GAMEDIR/"
  rm -rf "$GAMEDIR/data/" 
  rm -rf $GAMEDIR/installer/*.sh
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


# Seperate the Controller/Keyboard inputs for GPTOKEY2, since its broken on arkos/amberelec
if [ "$badgptokey_mode" -eq 0 ]; then 
	$GPTOKEYB2 "Heist" -x &
else
	$GPTOKEYB2 "Heist" -c "$GAMEDIR/Heist.gptk" &
fi
unset XDG_DATA_HOME
pm_platform_helper "$GAMEDIR/box86.${DEVICE_ARCH}"

#Sort out Panfrost/Adreno on Rocknix from libmali on anything else and launch accordingly
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if glxinfo | grep "OpenGL version string"; then
	$ESUDO env CRUSTY_BLOCK_INPUT=1 WRAPPED_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}/":"$GAMEDIR/box86/native":"/usr/lib":"/usr/lib32" $weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es \
	XDG_DATA_HOME=$CONFDIR BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32/:./:lib/:lib32/:x86/" \
	LIBGL_NOBANNER=1 BOX86_DYNAREC=1 BOX86_DLSYM_ERROR=1 BOX86_SHOWSEGV=1 BOX86_SHOWBT=1 \
	XDG_DATA_HOME=$CONFDIR SDL_VIDEODRIVER=x11 "$GAMEDIR/box86/box86" "$GAMEDIR/Heist"
    else 
	$ESUDO env CRUSTY_BLOCK_INPUT=1 WRAPPED_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}/":"$GAMEDIR/box86/native":"/usr/lib":"/usr/lib32" $weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es \
	XDG_DATA_HOME=$CONFDIR BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32/:./:lib/:lib32/:x86/" \
	LIBGL_NOBANNER=1 BOX86_DYNAREC=1 BOX86_DLSYM_ERROR=1 BOX86_SHOWSEGV=1 BOX86_SHOWBT=1 \
	XDG_DATA_HOME=$CONFDIR "$GAMEDIR/box86/box86" "$GAMEDIR/Heist"
    fi
else
   $ESUDO env CRUSTY_BLOCK_INPUT=1 WRAPPED_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}/":"$GAMEDIR/box86/native":"/usr/lib":"/usr/lib32" $weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es \
   XDG_DATA_HOME=$CONFDIR BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32/:./:lib/:lib32/:x86/" \
   LIBGL_NOBANNER=1 BOX86_DYNAREC=1 BOX86_DLSYM_ERROR=1 BOX86_SHOWSEGV=1 BOX86_SHOWBT=1 \
   XDG_DATA_HOME=$CONFDIR "$GAMEDIR/box86/box86" "$GAMEDIR/Heist"
fi

#Clean up after ourselves
$ESUDO $weston_dir/westonwrap32.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish

                                           