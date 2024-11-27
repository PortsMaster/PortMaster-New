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

# We source custom mod files from the portmaster folder example mod_jelos.txt which containts pipewire fixes
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# We pull the controller configs like the correct SDL2 Gamecontrollerdb GUID from the get_controls function from the control.txt file here
get_controls

GAMEDIR=/$directory/ports/planetmerge/
CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Switch to the game directory
cd $GAMEDIR

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Some ports like to create save files or settings files in the user's home folder or other locations. We map these config folders so we can either preconfigure games and or have the savefiles in one place. I
# You can either use XDG variables to redirect the Ports to our gamefolder if the port supports it:

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export XDG_CONFIG_HOME="$CONFDIR"

# Provide appropriate controller configuration if it recognizes SDL controller input
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# We launch gptokeyb using this $GPTOKEYB variable as it will take care of sourcing the executable from the central location,
# assign the appropriate exit hotkey dependent on the device (ex. select + start for most devices and minus + start for the 
# rgb10) and assign the appropriate method for killing an executable dependent on the OS the port is run from.
# With -c we assign a custom mapping file else gptokeyb will only run as a tool to kill the process.
# For $ANALOGSTICKS we have the ability to supply multiple gptk files to support 1 and 2 analogue stick devices in different ways.
# For a proper documentation how gptokeyb works: [Link](https://github.com/PortsMaster/gptokeyb)
#$GPTOKEYB "planets.${DEVICE_ARCH}" -c "./planetmerge.gptk.$ANALOGSTICKS" &

# Do some platform specific stuff right before the port is launched but after GPTOKEYB is run.
pm_platform_helper "$GAMEDIR/planets.${DEVICE_ARCH}"

./planets.${DEVICE_ARCH}

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish
