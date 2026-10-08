#!/bin/bash
#
# wiliwili (Bilibili client) - ROCKNIX port launch script
#
# ROCKNIX port by 南宫镜.  Follows the ROCKNIX/PortMaster conventions
# (control.txt + get_controls + $GPTOKEYB + pm_finish) and still runs standalone
# when PortMaster is not installed.
#
# ROCKNIX runs EmulationStation inside a Wayland compositor (sway/weston) and
# configures SDL through /etc/profile.d (SDL_VIDEODRIVER=wayland,
# WAYLAND_DISPLAY=wayland-1, XDG_RUNTIME_DIR=/var/run/0-runtime-dir).  Those
# values are repeated here so the port behaves the same however it was started.
#

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# ---------------------------------------------------------------- control folder
controlfolder=""
for c in "/opt/system/Tools/PortMaster" \
         "/opt/tools/PortMaster" \
         "/storage/roms/ports/PortMaster" \
         "/roms/ports/PortMaster" \
         "$XDG_DATA_HOME/PortMaster" \
         "/mnt/sdcard/Roms/ports/PortMaster" \
         "/mnt/sdcard/PortMaster"; do
    if [ -d "$c" ]; then
        controlfolder="$c"
        break
    fi
done

if [ -n "$controlfolder" ] && [ -f "$controlfolder/control.txt" ]; then
    source "$controlfolder/control.txt"
    [ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
    get_controls
    DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
    if [ -n "$directory" ] && [ -d "/$directory/ports/wiliwili" ]; then
        GAMEDIR="/$directory/ports/wiliwili"
    else
        GAMEDIR="$(cd "$(dirname "$0")" && pwd)/wiliwili"
    fi
else
    # standalone mode (PortMaster not installed)
    DEVICE_ARCH="${DEVICE_ARCH:-$(uname -m)}"
    GAMEDIR="$(cd "$(dirname "$0")" && pwd)/wiliwili"
    ESUDO=""
    GPTOKEYB=""
fi

CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR/wiliwili" "$CONFDIR/cache"

cd "$GAMEDIR" || exit 1

# ------------------------------------------------------------------ logging
> "$GAMEDIR/log.txt" 2>/dev/null && exec > >(tee "$GAMEDIR/log.txt") 2>&1
echo "=== wiliwili $(date) | CFW=${CFW_NAME:-standalone} arch=${DEVICE_ARCH} ==="

# ---------------------------------------------------------------- ui scale
# This port carries a 480p (640x480) UI preset in place of the stock 544p one,
# so migrate a config file written by an earlier version of the port.
CFG="$CONFDIR/wiliwili/wiliwili_config.json"
if [ -f "$CFG" ] && grep -q '"544p"' "$CFG" 2>/dev/null; then
    sed -i 's/"544p"/"480p"/' "$CFG" && echo "ui scale: migrated 544p -> 480p"
fi

# --------------------------------------------------------------- user data
# keep config/cookies/cache inside the port folder
export XDG_DATA_HOME="$CONFDIR"
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_CACHE_HOME="$CONFDIR/cache"
if command -v bind_directories > /dev/null 2>&1; then
    bind_directories "$HOME/.config/wiliwili" "$CONFDIR/wiliwili"
fi

# ------------------------------------------------------------ bundled libs
# libs.aarch64 carries the mpv/FFmpeg stack that ROCKNIX no longer ships
# (ROCKNIX moved to FFmpeg 9, the bundled mpv needs FFmpeg 6).  Compositor,
# graphics, audio and system libraries are deliberately NOT bundled so that the
# device versions, which match the driver stack, are used instead.
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/libs:$LD_LIBRARY_PATH"

# -------------------------------------------------------------- controller
# wiliwili reads gamepads through SDL2 itself; the controller database from
# control.txt only adds the correct GUID mappings.
[ -n "$sdl_controllerconfig" ] && export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# ------------------------------------------------------------- https certs
if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
elif [ -f "$GAMEDIR/ca-certificates.crt" ]; then
    export SSL_CERT_FILE="$GAMEDIR/ca-certificates.crt"
    export CURL_CA_BUNDLE="$GAMEDIR/ca-certificates.crt"
fi

# ------------------------------------------------------- compositor / video
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/var/run/0-runtime-dir}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Stable Wayland app-id equal to the binary name, so ROCKNIX's
# portmaster_sway_fullscreen.sh can find and fullscreen the window.
export SDL_VIDEO_WAYLAND_WMCLASS="${SDL_VIDEO_WAYLAND_WMCLASS:-wiliwili.${DEVICE_ARCH}}"

