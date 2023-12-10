#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
if [ -z ${TASKSET+x} ]; then
  source $controlfolder/tasksetter
fi

get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/vanillatd"
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" > $CUR_TTY

printf "\033c" > $CUR_TTY

## CHECK FOR GAME FILES
shopt -s nocaseglob

if find "${GAMEDIR}/data/vanillatd" -iname "*.mix" -print -quit | grep -q .; then
  FIRST_WARN="Y"
  for file in "CONQUER.MIX" "DESERT.MIX" "TEMPERAT.MIX" "WINTER.MIX" "SOUNDS.MIX" "CCLOCAL.MIX" "TRANSIT.MIX" "SPEECH.MIX" "UPDATE.MIX" "UPDATEC.MIX" "DESEICNH.MIX" "TEMPICNH.MIX" "WINTICNH.MIX"; do
    if [[ ! -f "${GAMEDIR}/data/vanillatd/${file}" ]]; then
      if [[ "$FIRST_WARN" == "Y" ]]; then
        echo "Missing game files, see README for help installing game files." > $CUR_TTY
        FIRST_WARN="N"
      fi
      echo "- ${file} not found" > $CUR_TTY
    fi
  done

  if [[ "$FIRST_WARN" == "N" ]]; then
    sleep 5
    printf "\033c" >> $CUR_TTY
    exit 1
  fi

  ALL_FOUND="N"
  MISSING_FILES="Missing game files, see README for help installing game files."
  for path in "gdi" "nod" "."; do
    FiLES_FOUND="Y"

    for file in "GENERAL.MIX" "MOVIES.MIX" "SCORES.MIX"; do
      if [[ ! -f "${GAMEDIR}/data/vanillatd/${path}/${file}" ]]; then
        if [[ "$path" != "." ]]; then
          MISSING_FILES="${MISSING_FILES}\n- ${path}/${file}"
        fi
        FiLES_FOUND="N"
      fi
    done

    if [[ "${FiLES_FOUND}" == "Y" ]]; then
      ALL_FOUND="Y"
    fi
  done

  if [[ "${ALL_FOUND}" == "N" ]]; then
    printf "$MISSING_FILES\n" > $CUR_TTY
    sleep 5
    printf "\033c" >> $CUR_TTY
    exit 1
  fi

  echo "Starting game." > $CUR_TTY
  export PORTMASTER_DATA="data"
else
  echo "Starting demo." > $CUR_TTY
  export PORTMASTER_DATA="demo"
fi


if [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]]; then
  if [ ! -f "${GAMEDIR}/save/vanillatd/conquer.ini" ]; then
    mkdir -p "${GAMEDIR}/save/vanillatd"
    cat << __CONF__ > "${GAMEDIR}/save/vanillatd/conquer.ini"
[Video]
BoxingAspectRatio=5:3
Windowed=no
Width=1920
Height=1152
__CONF__
  fi
else
  if [ ! -f "${GAMEDIR}/save/vanillatd/conquer.ini" ]; then
    mkdir -p "${GAMEDIR}/save/vanillatd"
    cat << __CONF__ > "${GAMEDIR}/save/vanillatd/conquer.ini"
[Video]
Windowed=no
DOSMode=no
BoxingAspectRatio=4:3
Width=640
Height=480
Scaler=linear
__CONF__
  fi
fi

## RUN SCRIPT HERE

export PORTMASTER_HOME="$GAMEDIR"

export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"

$GPTOKEYB "vanillatd" -c vanillatd.gptk textinput &
$TASKSET ./vanillatd 2>&1 | $ESUDO tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
