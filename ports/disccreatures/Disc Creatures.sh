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
export controlfolder

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/disccreatures

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

chmod +x "$GAMEDIR/mkxp-z.${DEVICE_ARCH}"

# Patch Game.rgss3a on first run (stubs out Win32API/kernel32 calls).
# Must run BEFORE LD_LIBRARY_PATH is set to avoid readline crash on ROCKNIX.
if [ ! -f "$GAMEDIR/patchlog.txt" ]; then
  pm_message "Patching game files..."
  python3 "$GAMEDIR/disccreatures_patcher.py"
  if [ $? -eq 0 ]; then
    pm_message "Patch applied successfully." > "$GAMEDIR/patchlog.txt"
  else
    pm_message "Patch failed! Game may not run correctly."
  fi
fi

$GPTOKEYB "mkxp-z.${DEVICE_ARCH}" -c "./disccreatures.gptk" &
pm_platform_helper "$GAMEDIR/mkxp-z.${DEVICE_ARCH}" >/dev/null

# LD_LIBRARY_PATH scoped inline only — never exported globally.
# A global export causes bash/readline symbol crashes on ROCKNIX.
LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH" ./mkxp-z.${DEVICE_ARCH}

pm_finish
