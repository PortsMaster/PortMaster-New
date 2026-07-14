#!/bin/bash
# Bully: Anniversary Edition Final -- Android so-loader for PortMaster.

PORTNAME="Bully: Anniversary Edition"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
elif [ -d "/roms/ports/PortMaster" ]; then
  controlfolder="/roms/ports/PortMaster"
else
  controlfolder="/storage/.config/PortMaster"
fi

[ -f "$controlfolder/control.txt" ] && source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME:-}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
type get_controls >/dev/null 2>&1 && get_controls

directory="${directory:-storage/roms}"
CUR_TTY=/dev/tty0
GAMEDIR="/${directory#/}/ports/bully"
LOGFILE="$GAMEDIR/log.txt"
CONFIG_FILE="${BULLY2_CONFIG_FILE:-$GAMEDIR/bully.conf}"
CONFIG_DEFAULT="$GAMEDIR/bully.conf.default"
GPTK_CONFIG="$GAMEDIR/bully.gptk"
GPTK_DEFAULT="$GAMEDIR/bully.gptk.default"
GPTK_PID=""

cd "$GAMEDIR" || exit 1
: > "$LOGFILE"
exec > >(tee "$LOGFILE") 2>&1

if [ -z "${BULLY2_CONFIG_FILE:-}" ] && [ ! -e "$CONFIG_FILE" ] \
   && [ -f "$CONFIG_DEFAULT" ]; then
  cp -f "$CONFIG_DEFAULT" "$CONFIG_FILE" \
    && echo "[config] created $CONFIG_FILE from Final defaults"
fi

# O mapa ativo e arquivo do usuario. O ZIP entrega apenas o modelo, portanto
# reinstalacoes/atualizacoes nao apagam uma remap versionada personalizada.
if [ ! -e "$GPTK_CONFIG" ] && [ -f "$GPTK_DEFAULT" ]; then
  cp -f "$GPTK_DEFAULT" "$GPTK_CONFIG" \
    && echo "[input] created editable $GPTK_CONFIG from defaults"
fi

# V3 corrige o contrato Android de L3/R3, usa L2/R2 como eixos e volta o mapa
# de face default ao neutro. V1 e o V2 padrao da RC anterior sao migrados;
# qualquer V2 personalizado pelo usuario e preservado e continua compativel.
if [ -e "$GPTK_CONFIG" ] \
   && ! grep -q '^#[[:space:]]*BULLY_GPTK_VERSION=3[[:space:]]*$' "$GPTK_CONFIG"; then
  gptk_migrate=0
  gptk_reason=""
  if ! grep -q '^#[[:space:]]*BULLY_GPTK_VERSION=' "$GPTK_CONFIG"; then
    gptk_migrate=1
    gptk_reason="legacy-v1"
  elif grep -q '^#[[:space:]]*BULLY_GPTK_VERSION=2[[:space:]]*$' "$GPTK_CONFIG"; then
    # BusyBox/mawk variants shipped by older CFWs do not all remove spaces
    # with the POSIX character class in gsub(). Records contain no newline, so
    # delete the concrete ASCII whitespace used by this file instead.
    gptk_signature=$(awk 'BEGIN { ORS="" } {
      sub(/#.*/, ""); gsub(/[ \t\r]/, "");
      if (length) printf "%s;", $0
    }' "$GPTK_CONFIG")
    case "$gptk_signature" in
      'a=c;b=x;x=t;y=q;start=enter;back=esc;l1=u;r1=i;l2=k;r2=l;l3=h;r3=j;up=up;down=down;left=left;right=right;left_analog_up=w;left_analog_down=s;left_analog_left=a;left_analog_right=d;right_analog_up=mouse_movement_up;right_analog_down=mouse_movement_down;right_analog_left=mouse_movement_left;right_analog_right=mouse_movement_right;mouse_scale=512;deadzone_y=15000;')
        gptk_migrate=1
        gptk_reason="stock-v2"
        ;;
      *) echo "[input] custom editable-v2 gptk preserved" ;;
    esac
  fi

  if [ "$gptk_migrate" = 1 ]; then
    GPTK_BACKUP="$GPTK_CONFIG.pre-v3-backup"
    gptk_saved=0
    if [ -e "$GPTK_BACKUP" ]; then
      gptk_saved=1
    elif cp "$GPTK_CONFIG" "$GPTK_BACKUP"; then
      gptk_saved=1
    else
      echo "[input] gptk backup failed; keeping the active file unchanged"
    fi
    if [ "$gptk_saved" = 1 ] && [ -s "$GPTK_DEFAULT" ] \
       && cp -f "$GPTK_DEFAULT" "$GPTK_CONFIG"; then
      echo "[input] migrated $gptk_reason gptk to editable-v3; backup=$GPTK_BACKUP"
    elif [ "$gptk_saved" = 1 ]; then
      echo "[input] editable-v3 default unavailable; keeping old gptk active"
    fi
  fi
