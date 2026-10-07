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

# Starting style by panel height: the largest scale that fits (x4 from 800
# lines, x3 from 600, x2 from 400, a 4:3 panel filled), shorter panels Classic.
# It is a default: the player's choice in Options - Style wins.
if [ "$DISPLAY_HEIGHT" -ge 800 ]; then
  PROFILE=hd-handheld-x4
elif [ "$DISPLAY_HEIGHT" -ge 600 ]; then
  PROFILE=hd-handheld
elif [ "$DISPLAY_HEIGHT" -ge 400 ] && [ $((DISPLAY_WIDTH * 3)) -eq $((DISPLAY_HEIGHT * 4)) ]; then
  PROFILE=hd-handheld-43
elif [ "$DISPLAY_HEIGHT" -ge 400 ]; then
  PROFILE=hd-handheld-x2
else
  PROFILE=dos-handheld
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
