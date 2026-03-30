#!/bin/bash

# Stardew Mod Manager - final build
# Place at: /roms2/ports/StardewModManager/StardewModManager.sh
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

set -euo pipefail

# --- Paths & names ---
CURR_TTY="/dev/tty1"
SCRIPT_NAME="StardewModManager.sh"

GAME_DIR="/roms2/ports/stardewvalley"
GAMEDATA="$GAME_DIR/gamedata"
CONTENT="$GAMEDATA/Content"
VANILLA="$GAMEDATA/Content_vanilla"
MODS="$GAMEDATA/mods"
ENABLED_FILE="$GAMEDATA/enabled_mods.txt"
LAUNCH_SCRIPT="/roms2/ports/StardewValley.sh"

DEBUG_LOG="/roms2/ports/stardewvalley/moddebug.txt"

# Ensure dirs and files exist
mkdir -p "$MODS" "$GAMEDATA"
touch "$ENABLED_FILE"
touch "$DEBUG_LOG"

# Make vanilla backup if missing
if [ ! -d "$VANILLA" ] && [ -d "$CONTENT" ]; then
    cp -r "$CONTENT" "$VANILLA" 2>/dev/null || true
fi

# --- TTY / display init ---
printf "\033c" > "$CURR_TTY"
printf "\e[?25l" > "$CURR_TTY"   # hide cursor
export TERM=linux
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

if [[ ! -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
    setfont /usr/share/consolefonts/Lat7-TerminusBold22x11.psf.gz 2>/dev/null || true
else
    setfont /usr/share/consolefonts/Lat7-Terminus16.psf 2>/dev/null || true
fi

# --- Controller / gptokeyb setup ---
GPTOKEYB="/opt/inttools/gptokeyb"
KEYMAP="/opt/inttools/keys.gptk"
GPT_PID=""

if command -v "$GPTOKEYB" &>/dev/null && [ -f "$KEYMAP" ]; then
    # ensure uinput usable
    [[ -e /dev/uinput ]] && chmod 666 /dev/uinput 2>/dev/null || true
    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"

    # kill any stale mapping for this script
    pkill -f "gptokeyb -1 $SCRIPT_NAME" >/dev/null 2>&1 || true

    # start gptokeyb mapped to this exact script name
    "$GPTOKEYB" -1 "$SCRIPT_NAME" -c "$KEYMAP" >/tmp/stardew_gkbd.log 2>&1 &
    GPT_PID=$!
else
    dialog --infobox "gptokeyb or keymap missing — controls may be disabled." 6 60 > "$CURR_TTY"
    sleep 1
fi

# Cleanup handler
cleanup() {
    printf "\033c" > "$CURR_TTY"
    printf "\e[?25h" > "$CURR_TTY"   # show cursor
    [ -n "${GPT_PID:-}" ] && kill "$GPT_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT SIGINT SIGTERM

# ---- Helper functions ----

build_menu() {
    MENU_ITEMS=()
    MOD_LIST=()
    MENU_ITEMS+=("0" "Restore Vanilla")

    idx=1
    # Build in filesystem order and store names into MOD_LIST (keeps stable indices)
    for folder in "$MODS"/*; do
        [ -d "$folder" ] || continue
        name=$(basename "$folder")
        MOD_LIST+=("$name")
        if grep -Fxq "$name" "$ENABLED_FILE" 2>/dev/null; then
            MENU_ITEMS+=("$idx" "$name [enabled]")
        else
            MENU_ITEMS+=("$idx" "$name [disabled]")
        fi
        idx=$((idx+1))
    done

    MENU_ITEMS+=("L" "Launch Stardew Valley")
    MENU_ITEMS+=("X" "Exit")
}

apply_enabled_mods() {
    # Rebuild CONTENT from VANILLA + enabled mods in order listed in ENABLED_FILE
    # Start from vanilla
    rm -rf "$CONTENT"
    if [ -d "$VANILLA" ]; then
        cp -r "$VANILLA" "$CONTENT" 2>/dev/null || true
    else
        mkdir -p "$CONTENT"
    fi

    while IFS= read -r m; do
        [ -z "$m" ] && continue
        if [ -d "$MODS/$m/Content" ]; then
            # copy contents into content dir (overwrite existing files)
            cp -r "$MODS/$m/Content/"* "$CONTENT"/ 2>/dev/null || true
            echo "$(date +%F_%T) DEBUG: Applied mod $m to $CONTENT" >> "$DEBUG_LOG"
        else
            echo "$(date +%F_%T) DEBUG: Mod $m has no Content/ folder" >> "$DEBUG_LOG"
        fi
    done < "$ENABLED_FILE"
}

toggle_mod() {
    local mod="$1"
    touch "$ENABLED_FILE"

    if grep -Fxq "$mod" "$ENABLED_FILE" 2>/dev/null; then
        # disable: remove line
        sed -i "/^${mod}$/d" "$ENABLED_FILE" 2>/dev/null || true
        echo "$(date +%F_%T) DEBUG: Disabled $mod" >> "$DEBUG_LOG"
    else
        # enable: append
        echo "$mod" >> "$ENABLED_FILE"
        echo "$(date +%F_%T) DEBUG: Enabled $mod" >> "$DEBUG_LOG"
    fi

    # Apply list (rebuild content)
    apply_enabled_mods
}

# --- Main interactive loop (persistent) ---
while true; do
    printf "\033c" > "$CURR_TTY"
    build_menu

    CHOICE=$(dialog --output-fd 1 \
        --backtitle "Stardew Valley Mod Manager" \
        --title "Manage Mods" \
        --menu "Use D-pad to move, A to select, B to cancel" 20 60 15 \
        "${MENU_ITEMS[@]}" \
        2>"$CURR_TTY")

    # User cancelled (B) or empty
    if [ -z "$CHOICE" ]; then
        cleanup
        exit 0
    fi

    # Exit
    if [ "$CHOICE" = "X" ]; then
        cleanup
        exit 0
    fi

    # Launch game (clean exit, then exec launch script)
    if [ "$CHOICE" = "L" ]; then
        cleanup
        exec "$LAUNCH_SCRIPT"
    fi

    # Restore vanilla (clear enabled list)
    if [ "$CHOICE" = "0" ]; then
        rm -rf "$CONTENT"
        if [ -d "$VANILLA" ]; then
            cp -r "$VANILLA" "$CONTENT" 2>/dev/null || true
        fi
        : > "$ENABLED_FILE"
        dialog --msgbox "Restored vanilla (all mods disabled)." 6 50 > "$CURR_TTY"
        continue
    fi

    # Numeric selection: toggle mod
    if [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
        index=$CHOICE
        # array is 0-based; menu indices started at 1 for mods
        mod="${MOD_LIST[$((index-1))]:-}"
        if [ -z "$mod" ]; then
            dialog --msgbox "Invalid selection." 6 40 > "$CURR_TTY"
            continue
        fi

        toggle_mod "$mod"
        dialog --msgbox "Toggled: $mod" 6 50 > "$CURR_TTY"
        continue
    fi

    # fallback - loop
done