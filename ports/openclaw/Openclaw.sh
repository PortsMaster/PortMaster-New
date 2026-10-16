#!/bin/bash
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [ -d /opt/system/Tools/PortMaster/ ]; then
  controlfolder=/opt/system/Tools/PortMaster
elif [ -d /opt/tools/PortMaster/ ]; then
  controlfolder=/opt/tools/PortMaster
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder=/roms/ports/PortMaster
fi
source "$controlfolder/control.txt"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls
GAMEDIR="/$directory/ports/openclaw"
cd "$GAMEDIR" || exit 1
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
if [ -f CLAW.REZ.gz ]; then
  gzip -dc CLAW.REZ.gz > CLAW.REZ.tmp || exit 1
  mv CLAW.REZ.tmp CLAW.REZ || exit 1
  rm CLAW.REZ.gz
fi
export LD_LIBRARY_PATH="$GAMEDIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TIMIDITY_CFG="$GAMEDIR/timidity.cfg"
chmod +x ./openclaw
$GPTOKEYB "openclaw" -c "$GAMEDIR/openclaw.gptk.1" &
./openclaw
pm_finish
