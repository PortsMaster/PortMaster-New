#!/bin/bash
# 80's Overdrive - PortMaster launcher

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
if [ -d /opt/system/Tools/PortMaster ]; then
    controlfolder=/opt/system/Tools/PortMaster
elif [ -d /opt/tools/PortMaster ]; then
    controlfolder=/opt/tools/PortMaster
elif [ -d "$XDG_DATA_HOME/PortMaster" ]; then
    controlfolder="$XDG_DATA_HOME/PortMaster"
else
    controlfolder=/roms/ports/PortMaster
fi

source "$controlfolder/control.txt"
source "$controlfolder/tasksetter"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/80soverdrive"
GAME="$GAMEDIR/gamedata"
MONODIR="$HOME/mono"
MONOFILE="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
GLDIR="$GAMEDIR/gl4es"
LIBDIR="$GAMEDIR/libs"

cd "$GAME"
exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Patch game
if [ ! -f "$GAMEDIR/install_completed" ]; then
    if [ ! -f "$controlfolder/utils/patcher.txt" ]; then
        pm_message 'Please update PortMaster before installing this port.'
        pm_finish
        exit 1
    fi
    chmod +x "$GAMEDIR/patch/patchscript.bash"
    export controlfolder ESUDO DEVICE_ARCH GAMEDIR
    export PATCHER_FILE="$GAMEDIR/patch/patchscript.bash"
    export PATCHER_GAME="80's Overdrive"
    export PATCHER_TIME='a short while...'
    source "$controlfolder/utils/patcher.txt"
fi

if [ ! -f "$GAMEDIR/install_completed" ] || [ ! -f "$GAME/80s_Overdrive.exe" ]; then
    pm_message 'Missing game files or first-run patch failed. Check the patch or patch error log.'
    pm_finish
    exit 1
fi

if [ ! -f "$MONOFILE" ]; then
    pm_message 'Mono 6.12 runtime is missing. Reinstall it through PortMaster.'
    pm_finish
    exit 1
fi

# Use the PortMaster runtime rather than distributing another Mono copy.
$ESUDO mkdir -p "$MONODIR"
mono_mounted=0
if ! grep -qs " $MONODIR " /proc/mounts; then
    if ! $ESUDO mount "$MONOFILE" "$MONODIR"; then
        pm_message 'Unable to mount the Mono runtime.'
        pm_finish
        exit 1
    fi
    mono_mounted=1
fi

export PATH="$MONODIR/bin:$PATH"
export LD_LIBRARY_PATH="$LIBDIR:$MONODIR/lib:/usr/config/emuelec/lib:/usr/lib:${LD_LIBRARY_PATH:-}"
export MONO_PATH="$GAME"
export MONO_IOMAP=all
export MONO_GC_PARAMS=major=marksweep-conc
export SDL_NO_SIGNAL_HANDLERS=1
export SDL_TOUCH_MOUSE_EVENTS=0 SDL_MOUSE_TOUCH_EVENTS=0

# Resolve firmware graphics settings before exposing the bundled GL4ES shim.
unset LIBGL_FB
if [ -f "$controlfolder/libgl_${CFW_NAME}.txt" ]; then
    source "$controlfolder/libgl_${CFW_NAME}.txt"
elif [ -f "$controlfolder/libgl_default.txt" ]; then
    source "$controlfolder/libgl_default.txt"
fi

case "${OVERDRIVE_GL:-auto}" in
    gl4es)  use_gl4es=1 ;;
    native) use_gl4es=0 ;;
    *)      [ -n "${LIBGL_FB:-}" ] && use_gl4es=1 || use_gl4es=0 ;;
esac

if [ "$use_gl4es" = 1 ]; then
    export SDL_VIDEO_GL_DRIVER="$GLDIR/libGL.so.1"
    export SDL_VIDEO_EGL_DRIVER="$GLDIR/libEGL.so.1"
    export LD_LIBRARY_PATH="$GLDIR:$LD_LIBRARY_PATH"
    export LIBGL_ES=2 LIBGL_GL=21
    if [ -z "${LIBGL_FB:-}" ]; then
        LIBGL_FB=4
        [ -e /dev/dri/card0 ] || LIBGL_FB=2
        export LIBGL_FB
    fi

    # Open-source Panfrost must use Mesa, never a proprietary libmali override.
    if [ -d /sys/module/panfrost ] || [ -d /sys/bus/platform/drivers/panfrost ]; then
        case "${LIBGL_EGL:-}${LIBGL_GLES:-}" in
            *libmali*) unset LIBGL_EGL LIBGL_GLES ;;
        esac
    else
        # When default EGL/GLES are GLVND dispatchers, look for the vendor library.
        for lib in /lib/aarch64-linux-gnu/libmali-*gbm*.so \
                   /usr/lib/aarch64-linux-gnu/libmali-*gbm*.so \
                   /lib/aarch64-linux-gnu/libmali.so.1 \
                   /usr/lib/aarch64-linux-gnu/libmali.so.1 /usr/lib/libmali.so.1; do
            if [ -e "$lib" ] && grep -qa eglInitialize "$lib" 2>/dev/null \
                 && grep -qa glGetString "$lib" 2>/dev/null; then
                export LIBGL_EGL="$lib" LIBGL_GLES="$lib"
                break
            fi
        done
    fi
