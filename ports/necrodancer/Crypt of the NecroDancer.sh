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
GAMEDIR="/$directory/ports/necrodancer"

# Detect game source and set binary path
GAME_SOURCE=""
if [ -f "$GAMEDIR/gamedata/.game_source" ]; then
    GAME_SOURCE="$(cat "$GAMEDIR/gamedata/.game_source")"
fi

case "$GAME_SOURCE" in
    gog|gog-synchrony)
        BINARY="gamedata/NecroDancerMP.app/Contents/MacOS/NecroDancer" ;;
    *)
        BINARY="gamedata/NecroDancerSP.app/Contents/MacOS/NecroDancer" ;;
esac

# Check for game files — if binary missing, check for unprocessed sources
if [ ! -f "$GAMEDIR/$BINARY" ]; then
    if [ -d "$GAMEDIR/gamedata/depot_247082" ] || [ -d "$GAMEDIR/gamedata/depot_247086" ]; then
        echo "Game depots found but not yet merged. Running patcher..."
    elif ls "$GAMEDIR/gamedata/"*.pkg >/dev/null 2>&1; then
        echo "GOG installer(s) found. Running patcher..."
    elif [ -d "$GAMEDIR/gamedata/NecroDancerMP.app" ] && [ -d "$GAMEDIR/gamedata/NecroDancer.app" ]; then
        echo "GOG game files found. Running patcher..."
    else
        pm_message "Game files not found. See README.md for installation instructions."
        sleep 15
        exit 1
    fi
fi

# Migrate from old .patched_complete marker to .game_source
if [ ! -f "$GAMEDIR/gamedata/.game_source" ] && [ -f "$GAMEDIR/gamedata/.patched_complete" ]; then
    echo "steam" > "$GAMEDIR/gamedata/.game_source"
fi

# Run patcher if needed (extracts GOG pkg or merges Steam depots on first run)
if [ ! -f "$GAMEDIR/gamedata/.game_source" ]; then
    # Check available disk space before patching.
    # GOG extraction needs temp space: ~4GB base-only, ~6GB with all DLC.
    # Final install is ~2GB. Subtracting current folder size accounts for
    # partial progress. Steam depot merge just moves files, so no extra needed.
    if ls "$GAMEDIR/gamedata/"*.pkg >/dev/null 2>&1; then
        PEAK_KB=$((6 * 1024 * 1024))
        CURRENT_KB=$(du -sk "$GAMEDIR" | cut -f1)
        FREE_KB=$(df -k "$GAMEDIR" | tail -1 | awk '{print $4}')
        NEEDED_KB=$((PEAK_KB - CURRENT_KB))
        if [ "$NEEDED_KB" -gt 0 ] && [ "$FREE_KB" -lt "$NEEDED_KB" ]; then
            FREE_GB=$(awk "BEGIN {printf \"%.1f\", $FREE_KB / 1048576}")
            NEEDED_GB=$(awk "BEGIN {printf \"%.1f\", $NEEDED_KB / 1048576}")
            pm_message "Not enough disk space to extract GOG installers. Need ${NEEDED_GB}GB free but only ${FREE_GB}GB available. Free up space and try again."
            sleep 15
            exit 1
        fi
    fi

    export PATCHER_FILE="$GAMEDIR/patch/patch.bash"
    export PATCHER_GAME="Crypt of the NecroDancer"
    if ls "$GAMEDIR/gamedata/"*.pkg >/dev/null 2>&1; then
        export PATCHER_TIME="10 minutes"
    else
        export PATCHER_TIME="1-2 minutes"
    fi

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        $ESUDO chmod a+x "$GAMEDIR/patch/patch.bash"
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
        sleep 5
        exit 1
    fi

    if [ ! -f "$GAMEDIR/gamedata/.game_source" ]; then
        echo "Patching failed"
        sleep 5
        exit 1
    fi
fi

# Re-read source after patching (may have just been written)
if [ -f "$GAMEDIR/gamedata/.game_source" ]; then
    GAME_SOURCE="$(cat "$GAMEDIR/gamedata/.game_source")"
fi

# Set binary path based on detected source
case "$GAME_SOURCE" in
    gog|gog-synchrony)
        BINARY="gamedata/NecroDancerMP.app/Contents/MacOS/NecroDancer" ;;
    *)
        BINARY="gamedata/NecroDancerSP.app/Contents/MacOS/NecroDancer" ;;
