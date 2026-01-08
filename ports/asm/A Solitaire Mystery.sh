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

GAMEDIR=/$directory/ports/asm
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"
cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"

#  If XDG Path does not work
# Use bind_directories to reroute that to a location within the ports folder.
# bind_directories ~/.portfolder $GAMEDIR/conf/.portfolder 

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

source $controlfolder/runtimes/"love_11.5"/love.txt

if [ -f "$GAMEDIR/gamedata/ASM.exe" ]; then
	expected_checksum="380c2b9b47d8a0aee7c89ae21a5f319e"
	checksum=$(md5sum "$GAMEDIR/gamedata/ASM.exe" | awk '{print $1}')
	if [ "$checksum" != "$expected_checksum" ]; then
		echo "Invalid checksum: $game_file $checksum"
		exit
	else
		$controlfolder/xdelta3 -d -vfs "$GAMEDIR/gamedata/ASM.exe" "$GAMEDIR/patch/ASM.vcdiff" "$GAMEDIR/gamedata/ASM.love"
		mv "$GAMEDIR/gamedata/ASM.exe" "$GAMEDIR/gamedata/ASM.exe.bak"
	fi
fi

if [ -f "$GAMEDIR/gamedata/ASM.love" ]; then
	# Run the love runtime
	$GPTOKEYB "$LOVE_GPTK" -c "ASM.gptk" &
	pm_platform_helper "$LOVE_BINARY"
	$LOVE_RUN "$GAMEDIR/gamedata/ASM.love"
else
	echo "No usable game files found, please place your ASM.exe in the gamedata directory"
fi

pm_finish
