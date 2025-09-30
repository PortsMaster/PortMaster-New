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

GAMEDIR=/$directory/ports/worldofgoo
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Setup Box64
export LD_LIBRARY_PATH="$GAMEDIR/box64/native":"/usr/lib":"/usr/lib/aarch64-linux-gnu/":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/x64":"$GAMEDIR/box64/native":"$GAMEDIR/libs/x64"

# Move existing savedata to the port directory to avoid overwriting existing
# saves. (Previous versions of the port didn't symlink savedata.)
if [ -d ~/.WorldOfGoo ] && [ ! -h ~/.WorldOfGoo ]; then
    $ESUDO cp -RT ~/.WorldOfGoo "$GAMEDIR/savedata"
fi

# Setup savedir
bind_directories ~/.WorldOfGoo "$GAMEDIR/savedata"

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi 

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

#export BOX64_LOG=1
#export BOX64_DLSYM_ERROR=1
#export BOX64_SHOWSEGV=1
#export BOX64_SHOWBT=1

# Extract and organize game files if the installer exists
WOG_FILE=$(ls *.sh 2> /dev/null | head -n 1)

if [ -f "$WOG_FILE" ]; then
    unzip -o "$WOG_FILE"
    # Handle game directory movement based on structure
    if [ -d "data/noarch/game/game" ]; then
        $ESUDO mv -f data/noarch/game/game "$GAMEDIR/gamedata/"
    elif [ -d "data/noarch/game" ]; then
        $ESUDO mv -f data/noarch/game "$GAMEDIR/gamedata/"
    else
        pm_message "Game directory not found after extraction."
        sleep 5
        exit 1
    fi
    # Directly search and move WorldOfGoo.bin.x86_64
    if $ESUDO mv -f $(find . -name "WorldOfGoo.bin.x86_64" -print -quit) "$GAMEDIR/gamedata/WorldOfGoo.bin" 2>/dev/null; then
        $ESUDO chmod +x "$GAMEDIR/gamedata/WorldOfGoo.bin"
    else
        pm_message "WorldOfGoo.bin.x86_64 not found after extraction."
        sleep 5
        exit 1
    fi

    rm -rf data/ meta/ scripts/
    rm -f "$WOG_FILE"
    pm_message "Setup complete. Have fun playing!"
fi

$GPTOKEYB "WorldOfGoo.bin" -c "./worldofgoo.gptk" &
pm_platform_helper "$$GAMEDIR/box64/box64"
$GAMEDIR/box64/box64 gamedata/WorldOfGoo.bin

pm_finish
