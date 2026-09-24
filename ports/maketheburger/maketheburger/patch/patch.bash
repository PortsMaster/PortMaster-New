#!/bin/bash

set -e

GAMEDIR="$(cd "$(dirname "$0")/.." && pwd)"
PATCHDIR="$GAMEDIR/patch"
GAMEDATA="$GAMEDIR/gamedata"
STATE="$GAMEDATA/.patch_state"
PATCHLOG="$GAMEDIR/patchlog.txt"

if [ -z "$controlfolder" ]; then
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
fi

exec > >(tee -a "$PATCHLOG") 2>&1
> "$PATCHLOG" 

mkdir -p "$GAMEDATA"

V_XDELTA="1"        
V_RELOCATE="1"       
V_REPACK="2"         

step_done() {
    local marker="$STATE/$1"
    [ -f "$marker" ] && [ "$(cat "$marker")" = "$2" ]
}

mark_done() {
    mkdir -p "$STATE"
    echo "$2" > "$STATE/$1"
}

fail() {
    echo "FATAL: $1"
    exit 1
}

echo "=== Make The Burger Patcher ==="
echo ""


if [ ! -f "$GAMEDATA/data.win" ]; then
    for file in "$GAMEDIR"/data.win "$GAMEDIR"/assets/data.win; do
        if [ -f "$file" ]; then
            mv -fv "$file" "$GAMEDATA/data.win"
            break
        fi
    done
fi

[ -f "$GAMEDATA/data.win" ] || fail "data.win not found. Place your own legitimate copy of Make The Burger's data.win (from Steam) into gamedata/."

echo "Game file found."

if step_done "xdelta" "$V_XDELTA"; then
    echo "Step 1: Apply patch... already done. OK"
else
    echo "Step 1: Applying compatibility patch..."

    if [ -f "$GAMEDATA/data.win.orig" ]; then

        cp -f "$GAMEDATA/data.win.orig" "$GAMEDATA/data.win"
    else
        cp "$GAMEDATA/data.win" "$GAMEDATA/data.win.orig"
    fi

    XDELTA_BIN="$controlfolder/xdelta3"
    [ -f "$XDELTA_BIN" ] || fail "xdelta3 not found in $controlfolder. Try updating PortMaster."

    [ -f "$PATCHDIR/maketheburger.xdelta" ] || fail "maketheburger.xdelta not found in patch/"

    error=$("$XDELTA_BIN" -d -f -s "$GAMEDATA/data.win.orig" "$PATCHDIR/maketheburger.xdelta" "$GAMEDATA/data.win.patched" 2>&1)
    if [ $? -ne 0 ]; then
        fail "Failed to apply patch: $error -- is gamedata/data.win the correct, unmodified Steam build (depot 1358612, manifest 7027764266055537486)?"
    fi

    mv -f "$GAMEDATA/data.win.patched" "$GAMEDATA/data.win"

    mark_done "xdelta" "$V_XDELTA"
    echo "Step 1: Apply patch... OK"
fi

if step_done "relocate" "$V_RELOCATE"; then
    echo "Step 2: Relocate... already done. OK"
else
    echo "Step 2: Relocating game data..."

    mkdir -p "$GAMEDATA/assets"
    cp -f "$GAMEDATA/data.win" "$GAMEDATA/assets/game.droid"

    mark_done "relocate" "$V_RELOCATE"
    echo "Step 2: Relocate... OK"
fi

if step_done "repack" "$V_REPACK"; then
    echo "Step 3: Repack .port... already done. OK"
else
    echo "Step 3: Repacking .port file..."

    cd "$GAMEDIR"

    rm -rf "$GAMEDIR/assets"
    mkdir -p "$GAMEDIR/assets"
    cp -f "$GAMEDATA/assets/game.droid" "$GAMEDIR/assets/game.droid"
    [ -f "$GAMEDIR/options.ini" ] && cp -f "$GAMEDIR/options.ini" "$GAMEDIR/assets/options.ini"

    if [ -f "$GAMEDATA/splash.png" ]; then
        cp -f "$GAMEDATA/splash.png" "$GAMEDIR/assets/splash.png"
        echo "Custom splash.png found, bundling it into the .port."
    fi

    zip -r -0 -q "$GAMEDIR/maketheburger.port" ./assets/
    rm -rf "$GAMEDIR/assets"

    mark_done "repack" "$V_REPACK"
    echo "Step 3: Repack .port... OK"
fi

echo "1" > "$GAMEDATA/.patched_complete"

echo ""
echo "=== Patching complete ==="
