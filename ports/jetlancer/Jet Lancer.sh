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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR="/$directory/ports/jetlancer"
TOOLDIR="$GAMEDIR/tools"
TMPDIR="$GAMEDIR/tmp"

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=0
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_windows"
export TOOLDIR="$GAMEDIR/tools"
export PATH=$PATH:$GAMEDIR/tools
export PATCHER_FILE="$GAMEDIR/patch/patchscript"
export PATCHER_GAME="Jet Lancer"
export PATCHER_TIME="10 to 15 minutes"
export PATCHDIR=$GAMEDIR

# We log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Permissions
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod +x "$GAMEDIR/gmloader"
$ESUDO chmod +x "$GAMEDIR/lib/splash"
$ESUDO chmod +x "$GAMEDIR/tools/xdelta3"
$ESUDO chmod 777 "$TOOLDIR/gmKtool.py"
$ESUDO chmod 777 "$TOOLDIR/oggenc"

cd "$GAMEDIR"

# Run install if needed
if [ ! -f "$GAMEDIR/gamedata/game.droid" ]; then
source "$controlfolder/utils/patcher.txt"
fi

config_file="$GAMEDIR/gamedata/config.ini"

if [ ! -f "$GAMEDIR/gamedata/config.ini" ]; then
  mv "$GAMEDIR/config.ini.default" "$GAMEDIR/gamedata/config.ini"
fi

$GPTOKEYB "gmloader" &

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader jetlancer.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
