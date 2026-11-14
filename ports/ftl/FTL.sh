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

GAMEDIR="/$directory/ports/ftl"
GAMEDATA="$GAMEDIR/gamedata"
BINARY=FTL.amd64

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# A GOG Linux installer in gamedata/ is unpacked in its place.
for installer in "$GAMEDATA"/*.sh; do
  [ -f "$installer" ] || continue
  pm_message "Unpacking $(basename "$installer"), this can take a few minutes..." --title "Please wait"
  unpacked="$GAMEDATA/.gog"
  gog_data="data/noarch/game/data"
  if ! "$controlfolder/7zzs.$DEVICE_ARCH" x -tzip -aoa -o"$unpacked" "$installer" "$gog_data/*" "-x!$gog_data/FTL.x86" ||
    [ ! -f "$unpacked/$gog_data/$BINARY" ]; then
    rm -rf "$unpacked"
    pm_show_error "Could not unpack $(basename "$installer"). Check that it is the GOG Linux installer and that there is enough free space, then launch the game again." --title "Unpacking failed"
    exit 1
  fi
  mv "$unpacked/$gog_data/"* "$GAMEDATA/" && rm -rf "$unpacked" "$installer"
done
# Accepts the data folder itself as well as its contents.
if [ -d "$GAMEDATA/data" ] && [ -f "$GAMEDATA/data/$BINARY" ]; then
  mv "$GAMEDATA/data/"* "$GAMEDATA/" && rmdir "$GAMEDATA/data"
fi
if [ ! -f "$GAMEDATA/$BINARY" ] || [ ! -f "$GAMEDATA/ftl.dat" ]; then
  pm_show_error "Copy the contents of the Linux game's data folder, or the GOG Linux installer, into ports/ftl/gamedata/ and launch the game again." --title "Game files missing" --type warning
  exit 1
fi
chmod +x "$GAMEDIR/box64" "$GAMEDATA/$BINARY"

python3 "$GAMEDIR/patches/fbo_patch.py" "$GAMEDATA/$BINARY"

CONFDIR="$GAMEDIR/conf"
mkdir -p "$CONFDIR/FasterThanLight"
[ -f "$CONFDIR/FasterThanLight/settings.ini" ] || cp "$GAMEDIR/settings.ini" "$CONFDIR/FasterThanLight/"

weston_dir=/tmp/weston
weston_runtime="weston_pkg_0.2"
if [ ! -f "$controlfolder/libs/${weston_runtime}.squashfs" ]; then
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    pm_show_error "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." --title "PortMaster update needed"
    exit 1
  fi
  pm_message "Downloading the Westonpack runtime, this can take a few minutes..." --title "Please wait"
  $ESUDO "$controlfolder/harbourmaster" --quiet --no-check runtime_check "${weston_runtime}.squashfs"
fi

# Free RAM and swap together the game needs.
NEED_MB=750
read -r avail_mb swap_mb < <(awk '/^MemAvailable:/ {a = $2} /^SwapFree:/ {s = $2} END {print int(a / 1024), int(s / 1024)}' /proc/meminfo)
echo "Free memory: $avail_mb MB RAM + $swap_mb MB swap, $NEED_MB needed"
free_mb=$((avail_mb + swap_mb))
if [ "$free_mb" -lt "$NEED_MB" ]; then
  pm_show_error "FTL needs $NEED_MB MB of free memory. Turn on swap in the system settings." --title "Not enough memory"
  exit 1
fi

gl_env=()
system_gl=""
if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
  # The same test westonwrap uses to tell a system GL (Panfrost, freedreno) from libMali.
  glxinfo 2>/dev/null | grep -q "OpenGL version string" && system_gl=1
fi

$ESUDO mkdir -p "$weston_dir"
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$weston_dir"
fi
$ESUDO mount "$controlfolder/libs/${weston_runtime}.squashfs" "$weston_dir"

cd "$GAMEDATA"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
# SDL turns touch into mouse moves that fight the emulated cursor.
export SDL_TOUCH_MOUSE_EVENTS=0

layout="$GAMEDIR/ftlhelm.ini"
# ftlhelm's command channel, for tests over SSH: on while ftl/.debug exists.
cmd_env=()
if [ -f "$GAMEDIR/.debug" ]; then
  [ -p /tmp/ftlhelm.cmd ] || mkfifo /tmp/ftlhelm.cmd
  cmd_env=(FTLHELM_CMD=/tmp/ftlhelm.cmd)
fi
# gptokeyb2 keeps only the Select + Start exit.
$GPTOKEYB2 "$BINARY" > /dev/null &
pm_platform_helper "$GAMEDIR/box64"

shrink=""
# Below the game's resolution the frame is scaled down, so shrunk textures lose no detail.
[ "$DISPLAY_WIDTH" -lt 1280 ] && shrink=1
# Full-size textures outgrow a low-memory device.
[ "${DEVICE_RAM:-2}" -lt 2 ] && shrink=1
if [ -n "$shrink" ]; then
  gl_env+=(LIBGL_SHRINK=3)
  # LIBGL_SHRINK needs gl4es, and westonwrap leaves a system GL in place.
  [ -n "$system_gl" ] && gl_env+=(BOX64_LIBGL="$weston_dir/lib_aarch64/graphics/gl4es_x11/libGL.so.1")
fi

# westonwrap moves XDG_RUNTIME_DIR, which hides the sound server's socket from ALSA's plugins.
REAL_XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

# LC_NUMERIC=C is what Steam's own data/FTL wrapper sets. Without WAYLAND_DISPLAY, crusty's
# SDL cannot pick the headless Weston, which has no EGL.
$ESUDO "$weston_dir/westonwrap.sh" headless noop kiosk crusty_glx_gl4es \
  XDG_DATA_HOME="$CONFDIR" LC_ALL= LC_NUMERIC=C "${gl_env[@]}" \
  XDG_RUNTIME_DIR="$REAL_XDG_RUNTIME_DIR" WAYLAND_DISPLAY= \
  BOX64_LD_LIBRARY_PATH="$GAMEDATA/amd64:$GAMEDIR" \
  BOX64_LD_PRELOAD=ftlhelm.so FTLHELM_EXE="$GAMEDATA/$BINARY" FTLHELM_LAYOUT="$layout" \
  "${cmd_env[@]}" \
  "$GAMEDIR/box64" "./$BINARY"

$ESUDO "$weston_dir/westonwrap.sh" cleanup
if [[ "$PM_CAN_MOUNT" != "N" ]]; then
  $ESUDO umount "$weston_dir"
fi
pm_finish
