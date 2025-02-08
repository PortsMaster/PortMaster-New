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
GAMEDIR="/$directory/ports/doomengines"

GZDOOM1="$GAMEDIR/configs/gzdoom/gzdoom.ini"
GZDOOM2="$GAMEDIR/configs/gzdoom/heretic.ini"
GZDOOM3="$GAMEDIR/configs/gzdoom/hexen.ini"
GZDOOM4="$GAMEDIR/configs/gzdoom/strife.ini"
CRISPY1="$GAMEDIR/configs/crispy-doom/crispy-doom.cfg"
CRISPY2="$GAMEDIR/configs/crispy-doom/crispy-heretic.cfg"
CRISPY3="$GAMEDIR/configs/crispy-doom/crispy-hexen.cfg"
CRISPY4="$GAMEDIR/configs/crispy-doom/crispy-strife.cfg"

# CD and set permissions
cd $GAMEDIR
exec > "$GAMEDIR/log.txt" 2>&1
$ESUDO chmod +xwr -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs/lovelibs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$GAMEDIR/configs"
export TEXTINPUTINTERACTIVE="Y"        # enables interactive text input mode
export TEXTINPUTNOAUTOCAPITALS="Y"     # disables automatic capitalisation of first letter of words in interactive text input mode
export TEXTINPUTADDEXTRASYMBOLS="Y"    # enables additional symbols for interactive text input

# Convert all files in iwads and mods folders to lowercase
for folder in "$GAMEDIR/iwads" "$GAMEDIR/mods"; do
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
./love launcher

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

# Modify resolution in config files
gzdoom_configs="$GZDOOM1 $GZDOOM2 $GZDOOM3 $GZDOOM4"
for config in $gzdoom_configs; do
    sed -i "s/^vid_defheight=[0-9]\+/vid_defheight=$DISPLAY_HEIGHT/" "$config"
    sed -i "s/^vid_defwidth=[0-9]\+/vid_defwidth=$DISPLAY_WIDTH/" "$config"
done

crispy_configs="$CRISPY1 $CRISPY2 $CRISPY3 $CRISPY4"
for config in $crispy_configs; do
    sed -i "s/^window_height=[0-9]\+/window_height=$DISPLAY_HEIGHT/" "$config"
    sed -i "s/^window_width=[0-9]\+/window_width=$DISPLAY_WIDTH/" "$config"
done

# If Exit chosen from launcher, quit
if [ "$FILE" = "Exit" ]; then
    exit
fi

# Function to convert a string to lowercase
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Build arguments
if [ -n "$FILE" ]; then
    dos2unix "$FILE" >/dev/null 2>&1
    TMP=$IFS
    while IFS== read -r key value; do
        case "$key" in
            ENGINE)
                ENGINE="$value"
                ;;
            IWAD)
                ARGS="$ARGS -iwad $GAMEDIR/$(to_lower "$value")"
                IWAD=$(to_lower "$value")
                ;;
            MOD)
                ARGS="$ARGS -file $GAMEDIR/$(to_lower "$value")"
                ;;
            DIFF)
                ARGS="$ARGS +set skill $value"
                ;;
            MAP)
                ARGS="$ARGS +map $value"
                ;;
            INI)
                INI=$(to_lower "$value")
        esac
    done < "$FILE"
    IFS=$TMP
fi

# Switch the engine based on the IWAD selected
if [ "$ENGINE" = "crispydoom" ]; then
    case "$IWAD" in
        "iwads/heretic.wad") ENGINE="crispyheretic" ;;
        "iwads/hexen.wad") ENGINE="crispyhexen" ;;
        "iwads/strife1.wad") ENGINE="crispystrife" ;;
    esac
fi

# Switch INI if it's empty
if [ -z "$INI" ] && [ "$ENGINE" = "gzdoom" ]; then
    INI="configs/gzdoom/$ENGINE.ini"
fi

# Add supplemental arguments for gzdoom
if [ "$ENGINE" = "gzdoom" ]; then
    ARGS="$ARGS -config $INI +gl_es 1 +vid_preferbackend 3 +cl_capfps 0 +vid_fps 0"
fi

# Determine analog sticks available and start gptokeyb
$GPTOKEYB "$ENGINE" -c "configs/$ANALOG_STICKS.gptk" & 

# Disable gamepad
export LD_PRELOAD="$GAMEDIR/libs/hacksdl.so"
export HACKSDL_NO_GAMECONTROLLER=1
export HACKSDL_VERBOSE=0

# Run the game
echo "[LOG]: Running ${ENGINE} with args: ${ARGS}"
pm_platform_helper "$GAMEDIR/$ENGINE" > /dev/null
./engines/$ENGINE $ARGS

# Cleanup
pm_finish