fi

cleanup() {
  local rc=$?
  trap - EXIT INT TERM HUP
  if [ -n "$GPTK_PID" ]; then
    kill "$GPTK_PID" 2>/dev/null || true
    wait "$GPTK_PID" 2>/dev/null || true
  fi
  ${ESUDO:-} pkill -9 -x gptokeyb 2>/dev/null || true
  ${ESUDO:-} pkill -9 -x gptokeyb2 2>/dev/null || true
  ${ESUDO:-} chmod 666 "$CUR_TTY" 2>/dev/null || true
  printf '\033c' >> "$CUR_TTY" 2>/dev/null || true
  command -v pm_finish >/dev/null 2>&1 && pm_finish
  exit "$rc"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

${ESUDO:-} chmod 666 "$CUR_TTY" 2>/dev/null || true
pkill -9 -x bully 2>/dev/null || true
${ESUDO:-} pkill -9 -x gptokeyb 2>/dev/null || true
${ESUDO:-} pkill -9 -x gptokeyb2 2>/dev/null || true

trim_value() {
  local value=$1
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

CFG_RENDERER=auto
CFG_RENDER_SCALE=auto
CFG_TEXTURES=auto
CFG_TRILINEAR=auto
CFG_STREAM_DISTANCE=auto
CFG_FACE_BUTTONS=auto
CFG_INPUT_DEBUG=auto
CFG_USE_GPTK=auto
CFG_WEAPON_SWITCH=auto

load_config() {
  local raw key value lineno=0
  [ -f "$CONFIG_FILE" ] || {
    echo "[config] $CONFIG_FILE not found; using automatic defaults"
    return 0
  }

  while IFS= read -r raw || [ -n "$raw" ]; do
    lineno=$((lineno + 1))
    raw="${raw%$'\r'}"
    raw="${raw%%#*}"
    raw="$(trim_value "$raw")"
    [ -n "$raw" ] || continue
    case "$raw" in
      *=*) ;;
      *) echo "[config] ignored line $lineno (expected key=value)"; continue ;;
    esac
    key="$(trim_value "${raw%%=*}")"
    value="$(trim_value "${raw#*=}")"
    key="${key,,}"
    value="${value,,}"
    case "$key:$value" in
      renderer:auto|renderer:es2|renderer:es3) CFG_RENDERER=$value ;;
      render_scale:auto|render_scale:profile|render_scale:0.5|render_scale:0.75|render_scale:1.0) CFG_RENDER_SCALE=$value ;;
      textures:auto|textures:low|textures:medium|textures:high) CFG_TEXTURES=$value ;;
      trilinear:auto|trilinear:on|trilinear:off) CFG_TRILINEAR=$value ;;
      stream_distance:auto|stream_distance:50|stream_distance:60|stream_distance:70|stream_distance:75|stream_distance:80|stream_distance:100) CFG_STREAM_DISTANCE=$value ;;
      face_buttons:auto|face_buttons:normal|face_buttons:swap_xy|face_buttons:swap_ab|face_buttons:swap_both) CFG_FACE_BUTTONS=$value ;;
      input_debug:on|input_debug:off) CFG_INPUT_DEBUG=$value ;;
      use_gptk:on|use_gptk:off) CFG_USE_GPTK=$value ;;
      weapon_switch:native|weapon_switch:touch) CFG_WEAPON_SWITCH=$value ;;
      renderer:*|render_scale:*|textures:*|trilinear:*|stream_distance:*|face_buttons:*|input_debug:*|use_gptk:*|weapon_switch:*)
        echo "[config] ignored invalid $key value on line $lineno: $value"
        ;;
      *) echo "[config] ignored unknown key on line $lineno: $key" ;;
    esac
  done < "$CONFIG_FILE"
}

