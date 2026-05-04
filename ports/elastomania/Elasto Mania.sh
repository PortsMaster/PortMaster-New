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

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/elastomania"
cd "$GAMEDIR" || exit 1

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Extract bundled level pack on first run (kept as 7z to keep the repo light).
if [ ! -d "$GAMEDIR/lev" ] && [ -f "$GAMEDIR/lev.7z" ]; then
    pm_message "First run: extracting levels ..."
    "$controlfolder/7zzs.$DEVICE_ARCH" x "$GAMEDIR/lev.7z" -o"$GAMEDIR" -y && rm "$GAMEDIR/lev.7z"
fi

# Make PortMaster's gamepad mapping available to the launcher binary too,
# so SDL_GameController recognises the device on every supported CFW.
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# --- Layout selection ---
# Skip launcher entirely if user pressed SELECT/START to keep+lock previously.
# (delete layout.conf.lock on the SD card to re-enable the launcher)
if [ ! -f "$GAMEDIR/layout.conf.lock" ] && [ -x "$GAMEDIR/layout_select" ]; then
    chmod +x "$GAMEDIR/layout_select" 2>/dev/null
    HAS_PREV=0
    [ -f "$GAMEDIR/layout.conf" ] && HAS_PREV=1
    "$GAMEDIR/layout_select" "$GAMEDIR/layout.conf" "$HAS_PREV"
fi

LAYOUT=$(cat "$GAMEDIR/layout.conf" 2>/dev/null | tr -d '[:space:]')
LAYOUT="${LAYOUT:-1}"

if [ "$LAYOUT" = "custom" ] && [ -f "$GAMEDIR/layouts/custom.gptk" ]; then
    cp "$GAMEDIR/layouts/custom.gptk" "$GAMEDIR/elastomania.gptk"
elif [ -f "$GAMEDIR/layouts/layout${LAYOUT}.gptk" ]; then
    cp "$GAMEDIR/layouts/layout${LAYOUT}.gptk" "$GAMEDIR/elastomania.gptk"
elif [ -f "$GAMEDIR/layouts/layout1.gptk" ]; then
    cp "$GAMEDIR/layouts/layout1.gptk" "$GAMEDIR/elastomania.gptk"
fi

# --- Copy game files from gamefiles/ on first run ---
GFDIR="$GAMEDIR/gamefiles"

# Find and copy elma.res (case-insensitive)
if [ ! -f "$GAMEDIR/elma.res" ]; then
  for f in "$GFDIR"/[Ee][Ll][Mm][Aa].[Rr][Ee][Ss]; do
    [ -f "$f" ] && cp "$f" "$GAMEDIR/elma.res" && break
  done
fi

# Find and copy default.lgr (case-insensitive, flat or in Lgr/ subfolder)
if [ ! -f "$GAMEDIR/lgr/default.lgr" ]; then
  for f in "$GFDIR"/[Dd][Ee][Ff][Aa][Uu][Ll][Tt].[Ll][Gg][Rr] \
           "$GFDIR"/[Ll][Gg][Rr]/[Dd][Ee][Ff][Aa][Uu][Ll][Tt].[Ll][Gg][Rr] \
           "$GFDIR"/orig.lgr; do
    [ -f "$f" ] && cp "$f" "$GAMEDIR/lgr/default.lgr" && break
  done
fi

# Copy optional state.dat
if [ ! -f "$GAMEDIR/state.dat" ]; then
  for f in "$GFDIR"/[Ss][Tt][Aa][Tt][Ee].[Dd][Aa][Tt]; do
    [ -f "$f" ] && cp "$f" "$GAMEDIR/state.dat" && break
  done
fi

# Copy optional .lev files
for f in "$GFDIR"/*.[Ll][Ee][Vv] "$GFDIR"/[Ll][Ee][Vv]/*.[Ll][Ee][Vv]; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [ -f "$GAMEDIR/lev/$base" ] || cp "$f" "$GAMEDIR/lev/$base"
done

# --- Check required files ---
if [ ! -f "$GAMEDIR/elma.res" ] || [ ! -f "$GAMEDIR/lgr/default.lgr" ]; then
  echo "ERROR: Game files missing!"
  echo "Copy Elma.res and Default.lgr into:"
  echo "  $GFDIR/"
  echo "See gamefiles/README.txt for details."
  sleep 5
  pm_finish
  exit 1
fi

$ESUDO chmod 666 /dev/uinput 2>/dev/null

$GPTOKEYB "elma" -c "$GAMEDIR/elastomania.gptk" &
pm_platform_helper "$GAMEDIR/elma"
./elma 2>&1

pm_finish
