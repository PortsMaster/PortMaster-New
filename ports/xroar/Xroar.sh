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

GAMEDIR="/$directory/ports/xroar"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

[ ! -f "$gamedir/bios/d32.rom" ] && pm_message "Error: d32.rom (Dragon 32) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/d64_1.rom" ] && pm_message "Error: d64_1.rom (Dragon 64 32K) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/d64_2.rom" ] && pm_message "Error: d64_2.rom (Dragon 64 64K) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/ddos10.rom" ] && pm_message "Error: ddos10.rom (DragonDOS) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/bas13.rom" ] && pm_message "Error: bas13.rom (Tandy Colour) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/extbas11.rom" ] && pm_message "Error: extbas11.rom (Tandy Extended) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/coco3.rom" ] && pm_message "Error: coco3.rom (Tandy CoCo3 NTSC) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/coco3p.rom" ] && pm_message "Error: coco3p.rom (Tandy CoCo3 PAL) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/disk11.rom" ] && pm_message "Error: disk11.rom (Tandy RS-DOS) not present in bios directory. If game does not load, fix this first."
[ ! -f "$gamedir/bios/mc10.rom" ] && pm_message "Error: mc10.rom (TANDY Microcolour) not present in bios directory. If game does not load, fix this first."
[ -f "/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2" ] && export LD_PRELOAD="/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2"

cd $GAMEDIR

$ESUDO chmod +x $GAMEDIR/xroarmenu.${DEVICE_ARCH}
$ESUDO chmod +x $GAMEDIR/xroar.${DEVICE_ARCH}

# Setup biosdir
bind_directories ~/.xroar/roms "$GAMEDIR/bios"

# ENVARS need to be exported or xroarmenu will not see them
export GAMEDIR="$GAMEDIR" DEVICE_ARCH="$DEVICE_ARCH" DEVICE_NAME="$DEVICE_NAME" GPTOKEYB="$GPTOKEYB"

$GPTOKEYB "xroarmenu.${DEVICE_ARCH}" -c "$GAMEDIR/gptk/xroarmenu.gptk" &
pm_platform_helper "$GAMEDIR/xroarmenu.${DEVICE_ARCH}"
./xroarmenu.${DEVICE_ARCH}

pm_finish
