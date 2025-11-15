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

source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls # We pull the controller configs from the get_controls function from the control.txt file here

# We switch to the port's directory location below
if [ -z "$directory" ]; then
  cd $(dirname "$0")/asteroludi
else
  cd /$directory/ports/asteroludi
fi

./arcajs.`uname -m` -f asteroludi.ajs >out.log 2>&1
