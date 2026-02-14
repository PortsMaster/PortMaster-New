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

GAMEDIR=/$directory/ports/asolitairemystery
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

if [ -f "$GAMEDIR/gamedata/ASM_itch.exe" ]; then
	expected_checksum="16131426c10fbd57d3834af1a940caba"
	checksum=$(md5sum "$GAMEDIR/gamedata/ASM_itch.exe" | awk '{print $1}')
	if [ "$checksum" != "$expected_checksum" ]; then
		echo "Invalid checksum: $game_file $checksum"
	else
		pm_message "Unpacking ASM_itch.exe ..."
		unzip -o "$GAMEDIR/gamedata/ASM_itch.exe" -d "$GAMEDIR/patched/"
		pm_message "Patching files ..."
		$controlfolder/xdelta3 -v -d -s "$GAMEDIR/patched/main.lua" "$GAMEDIR/patch/main.lua.vcdiff" "$GAMEDIR/patched/mainp.lua"
		$controlfolder/xdelta3 -v -d -s "$GAMEDIR/patched/render.lua" "$GAMEDIR/patch/render.lua.vcdiff" "$GAMEDIR/patched/renderp.lua"
		pm_message "Moving and cleaning up files ..."
		rm "$GAMEDIR/patched/main.lua"
		rm "$GAMEDIR/patched/render.lua"
        mv "$GAMEDIR/patched/mainp.lua" "$GAMEDIR/patched/main.lua"
		mv "$GAMEDIR/patched/renderp.lua" "$GAMEDIR/patched/render.lua"
		cp "$GAMEDIR/source/left_ptr.png" "$GAMEDIR/patched/left_ptr.png"
		rm "$GAMEDIR/gamedata/ASM_itch.exe"
	fi
fi

if [ -f "$GAMEDIR/patched/main.lua" ]; then
	# Run the love runtime
	$GPTOKEYB "$LOVE_GPTK" -c "ASM.gptk" &
	pm_platform_helper "$LOVE_BINARY"
	$LOVE_RUN "$GAMEDIR/patched/"
else
	echo "No usable game files found, please place your ASM_itch.exe in the gamedata directory"
fi

pm_finish
