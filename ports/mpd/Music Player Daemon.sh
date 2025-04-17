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

GAMEDIR=/$directory/ports/mpdui
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
bind_directories ~/music $GAMEDIR/music
bind_directories ~/playlists $GAMEDIR/playlists

source $controlfolder/runtimes/"love_11.5"/love.txt
# MPD Start
if [ "$CFW_NAME" = "ROCKNIX" ]; then
    echo "Running on Rocknix with Pipewire"
    ./mpd ./configs/pipewire/mpdconf
elif [ "$CFW_NAME" = "muOS" ]; then
    echo "Running on MuOS with Pipewire"
    ./mpd ./configs/pipewire/mpdconf
elif [ "$CFW_NAME" = "knulli" ]; then
    echo "Running on Knulli with Pipewire ( Using special libs for SYSTEMD ) "
    export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/knullilibs:$LD_LIBRARY_PATH"
    ./mpd ./configs/pipewire/mpdconf
else
    echo "Running on ALSA"
    export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/nonpipewire.libs:$LD_LIBRARY_PATH"
    ./mpd mpdconf
fi


# Run the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "input.gptk" &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "mpdUI"

pm_finish
