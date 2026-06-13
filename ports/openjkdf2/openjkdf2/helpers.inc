# Sourced from PortMaster wrappers after GAMEDIR/CONFDIR are set.

openjkdf2_dir_empty() {
  [ ! -d "$1" ] || [ -z "$(ls -A "$1" 2>/dev/null)" ]
}

openjkdf2_fixup_dir_case() {
  local base="$1" want="$2" entry name
  [ -d "$base" ] || return 1
  if [ -d "$base/$want" ] && ! openjkdf2_dir_empty "$base/$want"; then
    return 0
  fi
  if [ -d "$base/$want" ] && openjkdf2_dir_empty "$base/$want"; then
    for entry in "$base"/*; do
      [ -d "$entry" ] || continue
      name=$(basename "$entry")
      [ "$name" = "$want" ] || [ "${name,,}" != "$want" ] && continue
      openjkdf2_dir_empty "$entry" || { rm -rf "$base/$want"; mv "$entry" "$base/$want"; return 0; }
    done
  fi
  for entry in "$base"/*; do
    [ -d "$entry" ] || continue
    name=$(basename "$entry")
    [ "${name,,}" = "$want" ] || continue
    mv "$entry" "$base/$want"
    return 0
  done
  return 1
}

openjkdf2_find_insensitive() {
  local dir="$1" want="$2" entry base
  [ -e "$dir/$want" ] && { echo "$dir/$want"; return 0; }
  [ -d "$dir" ] || return 1
  for entry in "$dir"/*; do
    [ -e "$entry" ] || continue
    base=$(basename "$entry")
    [ "${base,,}" = "${want,,}" ] || continue
    echo "$entry"
    return 0
  done
  return 1
}

openjkdf2_ensure_asset() {
  local root="$1" relpath="$2" dir base src dest
  dest="$root/$relpath"
  [ -e "$dest" ] && return 0
  dir="$root/$(dirname "$relpath")"
  base=$(basename "$relpath")
  src=$(openjkdf2_find_insensitive "$dir" "$base") || return 1
  mv "$src" "$dest"
}

openjkdf2_prepare_jk1() {
  local req missing=0
  mkdir -p "$OPENJKDF2_ROOT" "$OPENJKMOTS_ROOT" "$GAMEDIR/expansions" "$GAMEDIR/mods"
  openjkdf2_fixup_dir_case "$OPENJKDF2_ROOT" episode || true
  openjkdf2_fixup_dir_case "$OPENJKDF2_ROOT" resource || true
  for req in episode/JK1.gob episode/JK1CTF.gob episode/JK1MP.gob \
             resource/Res1hi.gob resource/Res2.gob resource/jk_.cd; do
    openjkdf2_ensure_asset "$OPENJKDF2_ROOT" "$req" || true
  done
  if [ ! -d "$OPENJKDF2_ROOT/episode" ] || [ ! -d "$OPENJKDF2_ROOT/resource" ]; then
    pm_message "Copy JKDF2 to openjkdf2/jk1/episode/ and jk1/resource/ (lowercase)."
    sleep 5
    exit 1
  fi
  for req in episode/JK1.gob episode/JK1CTF.gob episode/JK1MP.gob \
             resource/Res1hi.gob resource/Res2.gob resource/jk_.cd; do
    [ -e "$OPENJKDF2_ROOT/$req" ] || missing=1
  done
  if [ "$missing" -eq 1 ]; then
    pm_message "Missing .gob/.cd in jk1/episode or jk1/resource."
    sleep 5
    exit 1
  fi
}

openjkdf2_ensure_goo_or_gob() {
  local root="$1" relpath_no_ext="$2" goo gob dir base src
  goo="${relpath_no_ext}.goo"
  gob="${relpath_no_ext}.gob"
  dir="$root/$(dirname "$relpath_no_ext")"
  base="$(basename "$relpath_no_ext")"
  [ -e "$root/$goo" ] && return 0
  openjkdf2_ensure_asset "$root" "$goo" && return 0
  src=$(openjkdf2_find_insensitive "$dir" "$base.gob") || return 1
  mv "$src" "$root/$goo"
}

openjkdf2_mots_cd_ok() {
  local cd magic
  cd=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT/resource" "jk_.cd") || return 1
  magic=$(od -An -tx4 -N4 "$cd" 2>/dev/null | tr -d ' \n')
  # MOTS jk_.cd magic (od -tx4 on LE: 0x3B426929; JKDF2 is 0xC4329269)
  [ "$magic" = "3b426929" ]
}

# Min sizes from a working Steam MOTS install (Jun 2026).
openjkdf2_mots_file_ok() {
  local relpath="$1" min_bytes="$2"
  local dir base found size
  dir="$OPENJKMOTS_ROOT/$(dirname "$relpath")"
  base="$(basename "$relpath")"
  found=$(openjkdf2_find_insensitive "$dir" "$base") || return 1
  size=$(stat -c%s "$found" 2>/dev/null) || return 1
  [ "$size" -ge "$min_bytes" ]
}

openjkdf2_mots_music_ok() {
  local dir count
  dir=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" "MUSIC") || return 1
  [ -d "$dir" ] || return 1
  count=$(find "$dir" -maxdepth 1 -type f -iname '*.ogg' 2>/dev/null | wc -l)
  [ "$count" -ge 10 ]
}

openjkdf2_mots_report_missing() {
  local msg="$1"
  echo "OpenJKDF2: MOTS — $msg" >&2
  openjkdf2_mots_errors+=("$msg")
}

openjkdf2_prepare_mots_launch() {
  local missing=0 warn=0 strict=0
  openjkdf2_mots_errors=()
  [ -d "$OPENJKMOTS_ROOT" ] || return 0
  [ "${OPENJKDF2_MOTS:-0}" = "1" ] && strict=1
  [ -d "$OPENJKMOTS_ROOT/episode" ] || [ -d "$OPENJKMOTS_ROOT/resource" ] || \
    [ -d "$OPENJKMOTS_ROOT/Episode" ] || [ -d "$OPENJKMOTS_ROOT/Resource" ] || return 0

  openjkdf2_fixup_dir_case "$OPENJKMOTS_ROOT" episode || true
  openjkdf2_fixup_dir_case "$OPENJKMOTS_ROOT" resource || true
  openjkdf2_fixup_dir_case "$OPENJKMOTS_ROOT" MUSIC || true
  openjkdf2_fixup_dir_case "$OPENJKMOTS_ROOT/resource" video || true

  for req in episode/JKM_KFY episode/JKM_MP episode/JKM_SABER episode/JKM \
             resource/Jkmres resource/JKMsndLO; do
    openjkdf2_ensure_goo_or_gob "$OPENJKMOTS_ROOT" "$req" || missing=1
  done
  openjkdf2_ensure_asset "$OPENJKMOTS_ROOT" "resource/jk_.cd" || true

  openjkdf2_mots_file_ok "episode/JKM.goo" 30000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM.goo (need ~36 MB)"; missing=1; }
  openjkdf2_mots_file_ok "episode/JKM_KFY.goo" 5000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM_KFY.goo (need ~7 MB)"; missing=1; }
  openjkdf2_mots_file_ok "episode/JKM_MP.goo" 12000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM_MP.goo (need ~15 MB)"; missing=1; }
  openjkdf2_mots_file_ok "episode/JKM_SABER.goo" 2000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM_SABER.goo (need ~2.5 MB)"; missing=1; }
  openjkdf2_mots_file_ok "resource/Jkmres.goo" 70000000 \
    || { openjkdf2_mots_report_missing "missing or too small: resource/Jkmres.goo (need ~85 MB)"; missing=1; }
  openjkdf2_mots_file_ok "resource/JKMsndLO.goo" 40000000 \
    || { openjkdf2_mots_report_missing "missing or too small: resource/JKMsndLO.goo (need ~46 MB)"; missing=1; }
  openjkdf2_mots_file_ok "resource/jk_.cd" 4 \
    || { openjkdf2_mots_report_missing "missing: resource/jk_.cd"; missing=1; }

  if ! openjkdf2_mots_cd_ok; then
    openjkdf2_mots_report_missing "resource/jk_.cd is not a MOTS key file (copy from MOTS, not JKDF2)"
    missing=1
  fi

  openjkdf2_mots_file_ok "resource/video/JKMINTRO.SAN" 10000000 \
    || { openjkdf2_mots_report_missing "missing or too small: resource/video/JKMINTRO.SAN"; missing=1; }

  if ! openjkdf2_mots_music_ok; then
    openjkdf2_mots_report_missing "MUSIC/ needs at least 10 .ogg tracks (copy the whole MUSIC folder)"
    missing=1
  fi

  if [ -d "$OPENJKMOTS_ROOT/player" ] && ! openjkdf2_dir_empty "$OPENJKMOTS_ROOT/player"; then
    : # GOG installs may include player/; Steam does not — both are fine
  fi

  if [ "$missing" -eq 1 ]; then
    warn=1
  fi
  if [ "$warn" -eq 1 ]; then
    echo "OpenJKDF2: MOTS data check failed. Copy episode/, resource/ (incl. video/), and MUSIC/ from Steam or GOG." >&2
  fi
  if [ "$missing" -eq 1 ] && [ "$strict" -eq 1 ]; then
    local detail="${openjkdf2_mots_errors[0]}"
    [ -n "$detail" ] || detail="see log.txt"
    pm_message "MOTS files incomplete: $detail"
    sleep 6
    exit 1
  fi
}

openjkdf2_guid_to_vidpid() {
  local guid="${1,,}"
  [ "${#guid}" -eq 32 ] || return 1
  printf '0x%04x/0x%04x' $((16#${guid:10:2}${guid:8:2})) $((16#${guid:18:2}${guid:16:2}))
}

openjkdf2_is_noise_js() {
  case "${1,,}" in
    *accelerometer*|*gyroscope*|*" motion"*|*" imu"*|*mouse*|*keyboard*|*touchpad*) return 0 ;;
  esac
  return 1
}

openjkdf2_is_handheld_js() {
  local name="${1,,}" handheld="${2,,}"
  [ -n "$handheld" ] && case "$name" in *"$handheld"*) return 0 ;; esac
  case "$name" in
    *odroidgo*|*retrogame*joy*|*"go-super"*|*ankergaming*|*rg35*|*rg34*|*rg40*|*trimui*) return 0 ;;
  esac
  return 1
}

openjkdf2_js_live() {
  local js="$1" phys="$2" name="$3" p connected bt
  [ -e "$js" ] && [ -e "/dev/input/$(basename "$js")" ] && [ -n "$name" ] || return 1
  p=$(readlink -f "$js/device" 2>/dev/null) || return 1
  while [ -n "$p" ] && [ "$p" != "/" ]; do
    if [ -f "$p/connected" ]; then
      connected=$(cat "$p/connected" 2>/dev/null)
      [ "$connected" = "1" ] && return 0
      return 1
    fi
    p=$(dirname "$p")
  done
  case "$phys" in
    *hci*|*bluetooth*)
      bt=$(echo "$phys" | grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' | head -n1)
      [ -n "$bt" ] && bluetoothctl info "$bt" 2>/dev/null | grep -q "Connected: yes" && return 0
      return 1 ;;
    usb-*|*/usb*)
      p=$(readlink -f "$js/device" 2>/dev/null) || return 1
      while [ -n "$p" ] && [ "$p" != "/" ]; do
        [ -f "$p/idVendor" ] && return 0
        p=$(dirname "$p")
      done
      return 1 ;;
  esac
  case "${name,,}" in *wireless*controller*|*dualsense*|*dualshock*) return 0 ;; esac
  return 0
}