# Apply one whitelisted option without replacing an existing environment value.
# Arguments: config-key primary-env legacy-env config-value auto-value.
apply_config() {
  local key=$1 primary=$2 legacy=$3 configured=$4 automatic=$5 value source
  if [ "${!primary+x}" ]; then
    value="${!primary}"
    source=environment
  elif [ -n "$legacy" ] && [ "${!legacy+x}" ]; then
    value="${!legacy}"
    source=environment
  elif [ "$configured" != auto ]; then
    value=$configured
    source=config
    case "$key:$value" in
      trilinear:on|input_debug:on|use_gptk:on) value=1 ;;
      trilinear:off|input_debug:off|use_gptk:off) value=0 ;;
    esac
    printf -v "$primary" '%s' "$value"
    export "$primary"
  else
    value=$automatic
    source=auto
  fi
  printf '[config] %-13s = %-8s (%s)\n' "$key" "${value:-<empty>}" "$source"
}

load_config
apply_config renderer BULLY2_RENDERER BULLY_RENDERER "$CFG_RENDERER" auto
apply_config render_scale BULLY2_RENDER_SCALE BULLY_RENDER_SCALE "$CFG_RENDER_SCALE" auto
apply_config textures BULLY2_TEXTURE_PROFILE BULLY_TEXTURE_PROFILE "$CFG_TEXTURES" auto
# An explicit automatic profile must bypass texture_profile.cfg left by V11;
# persistent manual choices now live in the validated bully.conf.
if [ -z "${BULLY2_TEXTURE_PROFILE+x}" ] && [ -z "${BULLY_TEXTURE_PROFILE+x}" ]; then
  export BULLY2_TEXTURE_PROFILE=auto
fi
apply_config trilinear BULLY2_TRILINEAR BULLY_TRILINEAR "$CFG_TRILINEAR" auto
apply_config stream_distance BULLY2_STREAM_DISTANCE_PCT "" "$CFG_STREAM_DISTANCE" auto
apply_config face_buttons BULLY2_FACE_BUTTONS "" "$CFG_FACE_BUTTONS" auto
apply_config input_debug BULLY2_INPUT_DEBUG "" "$CFG_INPUT_DEBUG" off
apply_config use_gptk BULLY2_USE_GPTK "" "$CFG_USE_GPTK" off
apply_config weapon_switch BULLY2_WEAPON_SWITCH "" "$CFG_WEAPON_SWITCH" native

if [ -z "${BULLY2_VERSION+x}" ] && [ -s "$GAMEDIR/version.txt" ]; then
  IFS= read -r BULLY2_VERSION < "$GAMEDIR/version.txt" || true
  BULLY2_VERSION="${BULLY2_VERSION%$'\r'}"
  export BULLY2_VERSION
fi
echo "[port] ${PORTNAME} ${BULLY2_VERSION:-Final}"

# ArkOS RK3326/Mali-G31 needs the Mali DDK matching its kernel. This path is
# also required by the first-run setup renderer, so configure it up front.
export LD_LIBRARY_PATH="/usr/local/lib/aarch64-linux-gnu:/usr/local/lib/arm-linux-gnueabihf:/usr/lib:$GAMEDIR:$controlfolder/libs:${LD_LIBRARY_PATH:-}:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu"

