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

GAMEDIR=/$directory/ports/deponia
BINARY=Deponia
DATADIR="$GAMEDIR/gamedata"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

GOG_INSTALLER=$(ls "$DATADIR"/deponia_*.sh 2> /dev/null | head -n 1)
if [ -n "$GOG_INSTALLER" ]; then
  pm_message "Extracting Deponia from the GOG installer, this can take a few minutes..." --title "Please wait"
  rm -rf "$DATADIR/.gog"
  "$controlfolder/7zzs.$DEVICE_ARCH" x -aoa -tzip "$GOG_INSTALLER" "data/noarch/game/*" -o"$DATADIR/.gog"
  if [ ! -f "$DATADIR/.gog/data/noarch/game/data.vis" ]; then
    rm -rf "$DATADIR/.gog"
    pm_show_error "Could not extract $(basename "$GOG_INSTALLER"). Check that there is at least 2 GB of free space, then launch again." --title "Extraction failed"
    exit 1
  fi
  for ITEM in "$DATADIR"/.gog/data/noarch/game/*; do
    rm -rf "$DATADIR/${ITEM##*/}"
    mv -f "$ITEM" "$DATADIR/"
  done
  rm -rf "$DATADIR/.gog" "$GOG_INSTALLER"
fi

rm -rf "$DATADIR/configtool" "$DATADIR/libsteam_api.so" "$DATADIR/steam_appid.txt" "$DATADIR"/libs64/libGalaxy* "$DATADIR"/goggame-* "$DATADIR/start" "$DATADIR/configure"

if [ ! -f "$DATADIR/data.vis" ] || [ ! -f "$DATADIR/$BINARY" ] || [ ! -d "$DATADIR/libs64" ]; then
  pm_show_error "Copy the GOG Linux installer (deponia_*.sh) or the Steam Linux depot files into ports/deponia/gamedata, then launch again." --title "Game data missing"
  exit 1
fi

if [ "$(md5sum "$DATADIR/$BINARY" | cut -d ' ' -f 1)" = "f432c959baa8bdbf225f54ceb19623e7" ]; then
  while read -r OFFSET HEXBYTES; do
    printf "$(echo "$HEXBYTES" | sed 's/../\\x&/g')" | dd of="$DATADIR/$BINARY" bs=1 seek="$OFFSET" conv=notrunc 2> /dev/null
  done < "$GAMEDIR/deponia_opus.patch"
fi

mkdir -p "$GAMEDIR/conf/Deponia"
bind_directories "$XDG_DATA_HOME/Daedalic Entertainment/Deponia" "$GAMEDIR/conf/Deponia"

for CONFIG in "$DATADIR/config.ini" "$GAMEDIR/conf/Deponia/config.ini"; do
  [ -f "$CONFIG" ] && sed -i -e 's/^FULLSCREEN = .*/FULLSCREEN = Yes/' \
    -e 's/^Device = .*/Device = OGL/' \
    -e 's/^RESOLUTION = .*/RESOLUTION = Desktop/' \
    -e 's/^UseHighResVideo = .*/UseHighResVideo = No/' \
    -e 's/^LockCursor = .*/LockCursor = Enabled/' "$CONFIG"
done

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$(awk '/MemTotal/ {print $2}' /proc/meminfo)" -lt 1572864 ]; then
  export LIBGL_SHRINK=1
  # no swap on some 1GB CFWs, and loading the intro video pushes the game into the OOM killer
  MKSWAP=$(PATH="$PATH:/usr/sbin:/sbin" command -v mkswap)
  SWAPON=$(PATH="$PATH:/usr/sbin:/sbin" command -v swapon)
  SWAPOFF=$(PATH="$PATH:/usr/sbin:/sbin" command -v swapoff)
  if [ -n "$MKSWAP" ] && [ -n "$SWAPON" ] && [ -n "$SWAPOFF" ] && [ "$(awk 'NR > 1' /proc/swaps | wc -l)" -eq 0 ] && [ "$(cat /sys/block/zram0/disksize 2> /dev/null)" = "0" ]; then
    echo lz4 | $ESUDO tee /sys/block/zram0/comp_algorithm > /dev/null
    echo 512M | $ESUDO tee /sys/block/zram0/disksize > /dev/null
    $ESUDO "$MKSWAP" /dev/zram0 > /dev/null && $ESUDO "$SWAPON" -p 5 /dev/zram0 && ZRAM_SWAP=1
  fi
fi

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/deponia.ini"
fi

if [ "$CFW_NAME" = "ROCKNIX" ]; then
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
  swaymsg seat '*' hide_cursor 0 2>/dev/null
  trap 'swaymsg seat "*" hide_cursor 1000 2>/dev/null' EXIT
fi

$GPTOKEYB2 "$BINARY" -c "./deponia.ini" &

pm_platform_helper "$DATADIR/$BINARY"

cd "$DATADIR"
SDL_DYNAMIC_API=libSDL2-2.0.so.0 SDL_NO_SIGNAL_HANDLERS=1 ALSOFT_CONF="$GAMEDIR/alsoft.conf" \
BOX64_DYNAREC_BIGBLOCK=3 BOX64_DYNAREC_CALLRET=1 BOX64_DYNAREC_SAFEFLAGS=0 \
BOX64_EMULATED_LIBS=libopenal.so.1 BOX64_LD_LIBRARY_PATH="$DATADIR/libs64:$GAMEDIR/box64/x64" \
"$GAMEDIR/box64/box64" "./$BINARY"

if [ -n "$ZRAM_SWAP" ]; then
  $ESUDO "$SWAPOFF" /dev/zram0
  echo 1 | $ESUDO tee /sys/block/zram0/reset > /dev/null
fi

pm_finish