# The video driver can be pinned by creating conf/videodriver; otherwise the
# ROCKNIX default (wayland) is used.
VID_DRIVER=""
if [ -f "$CONFDIR/videodriver" ]; then
    VID_DRIVER="$(tr -d ' \t\r\n' < "$CONFDIR/videodriver")"
fi
VID_DRIVER="${VID_DRIVER:-${SDL_VIDEODRIVER:-wayland}}"

APP="wiliwili.${DEVICE_ARCH}"
[ -f "$APP" ] || APP="wiliwili"
chmod +x "$APP" 2>/dev/null

# --------------------------------------------------------------- diagnostics
echo "--- environment ---"
echo "SDL_VIDEODRIVER   = ${SDL_VIDEODRIVER:-<unset>}"
echo "WAYLAND_DISPLAY   = ${WAYLAND_DISPLAY:-<unset>}"
echo "XDG_RUNTIME_DIR   = ${XDG_RUNTIME_DIR:-<unset>}"
echo "UI_SERVICE        = ${UI_SERVICE:-<unset>}"
echo "requested driver  = ${VID_DRIVER}"
echo "bundled libraries = $(ls "$GAMEDIR/libs.${DEVICE_ARCH}" 2>/dev/null | wc -l)"
echo "glibc             = $(getconf GNU_LIBC_VERSION 2>/dev/null)"
echo "drm devices:"; ls -l /dev/dri 2>&1 | sed 's/^/  /'
echo "wayland sockets:"; ls -l "$XDG_RUNTIME_DIR"/wayland-* 2>&1 | sed 's/^/  /'

# ------------------------------------------------------------------- run
if [ -n "$GPTOKEYB" ]; then
    # no mapping file on purpose: SDL already handles the gamepad, gptokeyb only
    # provides the "exit" hotkey (Select+Start / device equivalent) and a clean kill
    $GPTOKEYB "$APP" &
fi
command -v pm_platform_helper > /dev/null 2>&1 && pm_platform_helper "$GAMEDIR/$APP"

# Try the requested driver first, then KMS/DRM (used when no compositor is
# running), then the headless driver.  A quick non-zero exit means the driver
# could not create a window, so the next one is tried.
DRIVERS="$VID_DRIVER"
for d in kmsdrm offscreen; do
    case " $DRIVERS " in
        *" $d "*) ;;
        *) DRIVERS="$DRIVERS $d" ;;
    esac
done

RC=1
ATTEMPT=0
WAYLAND_TRIES=0
for DRV in $DRIVERS; do
    ATTEMPT=$((ATTEMPT + 1))
    EXTRA_ENV=""
    if [ "$DRV" = "wayland" ]; then
        WAYLAND_TRIES=$((WAYLAND_TRIES + 1))
        # on the second wayland attempt dump the whole Wayland protocol trace,
        # which makes a failed window creation self-explanatory
        [ "$WAYLAND_TRIES" -gt 1 ] && EXTRA_ENV="WAYLAND_DEBUG=1"
    fi
    echo "=== attempt ${ATTEMPT}: SDL_VIDEODRIVER=${DRV} ${EXTRA_ENV} ==="
    START=$(date +%s)
    if [ -n "$EXTRA_ENV" ]; then
        # capture the whole Wayland protocol trace, it explains a failed window
        # creation; keep log.txt readable by showing only the head and the tail
        TRACE="$GAMEDIR/log-${DRV}-trace.txt"
        env SDL_VIDEODRIVER="$DRV" $EXTRA_ENV ./"$APP" > "$TRACE" 2>&1
        RC=$?
        echo "--- first 40 lines of ${TRACE##*/} ---"
        head -40 "$TRACE"
        echo "--- last 40 lines of ${TRACE##*/} ---"
        tail -40 "$TRACE"
        echo "--- end of trace ---"
    else
        SDL_VIDEODRIVER="$DRV" ./"$APP"
        RC=$?
    fi
    ELAPSED=$(( $(date +%s) - START ))
    echo "=== attempt ${ATTEMPT} (${DRV}) exited with ${RC} after ${ELAPSED}s ==="
    [ $RC -eq 0 ] && break
    # a session that lasted a while was a real run, not a driver setup failure
    [ $ELAPSED -ge 20 ] && break
done

echo "wiliwili finished with code ${RC}"

if command -v pm_finish > /dev/null 2>&1; then
    pm_finish
else
    pkill -f "gptokeyb" 2>/dev/null
    systemctl restart oga_events 2>/dev/null || true
fi
