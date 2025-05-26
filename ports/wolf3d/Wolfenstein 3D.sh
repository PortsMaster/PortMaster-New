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

# Variables
GAMEDIR="/$directory/ports/wolf3d"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create config dir
bind_directories "$XDG_DATA_HOME/lzwolf" "$GAMEDIR/cfg"
bind_directories "$XDG_DATA_HOME/ecwolf" "$GAMEDIR/cfg"

# Select a config file
if [ "${ANALOG_STICKS}" -lt 2 ]; then
    CONFIG="cfg/nosticks.cfg"
else
    CONFIG="cfg/lzwolf.cfg" 
fi

# Modify the config file
if [ $DISPLAY_WIDTH -eq $DISPLAY_HEIGHT ]; then # RGB30 or 1:1
    DISPLAY_HEIGHT=540
fi
if [ $DISPLAY_HEIGHT -gt 1080 ]; then # RG552
    DISPLAY_HEIGHT=768
    DISPLAY_WIDTH=1366
fi

# Update config files
sed -i "s/^FullScreenHeight = [0-9]\+/FullScreenHeight = $DISPLAY_HEIGHT/" "$CONFIG"
sed -i "s/^FullScreenWidth = [0-9]\+/FullScreenWidth = $DISPLAY_WIDTH/" "$CONFIG"

# CD and set permissions
cd $GAMEDIR
exec > "$GAMEDIR/log.txt" 2>&1
$ESUDO chmod +xwr -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"        # enables interactive text input mode
export TEXTINPUTNOAUTOCAPITALS="Y"     # disables automatic capitalisation of first letter of words in interactive text input mode
export TEXTINPUTADDEXTRASYMBOLS="Y"    # enables additional symbols for interactive text input

# Convert all files in iwads and mods folders to lowercase
for folder in "$GAMEDIR/data" "$GAMEDIR/mods"; do
    if [ -d "$folder" ]; then
        find "$folder" -type f | while read -r file; do
            lowercase_file=$(echo "$file" | tr "[:upper:]" "[:lower:]")
            if [ "$file" != "$lowercase_file" ]; then
                mv "$file" "$lowercase_file"
            fi
        done
    fi
done

# Run launcher
chmod +xr ./love
$GPTOKEYB "love" &
./love .

# Read line from selected_game.txt
while IFS= read -r line; do
    if [ -z "$FILE" ]; then
        FILE="$line"  # First line is FILE
    else
        ENGINE="$line" # Second line is ENGINE
    fi
done < selected_game.txt

# Cleanup launcher
if [ -f selected_game.txt ]; then
    export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
    rm -rf selected_game.txt
    pm_finish
else
    exit
fi

# If Exit chosen from launcher, quit
if [[ $FILE == "Exit" ]]; then
    exit
else
    sed -i "s|^BaseDataPaths = .*|BaseDataPaths = \"$FOLDER;./data\";|" "$CONFIG"
fi

# Function to convert a string to lowercase
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Build arguments
ARGS="--config $CONFIG --savedir ./cfg"
if [ -n "$FILE" ]; then
    dos2unix "$FILE" >/dev/null 2>&1
    TMP=$IFS
    while IFS== read -r key value; do
        case "$key" in
            ENGINE)
                ENGINE="$value"
                ;;
            DATA)
                ARGS="$ARGS --data $(to_lower "$value")"
                DATA=$(to_lower "$value")
                ;;
            MOD)
                ARGS="$ARGS --file $GAMEDIR/$(to_lower "$value")"
                ;;
        esac
    done < "$FILE"
    IFS=$TMP
fi

# Run game
echo "[LOG]: Running ${ENGINE} with args: ${ARGS}"
$GPTOKEYB "$ENGINE" & 
pm_platform_helper "$GAMEDIR/$ENGINE" > /dev/null
./engines/$ENGINE $ARGS
