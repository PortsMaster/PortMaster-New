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

GAMEDIR=/$directory/ports/cortexcommand
BINARY=CortexCommand

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILES=(data-part1.tar.gz data-part2.tar.gz)
if compgen -G "data-part*.tar.gz" >/dev/null; then
    pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
    for ARCHIVE_FILE in "${ARCHIVE_FILES[@]}"; do
        [ -f "$ARCHIVE_FILE" ] || continue
        if ! gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
            pm_show_error "Could not extract $ARCHIVE_FILE. Check that there is enough free space, then launch again." --title "Extraction failed"
            exit 1
        fi
        $ESUDO rm -f "$ARCHIVE_FILE"
    done
    RES_MULT=1
    [ "${DISPLAY_WIDTH:-640}" -ge 1280 ] && [ "${DISPLAY_HEIGHT:-480}" -ge 720 ] && RES_MULT=2
    RES_X=$((${DISPLAY_WIDTH:-640} / RES_MULT))
    RES_Y=$((${DISPLAY_HEIGHT:-480} / RES_MULT))
    [ "$RES_X" -lt 640 ] || [ "$RES_Y" -lt 360 ] && RES_X=640 RES_Y=360
    sed -i -e "s/ResolutionX = .*/ResolutionX = $RES_X/" -e "s/ResolutionY = .*/ResolutionY = $RES_Y/" -e "s/ResolutionMultiplier = .*/ResolutionMultiplier = $RES_MULT/" Userdata/Settings.ini
fi
if [ ! -f 'Data/Base.rte/Index.ini' ] || [ ! -f 'Data/Browncoats.rte/Index.ini' ]; then
    pm_show_error "No game data found and the archive files are missing. Reinstall the port." --title "Game data missing"
    exit 1
fi

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

GAME_SDL_VIDEODRIVER=""
if [ -n "$SDL_VIDEODRIVER" ]; then
  export SDL3SHIM_SDL2_VIDEODRIVER="$SDL_VIDEODRIVER"
  GAME_SDL_VIDEODRIVER=sdl2
fi
GAME_SDL_AUDIODRIVER=""
if [ -n "$SDL_AUDIODRIVER" ]; then
  export SDL3SHIM_SDL2_AUDIODRIVER="$SDL_AUDIODRIVER"
  GAME_SDL_AUDIODRIVER=sdl2
fi

$GPTOKEYB2 "$BINARY" &

pm_platform_helper "$GAMEDIR/$BINARY"

SDL_VIDEODRIVER="$GAME_SDL_VIDEODRIVER" SDL_AUDIODRIVER="$GAME_SDL_AUDIODRIVER" ./$BINARY

pm_finish
