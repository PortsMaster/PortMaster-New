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

# Variables
GAMEDIR="/$directory/ports/steamlink"

# Set config
if [ ! -f "$GAMEDIR/config/SteamLink.conf" ]; then
    bind_directories ~/".config/Valve Corporation" "$GAMEDIR/config"
fi

# Patcher GUI exports
export PATCHER_FILE="$GAMEDIR/config/download"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="a few minutes"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

run_patcher() {
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
}

# Check if we need to download Steamlink
if [ "$DEVICE_ARCH" == "aarch64" ]; then
    LIBARCH="/usr/lib/"
    CDN_URL="http://cdn.origin.steamstatic.com/steamlink/rpi/bookworm/arm64/public_build.txt"
    CDN_TXT=$(curl -s "$CDN_URL")
    PACKAGE_URL=$(echo "$CDN_TXT" | grep -oP '(?<=https://)[^\s]*')
    PACKAGE_VERSION=$(echo "$PACKAGE_URL" | grep -oP 'steamlink-rpi-bookworm-arm64-([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)' | cut -d'-' -f4)
elif [ "$DEVICE_ARCH" == "armhf" ]; then
    LIBARCH="/usr/lib32/"
    echo "Armhf support is not yet implemented."
    exit 1
    #CDN_URL="http://cdn.origin.steamstatic.com/steamlink/rpi/bullseye/arm64/public_build.txt"
    #CDN_TXT=$(curl -s "$CDN_URL")
    #PACKAGE_URL=$(echo "$CDN_TXT" | grep -oP '(?<=https://)[^\s]*')
    #PACKAGE_VERSION=$(echo "$PACKAGE_URL" | grep -oP 'steamlink-rpi-bullseye-arm64-([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)' | cut -d'-' -f4)
else
    pm_message "Unable to determine architecture!"
fi

# If fetching build info fails, check if we have an existing shell binary
if [[ -z "$CDN_TXT" ]]; then
    if [[ -f "$GAMEDIR/bin/shell" ]]; then
        pm_message "No internet connection. Skipping update check."
    else
        pm_message "SteamLink requires an internet connection to download and use!"
        exit 1
    fi
# If we have an internet connection check the current version
elif [[ -f "$GAMEDIR/bin/version_${DEVICE_ARCH}.txt" ]]; then
    CURRENT_VERSION=$(grep -oP 'steamlink-rpi-bookworm-arm64-([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)' "$GAMEDIR/bin/version_${DEVICE_ARCH}.txt" | cut -d'-' -f4)
    if [[ "$CURRENT_VERSION" != "$PACKAGE_VERSION" ]]; then
        run_patcher
    fi
else
    run_patcher
fi

# Exports post-setup
QT_VERSION=$(ls -d $GAMEDIR/Qt-* 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/libs.${DEVICE_ARCH}/shell:$GAMEDIR/Qt-${QT_VERSION}/lib:$LD_LIBRARY_PATH"
export LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libgpucompat.so"
export QT_QPA_PLATFORM_PLUGIN_PATH="$GAMEDIR/Qt-${QT_VERSION}/plugins"
export QT_QPA_PLATFORM="xcb"
export SDL_VIDEO_DRIVER="x11"

# Assign gptokeyb and load the game
pm_platform_helper "$GAMEDIR/bin/shell.${DEVICE_ARCH} " >/dev/null
./"bin/shell.${DEVICE_ARCH}"

# Cleanup
pm_finish
