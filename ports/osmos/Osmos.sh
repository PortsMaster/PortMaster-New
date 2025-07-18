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

# Adjust these to your paths
GAMEDIR=/$directory/ports/osmos
gptk_filename="osmos_controls.ini"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Version check
VERSION_FILE="$GAMEDIR/gamefiles/version.txt"
if [ -f "$VERSION_FILE" ]; then
    game_version=$(<"$VERSION_FILE")
else
    echo "Version file not found at $VERSION_FILE, checking for installers."
    
    # Web Demo
    installer=$(find $GAMEDIR/installer/webdemo/ -maxdepth 1 -name "*.deb" | head -n 1)
    if [ ! -z "$installer" ]; then
	    echo "Installing Web Demo"
	    mkdir -p $GAMEDIR/gamefiles/
	    rm -r $GAMEDIR/gamefiles/* # in case there was a previous installation
	    LD_LIBRARY_PATH=$GAMEDIR/libs.aarch64 $GAMEDIR/tools/ar p "$installer" data.tar.gz | gunzip | tar -x -C $GAMEDIR/gamefiles/
	    mv $GAMEDIR/gamefiles/opt/OsmosDemo/* $GAMEDIR/gamefiles/
	    python3 $GAMEDIR/tools/patch.py $GAMEDIR/gamefiles/OsmosDemo.bin64 $GAMEDIR/gamefiles/OsmosDemo.bin64.patched
	    rm -r $GAMEDIR/gamefiles/opt/ $GAMEDIR/gamefiles/usr/
	    rm $installer
            chmod -R 777 $GAMEDIR/gamefiles/
	    echo "webdemo" > $GAMEDIR/gamefiles/version.txt
            game_version="webdemo"
    fi

    # Web Full Version
    installer=$(find $GAMEDIR/installer/webfull/ -maxdepth 1 -name "*.deb" | head -n 1)
    if [ ! -z "$installer" ]; then
            echo "Installing Web Full Version"
            mkdir -p $GAMEDIR/gamefiles/
            rm -r $GAMEDIR/gamefiles/* # in case there was a previous installation
            LD_LIBRARY_PATH=$GAMEDIR/libs.aarch64 $GAMEDIR/tools/ar p "$installer" data.tar.gz | gunzip | tar -x -C $GAMEDIR/gamefiles/
            mv $GAMEDIR/gamefiles/opt/Osmos/* $GAMEDIR/gamefiles/
            python3 $GAMEDIR/tools/patch.py $GAMEDIR/gamefiles/Osmos.bin64 $GAMEDIR/gamefiles/Osmos.bin64.patched
            rm -r $GAMEDIR/gamefiles/opt/ $GAMEDIR/gamefiles/usr/
            rm -r $installer
            chmod -R 777 $GAMEDIR/gamefiles/
            echo "webfull" > $GAMEDIR/gamefiles/version.txt
            game_version="webfull"
    fi
    
    # Steam Version
    installer=$(find $GAMEDIR/installer/steam/ -maxdepth 1 -name "*.bin32" | head -n 1)
    if [ ! -z "$installer" ]; then
            echo "Installing Steam Version"
            mkdir -p $GAMEDIR/gamefiles/
            rm -r $GAMEDIR/gamefiles/* # in case there was a previous installation
            mv $GAMEDIR/installer/steam/* $GAMEDIR/gamefiles/
            python3 $GAMEDIR/tools/patch.py $GAMEDIR/gamefiles/Osmos.bin32 $GAMEDIR/gamefiles/Osmos.bin32.patched
            cp -f $GAMEDIR/libs.x86/steamstub/libsteam_api.so $GAMEDIR/gamefiles/ # Steam Stub (not DRM-breaking, just achievement stub)
            chmod -R 777 $GAMEDIR/gamefiles/
            echo "steam" > $GAMEDIR/gamefiles/version.txt
            game_version="steam"
    fi
fi

if [ ! -f $GAMEDIR/gamefiles/version.txt ]; then
   echo "Game files are not installed correctly. Please add your game files to the appropriate folder in installer/. Check the instructions for more info"
   pm_message "Game files are not installed correctly. Please add your game files to the appropriate folder in installer/. Check the instructions for more info"
   sleep 5
   exit 1
fi

# Create directory for save files
CONFDIR="$GAMEDIR/conf/"
$ESUDO mkdir -p "${CONFDIR}"

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


# Calculate deadzone_scale based on DISPLAY_WIDTH
value=$((6*$DISPLAY_WIDTH/480))
echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = .*/\1 = $value/g" \
  "$GAMEDIR"/$gptk_filename*


cd $GAMEDIR/gamefiles

# Start Westonpack

case "$game_version" in
        webdemo)
            echo "Running Web Demo Version"
	    $GPTOKEYB2 "OsmosDemo.bin64" -c "$GAMEDIR/$gptk_filename" &
            pm_platform_helper "OsmosDemo.bin64.patched"
            $ESUDO env CRUSTY_SHOW_CURSOR=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es HOME=$CONFDIR BOX64_LD_LIBRARY_PATH=$GAMEDIR/libs.x64/ $GAMEDIR/box64 OsmosDemo.bin64.patched
            ;;
        webfull)
            echo "Running Full Web Version"
	    $GPTOKEYB2 "Osmos.bin64" -c "$GAMEDIR/$gptk_filename" &
            pm_platform_helper "Osmos.bin64.patched"
            $ESUDO env CRUSTY_SHOW_CURSOR=1 $weston_dir/westonwrap.sh headless noop kiosk crusty_glx_gl4es HOME=$CONFDIR BOX64_LD_LIBRARY_PATH=$GAMEDIR/libs.x64/ $GAMEDIR/box64 Osmos.bin64.patched
            ;;
        steam)
            echo "Running Steam Version"
            $GPTOKEYB2 "Osmos.bin32" -c "$GAMEDIR/$gptk_filename" &
            pm_platform_helper "OsmosDemo.bin32.patched"
            $ESUDO env CRUSTY_SHOW_CURSOR=1 $weston_dir/westonwrap32.sh headless noop kiosk crusty_glx_gl4es BOX86_LD_LIBRARY_PATH=$GAMEDIR/libs.x86/ $GAMEDIR/box86 Osmos.bin32.patched
            ;;
        *)
            echo "Unknown version: $version"
	    exit 1
            ;;
    esac


#Clean up after ourselves
$ESUDO $weston_dir/westonwrap.sh cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
    $ESUDO umount "${weston_dir}"
fi
pm_finish
