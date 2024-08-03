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

# Functions to be used later
calculate_sha() {
    sha1sum "$1" | awk '{ print $1 }'
}

install() {
    if [ -f "game.droid" ]; then
        sha=$(calculate_sha game.droid)
        if [ "$sha" == "$SHA_32" ]; then
            touch installed.32bit
            rm -rf "$APK"
        elif [ "$sha" == "$SHA_64" ]; then
            touch installed.64bit
            rm -rf "$APK"
        else
            echo "SHA1 hash is $sha"
            echo "ERROR: sha1 hash does not match expected values!" > $CUR_TTY
            sleep 1
            exit 1
        fi
    else
        echo "ERROR: game.droid not found after repack!" > $CUR_TTY
        sleep 1
        exit 1
    fi
}

# Set current virtual screen
if [ "$CFW_NAME" == "muOS" ]; then
    /opt/muos/extra/muxlog & CUR_TTY="/tmp/muxlog_info"
else
    CUR_TTY="/dev/tty0"
fi
echo "\033c" > $CUR_TTY

# Variables
GAMEDIR="/$directory/ports/sonictt16b"
SHA_32="debb51e30ce7a29d49686a8ff8f3d94a8421e6b2"
SHA_64="55b3fab22715553368138eff307428052db0bc69"

# Permissions
chmod 777 $GAMEDIR/*
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/uinput

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Conditional variable setup
if [ -f "sonic-triple-trouble-16-bit-v1-2-8-32bit.apk" ] && [ ! -f "installed.64bit" ] && [ ! -f "installed.32bit" ]; then
    APK="sonic-triple-trouble-16-bit-v1-2-8-32bit.apk"
elif [ -f "sonic-triple-trouble-16-bit-v1-2-8.apk" ] && [ ! -f "installed.32bit" ] && [ ! -f "installed.64bit" ]; then
    APK="sonic-triple-trouble-16-bit-v1-2-8.apk"
fi

# Check if the installation flags are present
if [ ! -f "installed.32bit" ] && [ ! -f "installed.64bit" ]; then
    if [ ! -f "game.droid" ]; then
        # If game.droid does not exist, source repack.txt
        source repack.txt
    fi
    # Perform MD5 check and set installation flags
    echo "Checking md5 sum..." > $CUR_TTY
    install
fi

# Apply xdelta patch for 64-bit if needed
if [ -f "installed.64bit" ] && [ -f "sonictt16b.patch" ]; then
    echo "Applying xdelta patch...please wait." > $CUR_TTY
    $controlfolder/xdelta3 -d -s "$GAMEDIR/game.droid" "$GAMEDIR/sonictt16b.patch" "$GAMEDIR/game2.droid"
    rm -rf game.droid
    rm -rf sonictt16b.patch
    mv game2.droid game.droid
fi

# Library exports and binary setup
if [ -f "installed.64bit" ]; then
    GMLOADER="gmloadernext.aarch64"
    export LD_LIBRARY_PATH="/usr/libs:$GAMEDIR/libs:$LD_LIBRARY_PATH"
elif [ -f "installed.32bit" ]; then
    export PORT_32BIT="Y"
    export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs32:$LD_LIBRARY_PATH"
    GMLOADER="gmloadernext.armhf"
fi

# Export an additional library if arkos
case "$CFW_NAME" in
    *ArkOS*)
        export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/libs2:$LD_LIBRARY_PATH"
        ;;
esac

# Run the game
echo "Loading, please wait... (might take a while!)" > $CUR_TTY
$GPTOKEYB "$GMLOADER" xbox360 &
./$GMLOADER game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0