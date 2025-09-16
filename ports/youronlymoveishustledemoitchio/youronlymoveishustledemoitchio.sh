#!/bin/bash
# PORTMASTER: youronlymoveishustledemoitchio.zip, youronlymoveishustledemoitchio.sh

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

GAMEDIR=/$directory/ports/youronlymoveishustledemoitchio/
CONFDIR="$GAMEDIR/conf/"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"
cd "$GAMEDIR"

# Comprobar si existe la biblioteca
LIBRARY_PATH="lib/libturn_based_fighting_game.so"
if [ -f "$LIBRARY_PATH" ]; then
    ls -la "$LIBRARY_PATH"
    file "$LIBRARY_PATH"

    [ ! -x "$LIBRARY_PATH" ] && chmod +x "$LIBRARY_PATH"

    command -v ldd >/dev/null 2>&1 && ldd "$LIBRARY_PATH" 2>/dev/null

    CURRENT_ARCH=$(uname -m)
    FILE_INFO=$(file "$LIBRARY_PATH")
    [[ "$CURRENT_ARCH" == "aarch64" ]] && echo "$FILE_INFO" | grep -q "aarch64\|ARM aarch64"
else
    ls -la lib/ 2>/dev/null
fi

# Comprobar archivo .gdnlib
GDNLIB_FILES=$(find . -name "*.gdnlib" 2>/dev/null)
if [ -n "$GDNLIB_FILES" ]; then
    echo "Archivos .gdnlib encontrados:"
    for gdnlib in $GDNLIB_FILES; do
        echo "📄 $gdnlib"
        echo "Contenido relevante:"
        grep -E "(entry/|dependency/)" "$gdnlib" | head -10
    done
else
    echo "⚠️  No se encontraron archivos .gdnlib"
fi

echo "=== FIN DEL DIAGNÓSTICO ==="

if [ "${ANALOG_STICKS}" -lt 2 ]; then
    rm -f youronlymoveishustledemoitchio.gptk
    cp yomih_one_stick.gptk youronlymoveishustledemoitchio.gptk
fi

runtime="frt_3.5.2"
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_message "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info."
    sleep 5
    exit 1
  fi
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${runtime}.squashfs"
fi

export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

bind_directories ~/godot "$GAMEDIR/conf/"

godot_dir="$HOME/godot"
godot_file="$controlfolder/libs/${runtime}.squashfs"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_file" || true
$ESUDO mount "$godot_file" "$godot_dir"
PATH="$godot_dir:$PATH"

export FRT_NO_EXIT_SHORTCUTS=FRT_NO_EXIT_SHORTCUTS 

$GPTOKEYB "$runtime" -c "./youronlymoveishustledemoitchio.gptk" &
pm_platform_helper "$godot_dir/$runtime"
"$runtime" $GODOT_OPTS --main-pack "gamedata/youronlymoveishustledemoitchio.pck"

[[ "$PM_CAN_MOUNT" != "N" ]] && $ESUDO umount "$godot_dir"
pm_finish
