#!/bin/bash

export OPENJKDF2_HUD_SCALE=2.0
# Optional handheld cheats submenu in pause menu (single-player only):
export OPENJKDF2_CHEATS_MENU=1

# Debug: simulate another panel resolution (logical render + letterbox on real screen).
# Formats: 480x320  720x720  480,320
# export OPENJKDF2_FORCE_RES=640x480

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

# ROCKNIX (sway): portmaster_sway_fullscreen.sh looks up Wayland app_id before SDL creates
# the window → "No matching node" spam. SDL fullscreen is enough on handhelds; disable by default.
if [ -z "${OPENJKDF2_SWAY_FULLSCREEN+x}" ] && { [ "${CFW_NAME:-}" = "ROCKNIX" ] || [ -e "/usr/bin/portmaster_sway_fullscreen.sh" ]; }; then
    export OPENJKDF2_SWAY_FULLSCREEN=0
fi

openjkdf2_pm_platform_helper() {
    if [ -e "$PM_PIPE" ]; then
        PortMasterDialogExit
    fi
    if [ "${OPENJKDF2_SWAY_FULLSCREEN:-0}" = "0" ]; then
        echo "ROCKNIX sway fullscreen: disabled (OPENJKDF2_SWAY_FULLSCREEN=0)"
        return
    fi
    if [ -e "/usr/bin/portmaster_sway_fullscreen.sh" ]; then
        echo "ROCKNIX sway fullscreen: OpenJKDF2 (background)"
        /usr/bin/portmaster_sway_fullscreen.sh "OpenJKDF2" &
    fi
}
pm_platform_helper() { openjkdf2_pm_platform_helper "$@"; }

get_controls

# Platform tweaks after get_controls (DISPLAY_WIDTH/HEIGHT are set by PortMaster here).
openjkdf2_is_rocknix=0
if [ "${CFW_NAME:-}" = "ROCKNIX" ] || [ -e "/usr/bin/portmaster_sway_fullscreen.sh" ]; then
    openjkdf2_is_rocknix=1
fi

if [ "$openjkdf2_is_rocknix" -eq 1 ]; then
    # startup.log in GAMEDIR (see trace_gles.c); mirrored to log.txt when OPENJKDF2_TRACE=1
    export OPENJKDF2_TRACE="${OPENJKDF2_TRACE:-1}"
    export SDL_HINT_APP_NAME="${SDL_HINT_APP_NAME:-OpenJKDF2}"
fi

# Internal render scale (0.75 = Mali H700; override with OPENJKDF2_SSAA=...)
if [ -z "${OPENJKDF2_SSAA+x}" ]; then
    if [ "$openjkdf2_is_rocknix" -eq 1 ] && [ "${DISPLAY_HEIGHT:-0}" -gt 720 ] 2>/dev/null; then
        # Mangmi Air X (1080p) and similar: ease VRAM/RAM pressure on 4 GB devices.
        export OPENJKDF2_SSAA=0.5
    else
        export OPENJKDF2_SSAA=0.75
    fi
fi

GAMEDIR="/$directory/ports/openjkdf2"
CONFDIR="$GAMEDIR/conf"
JK1DIR="$GAMEDIR/jk1"
MOTSDIR="$GAMEDIR/mots"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "OpenJKDF2 launch: CFW=${CFW_NAME:-?} arch=${DEVICE_ARCH:-?} display=${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
if [ "$openjkdf2_is_rocknix" -eq 1 ]; then
    echo "ROCKNIX profile: OPENJKDF2_TRACE=${OPENJKDF2_TRACE:-?} OPENJKDF2_SSAA=${OPENJKDF2_SSAA:-?} sway=${OPENJKDF2_SWAY_FULLSCREEN:-0}"
fi

# Saves/config for JKDF2 and MOTS (switch games in-game: Main menu -> Expansions & Mods)
mkdir -p "$CONFDIR/openjkdf2" "$CONFDIR/openjkmots" \
  "$HOME/.local/share/openjkdf2" "$HOME/.local/share/openjkmots"
export XDG_DATA_HOME="$CONFDIR"
bind_directories "$HOME/.local/share/openjkdf2" "$CONFDIR/openjkdf2"
bind_directories "$HOME/.local/share/openjkmots" "$CONFDIR/openjkmots"

