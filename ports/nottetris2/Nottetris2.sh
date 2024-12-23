#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
# Below we assign the source of the control folder (which is the PortMaster folder) based on the distro:
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt # We source the control.txt file contents here
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls # We pull the controller configs from the get_controls function from the control.txt file here

GAMEDIR="/$directory/ports/nottetris2"
LAUNCH_GAME="nottetris2"

# Log the execution of the script, the script overwrites itself on each launch
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Some ports like to create save files or settings files in the user's home folder or other locations.
# Love2D uses XDG_DATA_HOME for this
export XDG_DATA_HOME="$GAMEDIR/saves" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/saves"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

# TODO: If a port uses GL4ES (libgl.so.1) a folder named gl4es.aarch64 etc. needs to be created with the libgl.so.1 file in it. This makes sure that each cfw and device get the correct GL4ES export.
#if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
#  source "${controlfolder}/libgl_${CFW_NAME}.txt"
#else
#  source "${controlfolder}/libgl_default.txt"
#fi

# Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.aarch64, libs.armhf or libs.x64
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"

# We switch to the port's directory location below
cd $GAMEDIR

# Make sure uinput is accessible so we can make use of the gptokeyb controls.  351Elec/AmberElec and JelOS always runs in root, naughty naughty.
# The other distros don't so the $ESUDO variable provides the sudo or not dependant on the OS this script is run from.
$ESUDO chmod 666 /dev/uinput

export TEXTINPUTINTERACTIVE="Y"        # enables interactive text input mode for gptokeyb (for high score names)
export TEXTINPUTNOAUTOCAPITALS="Y"     # disables automatic capitalisation of first letter of words in interactive text input mode

# We launch gptokeyb using this $GPTOKEYB variable as it will take care of sourcing the executable from the central location,
# assign the appropriate exit hotkey dependent on the device (ex. select + start for rg351 devices and minus + start for the
# rgb10) and assign the appropriate method for killing an executable dependent on the OS the port is run from.
$GPTOKEYB "love.${DEVICE_ARCH}" -c $GAMEDIR/nottetris2.gptk &
pm_platform_helper "./bin/love.${DEVICE_ARCH}"
./bin/love.${DEVICE_ARCH} "$LAUNCH_GAME"

# Cleanup any running gptokeyb instances, and any platform specific stuff.
pm_finish