openjkdf2_is_external_js() {
  local js="$1" name="$2" phys="$3" vendor="$4" product="$5" handheld_vid="$6" handheld_name="$7"
  local ext=0
  openjkdf2_is_noise_js "$name" && return 1
  openjkdf2_is_handheld_js "$name" "$handheld_name" && return 1
  case "${name,,}" in *calibrat*|*uinput*|*virtual*) return 1 ;; esac
  [ -n "$handheld_vid" ] && [ "0x${vendor}/0x${product}" = "$handheld_vid" ] && return 1
  case "$phys" in *hci*|*bluetooth*) ext=1 ;;
    usb-*|*/usb*) [ "$vendor" != "0000" ] && [ "$product" != "0000" ] && ext=1 ;; esac
  if [ "$ext" -eq 0 ]; then
    case "${name,,}" in
      *wireless*controller*|*xbox*|*x-box*|*playstation*|*dualsense*|*dualshock*|*8bitdo*|*8-bitdo*|*"pro controller"*|*switch*pro*)
        ext=1 ;;
    esac
  fi
  if [ "$ext" -eq 0 ]; then
    case "$vendor" in 045e|054c|057e|056e|2dc8|2e24|3537|0e6f|146b|0079|2563|20d6|31e4) ext=1 ;; esac
  fi
  [ "$ext" -eq 1 ] && openjkdf2_js_live "$js" "$phys" "$name"
}

