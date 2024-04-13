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
source $controlfolder/device_info.txt
export PORT_32BIT="Y"


[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/MalditaCastilla"
LIBDIR="$GAMEDIR/lib32"

# gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# system
export LD_LIBRARY_PATH="$LIBDIR:/usr/lib32:/usr/local/lib/arm-linux-gnueabihf/"
export LD_PRELOAD="$LIBDIR/libbcm_host.so"

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "MalditaCastilla" xbox360 -c "$GAMEDIR/malditacastilla.gptk" &
./MalditaCastilla 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO sudo systemctl restart oga_events &
unset LD_LIBRARY_PATH
unset LD_PRELOAD
printf "\033c" >> /dev/tty1

#sudo ./rg351p-js2xbox.$param_device &
#sudo ./oga_controls MalditaCastilla $param_device &
#./MalditaCastilla 2>&1
#sudo kill -9 $(pidof rg351p-js2xbox.$param_device)
#sudo kill -9 $(pidof oga_controls)
#sudo systemctl restart oga_events &
#printf "\033c" >> /dev/tty1