# Some CFW sessions provide an empty XDG runtime directory. Create a private
# fallback so SDL can select Wayland when available or KMSDRM otherwise.
if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "${XDG_RUNTIME_DIR:-}" ]; then
  for runtime_dir in /run/0-runtime-dir "/run/user/$(id -u 2>/dev/null)" \
                     /run/user/0 /var/run/user/0 /tmp/bully-runtime; do
    [ -n "$runtime_dir" ] || continue
    if [ -d "$runtime_dir" ] || mkdir -p "$runtime_dir" 2>/dev/null; then
      chmod 700 "$runtime_dir" 2>/dev/null || true
      export XDG_RUNTIME_DIR="$runtime_dir"
      break
    fi
  done
fi
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  wayland_socket=$(find "${XDG_RUNTIME_DIR:-/nonexistent}" -maxdepth 1 \
    -type s -name 'wayland-*' -print 2>/dev/null | head -n 1)
  [ -n "$wayland_socket" ] && export WAYLAND_DISPLAY="${wayland_socket##*/}"
fi

${ESUDO:-} chmod +x "$GAMEDIR/bully" \
  "$GAMEDIR/tools/extract-bully-data" \
  "$GAMEDIR/tools/ensure-bully-menu-patch" 2>/dev/null \
  || chmod +x "$GAMEDIR/bully" \
    "$GAMEDIR/tools/extract-bully-data" \
    "$GAMEDIR/tools/ensure-bully-menu-patch" 2>/dev/null || true

if ! BULLY_BINARY="$GAMEDIR/bully" \
     "$GAMEDIR/tools/extract-bully-data" "" "$GAMEDIR"; then
  echo "Bully: copy your legal Bully 1.4.311 APK to $GAMEDIR/gamedata." \
    > "$CUR_TTY" 2>/dev/null || true
  sleep "${BULLY_SETUP_ERROR_DELAY:-8}"
  exit 1
fi

[ -n "${sdl_controllerconfig:-}" ] && export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL2COMPAT_FORCE_FULLSCREEN_DESKTOP=1
export SDL_VIDEO_FULLSCREEN_DESKTOP=1
export MALLOC_ARENA_MAX="${MALLOC_ARENA_MAX:-2}"
export MALLOC_TRIM_THRESHOLD_="${MALLOC_TRIM_THRESHOLD_:-131072}"
export MALLOC_MMAP_THRESHOLD_="${MALLOC_MMAP_THRESHOLD_:-65536}"

if [ -z "${ALSOFT_CONF:-}" ] && [ -f "$GAMEDIR/alsoft.conf" ]; then
  export ALSOFT_CONF="$GAMEDIR/alsoft.conf"
fi

unset BULLY2_INPUT BULLY2_GPTK_DIRECT
case "${BULLY2_USE_GPTK:-0}" in
  1|on|ON|true|TRUE|yes|YES)
    if [ ! -s "$GPTK_CONFIG" ] || [ -z "${GPTOKEYB:-}" ]; then
      echo "[input] use_gptk=on, but config/tool is unavailable; using native SDL"
    else
      ${ESUDO:-} chmod 666 /dev/uinput 2>/dev/null || true
      chmod u+rw "$GPTK_CONFIG" 2>/dev/null || true
      export BULLY2_INPUT=gptk BULLY2_GPTK_DIRECT=1
      # Standard PortMaster command supplied by control.txt.
      # shellcheck disable=SC2086
      $GPTOKEYB "bully" -c "$GPTK_CONFIG" &
      GPTK_PID=$!
      echo "[input] gptokeyb enabled pid=$GPTK_PID config=$GPTK_CONFIG"
    fi
    ;;
  *)
    echo "[input] native SDL enabled (use_gptk=off)"
    ;;
esac

command -v pm_platform_helper >/dev/null 2>&1 \
  && pm_platform_helper "$GAMEDIR/bully" >/dev/null 2>&1

# Keep the game in the foreground so PortMaster owns its lifecycle and exit code.
"$GAMEDIR/bully"
exit $?
