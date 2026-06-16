# Low-RAM swap for MOTS (~1 GB). Sourced from launch scripts after control.txt.
#
# Only create swap when MemTotal <= 1.25 GB and no active swap.
# LibreELEC family (ROCKNIX, JELOS, AmberELEC): zram if user has not enabled OS swap.
# ArkOS: /swapfile (Slayer366). KNULLI: dd → /media/SHARE/system/swap (exFAT-safe).
# OPENJKDF2_SWAP=0 disables; OPENJKDF2_SWAP_MB defaults to 384.

OPENJKDF2_SWAP_CREATED=""

openjkdf2_cfw_lc() {
  printf '%s' "${1,,}"
}

openjkdf2_swap_ensure_zram() {
  local size_mb="$1"
  echo "OpenJKDF2: zram swap (${size_mb}M)"
  [ -e /dev/zram0 ] && $ESUDO swapoff -a
  [ -e /dev/zram0 ] && $ESUDO zramctl --reset /dev/zram0
  modprobe zram 2>/dev/null || true
  $ESUDO zramctl --find --size "${size_mb}M"
  $ESUDO mkswap /dev/zram0
  $ESUDO swapon /dev/zram0
  OPENJKDF2_SWAP_CREATED=zram
}

openjkdf2_ensure_swap() {
  local mem_kb swap_kb size_mb cfw cfw_lc
  [ "${OPENJKDF2_SWAP:-1}" = "0" ] && return 0

  mem_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null)
  swap_kb=$(awk 'NR > 1 {s += $3} END {print s + 0}' /proc/swaps 2>/dev/null)
  size_mb="${OPENJKDF2_SWAP_MB:-384}"
  cfw="${CFW_NAME:-}"
  cfw_lc=$(openjkdf2_cfw_lc "$cfw")

  [ -n "$mem_kb" ] && [ "$mem_kb" -le 1250000 ] || return 0
  [ "${swap_kb:-0}" -eq 0 ] || return 0

  echo "OpenJKDF2: low RAM (${mem_kb} kB), no swap — adding ${size_mb}M (CFW_NAME=${cfw:-unset})"

  if [[ "$cfw_lc" == *"darkos"* ]]; then
    echo "OpenJKDF2: dArkOS"
    openjkdf2_swap_ensure_zram "$size_mb"

  elif [[ "$cfw_lc" == *"muos"* ]]; then
    echo "OpenJKDF2: muOS (enable ZRAM in Advanced Settings, or we add zram)"
    openjkdf2_swap_ensure_zram "$size_mb"

  elif [[ "$cfw_lc" == *"rocknix"* ]] || [[ "$cfw_lc" == *"jelos"* ]] \
    || [[ "$cfw_lc" == "amberelec" ]] || [[ "$cfw_lc" == *"unofficialos"* ]]; then
    echo "OpenJKDF2: ${cfw} (LibreELEC family zram)"
    openjkdf2_swap_ensure_zram "$size_mb"

  elif [[ "$cfw_lc" == *"arkos"* ]] || [[ "$cfw_lc" == *"odroid"* ]]; then
    echo "OpenJKDF2: ArkOS swapfile (${size_mb}M)"
    [ -f /swapfile ] && $ESUDO swapoff -v /swapfile
    [ -f /swapfile ] && $ESUDO rm -f /swapfile
    $ESUDO fallocate -l "${size_mb}M" /swapfile
    $ESUDO chmod 600 /swapfile
    $ESUDO mkswap /swapfile
    $ESUDO swapon /swapfile
    OPENJKDF2_SWAP_CREATED=/swapfile

  elif [[ "$cfw_lc" == "knulli" ]]; then
    echo "OpenJKDF2: KNULLI swapfile (${size_mb}M) → /media/SHARE/system/swap"
    [ -f /media/SHARE/system/swap ] && $ESUDO swapoff -v /media/SHARE/system/swap
    [ -f /media/SHARE/system/swap ] && $ESUDO rm -f /media/SHARE/system/swap
    $ESUDO dd if=/dev/zero of=/media/SHARE/system/swap bs=1024 count=$((size_mb * 1024)) status=none
    $ESUDO chmod 600 /media/SHARE/system/swap
    $ESUDO mkswap /media/SHARE/system/swap
    $ESUDO sync
    $ESUDO swapon /media/SHARE/system/swap
    OPENJKDF2_SWAP_CREATED=/media/SHARE/system/swap

  else
    echo "OpenJKDF2: no swap recipe for CFW_NAME=${cfw:-unset}; MOTS may OOM" >&2
    return 1
  fi
}

openjkdf2_swap_cleanup() {
  [ "${OPENJKDF2_SWAP:-1}" = "0" ] && return 0
  case "${OPENJKDF2_SWAP_CREATED:-}" in
    zram)
      echo "OpenJKDF2: zram swap cleanup"
      $ESUDO swapoff /dev/zram0 2>/dev/null || true
      [ -e /dev/zram0 ] && $ESUDO zramctl --reset /dev/zram0 2>/dev/null || true
      ;;
    /swapfile|/media/SHARE/system/swap)
      echo "OpenJKDF2: swapfile cleanup (${OPENJKDF2_SWAP_CREATED})"
      $ESUDO swapoff -v "$OPENJKDF2_SWAP_CREATED" 2>/dev/null || true
      $ESUDO rm -f "$OPENJKDF2_SWAP_CREATED" 2>/dev/null || true
      ;;
  esac
  OPENJKDF2_SWAP_CREATED=""
}
