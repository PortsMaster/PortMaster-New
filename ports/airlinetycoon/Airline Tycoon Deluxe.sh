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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/airlinetycoon
BINARY=ATDeluxe
DATADIR="$GAMEDIR/gamedata"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

GOG_INSTALLER=$(ls "$DATADIR"/gog_airline_tycoon_deluxe_*.sh 2> /dev/null | head -n 1)
if [ -n "$GOG_INSTALLER" ]; then
  pm_message "Extracting Airline Tycoon Deluxe from the GOG installer, this can take a few minutes..." --title "Please wait"
  rm -rf "$DATADIR/.gog"
  "$controlfolder/7zzs.$DEVICE_ARCH" x -aoa -tzip "$GOG_INSTALLER" "data/noarch/game/*" -o"$DATADIR/.gog"
  if [ ! -f "$DATADIR/.gog/data/noarch/game/$BINARY" ]; then
    rm -rf "$DATADIR/.gog"
    pm_show_error "Could not extract $(basename "$GOG_INSTALLER"). Check that there is enough free space, then launch again." --title "Extraction failed"
    exit 1
  fi
  for ITEM in "$DATADIR"/.gog/data/noarch/game/*; do
    rm -rf "$DATADIR/${ITEM##*/}"
    mv -f "$ITEM" "$DATADIR/"
  done
  rm -rf "$DATADIR/.gog" "$GOG_INSTALLER"
  # the installer stores these as symlinks, which 7zz drops and the SD card can't hold
  for LINK in libsmpeg2-2.0.so.0:libsmpeg2-2.0.so.0.0.0 libSDL2_mixer-2.0.so.0:libSDL2_mixer-2.0.so.0.0.0 libvorbisfile.so.3:libvorbisfile.so.3.3.5 libvorbis.so.0:libvorbis.so.0.4.6 libogg.so.0:libogg.so.0.8.1 libvorbisenc.so.2:libvorbisenc.so.2.0.9; do
    cp -f "$DATADIR/lib32/${LINK#*:}" "$DATADIR/lib32/${LINK%%:*}"
  done
  for LANG_DIR in de en fr; do
    for SUB in gli misc; do
      for FILE in "$DATADIR/$SUB"/*; do
        [ -e "$DATADIR/$LANG_DIR/$SUB/${FILE##*/}" ] || cp "$FILE" "$DATADIR/$LANG_DIR/$SUB/"
      done
    done
  done
fi

rm -rf "$DATADIR/.DepotDownloader" "$DATADIR"/*.pdf

if [ ! -f "$DATADIR/$BINARY" ] || [ ! -d "$DATADIR/lib32" ] || [ ! -d "$DATADIR/room" ]; then
  pm_show_error "Copy the GOG Linux installer (gog_airline_tycoon_deluxe_*.sh) or the Steam Linux depot files into ports/airlinetycoon/gamedata, then launch again." --title "Game data missing"
  exit 1
fi

mkdir -p "$GAMEDIR/conf/.AirlineTycoonDeluxe"
bind_directories ~/.AirlineTycoonDeluxe "$GAMEDIR/conf/.AirlineTycoonDeluxe"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# SDL's cursor is invisible on KMSDRM, and the game's own flag screen relies on it
if [ ! -f "$GAMEDIR/conf/.AirlineTycoonDeluxe/language.ini" ]; then
  pm_message_close 2> /dev/null
  PortMasterDialogExit
  export GAMEPAD_PICKER_OUTPUT="$GAMEDIR/.picker_result"
  ./gamepad-picker.${DEVICE_ARCH} "English|0" "Deutsch|2" "Français|1" > /dev/null
  LANGUAGE_CHOICE=$(cat "$GAMEPAD_PICKER_OUTPUT" 2> /dev/null)
  echo "language=${LANGUAGE_CHOICE:-0}" > "$GAMEDIR/conf/.AirlineTycoonDeluxe/language.ini"
  rm -f "$GAMEPAD_PICKER_OUTPUT"
fi

if [ "${DISPLAY_WIDTH:-640}" -gt 1280 ]; then
  sed -i "s/^deadzone_scale = .*/deadzone_scale = 18/" "$GAMEDIR/airlinetycoon.ini"
fi

if [ "$CFW_NAME" = "ROCKNIX" ]; then
  export SDL_TOUCH_MOUSE_EVENTS=0
  swaymsg input type:touch events disabled 2>/dev/null
  swaymsg seat '*' hide_cursor 0 2>/dev/null
  trap 'swaymsg seat "*" hide_cursor 1000 2>/dev/null' EXIT
fi

$GPTOKEYB2 "$BINARY" -c "$GAMEDIR/airlinetycoon.ini" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/box86/box86"

cd "$DATADIR"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib32:/usr/lib/arm-linux-gnueabihf" SDL_DYNAMIC_API=libSDL2-2.0.so.0 SDL_NO_SIGNAL_HANDLERS=1 \
BOX86_EMULATED_LIBS=libsmpeg2-2.0.so.0:libSDL2_mixer-2.0.so.0 BOX86_LD_LIBRARY_PATH="$DATADIR/lib32:$GAMEDIR/x86lib" "$GAMEDIR/box86/box86" "./$BINARY" /noinputgrab

pm_finish