openjkdf2_ignore_handheld_if_external() {
  [ "${OPENJKDF2_IGNORE_HANDHELD:-}" = "0" ] && return
  local guid="" handheld_name="" ignore_vid="" js_name js_phys js_vendor js_product
  local -a names=() vidpids=() externals=()
  local handheld_idx=-1 i

  if [ -n "${sdl_controllerconfig:-}" ]; then
    guid="${sdl_controllerconfig%%,*}"
    guid="${guid//[[:space:]]/}"
    handheld_name="${sdl_controllerconfig#*,}"
    handheld_name="${handheld_name%%,*}"
  fi
  openjkdf2_guid_to_vidpid "$guid" >/dev/null 2>&1 && ignore_vid=$(openjkdf2_guid_to_vidpid "$guid")

  for js in /sys/class/input/js*; do
    [ -e "$js" ] || continue
    js_name=$(cat "$js/device/name" 2>/dev/null) || continue
    openjkdf2_is_noise_js "$js_name" && continue
    js_phys=$(cat "$js/device/phys" 2>/dev/null || true)
    js_vendor=$(cat "$js/device/id/vendor" 2>/dev/null || echo 0000)
    js_product=$(cat "$js/device/id/product" 2>/dev/null || echo 0000)
    js_vendor=${js_vendor#0x}; js_product=${js_product#0x}
    names+=("$js_name")
    if [ "$js_vendor" != "0000" ] && [ "$js_product" != "0000" ]; then
      vidpids+=("0x${js_vendor}/0x${js_product}")
    else
      vidpids+=("")
    fi
    if [ "$handheld_idx" -lt 0 ] && openjkdf2_is_handheld_js "$js_name" "$handheld_name"; then
      handheld_idx=$((${#names[@]} - 1))
    fi
  done

  [ "$handheld_idx" -ge 0 ] && [ -n "${vidpids[$handheld_idx]}" ] && ignore_vid="${vidpids[$handheld_idx]}"

  for js in /sys/class/input/js*; do
    [ -e "$js" ] || continue
    js_name=$(cat "$js/device/name" 2>/dev/null) || continue
    js_phys=$(cat "$js/device/phys" 2>/dev/null || true)
    js_vendor=$(cat "$js/device/id/vendor" 2>/dev/null || echo 0000)
    js_product=$(cat "$js/device/id/product" 2>/dev/null || echo 0000)
    js_vendor=${js_vendor#0x}; js_product=${js_product#0x}
    openjkdf2_is_external_js "$js" "$js_name" "$js_phys" "$js_vendor" "$js_product" "$ignore_vid" "$handheld_name" \
      && externals+=("$js_name")
  done

  [ "${#externals[@]}" -eq 0 ] && [ "${OPENJKDF2_IGNORE_HANDHELD:-}" != "1" ] && return
  [ -z "$ignore_vid" ] && return
  export SDL_GAMECONTROLLER_IGNORE_DEVICES="$ignore_vid"
}

openjkdf2_prepare_jk1
openjkdf2_prepare_mots_launch
