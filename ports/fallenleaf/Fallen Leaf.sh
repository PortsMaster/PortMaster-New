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
export PORT_32BIT="Y"


[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0

# Set current virtual screen
if [ "$CFW_NAME" == "muOS" ]; then
  /opt/muos/extra/muxlog & CUR_TTY="/tmp/muxlog_info"
elif [ "$CFW_NAME" == "TrimUI" ]; then
  CUR_TTY="/dev/fd/1"
else
  CUR_TTY="/dev/tty0"
fi

printf "\033c" > $CUR_TTY

GAMEDIR="/$directory/ports/fallenleaf"
TOOLDIR="$GAMEDIR/tools"
TMPDIR="$GAMEDIR/tmp"
BITRATE=128

$ESUDO chmod 777 "$TOOLDIR/splash"
$ESUDO chmod 777 "$TOOLDIR/gmKtool.py"
$ESUDO chmod 777 "$TOOLDIR/swapabxy.py"
$ESUDO chmod 777 "$GAMEDIR/gmloader"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$TOOLDIR/libs:$LD_LIBRARY_PATH"
export PATH="$TOOLDIR:$PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

cd $GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Functions
install() {

    # Rename data.win
    [ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
    [ -f "./gamedata/game.win" ] && mv gamedata/game.win gamedata/game.droid
    [ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

    if [ -f "$GAMEDIR/compress.txt" ]; then
        # Compress audio
        compress_audio
    fi
}

compress_audio() {
    echo "Compressing audio. The process will take 5-10 minutes"  > $CUR_TTY
    mkdir -p "$TMPDIR"
    gmKtool.py -v -b $BITRATE -d "$TMPDIR" "$GAMEDIR/gamedata/game.droid"

    if [ $? -eq 0 ]; then
            mv $TMPDIR/* "$GAMEDIR/gamedata"
            rm "$GAMEDIR/compress.txt"
            rmdir "$TMPDIR"
            echo "Audio compression applied successfully." > $CUR_TTY
            return 0
        else
            echo "Audio compression failed." > $CUR_TTY
            rm -rf "$TMPDIR"
            return 1
    fi
}

random_splash() {
    # Randomize the splash screen
    n=$((1 + $RANDOM % 3))
    mkdir -p "$GAMEDIR/assets"
    cp "splash-$n.png" "$GAMEDIR/assets/splash.png"
    zip -u -r -0 "game.apk" "assets"
    rm "$GAMEDIR/assets/splash.png"
    rmdir "$GAMEDIR/assets"
}

swapabxy() {
    # Update SDL_GAMECONTROLLERCONFIG to swap a/b and x/y button

    if [ "$CFW_NAME" == "knulli" ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ];then
	      # Knulli seems to use SDL_GAMECONTROLLERCONFIG_FILE (on rg40xxh at least)
        cat "$SDL_GAMECONTROLLERCONFIG_FILE" | swapabxy.py > "$GAMEDIR/gamecontrollerdb_swapped.txt"
	      export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
    else
        # Other CFW use SDL_GAMECONTROLLERCONFIG
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | swapabxy.py`"
    fi
}

# Run install if needed
if [ ! -f "$GAMEDIR/gamedata/game.droid" ]; then
    [ "$CFW_NAME" == "muOS" ] && splash "splash-install.png" 1 # workaround for muOS
    splash "splash-install.png" 600000 & # 10 minutes
    SPLASH_PID=$!
    install
    res=$?
    $ESUDO kill -9 $SPLASH_PID
    if [ ! $res -eq 0 ]; then
      exit 1
    fi
fi

# Swap a/b and x/y button if needed
if [ -f "$GAMEDIR/swapabxy.txt" ]; then
    swapabxy
fi

random_splash

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" &

./gmloader game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > $CUR_TTY