esac

# Verify binary exists after patching
if [ ! -f "$GAMEDIR/$BINARY" ]; then
    pm_message "Game binary not found after patching. Check your game files."
    sleep 15
    exit 1
fi

# Verify binary matches a known version (patches are address-specific)
KNOWN_MD5="a9c10ca540484781267df006504cca9b de19e81ff2c45f3256996e5c2ae11af3 a0cc75edd6f5f4d6fb28acd15ae0800e"
BINARY_MD5="$(md5sum "$GAMEDIR/$BINARY" | cut -d' ' -f1)"
case " $KNOWN_MD5 " in
    *" $BINARY_MD5 "*) ;;
    *)
        pm_message "The version of Crypt of the NecroDancer you are using does not match the expected version. Please report this on the PortMaster Discord channel."
        sleep 15
        exit 1
        ;;
esac

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export MACHISMO_CONFIG="$GAMEDIR/conf/machismo-${GAME_SOURCE}.conf"

# Mesa optimizations for low-power GPU
export LIBGL_NOERROR=1
export MESA_NO_ERROR=1

# ROCKNIX runs Sway — force fullscreen and hide cursor
if [ -n "$(pgrep sway)" ]; then
    swaymsg 'seat * hide_cursor 0'
    timeout 7 watch swaymsg '[app_id=machismo] fullscreen enable' &
    SWAY_FULLSCREEN_PID=$!
fi

# Redirect game save data to port directory (not next to machismo binary)
export MACHISMO_HOME="$GAMEDIR/userdata"
mkdir -p "$GAMEDIR/userdata"

# Generate userconfig.json with device display resolution and memory-saving settings
cat > "$GAMEDIR/conf/userconfig.json" <<USERCONFIG
{
	"wos": {
		"game": {
			"graphics": {
				"textureAtlasSize": 1728,
				"textureLayerCount": 1
			},
			"window": {
				"size": [${DISPLAY_WIDTH:-640}, ${DISPLAY_HEIGHT:-480}],
				"maximized": false
			}
		}
	}
}
USERCONFIG

# Set view multiplier for small screens
if [ "${DISPLAY_HEIGHT:-480}" -le 480 ] 2>/dev/null; then
    SCALE_FACTOR=3
else
    SCALE_FACTOR=2
fi

# Seed or patch save data for handheld settings
PREFS="$GAMEDIR/userdata/Library/Preferences/NecroDancer"
mkdir -p "$PREFS"
if [ ! -f "$PREFS/SynchronyOptions.lua" ]; then
    cat > "$PREFS/SynchronyOptions.lua" <<OPTS
{
	["display.scaleFactor"] = ${SCALE_FACTOR},
	["preload.image.enabled"] = false,
	["preload.audio.enabled"] = false,
}
OPTS
else
    if ! grep -q "preload.image.enabled" "$PREFS/SynchronyOptions.lua"; then
        sed -i '/^}$/i\
\t["preload.image.enabled"] = false,' "$PREFS/SynchronyOptions.lua"
    fi
    if ! grep -q "preload.audio.enabled" "$PREFS/SynchronyOptions.lua"; then
        sed -i '/^}$/i\
\t["preload.audio.enabled"] = false,' "$PREFS/SynchronyOptions.lua"
    fi
    if ! grep -q "display.scaleFactor" "$PREFS/SynchronyOptions.lua"; then
        sed -i '/^}$/i\
\t["display.scaleFactor"] = '"${SCALE_FACTOR}"',' "$PREFS/SynchronyOptions.lua"
    fi
fi

# Display loading splash while game initializes
[ "$CFW_NAME" == "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1
$ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 8000 &

# Run it
$GPTOKEYB "machismo" &
pm_platform_helper "$GAMEDIR/bin/machismo" > /dev/null
"$GAMEDIR/bin/machismo" "$BINARY" "--userconfig=$GAMEDIR/conf/userconfig.json"

# Clean up
if [ -n "$SWAY_FULLSCREEN_PID" ]; then
    kill $SWAY_FULLSCREEN_PID 2>/dev/null
    swaymsg 'seat * hide_cursor 1000'
fi
pm_finish
