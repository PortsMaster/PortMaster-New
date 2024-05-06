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

get_controls

GAMEDIR=/$directory/ports/duke3dawo

$ESUDO chmod 777 -R $GAMEDIR/*

sed -i 's/ScreenMode = 1/ScreenMode = 0/' $GAMEDIR/conf/eduke32/eduke32.cfg
sed -i "s/ScreenWidth[[:space:]]*=[[:space:]]*[^[:space:]]*/ScreenWidth = $DISPLAY_WIDTH/" "$GAMEDIR/conf/eduke32/eduke32.cfg"
sed -i "s/ScreenHeight[[:space:]]*=[[:space:]]*[^[:space:]]*/ScreenHeight = $DISPLAY_HEIGHT/" "$GAMEDIR/conf/eduke32/eduke32.cfg"
sleep 0.3

cd $GAMEDIR

if [ ! -f $GAMEDIR/awo.zip ]; then
    $ESUDO cp $GAMEDIR/stopgap/USER.CON $GAMEDIR/USER.CON
    sleep 0.3
    zip -r $GAMEDIR/awo.zip *.CON *.DMO *.RTS *.ART *.def *.grpinfo e32wt.grp names.h version_e32wt.txt def editor fonts locale maps samples sound xrc -x "sound/DevCommentary*"
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO rm $GAMEDIR/eduke32.log

$ESUDO rm -rf ~/.config/eduke32
$ESUDO ln -sfv "/$GAMEDIR/conf/eduke32" ~/.config/

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Ensure Swap space is prepared or eduke32 may crash or fail to launch
   $ESUDO chmod 666 /dev/tty0
   printf "\033c" > /dev/tty0
	 echo "Preparing Swap File, please wait..." > /dev/tty0
	 echo " " > /dev/tty0
if id "ark" &>/dev/null || id "odroid" &>/dev/null; then
    $ESUDO swapoff /swapfile
    $ESUDO fallocate -l 384M /swapfile
    $ESUDO chmod 600 /swapfile
    $ESUDO mkswap /swapfile
    $ESUDO swapon /swapfile
else
  if [ ! -f /storage/swapfile ]; then
    $ESUDO swapoff /storage/swapfile
    $ESUDO dd if=/dev/zero of=/storage/swapfile bs=1024 count=384k
    $ESUDO chmod 600 /storage/swapfile
    $ESUDO mkswap /storage/swapfile
    $ESUDO sync
    $ESUDO swapon /storage/swapfile
  fi
fi

if [ $DEVICE_NAME == 'x55' ] || [ $DEVICE_NAME == 'RG353P' ]; then
    GPTOKEYB_CONFIG="$GAMEDIR/eduke32triggers.gptk"  
else
    GPTOKEYB_CONFIG="$GAMEDIR/eduke32.gptk"
fi

$GPTOKEYB "eduke32.${DEVICE_ARCH}" -c "$GPTOKEYB_CONFIG" &
./eduke32.${DEVICE_ARCH} awo.zip -nosetup -gamegrp e32wt.grp -xE32WT.CON

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
