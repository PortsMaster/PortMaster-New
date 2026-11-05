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

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/cassettebeasts
CONFDIR="$GAMEDIR/conf"
BINARY=frt_3.5.2

cd $GAMEDIR

# First-run setup (tools/patchscript); runs again for new DLC or a changed pack (markers hold the pack's fingerprint)
G="$GAMEDIR/gamedata"
pck_id() { echo "$(wc -c < "$1" | tr -d " ") $(head -c 1048576 "$1" | md5sum | cut -c1-8) $(tail -c 1048576 "$1" | md5sum | cut -c1-8)"; }
SETUP=
if [ ! -f "$G/.patched_complete" ]; then
  SETUP=1
elif [ "$(cat "$G/.patched_complete")" != "$(pck_id "$G/CassetteBeasts.pck")" ]; then
  rm -rf "$G/data"
  SETUP=1
fi
for f in "$G"/dlc/*.pck; do
  [ -f "$f" ] || continue
  D="$G/data/dlc_$(basename "$f" .pck)"
  if [ ! -f "$D/.done" ]; then
    SETUP=1
  elif [ "$(cat "$D/.done")" != "$(pck_id "$f")" ]; then
    rm -rf "$D"
    SETUP=1
  fi
done
if [ -n "$SETUP" ]; then
  rm -f "$G/.patched_complete"
  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    $ESUDO chmod +x "$GAMEDIR/tools/patchscript" "$GAMEDIR/tools/wav_adpcm" "$GAMEDIR/tools/tex3_convert"
    export GAMEDIR controlfolder DEVICE_ARCH
    export PATCHER_FILE="$GAMEDIR/tools/patchscript"
    export PATCHER_GAME="Cassette Beasts"
    export PATCHER_TIME="about 3 minutes"
    source "$controlfolder/utils/patcher.txt"
    pidof gptokeyb > /dev/null && $ESUDO kill -9 $(pidof gptokeyb)
  else
    pm_message "This port requires the latest version of PortMaster."
  fi
  [ -f "$G/.patched_complete" ] || exit 1
fi

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Snapdragon: full-resolution 3D and effects; RK3326: Ultra Low Tweaks
HI=
case "$DEVICE_CPU" in sm*|sd*|qcs*|SM*|SD*|QCS*) HI=_hi ;; rk3326|RK3326) HI=_lo ;; esac

export XDG_DATA_HOME="$CONFDIR" XDG_CONFIG_HOME="$CONFDIR" XDG_CACHE_HOME="$GAMEDIR/cache"
mkdir -p "$CONFDIR/CassetteBeasts"
SET=settings$HI.cfg
[ -f "$SET" ] || SET=settings.cfg
[ -f "$CONFDIR/CassetteBeasts/settings.cfg" ] || sed -e "s/@WIDTH@/$DISPLAY_WIDTH/" -e "s/@HEIGHT@/$DISPLAY_HEIGHT/" "$SET" > "$CONFDIR/CassetteBeasts/settings.cfg"

# the converted pack's references point here
ln -sfn "$G/data" /tmp/cassettebeasts-data

# 3D render scale for about 360x202 worth of pixels, 0.5 to 1 (no sqrt() in muOS's busybox awk)
RS=$(awk -v w="$DISPLAY_WIDTH" -v h="$DISPLAY_HEIGHT" 'BEGIN { a = (h * 16 > w * 9) ? w * w * 9 / 16 : h * h * 16 / 9; v = 72900 / a; s = v > 1 ? v : 1; for (i = 0; i < 40; i++) s = (s + v / s) / 2; if (s > 1) s = 1; if (s < 0.5) s = 0.5; printf "%.3f", s }')
sed -e "s#@GAMEDIR@#$GAMEDIR#g" -e "s#^quality/3d_render_scale=.*#quality/3d_render_scale=$RS#" override.cfg.in > gamedata/override.cfg
[ -n "$HI" ] && cat "override$HI.cfg" >> gamedata/override.cfg

godot_dir="$HOME/godot_cb"
$ESUDO mkdir -p "$godot_dir"
$ESUDO umount "$godot_dir" 2>/dev/null
$ESUDO mount "$GAMEDIR/frt_3.5.2_cb.squashfs" "$godot_dir" || { pm_message "Could not mount frt_3.5.2_cb.squashfs."; sleep 5; exit 1; }

export FRT_NO_EXIT_SHORTCUTS=1
# the handheld's controls are keys (gptokeyb2): it is always the keyboard player, player 1. Switch pads in Switch mode
# get the Switch name, so the game gives them Nintendo prompts
# Knulli maps the buttons by position: a/b and x/y swapped back to the printed letters
if [ "$CFW_NAME" = knulli ] && [ -f "$SDL_GAMECONTROLLERCONFIG_FILE" ]; then
  sed -E 's/,a:/,@:/; s/,b:/,a:/; s/,@:/,b:/; s/,x:/,@:/; s/,y:/,x:/; s/,@:/,y:/' "$SDL_GAMECONTROLLERCONFIG_FILE" > "$GAMEDIR/gamecontrollerdb_swapped.txt"
  export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb_swapped.txt"
  sdl_controllerconfig="$(cat "$SDL_GAMECONTROLLERCONFIG_FILE")"
fi
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export FRT_JOY_NAME="Nintendo Switch Pro Controller" FRT_JOY_NAME_MATCH="Pro Controller|Joy-Con"

# Local co-op: Bluetooth and external USB pads go to the game only, the built-in controls to gptokeyb2 only
SKIP= EXTERNAL=
for j in /sys/class/input/js*; do
  [ -e "$j/device/id/bustype" ] || continue
  id="0x$(cat "$j/device/id/vendor")/0x$(cat "$j/device/id/product")"
  if [ "$(cat "$j/device/id/bustype")" = 0005 ]; then
    EXTERNAL="${EXTERNAL:+$EXTERNAL,}$id"; continue
  fi
  d=$(readlink -f "$j/device")
  case "$d" in
    */usb[0-9]*)
      x=$d; rem=
      while [ -n "$x" ] && [ "$x" != / ]; do [ -f "$x/removable" ] && { rem=$(cat "$x/removable"); break; }; x=${x%/*}; done
      # 0x1209/0x3100: the RG351 series' controls, on an internal USB port
      [ "$rem" = fixed ] || [ "$id" = 0x1209/0x3100 ] || { EXTERNAL="${EXTERNAL:+$EXTERNAL,}$id"; continue; } ;;
  esac
  SKIP="${SKIP:+$SKIP|}$(cat "$j/device/name")"
done
# no built-in controls found: treat every pad as built-in, or the handheld's own controls could end up dead
[ -z "$SKIP" ] && EXTERNAL=
GPTK=$GPTOKEYB2
[ -n "$EXTERNAL" ] && GPTK=$(echo $GPTOKEYB2 | sed "s#\([^ ]*gptokeyb2\)#env SDL_GAMECONTROLLER_IGNORE_DEVICES=$EXTERNAL \1#")
$GPTK "$BINARY" -c "$GAMEDIR/cassettebeasts.ini" &

[ -n "$SKIP" ] && SKIP="$SKIP|IMU"
echo "co-op: built-in controls [$SKIP], external pads for the game only [${EXTERNAL:-none}]"
# The engine reads raw joystick buttons: pads as plain Linux joysticks (SDL's HIDAPI driver numbers them differently,
# with no mapping), with their rows from PortMaster's database (the firmware's config only has the built-in controls)
export SDL_JOYSTICK_HIDAPI=0
for id in ${EXTERNAL//,/ }; do
  v=${id%/*} p=${id#*/} v=${v#0x} p=${p#0x}
  rows=$(grep -i "^........${v:2:2}${v:0:2}0000${p:2:2}${p:0:2}0000.*platform:Linux" "$controlfolder/gamecontrollerdb.txt")
  [ -n "$rows" ] && SDL_GAMECONTROLLERCONFIG="$SDL_GAMECONTROLLERCONFIG
$rows"
done
# built-in controls unknown: the game opens no pads (the handheld's keys still work, co-op is off)
if [ -n "$SKIP" ]; then
  export FRT_JOY_SKIP="$SKIP"
else
  export FRT_NO_JOYSTICK=1
fi
pm_platform_helper "$godot_dir/$BINARY"
"$godot_dir/$BINARY" --video-driver GLES3 --resolution "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" --main-pack "$GAMEDIR/gamedata/CassetteBeasts.pck"

$ESUDO umount "$godot_dir"
pm_finish