# JKDF2 in jk1/, MOTS in mots/ — same binary; in-game menu restarts with -motsCompat when needed
mkdir -p "$JK1DIR" "$MOTSDIR" "$GAMEDIR/expansions" "$GAMEDIR/mods"
export OPENJKDF2_ROOT="$JK1DIR"
export OPENJKMOTS_ROOT="$MOTSDIR"

# Avoid libstdc++ iostream crash when locale data is missing on embedded systems
export LC_ALL=C
export LANG=C

# Linux (knulli, etc.) is case-sensitive: Steam copies from Windows often land as Episode/Resource.
openjkdf2_dir_is_empty() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  [ -z "$(ls -A "$dir" 2>/dev/null)" ]
}

openjkdf2_fixup_dir_case() {
  local base="$1"
  local want="$2"
  local entry name alt

  [ -d "$base" ] || return 1

  # Empty jk1/episode/ + full jk1/Episode/ is a common bad copy from Windows.
  if [ -d "$base/$want" ] && ! openjkdf2_dir_is_empty "$base/$want"; then
    return 0
  fi
  if [ -d "$base/$want" ] && openjkdf2_dir_is_empty "$base/$want"; then
    for entry in "$base"/*; do
      [ -d "$entry" ] || continue
      name=$(basename "$entry")
      [ "$name" = "$want" ] && continue
      [ "${name,,}" = "$want" ] || continue
      if ! openjkdf2_dir_is_empty "$entry"; then
        echo "jk1: replacing empty ${want}/ with ${name}/"
        rmdir "$base/$want" 2>/dev/null || rm -rf "$base/$want"
        mv "$entry" "$base/$want"
        return 0
      fi
    done
    return 0
  fi

  for entry in "$base"/*; do
    [ -d "$entry" ] || continue
    name=$(basename "$entry")
    [ "${name,,}" = "$want" ] || continue
    echo "jk1: renaming ${name}/ -> ${want}/ (Linux needs lowercase)"
    mv "$entry" "$base/$want"
    return $?
  done
  return 1
}

openjkdf2_fixup_jk1_case() {
  local fixed=0
  openjkdf2_fixup_dir_case "$JK1DIR" "episode" && fixed=1
  openjkdf2_fixup_dir_case "$JK1DIR" "resource" && fixed=1
  [ "$fixed" -eq 1 ] || return 0
}

openjkdf2_fixup_jk1_case

# Check game files (jk1/)
if [ ! -d "$JK1DIR/episode" ] || [ ! -d "$JK1DIR/resource" ]; then
  echo "jk1/ contents:"
  ls -la "$JK1DIR" 2>/dev/null || true
  pm_message "Missing jk1/episode and jk1/resource (lowercase). Copy Steam/GOG files to ports/openjkdf2/jk1/"
  sleep 5
  exit 1
fi

# Linux is case-sensitive: Steam/Windows copies often use JK1.GOB, RES1HI.GOB, JK_.CD, etc.
openjkdf2_find_insensitive() {
  local dir="$1"
  local want="$2"
  local entry base want_lower

  [ -e "$dir/$want" ] && { echo "$dir/$want"; return 0; }
  [ -d "$dir" ] || return 1
  want_lower="${want,,}"
  for entry in "$dir"/*; do
    [ -e "$entry" ] || continue
    base=$(basename "$entry")
    [ "${base,,}" = "$want_lower" ] || continue
    echo "$entry"
    return 0
  done
  return 1
}

openjkdf2_ensure_asset() {
  local relpath="$1"
  local dir base dest src

  dest="$JK1DIR/$relpath"
  [ -e "$dest" ] && return 0

  dir="$JK1DIR/$(dirname "$relpath")"
  base=$(basename "$relpath")
  src=$(openjkdf2_find_insensitive "$dir" "$base") || return 1

  echo "jk1: renaming $(basename "$src") -> $relpath"
  mv "$src" "$dest"
}

openjkdf2_canonical_asset() {
  case "${1,,}" in
    jk1.gob) echo "episode/JK1.gob" ;;
    jk1ctf.gob) echo "episode/JK1CTF.gob" ;;
    jk1mp.gob) echo "episode/JK1MP.gob" ;;
    res1hi.gob) echo "resource/Res1hi.gob" ;;
    res2.gob) echo "resource/Res2.gob" ;;
    jk_.cd) echo "resource/jk_.cd" ;;
    *) return 1 ;;
  esac
}

# .gob/.cd copied to jk1/ root or left in Episode/ after an empty episode/ was created.
openjkdf2_relocate_stray_assets() {
  local f base dest

  while IFS= read -r -d '' f; do
    base=$(basename "$f")
    dest=$(openjkdf2_canonical_asset "$base") || continue
    [ -e "$JK1DIR/$dest" ] && continue
    mkdir -p "$JK1DIR/$(dirname "$dest")"
    echo "jk1: moving stray $(realpath --relative-to="$JK1DIR" "$f" 2>/dev/null || echo "$f") -> $dest"
    mv "$f" "$JK1DIR/$dest"
  done < <(find "$JK1DIR" \( -iname '*.gob' -o -iname 'jk_.cd' \) \
    ! -path "$JK1DIR/episode/*" ! -path "$JK1DIR/resource/*" -print0 2>/dev/null)
}

openjkdf2_fixup_jk1_assets() {
  local req
  openjkdf2_relocate_stray_assets
  for req in \
    "episode/JK1.gob" "episode/JK1CTF.gob" "episode/JK1MP.gob" \
    "resource/Res1hi.gob" "resource/Res2.gob" "resource/jk_.cd"
  do
    openjkdf2_ensure_asset "$req" || true
  done
}

openjkdf2_fixup_jk1_assets

# Check assets OpenJKDF2 requires (avoids installer crash without NFD)
missing_assets=0
for req in \
  "episode/JK1.gob" "episode/JK1CTF.gob" "episode/JK1MP.gob" \
  "resource/Res1hi.gob" "resource/Res2.gob" "resource/jk_.cd"
do
  if [ ! -e "$JK1DIR/$req" ]; then
    echo "MISSING: jk1/$req"
    missing_assets=1
  fi
done
if [ "$missing_assets" -eq 1 ]; then
  echo "jk1/episode/:"
  ls -la "$JK1DIR/episode" 2>/dev/null || true
  echo "jk1/resource/:"
  ls -la "$JK1DIR/resource" 2>/dev/null || true
  echo "jk1/ (top level):"
  ls -la "$JK1DIR" 2>/dev/null || true
  echo "Any .gob/.cd under jk1/:"
  find "$JK1DIR" -maxdepth 3 \( -iname '*.gob' -o -iname 'jk_.cd' \) -print 2>/dev/null || true
  pm_message "Missing .gob/.cd in jk1/episode or jk1/resource. Copy from Steam: episode/ + resource/ contents."
  sleep 8
  exit 1
fi

# Check binary
if [ ! -f "$GAMEDIR/openjkdf2.${DEVICE_ARCH}" ]; then
  pm_message "Missing openjkdf2.${DEVICE_ARCH} in ports/openjkdf2/"
  sleep 5
  exit 1
fi

# Bundled libs (openal); system SDL2/GLES/EGL via PortMaster + CFW paths
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# If a second gamepad is connected (e.g. Bluetooth on TV), hide the handheld from SDL
# so the external pad becomes JOY1 with vanilla bindings. Handheld-only play is unchanged.
openjkdf2_guid_to_vidpid() {
  local guid="${1,,}"
  [ "${#guid}" -eq 32 ] || return 1
  printf '0x%04x/0x%04x' \
    $((16#${guid:10:2}${guid:8:2})) \
    $((16#${guid:18:2}${guid:16:2}))
}

openjkdf2_is_noise_js_name() {
  case "${1,,}" in
    *accelerometer*|*gyroscope*|*" motion"*|*" imu"*|*mouse*|*keyboard*|*touchpad*)
      return 0 ;;
  esac
  return 1
}

openjkdf2_is_handheld_js_name() {
  local name="${1,,}" handheld_name="${2,,}"
  [ -n "$handheld_name" ] && case "$name" in *"$handheld_name"*) return 0 ;; esac
  case "$name" in
    *odroidgo*|*retrogame*joy*|*"go-super"*|*ankergaming*|*rg35*|*rg34*|*rg40*|*trimui*)
      return 0 ;;
  esac
  return 1
}

openjkdf2_bt_addr_connected() {
  local addr="${1,,}" connected f
  for f in /sys/class/bluetooth/hci*/hci*:*/connected; do
    case "${f,,}" in
      *"${addr}"*)
        connected=$(cat "$f" 2>/dev/null || echo 0)
        [ "$connected" = "1" ] && return 0
        return 1
        ;;
    esac
  done
  if command -v bluetoothctl >/dev/null 2>&1; then
    bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes" && return 0
  fi
  return 1
}

