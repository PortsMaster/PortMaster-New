# Sourced from PortMaster wrappers after get_controls.
# Ignore the handheld SDL gamepad when a live external pad is connected (HDMI dock).

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
