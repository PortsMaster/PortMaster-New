# Sourced from PortMaster wrappers after GAMEDIR/CONFDIR are set.

openjkdf2_dir_empty() {
  [ ! -d "$1" ] || [ -z "$(ls -A "$1" 2>/dev/null)" ]
}

# exFAT/vfat: case-only renames need a temp hop (JK1.GOB -> jk1.gob). Use ESUDO on dArkOS.
openjkdf2_mv() {
  if [ -n "${ESUDO:-}" ]; then
    $ESUDO mv "$@"
  else
    mv "$@"
  fi
}

openjkdf2_mv_casefix() {
  local src="$1" dst="$2" dir base tmp
  [ -e "$src" ] || return 1
  [ "$src" = "$dst" ] && return 0
  dir=$(dirname "$dst")
  base=$(basename "$dst")
  tmp="$dir/.openjkdf2_casefix_${base}_$$"
  openjkdf2_mv "$src" "$tmp" || return 1
  openjkdf2_mv "$tmp" "$dst" || return 1
}

openjkdf2_lowercase_tree() {
  local root="$1" src dst dst_base
  [ -d "$root" ] || return 0
  while IFS= read -r -d '' src; do
    [ -e "$src" ] || continue
    dst_base=$(basename "$src" | tr '[:upper:]' '[:lower:]')
    dst="$(dirname "$src")/$dst_base"
    [ "$src" != "$dst" ] && openjkdf2_mv_casefix "$src" "$dst" || true
  done < <(find "$root" -depth -mindepth 1 -print0 2>/dev/null)
}

