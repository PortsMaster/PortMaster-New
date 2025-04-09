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
GAMEDIR="/$directory/ports/voidstranger"
export LD_LIBRARY_PATH="/usr/lib:/$GAMEDIR/lib:$LD_LIBRARY_PATH"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# permissions
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod +x "$GAMEDIR/lib/splash"
$ESUDO chmod +x "$GAMEDIR/gmloadernext"
$ESUDO chmod +x "$GAMEDIR/game_patching.txt"
$ESUDO chmod 666 /dev/uinput

cd $GAMEDIR

# log the execution of the script into log.txt
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# check for "installed" file; this assumes game.droid has already been patched/moved
if [ -f "installed" ]; then
  final_chksm=$(md5sum "game.droid" | awk '{print $1}')
  echo "Found patched game.droid file. md5: ""$final_chksm"
  # SPLASH
  if [ -f "gamedata/splash.png" ]; then
    $ESUDO ./lib/splash gamedata/"splash.png" 1 
    $ESUDO ./lib/splash gamedata/"splash.png" 8000 &
    echo "Normal splash."
  else
    echo "No splash image found. Add splash.png to the /gamedata/ folder."
  fi
else
  # first time installation process
  # SPLASH 0 
  $ESUDO ./lib/splash "loadingsplash.png" 1 
  $ESUDO ./lib/splash "loadingsplash.png" 12000 &
  echo "First splash."

  # game patching cases located in the game_patching script
  . ./game_patching.txt
  if [ $? != 0 ]; then
    exit 0
  fi

  # zip audio into the .apk
  echo "Attempting to zip game files into game.apk..."
  if [[ -f "gamedata/audiogroup1.dat" ]] && [[ -f "gamedata/audiogroup2.dat" ]]; then
    $ESUDO mkdir -p ./assets/
    $ESUDO mv gamedata/"audiogroup1.dat" ./assets/
    $ESUDO mv gamedata/"audiogroup2.dat" ./assets/
    $ESUDO zip -r -0 $GAMEDIR/game.apk ./assets/
    $ESUDO rm -r ./assets/
  else
    echo "WARNING: Some audiogroup data not found. Please add all assets to the /gamedata/ folder and try again."
    exit 0
  fi

  # move patched file to main directory if found
  [ -f "./gamedata/vs-patched.win" ] && mv gamedata/vs-patched.win $GAMEDIR/game.droid

  # create 'installed' file
  touch installed
fi

# move csv data file to main dir and clean if the ini has been generated already
if [ ! -f csvstring.ini ]; then
  if [ ! -f voidstranger_data.csv ]; then
    $ESUDO cp gamedata/"voidstranger_data.csv" ./
    echo "CSV data file copied to main directory."
  fi
else
  if [ -f voidstranger_data.csv ]; then
    echo "Cleaning up CSV file."
    $ESUDO rm "voidstranger_data.csv"
  fi
fi

$GPTOKEYB "gmloadernext" -c ./voidstranger.gptk &
  
./gmloadernext game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0