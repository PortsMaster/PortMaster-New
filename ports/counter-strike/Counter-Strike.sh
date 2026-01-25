#!/bin/bash

# ==============================
# User toggles
# ==============================
SHOW_CONSOLE=0   # 1 = launch with -console, 0 = no console
# ==============================

# ---- PortMaster ----
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

get_controls

# ---- Cleanup on exit ----
cleanup() {
  echo "[Cleanup] Running cleanup..."
  if [ "${VALVE_MOUNTED:-0}" -eq 1 ]; then
    echo "[Cleanup] Unmounting valve..."
    $ESUDO umount "$MY_VALVE" 2>/dev/null || $ESUDO umount -l "$MY_VALVE" 2>/dev/null || true
  fi

  unset XASH3D_BASEDIR

  if [ "${PM_STARTED:-0}" -eq 1 ]; then
    pm_finish || true
  fi

  echo "[Cleanup] Done."
}

trap cleanup EXIT

pm_start
PM_STARTED=1

# ---- Helper for clean failures ----
fail() {
  local msg="$1"
  echo "[ERROR] $msg"
  pm_message "$msg" || true
  exit 1
}

# ---- Sanity checks ----
[ -f "$ENGINE" ] || fail "Missing Xash3D engine binary.
Expected: $ENGINE"

[ -d "$LIBSDIR" ] || fail "Missing libs directory.
Expected: $LIBSDIR"

[ -f "${CSTRIKEDIR}/liblist.gam" ] || fail "Missing Counter-Strike data.
Expected: $CSTRIKEDIR"

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
  fail "Half-Life 'valve' data missing or incomplete.
Copy 'valve' either to:
  $MY_VALVE
or:
  $HL_VALVE"
fi

echo ""
echo "[Valve] Using valve dir: $USE_VALVE"
echo ""

# ---- Move into port dir ----
cd "$CSPORTDIR" || fail "Failed to cd into $CSPORTDIR"

# ---- Input + environment ----
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
