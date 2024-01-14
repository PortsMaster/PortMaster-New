#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/rvgl"

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
printf "\033c" >> /dev/tty1

if [ ! -f $GAMEDIR/rvgl ]; then
  echo "Downloading and installing game files.  Please wait..." > /dev/tty1
  sed -i "/roms\//s//$directory\//g" install_rvgl.py
  $ESUDO ./install_rvgl.py

  if [ -f $GAMEDIR/rvgl ]; then    # if installed, setup libraries and copy profile data for portmaster
    $ESUDO cp -f $GAMEDIR/.versions/rvgl_version.txt $GAMEDIR/.versions/rvgl_assets.txt    # version for assets
    $ESUDO cp -f $GAMEDIR/.versions/rvgl_version.txt $GAMEDIR/.versions/rvgl_linux.txt    # version for linux
    $ESUDO cp -f $GAMEDIR/lib/libarm64/libenet.so.7 $GAMEDIR/lib/libenet.so.7    # copy libraries
    $ESUDO cp -f $GAMEDIR/lib/libarm64/libopenal.so.1 $GAMEDIR/lib/libopenal.so.1    # copy libraries
    $ESUDO cp -f $GAMEDIR/lib/libarm64/libunistring.so.2 $GAMEDIR/lib/libunistring.so.2    # copy libraries
    $ESUDO mv -f $GAMEDIR/portmaster/profiles/ark $GAMEDIR/profiles/ark    # copy profile
    $ESUDO mv -f $GAMEDIR/portmaster/profiles/gamecontrollerdb.txt $GAMEDIR/profiles/gamecontrollerdb.txt    # copy rk3326 game controller configuration file
    cp -f $GAMEDIR/profiles/rvgl.ini $GAMEDIR/profiles/rvgl.bak    # backup settings file, if setup was run
    $ESUDO mv -f $GAMEDIR/portmaster/profiles/rvgl.ini $GAMEDIR/profiles/rvgl.ini    # replace settings file
    $ESUDO cp -f $GAMEDIR/portmaster/rvgl $GAMEDIR/rvgl    # replace rvgl script to ensure libenet.so.7 works
    rm -d -r $GAMEDIR/portmaster
  else
    echo "Could not get RVGL version. Are you online?" > /dev/tty1
    exit
  fi

fi

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "rvgl.arm64" -c "$GAMEDIR/rvgl.gptk" &
$GAMEDIR/rvgl 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1