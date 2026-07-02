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

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export PATH="$GAMEDIR/bin.${DEVICE_ARCH}:$PATH"

# Arch library paths.
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# CFW Specific
[ -e "$GAMEDIR/libs.${CFW_NAME}.${DEVICE_ARCH}" ] && export LD_LIBRARY_PATH="$GAMEDIR/libs.${CFW_NAME}.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
[ -e "$GAMEDIR/libs.${CFW_NAME}" ] && export LD_LIBRARY_PATH="$GAMEDIR/libs.${CFW_NAME}:$LD_LIBRARY_PATH"

# Detect dArkOS before normalization — it needs crusty cursor overlay unlike stock ArkOS.
IS_DARKOS=false
if echo "$CFW_NAME" | grep -qi "darkos"; then
    IS_DARKOS=true
fi

# Normalize ArkOS variants after CFW-specific libs are resolved.
if [[ "$CFW_NAME" == *"AeUX"* ]]; then
    export CFW_NAME="ArkOS"
    if [[ "$DEVICE_CPU" == "Cortex-A35" ]]; then
        export DEVICE_CPU="RK3326"
    fi
elif echo "$CFW_NAME" | grep -q "ArkOS"; then
    export CFW_NAME="ArkOS"
fi

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

if [ -n "$INSTALLER_FILE" ]; then
    export PATCHER_FILE="$GAMEDIR/patchscript"
    export PATCHER_GAME="$(basename "${0%.*}")"
    export PATCHER_TIME="about 6 minutes"

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

# More settings.
PRELOAD="$GAMEDIR/libcrusty.so"

# Copy arch dependent defaults
[ -f "defaults.${DEVICE_ARCH}.bin" ] && cp -f "defaults.${DEVICE_ARCH}.bin" defaults.bin

if [ "$DEVICE_ARCH" = "x86_64" ]; then
    # Steamdeck and Friends.
    PRELOAD=""

elif [ "$CFW_NAME" = "ROCKNIX" ]; then
    # God damned lochness monster!
    # PRELOAD="$GAMEDIR/libcrustiest_final_final_final2_for_real.so"

    # ~~Shows a cursor at least, enjoy the flickering. owo~~ FIXED THAANKS BINARY <3
    SDL_VIDEODRIVER=x11

    if [ "$CFW_VERSION" -gt "20250517" ]; then
        # This .so breaks shit on the testing build.
        rm -f "$GAMEDIR/libs.aarch64/libX11.so.6"
    fi

    if [ -e /usr/bin/gpudriver ]; then
        GPUDRIVER=$(/usr/bin/gpudriver)

        if [ "$GPUDRIVER" = "libmali" ]; then
            pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
            sleep 5
            exit 1
        fi
    else
        if ! glxinfo | grep "OpenGL version string"; then
            pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
            sleep 5
            exit 1
        fi
    fi

    if [[ "$UI_SERVICE" == *"sway"* ]]; then
        # Cursor auto-hide if on rocknix
        swaymsg 'seat * hide_cursor 1'
    else
        # On the OGU this breaks stuff.
        PRELOAD=""
    fi

    # Fixes weird sound on ROCKNIX - thanks bmdhacks!
    ROCKNIX_QUANTUM_SAVE="$(pw-metadata -n settings | grep 'clock.force-quantum' | cut -d"'" -f 4)"
    pw-metadata -n settings 0 clock.force-quantum 960
elif [ "$CFW_NAME" = "AmberELEC" ]; then
    # THIS IS SO FUCKING DUMB
    CRUSTY_CURSOR_FILE=$GAMEDIR/blank_cursor.bmp

elif { [ "$CFW_NAME" = "ArkOS" ] && { [ "$DEVICE_CPU" = "Cortex-A35" ] || [ "$DEVICE_CPU" = "RK3326" ]; }; } && [ "$IS_DARKOS" = false ]; then
    # THIS IS SO FUCKING DUMB
    CRUSTY_CURSOR_FILE=$GAMEDIR/blank_cursor.bmp
fi

# MOUNT POINT YO
MOUNT_POINT="/tmp/pm_python3"

