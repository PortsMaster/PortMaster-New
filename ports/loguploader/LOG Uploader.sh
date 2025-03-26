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

GAMEDIR="/$directory/ports/loguploader"

export XDG_DATA_HOME="$GAMEDIR/saves" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/saves"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$controlfolder/runtimes/love_11.5/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p $GAMEDIR/logs

## Uncomment the following file to log the output, for debugging purpose
# > "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR


# removing things that would break somethings
rm $GAMEDIR/uploadlog.txt
rm $GAMEDIR/logs/*
rm $GAMEDIR/internet.txt
rm $GAMEDIR/logs.zip

# copying things
cp $HOME/device_info_${CFW_NAME}_${DEVICE_NAME}.txt $GAMEDIR/logs

# Listing the runtimes
ls $controlfolder/libs > "$GAMEDIR/logs/runtimes.txt" 2>&1


# Create or clear the log file
log_file="$GAMEDIR/logs/device_log.txt"
> "$log_file"

# Append the output of ifconfig to the log file
echo "ifconfig output:" >> "$log_file"
ifconfig >> "$log_file"
echo -e "\n\n" >> "$log_file"

# Append the output of free -h to the log file
echo "free -h output:" >> "$log_file"
free -h >> "$log_file"
echo -e "\n\n" >> "$log_file"

# Append the output of uptime to the log file
echo "uptime output:" >> "$log_file"
uptime >> "$log_file"
echo -e "\n\n" >> "$log_file"

# Append the output of df -h to the log file
echo "df -h output:" >> "$log_file"
df -h >> "$log_file"
echo -e "\n\n" >> "$log_file"

# Append the output of df -h to the log file
echo "dmesg ouput:" >> "$log_file"
dmesg | tail -20 >> "$log_file"
echo -e "\n\n" >> "$log_file"

# Checking for Wifi Connection to give a nice Output
if ping -q -c 1 8.8.8.8 &> /dev/null
then
  echo "network's up" > $GAMEDIR/internet.txt 
else
  echo "network's down"
fi


$GPTOKEYB "love" -c "uploader.gptk" &
pm_platform_helper "./bin/love"
./bin/love "UI"

pm_finish
