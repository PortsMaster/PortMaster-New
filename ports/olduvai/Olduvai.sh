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

GAMEDIR=/$directory/ports/olduvai
BINARY=olduvai.${DEVICE_ARCH}

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Settings, saves and bug reports stay in the port folder.
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export OLDUVAI_BUG_DIR="$GAMEDIR/bug_reports"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Classic below 400 lines, else Enhanced, whose scale and aspect the engine
# fits to the panel (PortMaster's size, the panel as the player holds it).
# A default: Options - Style wins.
export OLDUVAI_PANEL="${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}"
if [ "$DISPLAY_HEIGHT" -lt 400 ]; then
  PROFILE=dos-handheld
else
  PROFILE=hd-handheld
fi

set -- --game-dir ./game --rom-dir ./mt32-roms --default-profile "$PROFILE"
# A SoundFont, if the player added one, plays the General MIDI music.
for sf in ./soundfonts/*.sf2 ./soundfonts/*.sf3; do
  if [ -f "$sf" ]; then set -- "$@" --soundfont "$sf"; break; fi
done

chmod +x "$GAMEDIR/$BINARY"

$GPTOKEYB "$BINARY" -c "$GAMEDIR/olduvai.gptk" &

pm_platform_helper "$GAMEDIR/$BINARY"

"$GAMEDIR/$BINARY" "$@"

pm_finish
