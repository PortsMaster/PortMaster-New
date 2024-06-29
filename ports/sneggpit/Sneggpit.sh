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

# We switch to the port's directory location below
cd /$directory/ports/sneggpit

./arcajs.aarch64 ../sneggpit