openjkdf2_usb_js_present() {
  local js="$1" p
  p=$(readlink -f "$js/device" 2>/dev/null) || return 1
  while [ -n "$p" ] && [ "$p" != "/" ]; do
    if [ -f "$p/idVendor" ] && [ -f "$p/idProduct" ]; then
      return 0
    fi
    p=$(dirname "$p")
  done
  return 1
}

# Stale js nodes linger after BT/USB disconnect; check sysfs connection state.
openjkdf2_js_is_live() {
  local js="$1" phys="$2" name="$3"
  local p connected bt_addr

  [ -e "$js" ] || return 1
  [ -e "/dev/input/$(basename "$js")" ] || return 1
  [ -n "$name" ] || return 1

  p=$(readlink -f "$js/device" 2>/dev/null) || return 1
  while [ -n "$p" ] && [ "$p" != "/" ]; do
    if [ -f "$p/connected" ]; then
      connected=$(cat "$p/connected" 2>/dev/null || echo 0)
      [ "$connected" = "1" ] && return 0
      return 1
    fi
    p=$(dirname "$p")
  done

  case "$phys" in
    usb-*|*/usb*)
      openjkdf2_usb_js_present "$js" && return 0
      return 1
      ;;
    *hci*|*bluetooth*)
      bt_addr=$(echo "$phys" | grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' | head -n1)
      [ -n "$bt_addr" ] && openjkdf2_bt_addr_connected "$bt_addr" && return 0
      return 1
      ;;
  esac

  case "${name,,}" in
    *wireless*controller*|*dualsense*|*dualshock*)
      # BT sysfs often missing on ROCKNIX; treat named pads as live if the node exists.
      return 0 ;;
  esac

  return 0
}

