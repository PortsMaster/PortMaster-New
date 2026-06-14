# Swap for < 2 GB RAM (MOTS). Sourced from launch scripts after CONFDIR is set.
# Never tears down existing system swap; only removes swap this session created.

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

  for path in /swapfile /media/SHARE/swapfile; do
    if [ -f "$path" ] && openjkdf2_swap_try_activate "$path"; then
      cur_kb=$(openjkdf2_swap_total_kb)
      [ "$cur_kb" -ge "$want_kb" ] && { echo "OpenJKDF2: swap ok after activating $path"; return 0; }
    fi
  done

  if [ -n "${CONFDIR:-}" ] && openjkdf2_swap_create_file "$CONFDIR/openjkdf2.swap" "$want_mb"; then
    return 0
  fi

  case "$cfw" in
    *dArkOS*|*ArkOS*|*ODROID*)
      openjkdf2_swap_create_file "/swapfile" "$want_mb" && return 0
      openjkdf2_swap_try_zram "$want_mb" && return 0
      ;;
    *KNULLI*|*knulli*)
      openjkdf2_swap_create_file "/media/SHARE/swapfile" "$want_mb" && return 0
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
