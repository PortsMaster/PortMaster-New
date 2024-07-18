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

GAMEDIR="/$directory/ports/render96ex"
CONFDIR="$GAMEDIR/conf/"
BASEROM="baserom.us.z64"
RESTOOL_DIR="restool"
RESTOOL_ZIP="restool.zip"
RES_DIR="res"
BASEZIP="base.zip"
DEMOS_DIR="demos"
TEXTS_DIR="texts"

mkdir -p "$CONFDIR"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="${GAMEDIR}/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export PATH="${GAMEDIR}/bin.${DEVICE_ARCH}:${PATH}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "sm64.us.f3dex2e.${DEVICE_ARCH}" &

# If a rom is detected try to install the ressources
if [ -f "$BASEROM" ]
then
  text_viewer -f 25 -w -t "Ressources installation" --input_file $GAMEDIR/restool-msg.txt -y
  if [ $? -eq 21 ]
  then
    unzip "${RESTOOL_ZIP}" 2>&1
    if [ ! $? -eq 0 ]
    then
      echo "$0: An error occured while extracting ${RESTOOL_ZIP}"
      text_viewer -e -f 25 -w -t "Error" -m "Oh, no! An error has occured while extracting ${RESTOOL_ZIP}. Please see log for details."
    fi
    cd "${RESTOOL_DIR}"
    ./install-res.sh ${CFW_NAME} 2>&1
    cd ../
    rm -rf ${RESTOOL_DIR}
  fi
fi

# Install a default sm64conf.txt
if [ ! -f $CONFDIR/sm64config.txt ]
then
  cp sm64config.default.txt $CONFDIR/sm64config.txt 2>&1
fi

# Check if mandatory ressources are installed before launching the game
if [ ! -f $GAMEDIR/$RES_DIR/$BASEZIP ] || [ ! -d $GAMEDIR/$RES_DIR/$DEMOS_DIR ] || [ ! -d $GAMEDIR/$RES_DIR/$TEXTS_DIR ]
then
  echo "Ressources are missing."
  text_viewer -e -f 25 -w -t "Error" -m "Oh, no! Ressources are missing. Install them first (put ${BASEROM} in ${GAMEDIR})."
else
  ./sm64.us.f3dex2e.${DEVICE_ARCH} --savepath ./conf/ 2>&1
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
