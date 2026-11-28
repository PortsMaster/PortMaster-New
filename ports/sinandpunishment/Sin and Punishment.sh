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

GAMEDIR="/$directory/ports/sinandpunishment"
BINARY="snprecompiled.${DEVICE_ARCH}"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SNP_ROM_DIR="$GAMEDIR/roms"
export ANALOG_STICKS

if [ -z "$SSL_CERT_FILE" ] && [ -z "$CURL_CA_BUNDLE" ]; then
  for ca in \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/pki/tls/certs/ca-bundle.crt \
    /etc/ssl/cert.pem \
    "${controlfolder}/files/ca-certificates.crt" \
    "$(dirname "$controlfolder")/files/ca-certificates.crt" \
    "${controlfolder}/exlibs/certifi/cacert.pem"; do
    if [ -f "$ca" ]; then
      export SSL_CERT_FILE="$ca"
      export CURL_CA_BUNDLE="$ca"
      break
    fi
  done
fi

shopt -s nullglob nocaseglob
rom_files=("$GAMEDIR/roms/"*.{z64,n64,v64})
user_patches=("$GAMEDIR/roms/"*.{bps,ups,ips,xdelta,xdelta3,vcdiff})
shopt -u nullglob nocaseglob

if [ ${#rom_files[@]} -eq 0 ] && [ ! -f "$GAMEDIR/snp.n64.en.fan.z64" ] && [ ! -f "$GAMEDIR/snp.n64.jp.1.0.z64" ]; then
  pm_show_error "Copy your legally obtained Sin and Punishment Nintendo 64 ROM (.z64, .n64, or .v64) to ports/sinandpunishment/roms/ and launch again." --title "Game files missing"
  pm_finish
  exit 1
fi

if [ -f "$GAMEDIR/snp.patch" ] || \
   [ ! -x "$GAMEDIR/$BINARY" ] || \
   ( [ ! -f "$GAMEDIR/snp.n64.en.fan.z64" ] && [ ! -f "$GAMEDIR/snp.n64.jp.1.0.z64" ] ) || \
   ( [ ${#user_patches[@]} -gt 0 ] && [ ! -f "$GAMEDIR/snp.n64.en.fan.z64" ] ); then
  chmod +x "$GAMEDIR/tools/patchscript" "$GAMEDIR/tools/snp-patch" 2>/dev/null || true
  PATCHER_FILE="$GAMEDIR/tools/patchscript"
  PATCHER_GAME="$(basename "${0%.*}")"
  PATCHER_TIME="about 5 seconds"
  export PATCHER_FILE PATCHER_GAME PATCHER_TIME controlfolder ESUDO DEVICE_ARCH GAMEDIR BINARY

  if [ -f "$controlfolder/utils/patcher.txt" ]; then
    source "$controlfolder/utils/patcher.txt"
  else
    pm_show_error "This port requires the latest version of PortMaster." --title "Update required"
    pm_finish
    exit 1
  fi

  patch_fail_msg="$(sed -n 's/^PATCH_FAIL_MSG://p' "$GAMEDIR/patchlog.txt" 2>/dev/null | tail -n 1 || true)"
  if [ -n "$patch_fail_msg" ] || [ ! -x "$GAMEDIR/$BINARY" ] || ( [ ! -f "$GAMEDIR/snp.n64.en.fan.z64" ] && [ ! -f "$GAMEDIR/snp.n64.jp.1.0.z64" ] ); then
    pm_show_error "${patch_fail_msg:-ROM verification or patching failed. Check patchlog.txt in ports/sinandpunishment/ for details.}" --title "Patching Failed"
    pm_finish
    exit 1
  fi
fi

$GPTOKEYB2 "snprecompiled" > /dev/null 2>&1 &

pm_platform_helper "$GAMEDIR/$BINARY"

./$BINARY

pm_finish