openjkdf2_fixup_dir_case() {
  local base="$1" want="$2" entry name
  [ -d "$base" ] || return 1
  openjkdf2_fs_case_insensitive "$base" && return 0
  if openjkdf2_find_insensitive "$base" "$want" >/dev/null; then
    return 0
  fi
  for entry in "$base"/*; do
    [ -d "$entry" ] || continue
    name=$(basename "$entry")
    [ "${name,,}" = "${want,,}" ] || continue
    openjkdf2_mv_casefix "$entry" "$base/$want"
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

# exFAT/vfat: case-only paths look identical to the kernel — bulk rename breaks layouts.
openjkdf2_fs_case_insensitive() {
  local dir="${1:-.}" tag hi lo
  mkdir -p "$dir" 2>/dev/null || return 1
  tag="openjkdf2_case_$$"
  hi=".${tag}_Hi"
  lo=".${tag}_lo"
  rm -f "$dir/$hi" "$dir/$lo" 2>/dev/null
  touch "$dir/$hi" 2>/dev/null || return 1
  if [ -f "$dir/$lo" ]; then
    rm -f "$dir/$hi" "$dir/$lo" 2>/dev/null
    return 0
  fi
  rm -f "$dir/$hi" 2>/dev/null
  return 1
}

openjkdf2_normalize_tree() {
  local root="$1"
  [ -d "$root" ] || return 0
  if openjkdf2_fs_case_insensitive "$root"; then
    echo "OpenJKDF2: case-insensitive FS at $root — no renames"
    return 0
  fi
  openjkdf2_fixup_dir_case "$root" episode || true
  openjkdf2_fixup_dir_case "$root" resource || true
}

openjkdf2_normalize_mots_tree() {
  local root="$1"
  [ -d "$root" ] || return 0
  if openjkdf2_fs_case_insensitive "$root"; then
    echo "OpenJKDF2: case-insensitive FS at $root — no renames (mots)"
    return 0
  fi
  openjkdf2_fixup_dir_case "$root" episode || true
  openjkdf2_fixup_dir_case "$root" resource || true
  openjkdf2_fixup_dir_case "$root" MUSIC || true
}

openjkdf2_ensure_asset() {
  local root="$1" relpath="$2" dir base src dest parent
  parent="$(dirname "$relpath")"
  base="$(basename "$relpath")"
  dir=$(openjkdf2_find_insensitive "$root" "$parent") || dir="$root/$parent"
  dest="$dir/$base"
  src=$(openjkdf2_find_insensitive "$dir" "$base") || return 1
  [ "$(basename "$src")" = "$base" ] && return 0
  if openjkdf2_fs_case_insensitive "$dir"; then
    return 0
  fi
  openjkdf2_mv_casefix "$src" "$dest"
}

openjkdf2_find_recursive() {
  local root="$1" name="$2" found
  [ -d "$root" ] || return 1
  found=$(find "$root" -maxdepth 5 -iname "$name" -print -quit 2>/dev/null)
  [ -n "$found" ] || return 1
  echo "$found"
}

openjkdf2_resolve_subdir() {
  local root="$1" subdir="$2" part dir="$root"
  local IFS='/'
  for part in $subdir; do
    dir=$(openjkdf2_find_insensitive "$dir" "$part") || dir="$dir/$part"
  done
  echo "$dir"
}

openjkdf2_relocate_if_found() {
  local root="$1" subdir="$2" filename="$3"
  local dest_dir found found_dir
  dest_dir=$(openjkdf2_resolve_subdir "$root" "$subdir")
  mkdir -p "$dest_dir" 2>/dev/null || return 1
  if openjkdf2_find_insensitive "$dest_dir" "$filename" >/dev/null; then
    return 0
  fi
  found=$(openjkdf2_find_recursive "$root" "$filename") || return 1
  [ -n "$found" ] || return 1
  found_dir=$(dirname "$found")
  if [ "${found_dir,,}" = "${dest_dir,,}" ]; then
    return 0
  fi
  echo "OpenJKDF2: moving misplaced $filename from $found_dir to $dest_dir"
  openjkdf2_mv "$found" "$dest_dir/" || return 1
  return 0
}

openjkdf2_recover_jk1_layout() {
  local f
  mkdir -p "$OPENJKDF2_ROOT/episode" "$OPENJKDF2_ROOT/resource" 2>/dev/null || true
  openjkdf2_normalize_tree "$OPENJKDF2_ROOT"
  for f in JK1.gob JK1CTF.gob JK1MP.gob; do
    openjkdf2_relocate_if_found "$OPENJKDF2_ROOT" episode "$f" || true
  done
  for f in Res1hi.gob Res2.gob jk_.cd; do
    openjkdf2_relocate_if_found "$OPENJKDF2_ROOT" resource "$f" || true
  done
}

openjkdf2_find_goo_or_gob() {
  local root="$1" relpath_no_ext="$2" base found
  base="$(basename "$relpath_no_ext")"
  found=$(openjkdf2_find_recursive "$root" "${base}.goo") || \
    found=$(openjkdf2_find_recursive "$root" "${base}.gob") || return 1
  [ -n "$found" ] || return 1
  echo "$found"
}

openjkdf2_relocate_goo_or_gob() {
  local root="$1" subdir="$2" base="$3"
  openjkdf2_relocate_if_found "$root" "$subdir" "${base}.goo" || true
  openjkdf2_relocate_if_found "$root" "$subdir" "${base}.gob" || true
}

openjkdf2_recover_mots_layout() {
  local f found
  mkdir -p "$OPENJKMOTS_ROOT/episode" "$OPENJKMOTS_ROOT/resource" 2>/dev/null || true
  openjkdf2_normalize_mots_tree "$OPENJKMOTS_ROOT"
  for f in JKM JKM_KFY JKM_MP JKM_SABER; do
    openjkdf2_relocate_goo_or_gob "$OPENJKMOTS_ROOT" episode "$f"
  done
  for f in Jkmres JKMsndLO; do
    openjkdf2_relocate_goo_or_gob "$OPENJKMOTS_ROOT" resource "$f"
  done
  openjkdf2_relocate_if_found "$OPENJKMOTS_ROOT" resource "jk_.cd" || true
  found=$(openjkdf2_find_recursive "$OPENJKMOTS_ROOT" "JKMINTRO.SAN") || found=""
  if [ -n "$found" ]; then
    openjkdf2_relocate_if_found "$OPENJKMOTS_ROOT" "resource/video" "JKMINTRO.SAN" || true
  fi
  if ! openjkdf2_fs_case_insensitive "$OPENJKMOTS_ROOT"; then
    for f in episode/JKM episode/JKM_KFY episode/JKM_MP episode/JKM_SABER \
      resource/Jkmres resource/JKMsndLO; do
      openjkdf2_ensure_goo_or_gob "$OPENJKMOTS_ROOT" "$f" || true
    done
  fi
}

openjkdf2_has_subdir() {
  openjkdf2_find_insensitive "$1" "$2" >/dev/null
}

openjkdf2_jk1_has_asset() {
  local subdir="$1" filename="$2" dir
  dir=$(openjkdf2_find_insensitive "$OPENJKDF2_ROOT" "$subdir") || return 1
  openjkdf2_find_insensitive "$dir" "$filename" >/dev/null && return 0
  openjkdf2_find_recursive "$OPENJKDF2_ROOT" "$filename" >/dev/null
}

openjkdf2_has_jk1_layout() {
  openjkdf2_has_subdir "$OPENJKDF2_ROOT" resource
}

openjkdf2_jk1_assets_complete() {
  local missing=0 f
  for f in JK1.gob JK1CTF.gob JK1MP.gob; do
    openjkdf2_jk1_has_asset episode "$f" || missing=1
  done
  for f in Res1hi.gob Res2.gob jk_.cd; do
    openjkdf2_jk1_has_asset resource "$f" || missing=1
  done
  [ "$missing" -eq 0 ]
}

openjkdf2_prepare_jk1() {
  local strict=1 epdir resdir f hint

  mkdir -p "$OPENJKDF2_ROOT" "$OPENJKMOTS_ROOT" "$GAMEDIR/expansions" "$GAMEDIR/mods"
  [ "${OPENJKDF2_MOTS:-0}" = "1" ] && strict=0

  if ! openjkdf2_has_subdir "$OPENJKDF2_ROOT" resource; then
    if [ "$strict" -eq 0 ]; then
      echo "OpenJKDF2: no jk1/ data (OK for MOTS-only)"
      return 0
    fi
    echo "OpenJKDF2: missing jk1/resource/ under $OPENJKDF2_ROOT" >&2
    ls -la "$OPENJKDF2_ROOT" 2>/dev/null >&2 || true
    pm_message "Missing jk1/resource/. Copy JKDF2 game data."
    sleep 6
    exit 1
  fi

  openjkdf2_recover_jk1_layout

  epdir=$(openjkdf2_find_insensitive "$OPENJKDF2_ROOT" episode) || epdir="$OPENJKDF2_ROOT/episode"
  resdir=$(openjkdf2_find_insensitive "$OPENJKDF2_ROOT" resource) || resdir="$OPENJKDF2_ROOT/resource"
  echo "OpenJKDF2: jk1 episode=$epdir resource=$resdir"

  if ! openjkdf2_jk1_assets_complete; then
    if [ "$strict" -eq 0 ]; then
      echo "OpenJKDF2: jk1/ incomplete — skipped (MOTS uses mots/)" >&2
      return 0
    fi
    for f in JK1.gob JK1CTF.gob JK1MP.gob Res1hi.gob Res2.gob jk_.cd; do
      hint=$(openjkdf2_find_recursive "$OPENJKDF2_ROOT" "$f")
      [ -n "$hint" ] && echo "OpenJKDF2: found $f at $hint" >&2
    done
    ls -la "$epdir" 2>/dev/null >&2 || true
    ls -la "$resdir" 2>/dev/null >&2 || true
    pm_message "Missing jk1/episode/ (.gob) or resource/ files. Re-copy from Steam/GOG."
    sleep 6
    exit 1
  fi

  echo "OpenJKDF2: jk1/ data OK"
}

openjkdf2_ensure_goo_or_gob() {
  local root="$1" relpath_no_ext="$2" goo gob dir base src
  goo="${relpath_no_ext}.goo"
  gob="${relpath_no_ext}.gob"
  dir="$root/$(dirname "$relpath_no_ext")"
  base="$(basename "$relpath_no_ext")"
  [ -e "$root/$goo" ] && return 0
  openjkdf2_ensure_asset "$root" "$goo" && return 0
  if openjkdf2_fs_case_insensitive "$dir"; then
    openjkdf2_find_insensitive "$dir" "${base}.gob" >/dev/null && return 0
    openjkdf2_find_recursive "$root" "${base}.gob" >/dev/null && return 0
    return 1
  fi
  src=$(openjkdf2_find_insensitive "$dir" "${base}.gob") || return 1
  openjkdf2_mv_casefix "$src" "$root/$goo"
}

openjkdf2_mots_cd_ok() {
  local resdir cd magic
  resdir=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" resource) || return 1
  cd=$(openjkdf2_find_insensitive "$resdir" "jk_.cd") || return 1
  magic=$(od -An -tx4 -N4 "$cd" 2>/dev/null | tr -d ' \n')
  # MOTS jk_.cd magic (od -tx4 on LE: 0x3B426929; JKDF2 is 0xC4329269)
  [ "$magic" = "3b426929" ]
}

# Min sizes from a working Steam MOTS install (Jun 2026). Accepts .goo or .gob.
openjkdf2_mots_archive_ok() {
  local relpath_no_ext="$1" min_bytes="$2"
  local found size
  found=$(openjkdf2_find_goo_or_gob "$OPENJKMOTS_ROOT" "$relpath_no_ext") || return 1
  size=$(stat -c%s "$found" 2>/dev/null) || return 1
  [ "$size" -ge "$min_bytes" ]
}

openjkdf2_mots_plain_file_ok() {
  local filename="$1" min_bytes="$2"
  local found size
  found=$(openjkdf2_find_recursive "$OPENJKMOTS_ROOT" "$filename") || return 1
  size=$(stat -c%s "$found" 2>/dev/null) || return 1
  [ "$size" -ge "$min_bytes" ]
}

openjkdf2_mots_music_ok() {
  local dir count
  dir=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" "MUSIC") || \
    dir=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" "music") || return 1
  [ -d "$dir" ] || return 1
  count=$(find "$dir" -maxdepth 1 -type f -iname '*.ogg' 2>/dev/null | wc -l)
  [ "$count" -ge 10 ]
}

openjkdf2_mots_has_layout() {
  openjkdf2_has_subdir "$OPENJKMOTS_ROOT" episode && \
    openjkdf2_has_subdir "$OPENJKMOTS_ROOT" resource
}

openjkdf2_mots_report_missing() {
  local msg="$1"
  echo "OpenJKDF2: MOTS — $msg" >&2
  openjkdf2_mots_errors+=("$msg")
}

openjkdf2_prepare_mots_launch() {
  local missing=0 strict=0 detail f hint

  openjkdf2_mots_errors=()
  [ -d "$OPENJKMOTS_ROOT" ] || return 0
  [ "${OPENJKDF2_MOTS:-0}" = "1" ] && strict=1

  if ! openjkdf2_has_subdir "$OPENJKMOTS_ROOT" resource; then
    if [ "$strict" -eq 1 ]; then
      pm_message "Missing mots/resource/. Copy MOTS game data."
      sleep 6
      exit 1
    fi
    return 0
  fi

  openjkdf2_recover_mots_layout

  echo "OpenJKDF2: mots episode=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" episode) resource=$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" resource)"

  openjkdf2_mots_archive_ok "episode/JKM" 30000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM (.goo or .gob, need ~36 MB)"; missing=1; }
  openjkdf2_mots_archive_ok "episode/JKM_KFY" 5000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM_KFY (.goo or .gob, need ~7 MB)"; missing=1; }
  openjkdf2_mots_archive_ok "episode/JKM_MP" 12000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM_MP (.goo or .gob, need ~15 MB)"; missing=1; }
  openjkdf2_mots_archive_ok "episode/JKM_SABER" 2000000 \
    || { openjkdf2_mots_report_missing "missing or too small: episode/JKM_SABER (.goo or .gob, need ~2.5 MB)"; missing=1; }
  openjkdf2_mots_archive_ok "resource/Jkmres" 70000000 \
    || { openjkdf2_mots_report_missing "missing or too small: resource/Jkmres (.goo or .gob, need ~85 MB)"; missing=1; }
  openjkdf2_mots_archive_ok "resource/JKMsndLO" 40000000 \
    || { openjkdf2_mots_report_missing "missing or too small: resource/JKMsndLO (.goo or .gob, need ~46 MB)"; missing=1; }
  openjkdf2_mots_plain_file_ok "jk_.cd" 4 \
    || { openjkdf2_mots_report_missing "missing: resource/jk_.cd"; missing=1; }

  if ! openjkdf2_mots_cd_ok; then
    openjkdf2_mots_report_missing "resource/jk_.cd is not a MOTS key file (copy from MOTS, not JKDF2)"
    missing=1
  fi

  openjkdf2_mots_plain_file_ok "JKMINTRO.SAN" 10000000 \
    || { openjkdf2_mots_report_missing "missing or too small: resource/video/JKMINTRO.SAN"; missing=1; }

  if ! openjkdf2_mots_music_ok; then
    openjkdf2_mots_report_missing "music/ or MUSIC/ needs at least 10 .ogg tracks"
    missing=1
  fi

  if [ "$missing" -eq 1 ]; then
    echo "OpenJKDF2: MOTS data check failed. Copy episode/, resource/ (incl. video/), and music/ from Steam or GOG." >&2
    for f in JKM JKM_KFY JKM_MP JKM_SABER; do
      hint=$(openjkdf2_find_goo_or_gob "$OPENJKMOTS_ROOT" "episode/$f")
      [ -n "$hint" ] && echo "OpenJKDF2: found $f at $hint" >&2
    done
    ls -la "$(openjkdf2_find_insensitive "$OPENJKMOTS_ROOT" episode)" 2>/dev/null >&2 || true
    if [ "$strict" -eq 1 ]; then
      detail="${openjkdf2_mots_errors[0]}"
      [ -n "$detail" ] || detail="see log.txt"
      pm_message "MOTS incomplete: $detail"
      sleep 6
      exit 1
    fi
    return 0
  fi

  echo "OpenJKDF2: MOTS data OK"
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

# --- Swap helpers (< 2 GB RAM). Never tears down existing system swap. ---

openjkdf2_device_ram_gb() {
  if [ -n "${DEVICE_RAM:-}" ] && [ "${DEVICE_RAM:-0}" -gt 0 ] 2>/dev/null; then
    echo "$DEVICE_RAM"
    return 0
  fi
  awk '/MemTotal:/ {printf "%d\n", int(($2 + 524287) / 1048576)}' /proc/meminfo 2>/dev/null
}

openjkdf2_swap_total_kb() {
  awk 'NR > 1 {sum += $3} END {print sum + 0}' /proc/swaps 2>/dev/null
}

openjkdf2_fs_supports_swap() {
  local dir="$1" fstype
  [ -d "$dir" ] || mkdir -p "$dir" 2>/dev/null || return 1
  fstype=$(df -T "$dir" 2>/dev/null | awk 'NR == 2 {print $2}')
  case "${fstype,,}" in
    vfat|exfat|msdos|fuseblk|ntfs) return 1 ;;
    *) return 0 ;;
  esac
}

openjkdf2_swap_try_activate() {
  local path="$1"
  [ -f "$path" ] || return 1
  grep -Fq "$path" /proc/swaps 2>/dev/null && return 0
  if [ -n "${ESUDO:-}" ]; then
    $ESUDO swapon "$path" 2>/dev/null
  else
    swapon "$path" 2>/dev/null
  fi
  grep -Fq "$path" /proc/swaps 2>/dev/null
}

openjkdf2_swap_create_file() {
  local path="$1" size_mb="$2"
  local dir size_kb cur_kb
  dir=$(dirname "$path")
  mkdir -p "$dir" 2>/dev/null || return 1
  openjkdf2_fs_supports_swap "$dir" || return 1

  size_kb=$((size_mb * 1024))
  cur_kb=$(openjkdf2_swap_total_kb)
  if [ "$cur_kb" -ge "$size_kb" ]; then
    echo "OpenJKDF2: swap already sufficient (${cur_kb} kB active)"
    return 0
  fi

  if [ -f "$path" ]; then
    if openjkdf2_swap_try_activate "$path"; then
      echo "OpenJKDF2: reusing existing swap file $path"
      return 0
    fi
    echo "OpenJKDF2: removing stale swap file $path"
    if [ -n "${ESUDO:-}" ]; then
      $ESUDO rm -f "$path"
    else
      rm -f "$path"
    fi
  fi

  echo "OpenJKDF2: creating ${size_mb}M swap at $path"
  if [ -n "${ESUDO:-}" ]; then
    $ESUDO fallocate -l "${size_mb}M" "$path" || $ESUDO truncate -s "${size_mb}M" "$path" || return 1
    $ESUDO chmod 600 "$path"
    $ESUDO mkswap "$path" >/dev/null || return 1
    $ESUDO swapon "$path" || return 1
  else
    fallocate -l "${size_mb}M" "$path" || truncate -s "${size_mb}M" "$path" || return 1
    chmod 600 "$path"
    mkswap "$path" >/dev/null || return 1
    swapon "$path" || return 1
  fi

  export OPENJKDF2_SWAP_CREATED=1
  export OPENJKDF2_SWAP_PATH="$path"
  echo "OpenJKDF2: swap active ($(openjkdf2_swap_total_kb) kB total)"
  return 0
}

openjkdf2_swap_try_zram() {
  local size_mb="$1" size_kb cur_kb zdev
  [ "${OPENJKDF2_SWAP_ZRAM:-1}" = "0" ] && return 1

  cur_kb=$(openjkdf2_swap_total_kb)
  size_kb=$((size_mb * 1024))
  [ "$cur_kb" -ge "$size_kb" ] && return 0

  if grep -q '[[:space:]]zram' /proc/swaps 2>/dev/null; then
    echo "OpenJKDF2: zram swap already active ($(openjkdf2_swap_total_kb) kB), not resetting"
    return 0
  fi

  if [ -n "${ESUDO:-}" ]; then
    $ESUDO modprobe zram 2>/dev/null || return 1
  else
    modprobe zram 2>/dev/null || return 1
  fi

  zdev=""
  for zdev in /dev/zram0 /dev/zram1 /dev/zram2; do
    [ -b "$zdev" ] || continue
    grep -Fq "$zdev" /proc/swaps 2>/dev/null && continue
    echo "OpenJKDF2: enabling ${size_mb}M zram swap on $zdev"
    if [ -n "${ESUDO:-}" ]; then
      $ESUDO sh -c "echo ${size_mb}M > /sys/block/$(basename "$zdev")/disksize" 2>/dev/null || continue
      $ESUDO mkswap "$zdev" >/dev/null 2>&1 || continue
      $ESUDO swapon "$zdev" 2>/dev/null || continue
    else
      echo "${size_mb}M" > "/sys/block/$(basename "$zdev")/disksize" 2>/dev/null || continue
      mkswap "$zdev" >/dev/null 2>&1 || continue
      swapon "$zdev" 2>/dev/null || continue
    fi
    export OPENJKDF2_SWAP_CREATED=1
    export OPENJKDF2_SWAP_PATH="$zdev"
    export OPENJKDF2_SWAP_IS_ZRAM=1
    echo "OpenJKDF2: zram swap active ($(openjkdf2_swap_total_kb) kB total)"
    return 0
  done
  return 1
}

# Extra swap for MOTS / heavy levels on 1 GB devices. Skips if enough swap exists.
openjkdf2_ensure_swap() {
  local ram_gb want_mb want_kb cur_kb cfw
  [ "${OPENJKDF2_SWAP:-1}" = "0" ] && return 0

  ram_gb=$(openjkdf2_device_ram_gb)
  [ -n "$ram_gb" ] && [ "$ram_gb" -lt 2 ] 2>/dev/null || return 0

  want_mb="${OPENJKDF2_SWAP_MB:-420}"
  want_kb=$((want_mb * 1024))
  cur_kb=$(openjkdf2_swap_total_kb)
  if [ "$cur_kb" -ge "$want_kb" ]; then
    echo "OpenJKDF2: swap ok (${cur_kb} kB active, target ${want_kb} kB)"
    return 0
  fi

  cfw="${CFW_NAME:-}"
  echo "OpenJKDF2: low RAM (${ram_gb} GB), swap ${cur_kb} kB < ${want_kb} kB — adding swap"

  # Reuse common CFW swap files if present (do not delete/recreate).
  for path in /swapfile /media/SHARE/swapfile; do
    if [ -f "$path" ] && openjkdf2_swap_try_activate "$path"; then
      cur_kb=$(openjkdf2_swap_total_kb)
      [ "$cur_kb" -ge "$want_kb" ] && { echo "OpenJKDF2: swap ok after activating $path"; return 0; }
    fi
  done

  # Prefer a port-local swap file when the conf dir is on a Linux FS.
  if [ -n "${CONFDIR:-}" ] && openjkdf2_swap_create_file "$CONFDIR/openjkdf2.swap" "$want_mb"; then
    return 0
  fi

  case "$cfw" in
    *dArkOS*|*ArkOS*|*ODROID*)
      if openjkdf2_swap_create_file "/swapfile" "$want_mb"; then
        return 0
      fi
      openjkdf2_swap_try_zram "$want_mb" && return 0
      ;;
    *KNULLI*|*knulli*)
      if openjkdf2_swap_create_file "/media/SHARE/swapfile" "$want_mb"; then
        return 0
      fi
      ;;
    *)
      openjkdf2_swap_try_zram "$want_mb" && return 0
      ;;
  esac

  echo "OpenJKDF2: warning — could not add swap; MOTS may OOM on this device" >&2
  return 1
}

openjkdf2_swap_cleanup() {
  local path="${OPENJKDF2_SWAP_PATH:-}"
  [ "${OPENJKDF2_SWAP_CREATED:-0}" = "1" ] || return 0
  [ -n "$path" ] || return 0

  echo "OpenJKDF2: removing session swap $path"
  if [ -n "${ESUDO:-}" ]; then
    $ESUDO swapoff "$path" 2>/dev/null || true
    if [ "${OPENJKDF2_SWAP_IS_ZRAM:-0}" != "1" ] && [ -f "$path" ]; then
      $ESUDO rm -f "$path"
    fi
  else
    swapoff "$path" 2>/dev/null || true
    if [ "${OPENJKDF2_SWAP_IS_ZRAM:-0}" != "1" ] && [ -f "$path" ]; then
      rm -f "$path"
    fi
  fi
  unset OPENJKDF2_SWAP_CREATED OPENJKDF2_SWAP_PATH OPENJKDF2_SWAP_IS_ZRAM
}

openjkdf2_log_launch() {
  echo "OpenJKDF2 launch: mode=$([ "${OPENJKDF2_MOTS:-0}" = "1" ] && echo MOTS || echo JKDF2) CFW=${CFW_NAME:-?} arch=${DEVICE_ARCH:-?} ram=$(openjkdf2_device_ram_gb)GB display=${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?} swap=$(openjkdf2_swap_total_kb)kB"
}

if [ "${OPENJKDF2_MOTS:-0}" = "1" ]; then
  openjkdf2_prepare_mots_launch
  openjkdf2_prepare_jk1
else
  openjkdf2_prepare_jk1
fi
