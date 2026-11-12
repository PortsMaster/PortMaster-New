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

chmod 666 /dev/uinput 2>/dev/null

patch_failure() {
    echo "Patching process failed."
    mv -f "$LOGFILE" "$LOGERR"
    exit 1
}

install_complete() {
    touch "$GAMEDIR/install_completed"
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo "Script completed in $DURATION seconds"
    echo "Installation completed successfully!"
    echo "-----------------------------"
    echo "Process finished at: $(date)"
}


# apply_xdelta <file name (.dll or .exe)> <xdelta file>
apply_xdelta() {
    target="$GAME_DIR/$1"

    # Split into base name and extension (e.g. Game + dll / exe)
    ext="${1##*.}"
    base="${1%.*}"
    patched="$GAME_DIR/${base}.patched.${ext}"

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
    install_file "$PATCH_DIR/ChaiFoxes.FMODAudio.Desktop.dll.config" "$GAME_DIR/ChaiFoxes.FMODAudio.Desktop.dll.config"
    install_file "$PATCH_DIR/MonoGame.Framework.dll.config" "$GAME_DIR/MonoGame.Framework.dll.config"
    install_file "$PATCH_DIR/OverdriveFmodHelper.dll" "$GAME_DIR/OverdriveFmodHelper.dll"
}

patch_steam() {
    echo "Patching Steam version"
    apply_xdelta "80s_Overdrive.exe" "$PATCH_DIR/exe.xdelta"
    apply_xdelta "ChaiFoxes.FMODAudio.Desktop.dll" "$PATCH_DIR/chaifoxes.xdelta"
    install_common_files
    install_complete
}

patch_steam