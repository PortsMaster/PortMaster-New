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

GAMEDIR="/$directory/ports/hollowknight"
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Unity's 32-bit player (ua_host, whose loader is /lib/ld-linux-armhf.so.3) needs glibc 2.35 or newer;
# elsewhere the 64-bit build (ua_host64, the game in arm64/). A build that is set up, or being set up,
# keeps its route.
ARMHF=no
if [ "$DEVICE_HAS_ARMHF" = Y ] && [ -e /lib/ld-linux-armhf.so.3 ]; then
  ARMHF=yes
  read -r major minor < <(/lib/ld-linux-armhf.so.3 --version 2>/dev/null | sed -n '1s/.*version \([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')
  [ -n "$minor" ] && [ $((major * 1000 + minor)) -lt 2035 ] && ARMHF="glibc $major.$minor"
fi
[ "$HK_ROUTE" = 64 ] || grep -Eqs '^[[:space:]]*(export[[:space:]]+)?HK_ROUTE=["'"'"']?64' port.env && HK_ROUTE=64
if [ "$HK_ROUTE" = 64 ]; then :
elif [ -f .setup_done ]; then HK_ROUTE=32
elif [ -f .setup_done64 ]; then HK_ROUTE=64
elif [ -d gamedata/.setup ]; then HK_ROUTE=32
elif [ -d gamedata/.setup64 ]; then HK_ROUTE=64
elif [ "$ARMHF" = yes ]; then HK_ROUTE=32
else HK_ROUTE=64; fi
# the 32-bit build tells the firmware's mod file so (PORT_32BIT: ROCKNIX and Knulli then point PipeWire
# at its 32-bit plugins; ua_host hands its 64-bit pw-cat, when it uses one, the system's own)
[ "$HK_ROUTE" = 32 ] && export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

echo "$CFW_NAME, $DEVICE_NAME, ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}: $HK_ROUTE-bit build (32-bit libraries: $ARMHF)"
if [ "$HK_ROUTE" = 64 ]; then
  SETUP=patchscript64; READY=.setup_done64; HOST=ua_host64; GAME="$GAMEDIR/arm64"
else
  SETUP=patchscript; READY=.setup_done; HOST=ua_host; GAME="$GAMEDIR"
fi

# Rockchip vendor kernels (dArkOS, ArkOS) keep the video decoder root-only: open it to the video group
# for the game's videos (pmhwdec/) and put it back when the game ends.
nodes=()
for n in /dev/vpu_service /dev/hevc_service; do
  [ -e "$n" ] && ! { [ -r "$n" ] && [ -w "$n" ]; } || continue
  o=$(stat -c '%u:%g:%a' "$n") && $ESUDO chgrp video "$n" && $ESUDO chmod 660 "$n" && nodes+=("$n:$o")
done
trap 'for e in "${nodes[@]}"; do o=${e#*:}; $ESUDO chown "${o%:*}" "${e%%:*}"; $ESUDO chmod "${o##*:}" "${e%%:*}"; done; pm_message_end' EXIT

# First launch: the setup builds the game from the player's copy in gamedata/ (PortMaster's patcher)
if [ ! -f "$READY" ]; then
  if [ -f "setup/$SETUP" ]; then
    export GAMEDIR DEVICE_ARCH controlfolder
    export PATCHER_FILE="$GAMEDIR/setup/$SETUP" PATCHER_GAME="Hollow Knight" PATCHER_TIME="one to three hours, once"
    export PATCHER_QUESTIONS="$GAMEDIR/setup/questions.lua"
    chmod +x "$PATCHER_FILE"
    source "$controlfolder/utils/patcher.txt"
    cd "$GAMEDIR"
  fi
  if [ ! -f "$READY" ]; then
    pm_message "Hollow Knight is not set up yet. Put GOG's Linux installer, or the game folder from GOG or Steam, in ports/hollowknight/gamedata and launch again; a setup that stopped goes on from there (log: ports/hollowknight/patchlog.txt)."
    sleep 8
    pm_finish
    exit 1
  fi
fi
rm -rf setup donor gamedata/.setup gamedata/.setup64   # the setup's files, not needed to play

export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG:-$sdl_controllerconfig}"
[ "$HK_ROUTE" = 64 ] && export UM_PMHWDEC=pmhwdec64/libpmhwdec.so.1
export UA_FPS=10   # a frame-rate line every 10 s in log.txt
# the setup's answers (aspect.txt: fill or bars; buttons.txt: nintendo or xbox prompts)
case "$(cat aspect.txt 2>/dev/null)" in fill) export ASMPATCH_HK_ASPECT=fill ;; bars) export ASMPATCH_HK_ASPECT= ;; esac
case "$(cat buttons.txt 2>/dev/null)" in nintendo) export UA_PAD_LETTERS=nintendo ;; xbox) export UA_PAD_LETTERS=xbox ;; esac
# settings that need a code patch or step of the setup stay off without it (the setup lists them in $READY)
grep -qs hk-render-size "$READY" || export UA_RENDER_SIZE_VAR=
grep -qs "convert=lazy" "$READY" || export UA_UNLOAD_ASSETS=
# port.env gives back the other languages' fonts after the start, not for a game saved in (or not yet
# set to) a language that uses them
case "$(awk -F'\t' '$1 == "s" && $2 == "M2H_lastLanguage" { print $3 }' \
         "$GAME/data/shared_prefs/com.pmunity.hollowknight.v2.playerprefs.prefs" 2>/dev/null | tail -n 1)" in
  ""|JA|KO|ZH|ZH_TW|RU) export UA_UNLOAD_ASSETS= ;;
esac
[ -f port.env ] && source port.env
[ -f answers.env ] && source answers.env
# no analog sticks (device_info.txt): the d-pad is the pad's only stick
if [ "${ANALOG_STICKS:-2}" = 0 ]; then
  case "${UA_DPAD_STICK:-}" in auto|auto,both) export UA_DPAD_STICK=${UA_DPAD_STICK/auto/1} ;; esac
fi
chmod +x "$HOST" pmhwdec/pmhwdec-cedard pmhwdec64/pmhwdec-cedard 2>/dev/null

$GPTOKEYB2 "$HOST" &   # exit hotkey only: the game reads the pad itself
pm_platform_helper "$GAMEDIR/$HOST"

if [ "$HK_ROUTE" = 64 ]; then
  ./ua_host64 "$GAME"
else
  LD_LIBRARY_PATH=/lib32:/usr/lib32${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} ./ua_host "$GAME"
fi

pm_finish
