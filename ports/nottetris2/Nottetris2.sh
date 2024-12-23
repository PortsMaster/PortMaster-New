#!/bin/bash

# Below we assign the source of the control folder (which is the PortMaster folder) based on the distro:
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster" # Location for ArkOS which is mapped from /roms/tools or /roms2/tools for devices that support 2 sd cards and have them in use.
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster" # Location for TheRA
else
  controlfolder="/roms/ports/PortMaster" # Location for 351Elec/AmberElec, JelOS and RetroOZ
fi

source $controlfolder/control.txt # We source the control.txt file contents here

get_controls # We pull the controller configs from the get_controls function from the control.txt file here
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/nottetris2"
LAUNCH_GAME="nottetris2"

# Some ports like to create save files or settings files in the user's home folder or other locations.  
# Love2D uses XDG_DATA_HOME for this
export XDG_DATA_HOME="$GAMEDIR/saves" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/saves"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4

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

# Now we launch the port's executable and provide the location of specific libraries in may need along with the appropriate
# controller configuration if it recognizes SDL controller input
# TODO: LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./blobby 2>&1 | tee -a ./log.txt

# Although you can kill most of the ports (if not all of the ports) via a hotkey, the user may choose to exit gracefully.
# That's fine but let's make sure gptokeyb is killed so we don't get ghost inputs or worse yet, 
# launch it again and have 2 or more of them running.
$ESUDO kill -9 $(pidof gptokeyb)

# The line below is helpful for ArkOS, RetroOZ, and TheRA as some of these ports tend to cause the 
# global hotkeys (like brightness and volume control) to stop working after exiting the port for some reason.
$ESUDO systemctl restart oga_events &

# Finally we clean up the terminal screen just for neatness sake as some people care about this.
printf "\033c" >> /dev/tty1