## MOD MANAGER -- Not yet compiled for x86_64
if [ ! -f "$GAMEDIR/skip_openmw_esmm" ] && [ -f "$GAMEDIR/bin.$DEVICE_ARCH/openmw_esmm" ]; then
    if [ ! -f "mlox_base.txt" ]; then
        # Fetch mlox rules as we cannot distribute them.
        curl https://raw.githubusercontent.com/DanaePlays/mlox-rules/main/mlox_base.txt -o mlox_base.txt
        curl https://raw.githubusercontent.com/DanaePlays/mlox-rules/main/mlox_user.txt -o mlox_user.txt
    fi

    # --- Python Version Check ---
    MIN_MINOR_VERSION=9

    echo "--- Checking system Python version ---"
    # Get version string like "3.7.5" from an output like "Python 3.7.5"
    # The 2>&1 redirects stderr to stdout, as some pythons write version info there.
    VERSION_STRING=$(python3 --version 2>&1 | awk '{print $2}')

    # Extract major and minor version numbers
    MAJOR_VERSION=$(echo "$VERSION_STRING" | cut -d'.' -f1)
    MINOR_VERSION=$(echo "$VERSION_STRING" | cut -d'.' -f2)

    runtime="python_3.11"

    # Check if the version is less than 3.8
    if [ "$PM_CAN_MOUNT" = "Y" ] && { [ "$MAJOR_VERSION" -lt 3 ] || { [ "$MAJOR_VERSION" -eq 3 ] && [ "$MINOR_VERSION" -lt "$MIN_MINOR_VERSION" ]; } }; then
        echo "System Python is version $VERSION_STRING, which is older than 3.8. A custom environment is required."
        USE_PYTHON_SQUASHFS=true

        if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
            # LETS DO THIS
            source "${controlfolder}/PortMasterDialog.txt"

            hasip=$(PortMasterIPCheck)
            if [[ -z "${hasip}" ]]; then
                # No internet connection, do not initialize with harbourmaster backend.
                PortMasterDialogInit "no-harbour"
                PortMasterDialogMessageBox "Runtime ${runtime}.squashfs is missing, no internet connection available.\n\nPlease manually download ${runtime}.squashfs and place it in the 'PortMaster/libs/' directory."
                PortMasterDialogExit
                exit 1
            fi

            # Dont check for updates.
            PortMasterDialogInit "no-check"

            PortMasterDialog "messages_begin"

            PortMasterDialog "message" "Downloading ${runtime}.squashfs."

            RUN_RESULT=$(PortMasterDialogCheckRuntime "${runtime}.squashfs")

            if [[ "$RUN_RESULT" != "OKAY" ]]; then
                PortMasterDialogMessageBox "Unable to download ${runtime}.squashfs.\n\nPlease manually download ${runtime}.squashfs and place it in the 'PortMaster/libs/' directory."
                PortMasterDialogExit
                exit 1
            fi 

            PortMasterDialog "message" "Success."
            sleep 3
            PortMasterDialogExit
        fi

        $ESUDO mkdir -p "$MOUNT_POINT"
        if mountpoint -q "$MOUNT_POINT"; then
          $ESUDO umount "$MOUNT_POINT"
          echo "Unmounted $MOUNT_POINT"
        fi
        $ESUDO mount "$controlfolder/libs/${runtime}.squashfs" "$MOUNT_POINT"

        export PATH="$MOUNT_POINT/bin:$PATH"
        export LD_LIBRARY_PATH="$MOUNT_POINT/libs:$LD_LIBRARY_PATH"
        export PYTHONHOME="$MOUNT_POINT"
    else
        echo "System Python is version $VERSION_STRING. No custom environment needed."
    fi

    $GPTOKEYB "openmw_esmm" &
    pm_platform_helper "$GAMEDIR/bin.$DEVICE_ARCH/openmw_esmm"
    if ! "openmw_esmm" --openmw-cfg-dir "$GAMEDIR/openmw/" --7zz "$controlfolder/7zzs.$DEVICE_ARCH"; then    
        pm_gptokeyb_finish

        if [ "$PM_CAN_MOUNT" = "Y" ] && mountpoint -q "$MOUNT_POINT"; then
          $ESUDO umount "$MOUNT_POINT"
          echo "Unmounted $MOUNT_POINT"
        fi
        exit 0
    fi
    pm_gptokeyb_finish
fi

$GPTOKEYB2 "$GAME_EXECUTABLE" -c "$GAMEDIR/$GPTK_FILENAME" > /dev/null &
pm_platform_helper "$GAMEDIR/$GAME_EXECUTABLE"
LD_PRELOAD="$PRELOAD" ./$GAME_EXECUTABLE

pm_finish

if [ "$PM_CAN_MOUNT" = "Y" ] && mountpoint -q "$MOUNT_POINT"; then
    $ESUDO umount "$MOUNT_POINT"
    echo "Unmounted $MOUNT_POINT"
fi

if [ "$CFW_NAME" = "muOS" ]; then
    # THANKS FOR NOTHING
    killall -9 hotkey.sh muhotkey
    sleep 1
    /opt/muos/script/mux/hotkey.sh &
elif [ "$CFW_NAME" = "ROCKNIX" ]; then
    # Restore this.
    pw-metadata -n settings 0 clock.force-quantum "$ROCKNIX_QUANTUM_SAVE"
fi