else
    unset SDL_VIDEO_GL_DRIVER SDL_VIDEO_EGL_DRIVER
    unset LIBGL_ES LIBGL_GL LIBGL_FB LIBGL_EGL LIBGL_GLES
fi

echo "Graphics: $([ "$use_gl4es" = 1 ] && echo GL4ES || echo native OpenGL)"

# FMOD and OpenAL can contend for exclusive ALSA devices on some firmwares.
cfw_lc="${CFW_NAME,,}"
shared=0
case "$cfw_lc" in amber*) shared=1 ;; esac
grep -qi amberelec /etc/os-release 2>/dev/null && shared=1
shared="${OVERDRIVE_ALSA_SHARED:-$shared}"
alias="$shared"
if grep -qiE 'pipewire|pulse' /etc/asound.conf "$HOME/.asoundrc" 2>/dev/null; then
    alias=1
fi
alias="${OVERDRIVE_ALSA_ALIAS:-$alias}"

if { [ "$shared" = 1 ] || [ "$alias" = 1 ]; } && [ -f /usr/share/alsa/alsa.conf ]; then
    alsa_conf="$GAMEDIR/alsa_shared.conf"
    printf '%s\n' '</usr/share/alsa/alsa.conf>' > "$alsa_conf"
    if [ "$shared" = 1 ]; then
        card="${OVERDRIVE_ALSA_CARD:-$(awk '$1 ~ /^[0-9]+$/ {print $1; exit}' /proc/asound/cards 2>/dev/null)}"
        card="${card:-0}"
        cat >> "$alsa_conf" <<ALSACONF
pcm.!default { type plug slave.pcm "overdrive_dmix" }
pcm.overdrive_dmix {
    type dmix
    ipc_key 80801984
    ipc_perm 0666
    slave {
        pcm { type hw card $card device 0 }
        rate 48000
        channels 2
        format S16_LE
        period_size 1024
        buffer_size 4096
    }
}
ALSACONF
    fi
    if [ "$alias" = 1 ]; then
        cat >> "$alsa_conf" <<'ALSACONF'
pcm.!sysdefault {
    @args [ CARD ]
    @args.CARD { type string default { @func getenv vars [ ALSA_PCM_CARD ALSA_CARD ] default { @func refer name defaults.pcm.card } } }
    type plug
    slave.pcm "default"
    hint {
        description "Default Audio Device (shared)"
        device_output { @func refer name defaults.pcm.dmix.device }
        device_input { @func refer name defaults.pcm.dsnoop.device }
    }
}
ALSACONF
    fi
    export ALSA_CONFIG_PATH="$alsa_conf"
    : "${OVERDRIVE_FMOD_OUTPUT:=alsa}"
    export OVERDRIVE_FMOD_OUTPUT
fi

# Additional logging is opt-in; the normal launch log stays compact.
if [ "${OVERDRIVE_DEBUG:-0}" = 1 ]; then
    "$MONODIR/bin/mono" --version
    env | grep -E '^(LIBGL|SDL_VIDEO|ALSA_|OVERDRIVE_|LD_LIBRARY_PATH)' || true
fi
[ "${OD_MONO_DLLTRACE:-0}" = 1 ] && export MONO_LOG_LEVEL=info MONO_LOG_MASK=dll

$GPTOKEYB mono &
pm_platform_helper "$MONODIR/bin/mono"
$TASKSET "$MONODIR/bin/mono" --debug "$GAME/80s_Overdrive.exe"
result=$?

if [ "$mono_mounted" = 1 ]; then
    $ESUDO umount "$MONODIR" || $ESUDO umount -l "$MONODIR"
fi
pm_finish
exit "$result"
