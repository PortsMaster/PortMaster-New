#!/bin/bash
[ -n "$GAMEDIR" ] || { echo "GAMEDIR is not set" >&2; exit 1; }

LOGFILE="$GAMEDIR/patchlog.txt"
LOGERR="$GAMEDIR/patchlog_error.txt"
START_TIME=$(date +%s)

exec > >(tee -a "$LOGFILE") 2>&1
echo "GAMEDIR is set to: $GAMEDIR"

export PATH="$controlfolder:$PATH"
export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/config/emuelec/lib:/usr/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GAME_DIR="$GAMEDIR/gamedata"
export PATCH_DIR="$GAMEDIR/patch"
TMP_DIR="$GAME_DIR/.extract_tmp"

chmod 666 /dev/uinput 2>/dev/null

# Only ever remove our own temp folder
trap 'rm -rf "$TMP_DIR"' 0

patch_failure() {
    echo "Patching process failed."
    mv -f "$LOGFILE" "$LOGERR"
    exit 1
}

install_complete() {
    touch "install_completed"
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo "Script completed in $DURATION seconds"
    echo "Installation completed successfully!"
    echo "-----------------------------"
    echo "Process finished at: $(date)"
}

# apply_xdelta <dll file name> <xdelta file>
apply_xdelta() {
    target="$GAME_DIR/$1"
    patched="$GAME_DIR/${1%.dll}.patched.dll"

    echo "Patching $1 ..."

    # Always patch from the pristine original so re-runs work
    if [ ! -f "$target.orig" ]; then
        cp "$target" "$target.orig" || patch_failure
    fi

    rm -f "$patched"
    if ! "$controlfolder/xdelta3" -d -s "$target.orig" "$2" "$patched"; then
        echo "Error: xdelta3 patch failed. Wrong game version?"
        rm -f "$patched"
        patch_failure
    fi
    mv -f "$patched" "$target" || patch_failure
    echo "$1 patched successfully..."
}

# install_file <source> <destination>: copy over, keeping a one-time .orig backup
install_file() {
    if [ -f "$2" ] && [ ! -f "$2.orig" ]; then
        cp "$2" "$2.orig" || patch_failure
    fi
    cp -f "$1" "$2" || patch_failure
}

install_common_files() {
    install_file "$PATCH_DIR/MonoGame.Framework.dll" "$GAME_DIR/MonoGame.Framework.dll"
    install_file "$PATCH_DIR/Steamworks.NET.dll" "$GAME_DIR/Steamworks.NET.dll"
    install_file "$PATCH_DIR/Steamworks.NET.dll.config" "$GAME_DIR/Steamworks.NET.dll.config"
}

extract_gog_installer() {
    SEVENZ="$controlfolder/7zzs.${DEVICE_ARCH}"
    chmod +x "$SEVENZ" 2>/dev/null
    archive="$GAME_DIR/jetboard_joust.gzip"

    # $installer may already be the .gzip left behind by a failed run
    if [ "$installer" != "$archive" ]; then
        mv -f "$installer" "$archive" || patch_failure
    fi

    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR" || patch_failure

    if "$SEVENZ" x -y "$archive" "-i!data/noarch/game/*" -o"$TMP_DIR" \
       && [ -d "$TMP_DIR/data/noarch/game" ]; then
        cp -a "$TMP_DIR/data/noarch/game/." "$GAME_DIR/" || patch_failure
        rm -rf "$TMP_DIR"
        rm -f "$archive"
    else
        echo "Extraction failed, keeping $archive so the next launch can retry"
        patch_failure
    fi
}

patch_steam() {
    echo "Patching Steam version"
    apply_xdelta "JetboardJoust.Cpda.Steam.dll" "$PATCH_DIR/steam/steam.xdelta"
    install_file "$PATCH_DIR/steam/JetboardJoust.Cpda.Steam.deps.json" "$GAME_DIR/JetboardJoust.Cpda.Steam.deps.json"
    install_file "$PATCH_DIR/steam/JetboardJoust.Cpda.Steam.runtimeconfig.json" "$GAME_DIR/JetboardJoust.Cpda.Steam.runtimeconfig.json"
    install_common_files
    install_complete
}

patch_gog() {
    echo "Patching GOG version"
    if [ -n "$installer" ]; then
        extract_gog_installer
    fi
    apply_xdelta "JetboardJoust.Cpda.dll" "$PATCH_DIR/gog/gog.xdelta"
    install_file "$PATCH_DIR/gog/JetboardJoust.Cpda.deps.json" "$GAME_DIR/JetboardJoust.Cpda.deps.json"
    install_file "$PATCH_DIR/gog/JetboardJoust.Cpda.runtimeconfig.json" "$GAME_DIR/JetboardJoust.Cpda.runtimeconfig.json"
    install_common_files
    install_complete
}

# --- Detect version (must happen before the installer is consumed) ---
installer=""
for f in "$GAME_DIR"/jetboard_joust*.sh "$GAME_DIR/jetboard_joust.gzip"; do
    if [ -f "$f" ]; then
        installer="$f"
        break
    fi
done

version=""
if [ -f "$GAME_DIR/JetboardJoust.Cpda.Steam.dll" ]; then
    version="steam"
elif [ -f "$GAME_DIR/JetboardJoust.Cpda.dll" ] || [ -n "$installer" ]; then
    version="gog"
fi

if [ -z "$version" ]; then
    echo "No Steam or GOG game files found in $GAME_DIR"
    patch_failure
fi

if [ "$version" = "steam" ]; then
    patch_steam
else
    patch_gog
fi