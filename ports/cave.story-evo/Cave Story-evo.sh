#!/bin/bash
# PORTMASTER: cave.story-evo.zip, Cave Story-evo.sh


if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR=/$directory/ports/nxengine-evo

exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if settings.dat file doesn't exist
if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    # Determine which settings.dat file to use based on the display width
    if [ "$DISPLAY_WIDTH" -eq 1920 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.1920" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 960 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.960" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 1280 ] || [ "$DISPLAY_WIDTH" -eq 854 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.854" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 480 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.480" "$GAMEDIR/conf/nxengine/settings.dat"
    else
        # Default settings for other display widths
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.640" "$GAMEDIR/conf/nxengine/settings.dat"
    fi

    # Remove any other settings.dat files
    rm -f "$GAMEDIR/conf/nxengine/settings.dat.*"
fi

$ESUDO rm -rf ~/.local/share/nxengine
$ESUDO ln -s $GAMEDIR/conf/nxengine ~/.local/share/
cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "nxengine-evo" -c nxengine-evo.gptk &
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GAMEDIR/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./nxengine-evo

$ESUDO kill -9 $(pidof gptokeyb) & 
printf "\033c" >> /dev/tty1
