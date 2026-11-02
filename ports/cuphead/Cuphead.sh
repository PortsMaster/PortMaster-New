#!/bin/bash

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
# Unity's Android player for Cuphead is 32-bit: a firmware without 32-bit (armhf) libraries gets
# the 64-bit build (CUPHEAD_ROUTE=64 picks it on one that has them). A build that is set up, or a
# setup under way, keeps its route (the libraries' check alone flipped between launches on muOS).
# The 32-bit build tells the firmware's mod file so (PORT_32BIT: muOS then sets up its 32-bit sound)
G="/$directory/ports/cuphead"
ARMHF=no; [ -e /lib/ld-linux-armhf.so.3 ] && ARMHF=yes
if [ "$CUPHEAD_ROUTE" = 64 ]; then ROUTE_WHY="CUPHEAD_ROUTE=64"
elif [ -f "$G/.cuphead_ready" ] || [ -d "$G/gamedata/.setup" ]; then CUPHEAD_ROUTE=32; ROUTE_WHY="the 32-bit build is there"
elif [ -f "$G/.cuphead_ready64" ] || [ -d "$G/gamedata/.setup64" ]; then CUPHEAD_ROUTE=64; ROUTE_WHY="the 64-bit build is there"
elif [ "$ARMHF" = yes ]; then CUPHEAD_ROUTE=32; ROUTE_WHY="32-bit libraries found"
else CUPHEAD_ROUTE=64; ROUTE_WHY="no 32-bit libraries"; fi
[ "$CUPHEAD_ROUTE" = 32 ] && export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/cuphead"
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
PORT_INFO="Cuphead port $(cat "$GAMEDIR/version.txt" 2>/dev/null || echo unknown); $CFW_NAME on $DEVICE_NAME, $DISPLAY_WIDTH x $DISPLAY_HEIGHT; $CUPHEAD_ROUTE-bit build ($ROUTE_WHY; 32-bit libraries: $ARMHF)"
echo "$PORT_INFO"
if [ "$CUPHEAD_ROUTE" = 32 ] && [ "$ARMHF" = no ]; then
  pm_message "The 32-bit build is set up, but this firmware's 32-bit libraries are missing right now (/lib/ld-linux-armhf.so.3). Restart the handheld and launch again; please send ports/cuphead/log.txt if it stays."
  sleep 8
fi

# first launch: the setup builds the game from the player's copy in gamedata/ with its own tools
# (setup/pmu, one native program). The rest of the setup's files come zipped (setup/setup.zip,
# setup64/setup64.zip) and are unpacked before their first setup
run_setup() {   # run_setup <patchscript> <time> [no-questions]
  $ESUDO chmod +x "$GAMEDIR/setup/pmu"
  for z in "$GAMEDIR"/setup/*.zip "$(dirname "$1")"/*.zip; do
    [ -f "$z" ] || continue
    "$GAMEDIR/setup/pmu" zip-extract "$z" "$(dirname "$z")" \
      && rm -f "$z" || { pm_message "Could not unpack ${z#$GAMEDIR/}: is the card full?"; sleep 5; pm_finish; exit 1; }
  done
  export GAMEDIR DEVICE_ARCH controlfolder DISPLAY_WIDTH DISPLAY_HEIGHT   # (the questions read the screen size)
  # the CPU at full speed while the setup runs, kept there if the firmware lowers it (setup/cpu.txt)
  source "$GAMEDIR/setup/cpu.txt"
  { echo "== $(date '+%Y-%m-%d %H:%M:%S') $PORT_INFO: $(basename "$(dirname "$1")")/$(basename "$1")"
    cpu_state; cpu_fast; cpu_state; } >> "$GAMEDIR/patchlog.txt"
  cpu_hold "$GAMEDIR/patchlog.txt" &
  local sampler=$!
  export PATCHER_FILE="$1" PATCHER_GAME="Cuphead" PATCHER_TIME="$2"
  export PATCHER_QUESTIONS="$GAMEDIR/setup/questions.lua"
  [ -n "$3" ] && unset PATCHER_QUESTIONS
  $ESUDO chmod +x "$1"
  source "$controlfolder/utils/patcher.txt"
  kill "$sampler" 2>/dev/null
  cpu_restore
}

# The Delicious Last Course added later (GOG's DLC installer, or a Cuphead.app with it, in
# gamedata/): the setup adds it to the built game, once
dlc_waiting() {   # dlc_waiting <built game folder>
  [ -f "$1/cuphead_dlc" ] || [ -f "$1/goggame-2048763853.info" ] && return 1
  for f in "$GAMEDIR"/gamedata/*.pkg "$GAMEDIR"/gamedata/Cuphead.app "$GAMEDIR"/gamedata/*/Cuphead.app; do
    [ -e "$f" ] && return 0
  done
  return 1
}

