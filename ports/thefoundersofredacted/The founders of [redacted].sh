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

# Pm:
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR=/$directory/ports/thefoundersofredacted
CONFDIR="$GAMEDIR/conf/"
cd $GAMEDIR

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Calculate dpad_mouse_step and deadzone_scale based on DISPLAY_WIDTH
value=$(( 4 + (DISPLAY_WIDTH >= 640) + 2 * (DISPLAY_WIDTH >= 1280) + 3 * (DISPLAY_WIDTH >= 1920) ))

echo "Setting dpad_mouse_step and deadzone_scale to $value"
sed -i -E "s/(dpad_mouse_step|deadzone_scale) = [0-9]/\1 = $value/g" "thefoundersofredacted.gptk"

# Source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt

# Use the love runtime
$GPTOKEYB "$LOVE_GPTK" -c "./thefoundersofredacted.gptk"  &
pm_platform_helper "$LOVE_BINARY"
$LOVE_RUN "$GAMEDIR/gamedata/game.love"

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish