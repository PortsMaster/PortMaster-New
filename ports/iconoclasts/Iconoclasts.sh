#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports/PortMaster" ]; then
  controlfolder="/roms/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/iconoclasts"
cd $GAMEDIR/gamedata

export CHOWDREN_FPS=30
export LIBGL_FB_TEX_SCALE=0.5
export LIBGL_SKIPTEXCOPIES=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX86_LOG=1
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export SDL_DYNAMIC_API="libSDL2-2.0.so.0"
export BOX86_LD_PRELOAD="$GAMEDIR/libIconoclasts.so"
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/box86/native/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/box86/native/libEGL.so.1"

export LD_LIBRARY_PATH="$GAMEDIR/box86/native":"/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"/usr/config/emuelec/lib32"
export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/native":"$GAMEDIR/gamedata/bin32"

export BOX86_DYNAREC=1
export BOX86_FORCE_ES=31
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# load user settings
source $GAMEDIR/settings.txt

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0

if [ ! -f 'bin32/Chowdren' ]; then
    # No game found, check for installers...
    for installer in iconoclasts_*.sh; do break; done;
    if [[ -z "$installer" ]] || [[ "$installer" == "iconoclasts_*.sh" ]]; then
        echo "No data, no installer... nothing to do :("
        printf "\033c" > /dev/tty1
        exit -1
    fi

    echo "Installing from $installer..." > /dev/tty0

    # extract the installer, but make sure we got the Chowdren binary present!
    python3 ../extract.py "$installer" "data/noarch/game/bin32/Chowdren" > /dev/tty0
    if [ $? != 0 ]; then
		rm -f bin32/Chowdren
        echo "Install failed..." > /dev/tty0
        sleep 5
        printf "\033c" > /dev/tty1
        exit -1
    fi
fi

if [ ! -f 'data/music/62SYS_title_B.dat' ]; then
	printf "\u001b[31m" > /dev/tty0
	echo " .########.########..########...#######..########. " > /dev/tty0
	echo " .##.......##.....##.##.....##.##.....##.##.....## " > /dev/tty0
	echo " .##.......##.....##.##.....##.##.....##.##.....## " > /dev/tty0
	echo " .######...########..########..##.....##.########. " > /dev/tty0
	echo " .##.......##...##...##...##...##.....##.##...##.. " > /dev/tty0
	echo " .##.......##....##..##....##..##.....##.##....##. " > /dev/tty0
	echo " .########.##.....##.##.....##..#######..##.....## " > /dev/tty0
	printf "\u001b[0m" > /dev/tty0
	echo " >> YOU ARE MISSING MUSIC DATA!!! <<" > /dev/tty0
	echo " >> MUSIC PLAYBACK WILL NOT WORK! <<" > /dev/tty0
	echo "Install the game and copy 'data/music' to 'gamedata/data/music'" > /dev/tty0

	sleep 10
	exit -1
fi

# Set executable permissions for sdcards using ext2 or similar.
chmod +x "$GAMEDIR/box86/box86"
chmod +x "$GAMEDIR/gamedata/bin32/Chowdren"

$GPTOKEYB "box86" -c "$GAMEDIR/iconoclasts.gptk" &
echo "Loading, please wait... (might take a while!)" > /dev/tty0
$GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0