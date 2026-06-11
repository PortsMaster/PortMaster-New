# OpenJKDF2 launch logic — sourced from PortMaster wrappers (.sh in ports/ root only).
# Not a .sh file: EmulationStation only indexes *.sh in the Ports system.
# Set OPENJKDF2_MOTS=1 in the wrapper to boot Mysteries of the Sith directly.

: "${GAMEDIR:?GAMEDIR must be set by the PortMaster wrapper}"
CONFDIR="$GAMEDIR/conf"
JK1DIR="$GAMEDIR/jk1"
MOTSDIR="$GAMEDIR/mots"

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

# Platform tweaks (DISPLAY_WIDTH/HEIGHT come from PortMaster get_controls in wrapper).
openjkdf2_is_rocknix=0
if [ "${CFW_NAME:-}" = "ROCKNIX" ] || [ -e "/usr/bin/portmaster_sway_fullscreen.sh" ]; then
    openjkdf2_is_rocknix=1
fi

# GLES startup trace → stderr + startup.log (tee captures stderr in log.txt). Set OPENJKDF2_TRACE=0 to disable.
export OPENJKDF2_TRACE="${OPENJKDF2_TRACE:-1}"

if [ "$openjkdf2_is_rocknix" -eq 1 ]; then
    export SDL_HINT_APP_NAME="${SDL_HINT_APP_NAME:-OpenJKDF2}"
fi

# Internal render scale (0.75 = Mali H700; override with OPENJKDF2_SSAA=...)
if [ -z "${OPENJKDF2_SSAA+x}" ]; then
    if [ "$openjkdf2_is_rocknix" -eq 1 ] && [ "${DISPLAY_HEIGHT:-0}" -gt 720 ] 2>/dev/null; then
        # Mangmi Air X (1080p) and similar: ease VRAM/RAM pressure on 4 GB devices.
        export OPENJKDF2_SSAA=0.5
    elif [ "${DISPLAY_HEIGHT:-999}" -l 480 ] 2>/dev/null || [ "${DISPLAY_WIDTH:-999}" -l 480 ] 2>/dev/null; then
        # RK3326 / 480x320 and similar: lower internal resolution for Mali 1 GB devices.
        export OPENJKDF2_SSAA=0.5
    else
        export OPENJKDF2_SSAA=0.75
    fi
fi

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

echo "OpenJKDF2 launch: mode=$([ "${OPENJKDF2_MOTS:-0}" = "1" ] && echo MOTS || echo JKDF2) CFW=${CFW_NAME:-?} arch=${DEVICE_ARCH:-?} display=${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
echo "OpenJKDF2 env: TRACE=${OPENJKDF2_TRACE:-?} SSAA=${OPENJKDF2_SSAA:-?} AUTO_DOWNSCALE=${OPENJKDF2_AUTO_DOWNSCALE:-1} FORCE_RES=${OPENJKDF2_FORCE_RES:-}"
if [ "$openjkdf2_is_rocknix" -eq 1 ]; then
    echo "ROCKNIX: sway=${OPENJKDF2_SWAY_FULLSCREEN:-0}"
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
        echo "${openjkdf2_fixup_tag:-jk1}: replacing empty ${want}/ with ${name}/"
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
    echo "${openjkdf2_fixup_tag:-jk1}: renaming ${name}/ -> ${want}/ (Linux needs lowercase)"
    mv "$entry" "$base/$want"
    return $?
  done
  return 1
}

openjkdf2_fixup_game_dirs() {
  local root="$1"
  openjkdf2_fixup_dir_case "$root" "episode" || true
  openjkdf2_fixup_dir_case "$root" "resource" || true
}

openjkdf2_fixup_tag=jk1
openjkdf2_fixup_game_dirs "$JK1DIR"

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

openjkdf2_ensure_asset_in() {
  local root="$1"
  local relpath="$2"
  local dir base dest src

  dest="$root/$relpath"
  [ -e "$dest" ] && return 0

  dir="$root/$(dirname "$relpath")"
  base=$(basename "$relpath")
  src=$(openjkdf2_find_insensitive "$dir" "$base") || return 1

  echo "${openjkdf2_fixup_tag}: renaming $(basename "$src") -> $relpath"
  mv "$src" "$dest"
}

openjkdf2_canonical_jk1_asset() {
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

openjkdf2_canonical_mots_asset() {
  case "${1,,}" in
    jkm_kfy.goo) echo "episode/JKM_KFY.goo" ;;
    jkm_mp.goo) echo "episode/JKM_MP.goo" ;;
    jkm_saber.goo) echo "episode/JKM_SABER.goo" ;;
    jkm.goo) echo "episode/JKM.goo" ;;
    jkmres.goo) echo "resource/Jkmres.goo" ;;
    jkmsndlo.goo) echo "resource/JKMsndLO.goo" ;;
    jk_.cd) echo "resource/jk_.cd" ;;
    *) return 1 ;;
  esac
}

openjkdf2_relocate_stray_assets_in() {
  local root="$1"
  local canon_fn="$2"
  local patterns="$3"
  local f base dest rel

  while IFS= read -r -d '' f; do
    base=$(basename "$f")
    dest=$("$canon_fn" "$base") || continue
    [ -e "$root/$dest" ] && continue
    mkdir -p "$root/$(dirname "$dest")"
    rel=$(realpath --relative-to="$root" "$f" 2>/dev/null || echo "$f")
    echo "${openjkdf2_fixup_tag}: moving stray ${rel} -> $dest"
    mv "$f" "$root/$dest"
  done < <(find "$root" $patterns \
    ! -path "$root/episode/*" ! -path "$root/resource/*" -print0 2>/dev/null)
}

