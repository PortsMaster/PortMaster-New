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
GAMEDIR=/$directory/ports/openmw

export controlfolder
export DEVICE_ARCH
export GAMEDIR

# Okay its working, lets make the logs a bit less verbose. uwu
export OSG_NOTIFY_LEVEL=ERROR
export OPENMW_DEBUG_LEVEL=ERROR
export OPENMW_RECAST_MAX_LOG_LEVEL=ERROR

if echo "$CFW_NAME" | grep -q "ArkOS"; then
    # THERE IS ONLY ONE!
    export CFW_NAME="ArkOS"
fi

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Extract a pre-computed navmesh.db if it exists, and we can.
if [ -f "$controlfolder/7zzs.${DEVICE_ARCH}" ]; then
    NAVMESH_DB_XZ="openmw/navmesh.db.xz"

    # Make sure its in the right place.
    for file in "navmesh.db.xz" "data/navmesh.db.xz"; do
        if [ -f "$file" ]; then
            mv -f "$file" "$NAVMESH_DB_XZ"
            break
        fi
    done

    if [ -f "$NAVMESH_DB_XZ" ]; then
        pm_message "Extracting navmesh.db.xz, this will take a moment."
        "$controlfolder/7zzs.${DEVICE_ARCH}" x "$NAVMESH_DB_XZ" -oopenmw/ -aoa
        rm -f "$NAVMESH_DB_XZ"
    fi
fi

# Applying settings on first run.
if [ -f "$GAMEDIR/first-run" ]; then
    DATE_BACKUP="$(date +'%Y.%m.%d-%H%M')"
    if [ -f "openmw/settings.cfg" ]; then
        ## Backup settings.cfg
        mv "openmw/settings.cfg" "openmw/settings.${DATE_BACKUP}.cfg"
    fi
    ## Copy the base one.
    cp "openmw/settings.base.cfg" "openmw/settings.cfg"

    if [ -f "openmw/openmw.cfg" ]; then
        ## Backup openmw.cfg
        mv "openmw/openmw.cfg" "openmw/openmw.${DATE_BACKUP}.cfg"
    fi
    ## Copy the base one and set the data directory.
    awk -v d="$GAMEDIR/data/" '{gsub("{{DATADIR}}",d);print}' "openmw/openmw.base.cfg" > "openmw/openmw.cfg"

    # Apply Resolution
    python3 "settings_cfg.py" "openmw/settings.cfg" "Video" "resolution x" "${DISPLAY_WIDTH}"
    python3 "settings_cfg.py" "openmw/settings.cfg" "Video" "resolution y" "${DISPLAY_HEIGHT}"

    # Scaling
    if [ "$DISPLAY_HEIGHT" -gt "720" ]; then
        python3 "settings_cfg.py" "openmw/settings.cfg" "GUI" "scaling factor" "1.5"

    elif [ "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" = "720x720" ]; then
        python3 "settings_cfg.py" "openmw/settings.cfg" "GUI" "scaling factor" "1.0"

    elif [ "$DISPLAY_HEIGHT" -gt "640" ]; then
        python3 "settings_cfg.py" "openmw/settings.cfg" "GUI" "scaling factor" "1.25"

    else

        python3 "settings_cfg.py" "openmw/settings.cfg" "GUI" "scaling factor" "0.75"
    fi

    if [ "$CFW_NAME" = "ROCKNIX" ] || [ "$CFW_NAME" = "RetroDECK" ]; then
        # Extract the OpenGL compatible resources.
        tar -xjf resources.OpenGL.tar.bz2
    fi

    # Apply device specific settings.
    if [ -f "openmw/settings.${CFW_NAME}.${DEVICE_CPU}.cfg" ]; then
        python3 "settings_cfg.py" -merge "openmw/settings.cfg" "openmw/settings.${CFW_NAME}.${DEVICE_CPU}.cfg"
    fi

    if [ -f "openmw/settings.${DEVICE_CPU}.cfg" ]; then
        python3 "settings_cfg.py" -merge "openmw/settings.cfg" "openmw/settings.${DEVICE_CPU}.cfg"
    fi

    if [ -f "openmw/settings.${CFW_NAME}.cfg" ]; then
        python3 "settings_cfg.py" -merge "openmw/settings.cfg" "openmw/settings.${CFW_NAME}.cfg"
    fi

    rm -f "$GAMEDIR/first-run"
fi

# Extract game files if found.
INSTALLER_EXE_GLOB="setup_the_elder_scrolls_iii_morrowind_*.exe"
INSTALLER_FILE=""

for directory in "$GAMEDIR/data" "$GAMEDIR"; do
    if [ ! -z "$INSTALLER_FILE" ]; then
        break
    fi

    for file in "$directory"/$INSTALLER_EXE_GLOB; do
        if [ -f "$file" ]; then
            INSTALLER_FILE="$file"
            break
        fi
    done
done

MOD_COUNT="$(ls -1 "$GAMEDIR/mods" | wc -l)"

if [ -n "$INSTALLER_FILE" ] || [ "$MOD_COUNT" -gt "0" ]; then
    export PATCHER_FILE="$GAMEDIR/patchscript"
    export PATCHER_GAME="$(basename "${0%.*}")"
    if [ -n "$INSTALLER_FILE" ]; then
        export PATCHER_TIME="about 6 minutes"
    else
        # Who knows with mods.
        export PATCHER_TIME="an amount of time"
    fi

    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
        sleep 5
        exit 1
    fi
