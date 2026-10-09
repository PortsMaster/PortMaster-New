#!/bin/bash
# PORTMASTER: fancypants.zip, Fancy Pants Adventures.sh

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

GAMEDIR="/$directory/ports/fancypants"
DATADIR="$GAMEDIR/gamedata"
cd "$GAMEDIR"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/ruffle_sdl" "$GAMEDIR/tools/fpa-prep" "$GAMEDIR/tools/patchscript" "$GAMEDIR/tools/run-ruffle"

# User settings: quality, aspect mode, frame rate
source "$GAMEDIR/fancypants.cfg"

# The setup patches the Steam files for Ruffle. It runs again when a port update ships new
# patches (tools/patch/version) or when the files it wrote change (a fresh copy of the game).
PATCH_VERSION="$(cat "$GAMEDIR/tools/patch/version")"
stamp() (
  export LC_ALL=C  # the same file order everywhere
  echo "$PATCH_VERSION"
  cd "$DATADIR" && for f in ClassicPack.swf ClassicPack-port.swf World?/FPAWorld?.swf \
      World4/assets/*/*.xml World4/assets/*/*.png World4/Levels/*.swf; do
    [ -e "$f" ] && echo "$f $(ls -lnL "$f" | awk '{print $5}') $(date -r "$f" +%s)"
  done
)
if [ "$(cat "$DATADIR/.port_prepared" 2>/dev/null)" != "$(stamp)" ]; then
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    rm -f "$DATADIR/.port_patched"
    export PATCHER_FILE="$GAMEDIR/tools/patchscript"
    export PATCHER_GAME="$(basename "${0%.*}")"
    export PATCHER_TIME="a few minutes"
    export controlfolder
    source "$controlfolder/utils/patcher.txt"
  else
    pm_message "This port requires the latest version of PortMaster."
    sleep 5
    pm_finish
    exit 1
  fi
  # the patch script leaves its version in .port_patched when it succeeds
  if [ "$(cat "$DATADIR/.port_patched" 2>/dev/null)" != "$PATCH_VERSION" ]; then
    pm_message "Preparing the game failed, see ports/fancypants/patchlog.txt."
    sleep 8
    pm_finish
    exit 1
  fi
  stamp > "$DATADIR/.port_prepared"
fi

mkdir -p "$GAMEDIR/saves"

# gptokeyb is unresponsive on muOS, so gptokeyb2 is used there
if [ "$CFW_NAME" = "muOS" ] && [ -n "$GPTOKEYB2" ]; then
  $GPTOKEYB2 "ruffle_sdl" -c "$GAMEDIR/fancypants.gptk" &
else
  $GPTOKEYB "ruffle_sdl" -c "$GAMEDIR/fancypants.gptk" &
fi
pm_platform_helper "$GAMEDIR/ruffle_sdl"

# ruffle_sdl: Ruffle on the firmware's own SDL2 and GLES 3 (no Weston or X11 needed)
# run-ruffle restarts Ruffle when the game switches worlds, so only one world is in memory
"$GAMEDIR/tools/run-ruffle" "$GAMEDIR/ruffle_sdl" --stage-scale movie --quality "$FPA_QUALITY" \
  -Paspect="$FPA_ASPECT" -Pworldfps="$FPA_WORLD_FPS" --save-directory "$GAMEDIR/saves" \
  "$DATADIR/ClassicPack-port.swf"

# Clean up after ourselves
pm_finish
