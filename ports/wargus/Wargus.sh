#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# -------------------------------------------------
# Locate PortMaster control folder
# -------------------------------------------------
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# -------------------------------------------------
# Paths
# -------------------------------------------------
GAMEDIR="/$directory/ports/wargus"
CONFDIR="$GAMEDIR/conf"
BINARY="sgs"
WARTOOL="wartool.${DEVICE_ARCH}"
INNOEXTRACT="$controlfolder/innoextract.$DEVICE_ARCH"
DATADIR="$GAMEDIR/data"
UTILDIR="$GAMEDIR/utils"
INSTALLER_EXE_GLOB="setup_warcraft_ii*.exe"
INSTALLER_FILE_GLOB="setup_warcraft_ii*.*"

mkdir -p "$CONFDIR"
cd "$GAMEDIR" || exit 1

# -------------------------------------------------
# Logging
# -------------------------------------------------
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

bind_directories "$HOME/.stratagus" "$CONFDIR"

# Stratagus v3.3.2 doesn't support XDG_DATA_HOME but latest master as of 2025/12/20 isn't stable for save/load
#export XDG_DATA_HOME="$CONFDIR"

# -------------------------------------------------
# Environment (IMPORTANT ORDER)
# -------------------------------------------------

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [[ $CFW_NAME == *"ArkOS"* ]]; then
  export LD_LIBRARY_PATH="$GAMEDIR/libs.arkos.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
fi

install() {
  # -------------------------------------------------
  # Sanity checks
  # -------------------------------------------------
  if [ ! -x "$GAMEDIR/$BINARY" ]; then
    pm_message "Missing Stratagus binary"
    sleep 3
    exit 1
  fi

  if [ ! -x "$GAMEDIR/$WARTOOL" ]; then
    pm_message "Missing wartool extractor"
    sleep 3
    exit 1
  fi

  # -------------------------------------------------
  # Locate Warcraft II source data
  # -------------------------------------------------
  SRC1="$GAMEDIR/gamefiles"
  SRC2="$GAMEDIR/war2"
  WAR_SRC=""

  if [ -d "$SRC1" ]; then WAR_SRC="$SRC1"; fi
  if [ -z "$WAR_SRC" ] && [ -d "$SRC2" ]; then WAR_SRC="$SRC2"; fi

  # -------------------------------------------------
  # Run extractor if needed
  # -------------------------------------------------
  NEEDED="$DATADIR/extracted"

  if [ ! -f "$NEEDED" ]; then
    pm_message "Warcraft II data not extracted"
    sleep 1

    if [ -z "$WAR_SRC" ]; then
      pm_message "Put Warcraft II files in:"
      pm_message "wargus/gamefiles/ or wargus/war2/"
      sleep 5
      exit 1
    fi

    mkdir -p "$DATADIR"

    found_installer="no"
    for file in "$WAR_SRC"/$INSTALLER_EXE_GLOB; do
        if [ -f "$file" ]; then
            found_installer="yes"
            break
        fi
    done

    if [ "$found_installer" = "yes" ]; then
        pm_message "Found Warcraft II GOG installer"
        pm_message "Extracting GOG installer"
        sleep 1
        "$INNOEXTRACT" "$WAR_SRC"/$INSTALLER_EXE_GLOB -d "$WAR_SRC"
    fi

    pm_message "Extracting Warcraft II data..."
    pm_message "Extraction may take up to 10-60min"
    # Produces data/scripts/wc2-config.lua and data/extracted if successful
    export PATH="$UTILDIR":"$PATH"
    "$GAMEDIR/$WARTOOL" -v -r "$WAR_SRC" "$DATADIR"

    if [ ! -f "$NEEDED" ]; then
      pm_message "Extraction failed"
      sleep 5
      exit 1
    fi

    pm_message "Extraction complete"
    sleep 1

    pm_message "Delete installer files."
    rm -fR "$WAR_SRC"/*.*
    rm -fR "$WAR_SRC"/*
    sleep 1
  fi
}

# -------------------------------------------------
# Install game data
# -------------------------------------------------
install

# -------------------------------------------------
# Launch game
# -------------------------------------------------

# This is for the Floppy DOS version of Warcraft II
# Which uses midi files configured in data/scripts/wc2-config.lua wargus.music_extension = ".mid"
# The soundfont file is available from: https://member.keymusician.com/Member/FluidR3_GM/
if [ -f "$GAMEDIR/data/FluidR3_GM.sf2" ]; then
  export SDL_SOUNDFONTS="$GAMEDIR/data/FluidR3_GM.sf2"
fi

# Optional controller mapper
$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/wargus.gptk" &
pm_platform_helper "$GAMEDIR/$BINARY"
"./$BINARY" -d data

pm_finish
