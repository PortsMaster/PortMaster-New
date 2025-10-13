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

GAMEDIR="/$directory/ports/minecraftjava"

## Uncomment the following file to log the output, for debugging purpose
> "$GAMEDIR/Launcherlog.txt" && exec > >(tee "$GAMEDIR/Launcherlog.txt") 2>&1

cd $GAMEDIR

check_versions() {
    # Vanilla 1.7
    if [ -f "$GAMEDIR/.minecraft/versions/1.7.10/1.7.10.jar" ]; then
        touch "$GAMEDIR/minecraft-launcher/vanilla-1.7.10-key"
    else
        rm -f "$GAMEDIR/minecraft-launcher/vanilla-1.7.10-key"
    fi

    # Forge 1.7.10
    if [ -f "$GAMEDIR/.minecraft/versions/1.7.10-Forge/1.7.10-Forge.jar" ] || [ -f "$GAMEDIR/.minecraft/versions/1.7.10-Forge10.13.4.1614-1.7.10/1.7.10-Forge10.13.4.1614-1.7.10.jar" ]; then
        touch "$GAMEDIR/minecraft-launcher/forge-1.7.10-key"
    else
        rm -f "$GAMEDIR/minecraft-launcher/forge-1.7.10-key"
    fi
    
    # Vanilla 1.12.2
    if [ -f "$GAMEDIR/.minecraft/versions/1.12.2/1.12.2.jar" ]; then
        touch "$GAMEDIR/minecraft-launcher/vanilla-1.12.2-key"
    else
        rm -f "$GAMEDIR/minecraft-launcher/vanilla-1.12.2-key"
    fi

    # Forge 1.12.2
    if [ -f "$GAMEDIR/.minecraft/versions/1.12.2-forge-14.23.5.2860/1.12.2-forge-14.23.5.2860.jar" ] || [ -f "$GAMEDIR/.minecraft/versions/1.12.2-Forge/1.12.2-Forge.jar" ]; then
        touch "$GAMEDIR/minecraft-launcher/forge-1.12.2-key"
    else
        rm -f "$GAMEDIR/minecraft-launcher/forge-1.12.2-key"
    fi


    # Fabric
    if [ -f "$GAMEDIR/.minecraft/versions/fabric-loader-0.16.14-1.16.5/fabric-loader-0.16.14-1.16.5.jar" ] || [ -f "$GAMEDIR/.minecraft/versions/1.16.5-Fabric/1.16.5-Fabric.jar" ]; then
        touch "$GAMEDIR/minecraft-launcher/fabric-1.16.5-key"
    else
        rm -f "$GAMEDIR/minecraft-launcher/fabric-1.16.5-key"
    fi
}
check_versions

# Runtime Checking and renaming
mv $controlfolder/libs/zulu8.86.0.25-ca-jdk8.0.452-linux.aarch64.squashfs $controlfolder/libs/zulu8.86.0.25-ca-jdk8.0.452-linux.squashfs
mv $controlfolder/libs/zulu17.54.21-ca-jre17.0.13-linux.aarch64.squashfs $controlfolder/libs/zulu17.54.21-ca-jre17.0.13-linux.squashfs
mv $controlfolder/libs/weston_pkg_0.2.aarch64.squashfs $controlfolder/libs/weston_pkg_0.2.squashfs

ls $controlfolder/libs > "$GAMEDIR/minecraft-launcher/runtimes.txt" 2>&1

if [[ -s server.txt ]]; then
    export SERVER="--server $(< server.txt)"
fi

tree $GAMEDIR/versions

if [ "$CFW_NAME" = "ROCKNIX" ]; then
	swaymsg seat seat0 hide_cursor 0
fi

# Run launcher
source $controlfolder/runtimes/love_11.5/love.txt
$GPTOKEYB "love.${DEVICE_ARCH}" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "minecraft-launcher"

# see what they selected in the launcher
GAME="$(cat selected_game.txt)"

# Cleanup launcher
rm -rf "selected_game.txt"
$ESUDO kill -9 $(pidof gptokeyb)
if [ -z "$GAME" ]; then exit 1; fi

source $GAME

pm_finish