fi


GAME_EXECUTABLE="openmw.${DEVICE_ARCH}"
GPTK_FILENAME="openmw.ini"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$GAMEDIR"
export XDG_CONFIG_HOME="$GAMEDIR"
export OPENMW_DECOMPRESS_TEXTURES=1
export LIBGL_STREAM=1

export CRUSTY_SHOW_CURSOR=1 # enable cursor
export CRUSTY_CURSOR_FILE=$GAMEDIR/cursor.bmp # path to your cursor file
export CRUSTY_CURSOR_OFFSET_X=0.0 # offset between pointer and sprite. 0 for top left, 1 for bottom right, 0.5 for middle
export CRUSTY_CURSOR_OFFSET_Y=0.0 # offset between pointer and sprite.
export CRUSTY_CURSOR_SIZE=0.75 # cursor size modifier. 1 is normal, 2 is twice as big, or any other positive value. Do not use 0

## LIBGL_BINARYCOUNTER_EDITION
export LIBGL_TEXPATH=$GAMEDIR/texcache/ # point this to an empty folder, this is where it saves the textures it creates
export LIBGL_RECOMPTEX=0 # 0 for none, 1 for ETC2, 2 for segfault (ASTC isn't working yet) :P
export LIBGL_NOMIPMAPS=0 # if you want to disable mipmaps completely. Saves a bit of RAM, looks crunchy :P
export LIBGL_SHRINK=0 # Looks potato, but not too bad. The actual SHRINK settings do not matter, for now if it's >0, it's gonna do "if width or height > 128, resolution /2"

# Setup gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
    source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
    source "${controlfolder}/libgl_default.txt"
fi

# Arch library paths.
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# CFW Specific
[ -e "$GAMEDIR/libs.${CFW_NAME}.${DEVICE_ARCH}" ] && LD_LIBRARY_PATH="$GAMEDIR/libs.${CFW_NAME}.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
[ -e "$GAMEDIR/libs.${CFW_NAME}" ] && LD_LIBRARY_PATH="$GAMEDIR/libs.${CFW_NAME}:$LD_LIBRARY_PATH"

# More settings.
PRELOAD="$GAMEDIR/libcrusty.so"

if [ "$DEVICE_ARCH" = "x86_64" ]; then
    # Steamdeck and Friends.
    PRELOAD=""

elif [ "$CFW_NAME" = "ROCKNIX" ]; then
    # God damned lochness monster!
    # PRELOAD="$GAMEDIR/libcrustiest_final_final_final2_for_real.so"

    # ~~Shows a cursor at least, enjoy the flickering. owo~~ FIXED THAANKS BINARY <3
    SDL_VIDEODRIVER=x11

    if ! glxinfo | grep "OpenGL version string"; then
        pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
        sleep 5
        exit 1
    fi

    # Cursor auto-hide if on rocknix
    swaymsg 'seat * hide_cursor 1'

    # Fixes weird sound on ROCKNIX - thanks bmdhacks!
    ROCKNIX_QUANTUM_SAVE="$(pw-metadata -n settings | grep 'clock.force-quantum' | cut -d"'" -f 4)"
    pw-metadata -n settings 0 clock.force-quantum 960
elif [ "$CFW_NAME" = "knulli" ]; then
    # POTATO MODE ACTIVATED
    export LIBGL_RECOMPTEX=1
    export LIBGL_SHRINK=3

elif [ "$CFW_NAME" = "AmberELEC" ]; then
    # Doesn't appear to work on AmberELEC, but also isn't needed.
    PRELOAD=""

elif [ "$CFW_NAME" = "ArkOS" ] && [ "$DEVICE_CPU" = "Cortex-A35" ]; then
    # Doesn't appear to work on AmberELEC, but also isn't needed.
    PRELOAD=""
fi

if [ "$DEVICE_RAM" -gt "1" ]; then
    # Disable on more than 1gb ram.
    export LIBGL_RECOMPTEX=0
    export LIBGL_SHRINK=0
fi

# Setup texture potato-ification
if [ "$LIBGL_SHRINK" -gt 0 ]; then
    mkdir -p "$LIBGL_TEXPATH"

    if [ -f "$LIBGL_TEXPATH/shrinky_dink" ] && [ "$(< "$LIBGL_TEXPATH"/shrinky_dink)" -ne "$LIBGL_SHRINK" ]; then
        rm -fR "$LIBGL_TEXPATH"/*
    fi

    echo "$LIBGL_SHRINK" > "$LIBGL_TEXPATH/shrinky_dink"

    echo "===================================="
    echo "= LIBGL_SHRINK=$LIBGL_SHRINK"
    echo "===================================="
fi

$GPTOKEYB2 "$GAME_EXECUTABLE" -c "$GAMEDIR/$GPTK_FILENAME" > /dev/null &
pm_platform_helper "$GAMEDIR/$GAME_EXECUTABLE"
LD_PRELOAD="$PRELOAD" $GAMEDIR/$GAME_EXECUTABLE

pm_finish

if [ "$CFW_NAME" = "muOS" ]; then
    # THANKS FOR NOTHING
    killall -9 hotkey.sh muhotkey
    sleep 1
    /opt/muos/script/mux/hotkey.sh &
elif [ "$CFW_NAME" = "ROCKNIX" ]; then
    # Restore this.
    pw-metadata -n settings 0 clock.force-quantum "$ROCKNIX_QUANTUM_SAVE"
fi
