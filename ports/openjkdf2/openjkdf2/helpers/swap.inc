# Swap for < 2 GB RAM (MOTS). Sourced from launch scripts after CONFDIR is set.

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

openjkdf2_cfw_is_darkos() {
  case "${1,,}" in *darkos*) return 0 ;; esac
  return 1
}

openjkdf2_swap_ensure_darkos() {
  local size_mb="${OPENJKDF2_SWAP_MB:-420}"
  local want_kb cur_kb
  want_kb=$((size_mb * 1024))
  cur_kb=$(openjkdf2_swap_total_kb)
  [ "$cur_kb" -ge "$want_kb" ] && return 0

  echo "OpenJKDF2: dArkOS zram swap (${size_mb}M)"
  [ -e /dev/zram0 ] && $ESUDO swapoff -a
  [ -e /dev/zram0 ] && $ESUDO zramctl --reset /dev/zram0
  [ -e /dev/zram1 ] && $ESUDO zramctl --reset /dev/zram1
  [ -e /dev/zram2 ] && $ESUDO zramctl --reset /dev/zram2
  modprobe zram
  $ESUDO zramctl --find --size "${size_mb}M"
  $ESUDO mkswap /dev/zram0
  $ESUDO swapon /dev/zram0

  cur_kb=$(openjkdf2_swap_total_kb)
  if [ "$cur_kb" -ge "$want_kb" ]; then
    echo "OpenJKDF2: dArkOS zram swap active (${cur_kb} kB total)"
    return 0
  fi
  echo "OpenJKDF2: dArkOS zram setup failed (swap still ${cur_kb} kB)" >&2
  return 1
}

openjkdf2_swap_ensure_arkos() {
  local size_mb="${OPENJKDF2_SWAP_MB:-420}"
  local want_kb cur_kb
  want_kb=$((size_mb * 1024))
  cur_kb=$(openjkdf2_swap_total_kb)
  [ "$cur_kb" -ge "$want_kb" ] && return 0

  echo "OpenJKDF2: ArkOS swapfile (${size_mb}M)"
  [ -f /swapfile ] && $ESUDO swapoff -v /swapfile
  [ -f /swapfile ] && $ESUDO rm -f /swapfile
  $ESUDO fallocate -l "${size_mb}M" /swapfile
  $ESUDO chmod 600 /swapfile
  $ESUDO mkswap /swapfile
  $ESUDO swapon /swapfile

  cur_kb=$(openjkdf2_swap_total_kb)
  if [ "$cur_kb" -ge "$want_kb" ]; then
    echo "OpenJKDF2: ArkOS swapfile active (${cur_kb} kB total)"
    return 0
  fi
  echo "OpenJKDF2: ArkOS swapfile setup failed (swap still ${cur_kb} kB)" >&2
  return 1
}

openjkdf2_swap_ensure_knulli() {
  local size_mb="${OPENJKDF2_SWAP_MB:-420}"
  local want_kb cur_kb
  want_kb=$((size_mb * 1024))
  cur_kb=$(openjkdf2_swap_total_kb)
  [ "$cur_kb" -ge "$want_kb" ] && return 0

  echo "OpenJKDF2: KNULLI swapfile (${size_mb}M)"
  [ -f /media/SHARE/swapfile ] && $ESUDO swapoff -v /media/SHARE/swapfile
  [ -f /media/SHARE/swapfile ] && $ESUDO rm -f /media/SHARE/swapfile
  $ESUDO fallocate -l "${size_mb}M" /media/SHARE/swapfile
  $ESUDO chmod 600 /media/SHARE/swapfile
  $ESUDO mkswap /media/SHARE/swapfile
  $ESUDO swapon /media/SHARE/swapfile

  cur_kb=$(openjkdf2_swap_total_kb)
  if [ "$cur_kb" -ge "$want_kb" ]; then
    echo "OpenJKDF2: KNULLI swapfile active (${cur_kb} kB total)"
    return 0
  fi
  echo "OpenJKDF2: KNULLI swapfile setup failed (swap still ${cur_kb} kB)" >&2
  return 1
}

openjkdf2_ensure_swap() {
  local ram_gb want_kb cur_kb cfw size_mb
  [ "${OPENJKDF2_SWAP:-1}" = "0" ] && return 0

  ram_gb=$(openjkdf2_device_ram_gb)
  [ -n "$ram_gb" ] && [ "$ram_gb" -lt 2 ] 2>/dev/null || return 0

  cfw="${CFW_NAME:-}"
  size_mb="${OPENJKDF2_SWAP_MB:-420}"
  want_kb=$((size_mb * 1024))
  cur_kb=$(openjkdf2_swap_total_kb)
  if [ "$cur_kb" -ge "$want_kb" ]; then
    echo "OpenJKDF2: swap ok (${cur_kb} kB active, target ${want_kb} kB)"
    return 0
  fi

  echo "OpenJKDF2: low RAM (${ram_gb} GB), swap ${cur_kb} kB < ${want_kb} kB — adding swap (CFW_NAME=${cfw:-unset})"

  # dArkOS: never use /swapfile (overlay → EINVAL). Slayer366 RG503 path.
  if openjkdf2_cfw_is_darkos "$cfw"; then
    openjkdf2_swap_ensure_darkos && return 0
    echo "OpenJKDF2: warning — could not add swap; MOTS may OOM on this device" >&2
    return 1
  fi

  if [[ "${cfw:-}" == *"ArkOS"* ]] || [[ "${cfw:-}" == *"ODROID"* ]]; then
    openjkdf2_swap_ensure_arkos && return 0
    echo "OpenJKDF2: warning — could not add swap; MOTS may OOM on this device" >&2
    return 1
  fi

  if [[ "${cfw^^}" == "KNULLI" ]]; then
    openjkdf2_swap_ensure_knulli && return 0
    echo "OpenJKDF2: warning — could not add swap; MOTS may OOM on this device" >&2
    return 1
  fi

  echo "OpenJKDF2: warning — no swap helper for CFW_NAME=${cfw:-unset}; MOTS may OOM on <2GB" >&2
  return 1
}

openjkdf2_swap_cleanup() {
  :
}