openjkdf2_is_external_js() {
  local js="$1" name="$2" phys="$3" vendor="$4" product="$5"
  local handheld_vidpid="$6" handheld_name="$7"
  local looks_external=0

  openjkdf2_is_noise_js_name "$name" && return 1
  openjkdf2_is_handheld_js_name "$name" "$handheld_name" && return 1

  case "${name,,}" in
    *calibrat*|*uinput*|*virtual*)
      return 1 ;;
  esac

  if [ -n "$handheld_vidpid" ] && [ "0x${vendor}/0x${product}" = "$handheld_vidpid" ]; then
    return 1
  fi

  case "$phys" in
    *hci*|*bluetooth*)
      looks_external=1 ;;
    usb-*|*/usb*)
      [ "$vendor" != "0000" ] && [ "$product" != "0000" ] && looks_external=1 ;;
  esac

  if [ "$looks_external" -eq 0 ]; then
    case "${name,,}" in
      *wireless*controller*|*xbox*|*x-box*|*playstation*|*dualsense*|*dualshock*|*8bitdo*|*8-bitdo*)
        looks_external=1 ;;
      *"pro controller"*|*switch*pro*|*"game controller"*)
        looks_external=1 ;;
    esac
  fi

  if [ "$looks_external" -eq 0 ]; then
    case "$vendor" in
      045e|054c|057e|056e|2dc8|2e24|3537|0e6f|146b|0079|2563|20d6|31e4)
        looks_external=1 ;;
    esac
  fi

  [ "$looks_external" -eq 1 ] || return 1
  openjkdf2_js_is_live "$js" "$phys" "$name"
}