# the pad reaches the game as an Android gamepad; Rewired maps this name as a standard pad
export UA_PAD_NAME="Xbox Wireless Controller"
# the letters the game's prompts show (buttons.txt, from the setup): "nintendo" (the default: B at the
# bottom, A on the right) or "xbox" (A at the bottom). The buttons never move: the bottom one jumps
[ "$(cat "$GAMEDIR/buttons.txt" 2>/dev/null)" = xbox ] && export CUPHEAD_PROMPTS=xbox
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ "$CUPHEAD_ROUTE" = 64 ]; then
  source "$GAMEDIR/launch64.txt"
  exit
fi

[ -f "$GAMEDIR/.cuphead_ready" ] || run_setup "$GAMEDIR/setup/patchscript" "one to a few hours, once"
if [ ! -f "$GAMEDIR/.cuphead_ready" ]; then
  if [ -f "$GAMEDIR/gamedata/.setup/.step_game" ]; then   # (the game's files are taken in: only the rest is left)
    pm_message "The setup stopped before it finished (log: ports/cuphead/patchlog.txt). Launch Cuphead again: it continues where it stopped."
  else
    pm_message "Cuphead is not set up yet: put Cuphead.app or GOG's macOS installers in ports/cuphead/gamedata and launch again (log: ports/cuphead/patchlog.txt)."
  fi
  sleep 8
  pm_finish
  exit 1
fi
dlc_waiting "$GAMEDIR" && export DLC_TARGET="$GAMEDIR" && run_setup "$GAMEDIR/setup/dlcscript" "about half an hour, once" no-questions

# the picture shape the setup asked for (aspect.txt: "fill", "16:9" for the game's letterbox on any
# screen, "crop" to fill 4:3 screens too, or a shape such as "4:3" between the two),
# and an optional smaller render size (resolution.txt: a share of the panel's, e.g. 0.75, which the
# display engine scales up to the whole panel)
A=$(cat "$GAMEDIR/aspect.txt" 2>/dev/null); case "$A" in crop|[0-9]*:[0-9]*) export CUPHEAD_ASPECT="$A" ;; esac
R=$(cat "$GAMEDIR/resolution.txt" 2>/dev/null); [ -n "$R" ] && [ "$R" != device ] && export UA_RENDER_SCALE="$R"

export SDL_AUDIODRIVER=alsa
# dArkOS on kernels before 5.6 (RK3326): its 32-bit alsa-lib uses PCM ioctls these kernels lack,
# so the game's sound goes through the system's 64-bit aplay instead
kv=$(uname -r); kmaj=${kv%%.*}; kmin=${kv#*.}; kmin=${kmin%%.*}
if [ "$CFW_NAME" = "dArkOS" ] && { [ "$kmaj" -lt 5 ] || { [ "$kmaj" -eq 5 ] && [ "$kmin" -lt 6 ]; }; }; then
  a="aplay -q -t raw -f S16_LE -r 48000 -c 2 --buffer-time=40000"
  export ANDROID_SLES_OUTPUT=pipe
  export ANDROID_SLES_PIPE_CMD="$a -D plughw:0,0 --period-time=10000 - 2>/dev/null || exec $a -"
fi

$ESUDO chmod +x "$GAMEDIR/ua_host"
$GPTOKEYB "ua_host" -c "$GAMEDIR/cuphead_hotkey.gptk" &
pm_platform_helper "$GAMEDIR/ua_host"
LD_LIBRARY_PATH=/lib32:/usr/lib32:$LD_LIBRARY_PATH ./ua_host "$GAMEDIR"

pm_finish
