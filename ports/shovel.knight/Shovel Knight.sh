#!/bin/bash


if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="/$directory/ports/shovelknight"
cd $GAMEDIR/gamedata/shovelknight/32

# gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

export LIBGL_NOBANNER=1
export BOX86_LOG=0
export BOX86_LD_PRELOAD=$GAMEDIR/libShovelKnight.so
export LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib:/usr/lib32
export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/
export BOX86_DYNAREC=1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm -rf ~/.local/share/Yacht\ Club\ Games
$ESUDO ln -s $GAMEDIR/Yacht\ Club\ Games ~/.local/share/
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "box86" -c "$GAMEDIR/shovelknight.gptk" &
echo "Loading, please wait... (might take a while!)" > /dev/tty0
$GAMEDIR/box86/box86 ShovelKnight 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0