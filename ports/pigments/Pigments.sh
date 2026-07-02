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
GAMEDIR="/$directory/ports/pigments"
BINARY="gamedata/pigments.app/Contents/MacOS/pigments"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check for game files
if [ ! -f "$GAMEDIR/$BINARY" ]; then
    pm_message "Game files not found. See README.md for installation instructions."
    sleep 15
    exit 1
fi

# Redirect game save data to port directory
mkdir -p "$GAMEDIR/userdata"

# Display loading splash while game initializes
[ "$CFW_NAME" == "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1
$ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 8000 &


PATCHES_DIR="$GAMEDIR/conf/patches"
PATCHES=""
if command -v python3 >/dev/null 2>&1 \
   && [ -f "$GAMEDIR/tools/sugar_fingerprint.py" ]; then
    for candidate in "$PATCHES_DIR"/pigments*.conf; do
        [ -f "$candidate" ] || continue
        if python3 "$GAMEDIR/tools/sugar_fingerprint.py" \
                   "$GAMEDIR/$BINARY" "$candidate" >/dev/null 2>&1; then
            PATCHES="$candidate"
            break
        fi
    done
else
    BIN_SIZE=$(stat -c%s "$GAMEDIR/$BINARY" 2>/dev/null \
               || stat -f%z "$GAMEDIR/$BINARY" 2>/dev/null)
    case "$BIN_SIZE" in
        5399168)  PATCHES="$PATCHES_DIR/pigments.conf" ;;
    esac
fi
if [ -z "$PATCHES" ]; then
    pm_message "Unrecognised Pigments binary"
    sleep 15
    exit 1
fi
echo "launcher: selected patches $(basename "$PATCHES")"

if [ "$CFW_NAME" = "ROCKNIX" ]; then
    MACHISMO_CONF_TEMPLATE="$GAMEDIR/conf/machismo_mesa.conf"
    GAME_ARGS=""
else
    MACHISMO_CONF_TEMPLATE="$GAMEDIR/conf/machismo.conf"
    GAME_ARGS="shaderless"
fi
MACHISMO_CONF="$GAMEDIR/.machismo.conf.run"
sed "s|PATCHES_PATH|$PATCHES|" "$MACHISMO_CONF_TEMPLATE" > "$MACHISMO_CONF"

$GPTOKEYB "machismo" -c "pigments.gptk" &
pm_platform_helper "$GAMEDIR/bin/machismo" > /dev/null
$ESUDO env \
    SDL_GAMEPADMAPPINGS="$sdl_controllerconfig" \
    LD_LIBRARY_PATH="$GAMEDIR/libs:${LD_LIBRARY_PATH:-}" \
    MACHISMO_CONFIG="$MACHISMO_CONF" \
    MACHISMO_HOME="$GAMEDIR/userdata" \
    XDG_DATA_HOME="$GAMEDIR/userdata" \
    XDG_CONFIG_HOME="$GAMEDIR/userdata" \
    MESA_NO_ERROR=1 \
    LIBGL_GL=32 \
    LIBGL_ES=2 \
    LIBGL_NOERROR=1 \
    "$GAMEDIR/bin/machismo" "$BINARY" $GAME_ARGS

pm_finish