openjkdf2_ignore_handheld_if_external() {
  # OPENJKDF2_IGNORE_HANDHELD=0 disables; =1 forces ignore using PortMaster GUID/VID:PID
  if [ "${OPENJKDF2_IGNORE_HANDHELD:-}" = "0" ]; then
    echo "Handheld SDL ignore: disabled (OPENJKDF2_IGNORE_HANDHELD=0)"
    return
  fi

  local handheld_name="" guid="" ignore_vidpid="" js_name js_vendor js_product js_phys js_dev
  local -a js_names=() js_vidpids=() external_names=()
  local handheld_idx=-1 i

  if [ -n "${sdl_controllerconfig:-}" ]; then
    guid="${sdl_controllerconfig%%,*}"
    guid="${guid//[[:space:]]/}"
    handheld_name="${sdl_controllerconfig#*,}"
    handheld_name="${handheld_name%%,*}"
  fi

  for js in /sys/class/input/js*; do
    [ -e "$js" ] || continue
    js_dev="/dev/input/$(basename "$js")"
    [ -e "$js_dev" ] || continue

    js_name=$(cat "$js/device/name" 2>/dev/null || true)
    [ -n "$js_name" ] || continue
    openjkdf2_is_noise_js_name "$js_name" && continue

    js_phys=$(cat "$js/device/phys" 2>/dev/null || true)
    js_vendor=$(cat "$js/device/id/vendor" 2>/dev/null || echo 0000)
    js_product=$(cat "$js/device/id/product" 2>/dev/null || echo 0000)
    js_vendor=${js_vendor#0x}
    js_product=${js_product#0x}

    js_names+=("$js_name")
    if [ "$js_vendor" != "0000" ] && [ "$js_product" != "0000" ]; then
      js_vidpids+=("0x${js_vendor}/0x${js_product}")
    else
      js_vidpids+=("")
    fi

    if [ "$handheld_idx" -lt 0 ] && openjkdf2_is_handheld_js_name "$js_name" "$handheld_name"; then
      handheld_idx=${#js_names[@]}
      handheld_idx=$((handheld_idx - 1))
    fi
  done

  if openjkdf2_guid_to_vidpid "$guid" >/dev/null 2>&1; then
    ignore_vidpid=$(openjkdf2_guid_to_vidpid "$guid")
  fi
  if [ "$handheld_idx" -ge 0 ] && [ -n "${js_vidpids[$handheld_idx]}" ]; then
    ignore_vidpid="${js_vidpids[$handheld_idx]}"
  fi

  for js in /sys/class/input/js*; do
    [ -e "$js" ] || continue
    js_dev="/dev/input/$(basename "$js")"
    [ -e "$js_dev" ] || continue

    js_name=$(cat "$js/device/name" 2>/dev/null || true)
    [ -n "$js_name" ] || continue
    js_phys=$(cat "$js/device/phys" 2>/dev/null || true)
    js_vendor=$(cat "$js/device/id/vendor" 2>/dev/null || echo 0000)
    js_product=$(cat "$js/device/id/product" 2>/dev/null || echo 0000)
    js_vendor=${js_vendor#0x}
    js_product=${js_product#0x}

    if openjkdf2_is_external_js "$js" "$js_name" "$js_phys" "$js_vendor" "$js_product" "$ignore_vidpid" "$handheld_name"; then
      external_names+=("$js_name")
    fi
  done

  if [ "${#external_names[@]}" -eq 0 ] && [ "${OPENJKDF2_IGNORE_HANDHELD:-}" != "1" ]; then
    echo "Handheld SDL ignore: no connected external gamepad; keeping integrated as JOY1"
    if [ "${#js_names[@]}" -gt 0 ]; then
      echo "  detected gamepad nodes: ${js_names[*]}"
    fi
    return
  fi

  if [ -z "$ignore_vidpid" ]; then
    echo "Handheld SDL ignore: external gamepad(s) present but handheld VID:PID unknown"
    printf '  detected gamepads:'
    for js_name in "${js_names[@]}"; do
      printf ' "%s"' "$js_name"
    done
    printf '\n'
    return
  fi

  export SDL_GAMECONTROLLER_IGNORE_DEVICES="$ignore_vidpid"
  echo "Handheld SDL ignore: hiding ${js_names[$handheld_idx]:-$handheld_name} ($ignore_vidpid)"
  echo "  external gamepad(s): ${external_names[*]}"
}

openjkdf2_ignore_handheld_if_external

$ESUDO chmod +x "$GAMEDIR/openjkdf2.${DEVICE_ARCH}"

# gptokeyb without -c: Select+Start quit only; game controls stay native SDL
if [ -n "${GPTOKEYB:-}" ] && [ "${OPENJKDF2_GPTOKEYB:-1}" != "0" ]; then
    $GPTOKEYB "openjkdf2.${DEVICE_ARCH}" &
else
    echo "gptokeyb: skipped (OPENJKDF2_GPTOKEYB=${OPENJKDF2_GPTOKEYB:-0})"
fi
pm_platform_helper "$GAMEDIR/openjkdf2.${DEVICE_ARCH}"
if command -v stdbuf >/dev/null 2>&1; then
    stdbuf -oL -eL ./openjkdf2.${DEVICE_ARCH}
else
    ./openjkdf2.${DEVICE_ARCH}
fi
game_exit=$?
echo "OpenJKDF2 exited with code $game_exit"
if [ -f "$GAMEDIR/startup.log" ]; then
    echo "--- startup.log ---"
    cat "$GAMEDIR/startup.log"
fi

pm_finish
