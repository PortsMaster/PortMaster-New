#!/bin/bash

# ==============================
# User toggles
# ==============================
SHOW_CONSOLE=0   # 1 = launch with -console, 0 = no console
# ==============================

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# ---- PortMaster boilerplate ----
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
source "$controlfolder/tasksetter"
source "$controlfolder/device_info.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# ---- TTY setup so we can show errors ----
CUR_TTY=/dev/tty0
$ESUDO chmod 666 "$CUR_TTY" 2>/dev/null
export TERM=linux
printf "\033c" > "$CUR_TTY"

# ---- Paths ----
PORTDIR="/$directory/ports"
CSPORTDIR="${PORTDIR}/counter-strike"
HLPORTDIR="${PORTDIR}/Half-Life"

DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

ENGINE="${CSPORTDIR}/xash3d.${DEVICE_ARCH}"
LIBSDIR="${CSPORTDIR}/libs.${DEVICE_ARCH}"

CSTRIKEDIR="${CSPORTDIR}/cstrike"
MY_VALVE="${CSPORTDIR}/valve"     # local valve folder (standalone)
HL_VALVE="${HLPORTDIR}/valve"     # Half-Life valve folder (shared)

USE_VALVE=""
VALVE_MOUNTED=0

# ---- Debug Log (overwrites every run) ----
SESSION_LOG="${CSPORTDIR}/session.log"
mkdir -p "$CSPORTDIR" >/dev/null 2>&1
echo "=== Counter-Strike Launcher Session Log ===" > "$SESSION_LOG"
echo "Timestamp: $(date)" >> "$SESSION_LOG"
echo "" >> "$SESSION_LOG"

# Redirect ALL stdout & stderr into debug log.
# (TTY messages still appear via manual echo > /dev/tty0)
exec >>"$SESSION_LOG" 2>&1

echo "[Launcher] Starting..."
echo "[Paths]"
echo "  PORTDIR      = $PORTDIR"
echo "  CSPORTDIR    = $CSPORTDIR"
echo "  HLPORTDIR    = $HLPORTDIR"
echo "  ENGINE       = $ENGINE"
echo "  LIBSDIR      = $LIBSDIR"
echo "  CSTRIKEDIR   = $CSTRIKEDIR"
echo "  MY_VALVE     = $MY_VALVE"
echo "  HL_VALVE     = $HL_VALVE"
echo "  DEVICE_ARCH  = $DEVICE_ARCH"
echo ""

# ---- Helper for clean failures ----
fail() {
  local msg="$1"
  echo "[ERROR] $msg"
  echo -e "$msg" > "$CUR_TTY"
  sleep 4
  printf "\033c" > "$CUR_TTY"
  cleanup
  exit 1
}

# ---- Sanity checks ----
[ -f "$ENGINE" ] || fail "Missing Xash3D engine binary.\nExpected: $ENGINE"

[ -d "$LIBSDIR" ] || fail "Missing libs directory.\nExpected: $LIBSDIR"

[ -f "${CSTRIKEDIR}/liblist.gam" ] || fail "Missing Counter-Strike data.\nExpected: $CSTRIKEDIR"

echo "[Sanity] Engine, libs, cstrike validated OK."
echo ""

# ---- Detect valve automatically ----
echo "[Valve Detection]"

if [ -d "$MY_VALVE" ] && [ -f "$MY_VALVE/gfx.wad" ]; then
  echo "  Using LOCAL valve folder."
  USE_VALVE="$MY_VALVE"

elif [ -d "$HL_VALVE" ] && [ -f "$HL_VALVE/gfx.wad" ]; then
  echo "  Using Half-Life valve via bind mount."
  USE_VALVE="$MY_VALVE"

  $ESUDO mkdir -p "$MY_VALVE"

  if command -v mountpoint >/dev/null 2>&1 && mountpoint -q "$MY_VALVE"; then
    echo "  Found old mount, cleaning..."
    $ESUDO umount "$MY_VALVE" 2>/dev/null || $ESUDO umount -l "$MY_VALVE"
  fi

  $ESUDO mount --bind "$HL_VALVE" "$MY_VALVE"
  if [ $? -ne 0 ]; then
    fail "Failed to bind-mount Half-Life valve folder."
  fi
  VALVE_MOUNTED=1
  echo "  Bind mount OK."

else
  fail "Half-Life 'valve' data missing or incomplete.\nCopy 'valve' either to:\n  $MY_VALVE\nor:\n  $HL_VALVE"
fi

echo ""
echo "[Valve] Using valve dir: $USE_VALVE"
echo ""

# ---- Move into port dir ----
cd "$CSPORTDIR" || fail "Failed to cd into $CSPORTDIR"

# ---- Cleanup on exit ----
cleanup() {
  echo "[Cleanup] Running cleanup..."
  if [ "$VALVE_MOUNTED" -eq 1 ]; then
    echo "[Cleanup] Unmounting valve..."
    $ESUDO umount "$MY_VALVE" 2>/dev/null || $ESUDO umount -l "$MY_VALVE"
  fi
  $ESUDO kill -9 "$(pidof gptokeyb)" 2>/dev/null
  unset LD_LIBRARY_PATH
  unset SDL_GAMECONTROLLERCONFIG
  unset XASH3D_BASEDIR
  echo "[Cleanup] Done."
}

trap cleanup EXIT

# ---- Input + environment ----
$ESUDO chmod 666 /dev/tty1 /dev/uinput 2>/dev/null

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XASH3D_BASEDIR="$CSPORTDIR"

export LD_LIBRARY_PATH="${LIBSDIR}:$LD_LIBRARY_PATH:/usr/lib32:${USE_VALVE}/dlls:${USE_VALVE}/cl_dlls:${CSTRIKEDIR}/dlls:${CSTRIKEDIR}/cl_dlls"

# ---- Build engine args (safer than string building) ----
ENGINE_ARGS=(
  -ref gles2
  -fullscreen
  -game cstrike
)

if [ "${SHOW_CONSOLE:-0}" -eq 1 ]; then
  ENGINE_ARGS+=( -console )
  echo "[Launch] SHOW_CONSOLE=1 (adding -console)"
else
  echo "[Launch] SHOW_CONSOLE=0 (no -console)"
fi

echo "[Launch] Starting Xash3D engine..."
echo ""

$GPTOKEYB "xash3d.${DEVICE_ARCH}" &

"$ENGINE" "${ENGINE_ARGS[@]}"

ENGINE_EXIT=$?
echo ""
echo "[Launcher] Engine exited with code: ${ENGINE_EXIT}"
