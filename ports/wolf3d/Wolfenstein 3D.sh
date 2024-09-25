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

# Variables
GAMEDIR="/$directory/ports/wolf3d"
HEIGHT=$DISPLAY_HEIGHT
WIDTH=$DISPLAY_WIDTH

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create config dir
rm -rf "$XDG_DATA_HOME/lzwolf"
rm -rf "$XDG_DATA_HOME/ecwolf"
ln -s "$GAMEDIR/cfg" "$XDG_DATA_HOME/lzwolf"
ln -s "$GAMEDIR/cfg" "$XDG_DATA_HOME/ecwolf"

# Permissions
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$ESUDO chmod 777 -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_GAMECONTROLLERCONFIG_FILE="$sdl_controllerconfig"

# Select a config file
if [ "${ANALOG_STICKS}" -lt 2 ]; then
    CONFIG="./cfg/nosticks.cfg"
else
    CONFIG="./cfg/lzwolf.cfg" 
fi

# Run launcher
chmod +xr ./love
$GPTOKEYB "love" &
./love launcher

# Read both lines from selected_game.txt
# Initialize variables
FOLDER=""
ENGINE=""

# Read the file line by line
while IFS= read -r line; do
    if [ -z "$FOLDER" ]; then
        FOLDER="$line"  # First line is FOLDER
    else
        ENGINE="$line"  # Second line is ENGINE
    fi
done < selected_game.txt

# Cleanup launcher
rm -rf selected_game.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0

# Modify the config file
if [ $WIDTH -eq $HEIGHT ]; then # RGB30 or 1:1
    HEIGHT=540
fi
if [ $HEIGHT -gt 1080 ]; then # RG552
    HEIGHT=768
    WIDTH=1366
fi

sed -i "s/^FullScreenHeight = [0-9]\+/FullScreenHeight = $HEIGHT/" "$CONFIG"
sed -i "s/^FullScreenWidth = [0-9]\+/FullScreenWidth = $WIDTH/" "$CONFIG"

if [[ $FOLDER == "Exit" ]]; then
    exit
else
    sed -i "s|^BaseDataPaths = .*|BaseDataPaths = \"./data;$FOLDER\";|" "$CONFIG"
fi

# List of games that should use EC Wolf
ECGAMES="2.1 Mission Pack - Return to Danger:2.2 Mission Pack - Ultimate Challenge:3. Super Noah's Ark 3D"

# List of games that should use LZ Wolf
LZGAMES="1. Wolfenstein 3D HD:2. Spear of Destiny HD"

# Pick the engine to use
eccontains() {
    local value="$1"  # Use the first argument as the value to check
    local item
    local tmp=$IFS
    IFS=":" # Use : as the delimiter
    for item in $ECGAMES; do
        echo "[DEBUG]: Checking ${FOLDER##*/} against item: '$item'"
        if [ "$item" = "$value" ]; then
            IFS=$tmp
            return 0
        fi
    done
    IFS=$tmp
    return 1
}

lzcontains() {
    local value="$1"  # Use the first argument as the value to check
    local item
    local tmp=$IFS
    IFS=":" # Use : as the delimiter
    for item in $LZGAMES; do
        echo "[DEBUG]: Checking ${FOLDER##*/} against item: '$item'"
        if [ "$item" = "$value" ]; then
            IFS=$tmp
            return 0
        fi
    done
    IFS=$tmp
    return 1
}

if eccontains "${FOLDER##*/}"; then
    echo "[LOG]: ${FOLDER##*/} chosen, which requires EC Wolf"
    ENGINE=ecwolf
fi

if lzcontains "${FOLDER##*/}"; then
    echo "[LOG]: ${FOLDER##*/} chosen, which requires LZ Wolf"
    ENGINE=lzwolf
fi

# Build args
ARGS="--config $CONFIG --savedir ./cfg"
if [ -n "$FOLDER" ]; then
    dos2unix "$FOLDER/.load.txt" >/dev/null 2>&1
    TMP=$IFS
    while IFS== read -r key value; do
        case "$key" in
            DATA)
                ARGS+=" --data $value"
                ;;
            PK3|PK3_1|PK3_2|PK3_3|PK3_4)
                ARGS+=" --file $value"
                ;;
        esac
    done < "${FOLDER}/.load.txt"
    IFS=$TMP
fi

# Run game
echo "[LOG]: Running ${ENGINE} with args: ${ARGS}"
$GPTOKEYB "$ENGINE" & 
./$ENGINE $ARGS

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0