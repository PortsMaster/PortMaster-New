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

GAMEDIR=/$directory/ports/nazizombies
TOOLDIR=$GAMEDIR/tools
RUNDIR=$GAMEDIR/game
BINARY="nzp-sdl"

cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "Device architecture is $DEVICE_ARCH"
echo "Glibc version is $CFW_GLIBC"
echo "Screen resolution $DISPLAY_WIDTH x $DISPLAY_HEIGHT"

# Libmali does not work on Rocknix
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  if ! glxinfo | grep "OpenGL version string"; then
    pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
    sleep 5
    exit 1
  fi
fi

# Check if the game is already configured
if [ ! -f "$RUNDIR/$BINARY" ]; then
  echo "First time run"
  cd "$RUNDIR"

  if [ "$CFW_GLIBC" -lt 231 ]; then
    cp "nzp-glibc230-sdl" $BINARY
  else
    cp "nzp-$DEVICE_ARCH-sdl" $BINARY
  fi

  chmod 777 $BINARY

  # patch config
  echo "Patching config"
  CONFIGDIR="$RUNDIR"/nzp
  CONFIGFILE="$CONFIGDIR"/nzportable.cfg
  cd "$CONFIGDIR"
  sed -i -E "s/vid_width.*/vid_width \"$DISPLAY_WIDTH\"/" $CONFIGFILE
  sed -i -E "s/vid_height.*/vid_height \"$DISPLAY_HEIGHT\"/" $CONFIGFILE
  sed -i -E "s/vid_conwidth.*/vid_conwidth \"$DISPLAY_WIDTH\"/" $CONFIGFILE
  sed -i -E "s/vid_conheight.*/vid_conheight \"$DISPLAY_HEIGHT\"/" $CONFIGFILE
  sed -i -E "s/sensitivity.*/sensitivity \"1\"/" $CONFIGFILE
  sed -i -E "s/sensitivity.*/sensitivity \"1\"/" $CONFIGFILE
  sed -i -E "s/joyyawsensitivity.*/joyyawsensitivity \"0.3\"/" $CONFIGFILE
  sed -i -E "s/joypitchsensitivity.*/joypitchsensitivity \"0.05\"/" $CONFIGFILE
  sed -i -E "s/bind.*GP_LSHOULDER.*/bindlevel GP_LSHOULDER 30 \"+button8\"/" $CONFIGFILE
  sed -i -E "s/bind.*GP_RSHOULDER.*/bindlevel GP_RSHOULDER 30 \"+attack\"/" $CONFIGFILE
  sed -i -E "s/bind.*GP_LTRIGGER.*/bindlevel GP_LTRIGGER 30 \"impulse 33\"/" $CONFIGFILE
  sed -i -E "s/bind.*GP_RTRIGGER.*/bindlevel GP_RTRIGGER 30 \"+button3\"/" $CONFIGFILE
  sed -i -E "s/name \"Unknown Soldier\"/name \"PortMaster Soldier\"/" $CONFIGFILE

  if [ $ANALOG_STICKS -lt 2 ]; then
    sed -i -E "/bindlevel.*GP_DPAD.*/d" $CONFIGFILE
    sed -i -E "s/bind.*GP_Y.*/bind GP_Y \"+left\"/" $CONFIGFILE
    sed -i -E "s/bindlevel.*GP_A.*/bindlevel GP_A 30 \"+right\"/" $CONFIGFILE
    sed -i -E "s/bindlevel.*GP_B.*/bindlevel GP_B 30 \"+lookdown\"/" $CONFIGFILE
    sed -i -E "s/bindlevel.*GP_X.*/bindlevel GP_X 30 \"+lookup\"/" $CONFIGFILE
    sed -i -E "s/bind.*GP_VIEW.*/bind GP_VIEW \"+button7\"/" $CONFIGFILE
    sed -i -E "s/bind.*GP_LTRIGGER.*/bindlevel GP_LTRIGGER 30 \"+button5\"/" $CONFIGFILE
    sed -i -E "s/bind.*GP_RTRIGGER.*/bindlevel GP_RTRIGGER 30 \"impulse 23\"/" $CONFIGFILE
  fi
else
  # Update screen resolution settings
  if [ -f "$RUNDIR/nzp/user_settings.cfg" ]; then
    CONFIGFILE="$RUNDIR"/nzp/user_settings.cfg
  else
    CONFIGFILE="$RUNDIR"/nzp/nzportable.cfg
  fi
  echo "Updating resolution in $CONFIGFILE"
  sed -i -E "s/vid_width.*/vid_width \"$DISPLAY_WIDTH\"/" $CONFIGFILE
  sed -i -E "s/vid_height.*/vid_height \"$DISPLAY_HEIGHT\"/" $CONFIGFILE
  sed -i -E "s/vid_conwidth.*/vid_conwidth \"$DISPLAY_WIDTH\"/" $CONFIGFILE
  sed -i -E "s/vid_conheight.*/vid_conheight \"$DISPLAY_HEIGHT\"/" $CONFIGFILE
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd "$RUNDIR"

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/nzp.ini" >/dev/null &

pm_platform_helper "$BINARY" >/dev/null

./$BINARY

pm_finish