openjkdf2_fixup_assets_in() {
  local root="$1"
  local canon_fn="$2"
  local patterns="$3"
  shift 3
  local req

  openjkdf2_relocate_stray_assets_in "$root" "$canon_fn" "$patterns"
  for req in "$@"; do
    openjkdf2_ensure_asset_in "$root" "$req" || true
  done
}

openjkdf2_mots_cd_is_valid() {
  local cd="$1"
  local b0 b1 b2 b3
  [ -f "$cd" ] || return 1
  b0=$(od -An -tu1 -N1 -j0 "$cd" 2>/dev/null | tr -d ' ')
  b1=$(od -An -tu1 -N1 -j1 "$cd" 2>/dev/null | tr -d ' ')
  b2=$(od -An -tu1 -N1 -j2 "$cd" 2>/dev/null | tr -d ' ')
  b3=$(od -An -tu1 -N1 -j3 "$cd" 2>/dev/null | tr -d ' ')
  # MOTS jk_.cd magic 0x3B426929 (LE bytes: 0x29 0x69 0x42 0x3B)
  [ "$b0" = "41" ] && [ "$b1" = "105" ] && [ "$b2" = "66" ] && [ "$b3" = "59" ]
}

openjkdf2_fixup_mots_optional() {
  local req missing=0

  [ -d "$MOTSDIR" ] || return 0
  [ -n "$(ls -A "$MOTSDIR" 2>/dev/null)" ] || return 0

  echo "MOTS: normalizing mots/ game data (optional expansion)"
  openjkdf2_fixup_tag=mots
  openjkdf2_fixup_game_dirs "$MOTSDIR"
  openjkdf2_fixup_assets_in "$MOTSDIR" openjkdf2_canonical_mots_asset \
    '\( -iname "*.goo" -o -iname "jk_.cd" \)' \
    "episode/JKM_KFY.goo" "episode/JKM_MP.goo" "episode/JKM_SABER.goo" "episode/JKM.goo" \
    "resource/Jkmres.goo" "resource/JKMsndLO.goo" "resource/jk_.cd"

  for req in \
    "episode/JKM_KFY.goo" "episode/JKM_MP.goo" "episode/JKM_SABER.goo" "episode/JKM.goo" \
    "resource/Jkmres.goo" "resource/JKMsndLO.goo" "resource/jk_.cd"
  do
    if [ ! -e "$MOTSDIR/$req" ]; then
      echo "MOTS MISSING: mots/$req"
      missing=1
    fi
  done

  if [ "$missing" -eq 1 ]; then
    echo "mots/episode/:"
    ls -la "$MOTSDIR/episode" 2>/dev/null || true
    echo "mots/resource/:"
    ls -la "$MOTSDIR/resource" 2>/dev/null || true
    echo "Any .goo/.cd under mots/:"
    find "$MOTSDIR" -maxdepth 3 \( -iname '*.goo' -o -iname 'jk_.cd' \) -print 2>/dev/null || true
    echo "MOTS: incomplete — menu will show Install until episode/ + resource/ are copied from Steam/GOG MOTS"
    return 0
  fi

  if openjkdf2_mots_cd_is_valid "$MOTSDIR/resource/jk_.cd"; then
    echo "MOTS: detected (resource/jk_.cd key OK)"
  else
    echo "MOTS WARN: resource/jk_.cd is not a MOTS key file — use MOTS CD data, not JKDF2"
  fi
}

openjkdf2_fixup_tag=jk1
openjkdf2_fixup_assets_in "$JK1DIR" openjkdf2_canonical_jk1_asset \
  '\( -iname "*.gob" -o -iname "jk_.cd" \)' \
  "episode/JK1.gob" "episode/JK1CTF.gob" "episode/JK1MP.gob" \
  "resource/Res1hi.gob" "resource/Res2.gob" "resource/jk_.cd"

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

openjkdf2_fixup_mots_optional

if [ "${OPENJKDF2_MOTS:-0}" = "1" ]; then
  missing_mots=0
  for req in \
    "episode/JKM_KFY.goo" "episode/JKM_MP.goo" "episode/JKM_SABER.goo" "episode/JKM.goo" \
    "resource/Jkmres.goo" "resource/JKMsndLO.goo" "resource/jk_.cd"
  do
    if [ ! -e "$MOTSDIR/$req" ]; then
      echo "MISSING (MOTS launch): mots/$req"
      missing_mots=1
    fi
  done
  if [ "$missing_mots" -eq 1 ]; then
    pm_message "MOTS launch needs .goo files in mots/episode/ and mots/resource/ (from Steam/GOG MOTS)."
    sleep 8
    exit 1
  fi
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

OPENJKDF2_GAME_ARGS=""
if [ "${OPENJKDF2_MOTS:-0}" = "1" ]; then
    OPENJKDF2_GAME_ARGS="-motsCompat"
fi

if command -v stdbuf >/dev/null 2>&1; then
    stdbuf -oL -eL ./openjkdf2.${DEVICE_ARCH} $OPENJKDF2_GAME_ARGS
else
    ./openjkdf2.${DEVICE_ARCH} $OPENJKDF2_GAME_ARGS
fi
game_exit=$?
echo "OpenJKDF2 exited with code $game_exit"
if [ -f "$GAMEDIR/startup.log" ]; then
    echo "--- GLES / display summary ---"
    grep -E 'GL_VERSION=|GL_RENDERER=|auto downscale|fill panel|VBufferNew failed|null pixels|AddToTextureCache|Texture cache exhausted' \
        "$GAMEDIR/startup.log" 2>/dev/null || true
    echo "--- startup.log ---"
    cat "$GAMEDIR/startup.log"
fi

pm_finish
