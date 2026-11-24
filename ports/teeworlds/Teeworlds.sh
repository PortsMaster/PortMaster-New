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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/teeworlds
BINARY=teeworlds.${DEVICE_ARCH}
MENU_BINARY=menu_picker.${DEVICE_ARCH}
MAP_BINARY=map_picker.${DEVICE_ARCH}
SERVER_BINARY=teeworlds_srv.${DEVICE_ARCH}
BOT_BINARY=teeworlds_bot_srv.${DEVICE_ARCH}

mkdir -p "$GAMEDIR/conf/.teeworlds"
cd $GAMEDIR
chmod +x "$GAMEDIR"/*.${DEVICE_ARCH}

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

ARCHIVE_FILE="$GAMEDIR/gamedata.tar.gz"
if [[ -f "$ARCHIVE_FILE" ]]; then
  pm_message "Extracting game data, this can take a few minutes..." --title "Please wait"
  if ! gunzip -c "$ARCHIVE_FILE" | tar --no-same-owner -xf -; then
    pm_show_error "Could not extract game data. Check free space and launch again." --title "Extraction failed"
    exit 1
  fi
  $ESUDO rm -f "$ARCHIVE_FILE"
elif [[ ! -f "$GAMEDIR/data/fonts/DejaVuSans.ttf" ]]; then
  pm_show_error "Game data is missing. Reinstall the port." --title "Data missing"
  exit 1
fi
pm_message_close 2>/dev/null || true

bind_directories "$HOME/.teeworlds" "$GAMEDIR/conf/.teeworlds"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export OMNI_MODE=buffered
export OMNI_EVENT_MODE=auto
export OMNI_UP_KEY=space
export OMNI_DOWN_KEY=esc
export OMNI_LEFT_KEY=a
export OMNI_RIGHT_KEY=d
export OMNI_CONFIRM_KEY=t

setup_gl4es() {
  cd $GAMEDIR
  if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
    source "${controlfolder}/libgl_${CFW_NAME}.txt"
  else
    source "${controlfolder}/libgl_default.txt"
  fi
}

run_client() {
  if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
    sed -i "s/^deadzone_scale = .*/deadzone_scale = 48/" "$GAMEDIR/teeworlds.ini"
  fi
  $GPTOKEYB2 "${BINARY%%.*}" -c "$GAMEDIR/teeworlds.ini" > /dev/null 2>&1 &
  pm_platform_helper "$GAMEDIR/$BINARY"
  LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" \
    "./$BINARY" "$@"
}

pick_map() {
  MAP_RESULT="$GAMEDIR/.map_picker_result"
  rm -f "$MAP_RESULT"

  $GPTOKEYB2 "${MAP_BINARY%%.*}" -c "$GAMEDIR/map_picker.ini" > /dev/null 2>&1 &
  pm_platform_helper "$GAMEDIR/$MAP_BINARY"
  env OMNI_UP_KEY= OMNI_DOWN_KEY= OMNI_LEFT_KEY= OMNI_RIGHT_KEY= OMNI_CONFIRM_KEY=g \
    LD_PRELOAD="$GAMEDIR/libs.${DEVICE_ARCH}/libomni_osk.so${LD_PRELOAD:+:$LD_PRELOAD}" \
    "./$MAP_BINARY" "$GAMEDIR/data/maps" "$GAMEDIR/conf/favorites.txt" \
    "$GAMEDIR/data/fonts/DejaVuSans.ttf" "$GAMEDIR/map_picker_bg.png" "$MAP_RESULT"
  pm_gptokeyb_finish

  PICKED_MAP=$(cat "$MAP_RESULT" 2>/dev/null)
  if [[ "$PICKED_MAP" == *[\;\#\"\\]* ]] || [[ "$PICKED_MAP" == *$'\n'* ]]; then
    PICKED_MAP=""
  fi
}

PICKER_RESULT="$GAMEDIR/.picker_result"
rm -f "$PICKER_RESULT"

pm_platform_helper "$GAMEDIR/$MENU_BINARY"
"./$MENU_BINARY" loader_menu.png selector.png "$PICKER_RESULT"

CHOICE=$(cat "$PICKER_RESULT" 2>/dev/null)
CHOICE="${CHOICE:--1}"

case "$CHOICE" in
0)
  setup_gl4es
  run_client
  ;;
1)
  pick_map
  SERVER_ARGS=(-f server.cfg)
  [ -n "$PICKED_MAP" ] && SERVER_ARGS+=("sv_map $PICKED_MAP")
  "./$SERVER_BINARY" "${SERVER_ARGS[@]}" &
  SRV_PID=$!
  sleep 1.5
  setup_gl4es
  run_client "connect localhost:8303"
  kill "$SRV_PID" 2>/dev/null
  ;;
2)
  pick_map
  rm -f "$GAMEDIR/.bot_srv.log"
  BOT_ARGS=(-f server_bot.cfg)
  [ -n "$PICKED_MAP" ] && BOT_ARGS+=("sv_map $PICKED_MAP")
  "./$BOT_BINARY" "${BOT_ARGS[@]}" > >(tee "$GAMEDIR/.bot_srv.log") 2>&1 &
  SRV_PID=$!
  for i in $(seq 1 90); do
    grep -q "rcon password" "$GAMEDIR/.bot_srv.log" 2>/dev/null && break
    sleep 1
  done
  setup_gl4es
  run_client "connect localhost:8303"
  kill "$SRV_PID" 2>/dev/null
  ;;
*)
  ;;
esac

pm_finish
