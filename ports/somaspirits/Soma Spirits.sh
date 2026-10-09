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

GAMEDIR=/$directory/ports/somaspirits

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"

chmod +x "$GAMEDIR/mkxp-z.${DEVICE_ARCH}"

# Patch Scripts.rvdata2 on first run (neuters TRGSSX exit + gdi32 Region
# Win32API calls in KGC Bitmap Extension, disables Zeus81's Fullscreen++).
# Must run BEFORE LD_LIBRARY_PATH is set to avoid readline crash on ROCKNIX.
if [ ! -f "$GAMEDIR/patchlog.txt" ]; then
  pm_message "Patching game files..."
  python3 "$GAMEDIR/somaspirits_patcher.py" "$GAMEDIR"
  if [ $? -eq 0 ]; then
    pm_message "Patch applied successfully." > "$GAMEDIR/patchlog.txt"
  else
    pm_message "Patch failed! Game may not run correctly."
  fi
fi

$GPTOKEYB "mkxp-z.${DEVICE_ARCH}" -c "./somaspirits.gptk" &
pm_platform_helper "$GAMEDIR/mkxp-z.${DEVICE_ARCH}" >/dev/null

# LD_LIBRARY_PATH scoped inline only — never exported globally.
# A global export causes bash/readline symbol crashes on ROCKNIX.
LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH" ./mkxp-z.${DEVICE_ARCH}

pm_finish
