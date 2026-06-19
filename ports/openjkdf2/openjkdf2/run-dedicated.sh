#!/bin/bash
# OpenJKDF2 dedicated multiplayer server (x86_64 Linux).
#
# Run from the openjkdf2/ folder after unzipping the port and copying game data
# into jk1/. See MULTIPLAYER.md for setup, firewall, and client join instructions.
set -euo pipefail

GAMEDIR="$(cd "$(dirname "$0")" && pwd)"
CONFDIR="$GAMEDIR/conf"
BIN="$GAMEDIR/openjkdf2.x86_64"
LIBS="$GAMEDIR/libs.x86_64"
LOG="$GAMEDIR/log.txt"
MPCONF="$CONFDIR/mp.conf"

EPISODE="${OPENJKDF2_MP_EPISODE:-JK1MP}"
MAP="${OPENJKDF2_MP_MAP:-m2}"
HEADLESS=1
VERBOSE_NET=1
EXTRA_ARGS=()

usage() {
    cat <<EOF
Usage: ./run-dedicated.sh [options] [-- extra-engine-args...]

Starts a headless JKDF2 multiplayer dedicated server (no local player).

Prerequisites:
  - Linux x86_64
  - Game data in jk1/ (including jk1/episode/JK1MP.gob)
  - openjkdf2.x86_64 and libs.x86_64/ from the port zip

Options:
  --episode NAME     MP episode gob base name (default: JK1MP, or [host] episode in mp.conf)
  --map NAME         Map jkl base name (default: m2, or [host] map in mp.conf)
  --no-headless      Keep video subsystem (not recommended on VPS)
  --quiet-net        Disable -verboseNetworking
  -h, --help         Show this help

Environment:
  OPENJKDF2_MP_EPISODE / OPENJKDF2_MP_MAP  Override episode/map
  OPENJKDF2_ROOT       JKDF2 data path (default: \$GAMEDIR/jk1)

Host settings in conf/mp.conf ([host] episode/map) are read when present.
Other [host] keys (port, max_players, password) apply when hosting via the
in-game menu; for CLI dedicated mode use defaults or host once from the menu
to persist settings under conf/openjkdf2/.

Logs: $LOG
EOF
}

mpconf_host() {
    local key="$1"
    [[ -f "$MPCONF" ]] || return 1
    awk -F= -v want="$key" '
        BEGIN { sect=0 }
        /^\[/ {
            sect = ($0 ~ /^\[host\]/) ? 1 : 0
            next
        }
        sect && $1 ~ "^[ \t]*" want "[ \t]*$" {
            sub(/^[^=]*=/, "")
            gsub(/^[ \t]+|[ \t]+$/, "", $0)
            gsub(/^[ \t"]+|[ \t"]+$/, "", $0)
            print $0
            exit
        }
    ' "$MPCONF"
}

strip_ext() {
    local v="$1"
    v="${v%.gob}"
    v="${v%.GOB}"
    v="${v%.jkl}"
    v="${v%.JKL}"
    printf '%s' "$v"
}

has_mp_data() {
    local ep="$GAMEDIR/jk1/episode"
    [[ -d "$ep" ]] || return 1
    compgen -G "$ep/JK1MP.gob" >/dev/null 2>&1 \
        || compgen -G "$ep/jk1mp.gob" >/dev/null 2>&1 \
        || compgen -G "$ep/*MP*.gob" >/dev/null 2>&1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --episode) EPISODE="$(strip_ext "$2")"; shift 2 ;;
        --map) MAP="$(strip_ext "$2")"; shift 2 ;;
        --no-headless) HEADLESS=0; shift ;;
        --quiet-net) VERBOSE_NET=0; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; EXTRA_ARGS+=("$@"); break ;;
        -*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
        *) EXTRA_ARGS+=("$1"); shift ;;
    esac
done

if [[ "$(uname -m)" != "x86_64" ]]; then
    echo "ERROR: Dedicated server script requires Linux x86_64 (VPS / PC)." >&2
    echo "Handhelds can join games but should not run this script." >&2
    exit 1
fi

[[ -x "$BIN" ]] || {
    echo "ERROR: Missing $BIN — use the port zip with openjkdf2.x86_64." >&2
    exit 1
}

[[ -d "$LIBS" ]] || {
    echo "ERROR: Missing $LIBS (GNS + OpenSSL 1.1)." >&2
    exit 1
}

for lib in libGameNetworkingSockets.so libcrypto.so.1.1 libssl.so.1.1; do
    [[ -f "$LIBS/$lib" ]] || {
        echo "ERROR: Missing $LIBS/$lib (multiplayer will not work)." >&2
        exit 1
    }
done

if ! has_mp_data; then
    echo "ERROR: JK1MP.gob not found under jk1/episode/." >&2
    echo "Copy your GOG/Steam JKDF2 install into jk1/ first." >&2
    exit 1
fi

if [[ -f "$MPCONF" ]]; then
    conf_ep="$(mpconf_host episode || true)"
    conf_map="$(mpconf_host map || true)"
    [[ -n "$conf_ep" ]] && EPISODE="$(strip_ext "$conf_ep")"
    [[ -n "$conf_map" ]] && MAP="$(strip_ext "$conf_map")"
fi

export OPENJKDF2_ROOT="${OPENJKDF2_ROOT:-$GAMEDIR/jk1}"
export OPENJKMOTS_ROOT="${OPENJKMOTS_ROOT:-$GAMEDIR/mots}"
export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$LIBS${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

mkdir -p "$CONFDIR/openjkdf2" "$CONFDIR/openjkmots"

ARGS=(
    -dedicatedServer
    -autostart
    -mp
    "-episode" "$EPISODE"
    "-map" "$MAP"
)
[[ $HEADLESS -eq 1 ]] && ARGS+=(-headless)
[[ $VERBOSE_NET -eq 1 ]] && ARGS+=(-verboseNetworking)
ARGS+=("${EXTRA_ARGS[@]}")

cd "$GAMEDIR"
: >"$LOG"

echo "== OpenJKDF2 dedicated server =="
echo "Gamedir:  $GAMEDIR"
echo "Episode:  $EPISODE"
echo "Map:      $MAP"
echo "Log:      $LOG"
echo "Default UDP port: 27020 (open in firewall; see MULTIPLAYER.md)"
echo

exec > >(tee -a "$LOG") 2>&1
exec "$BIN" "${ARGS[@]}"
