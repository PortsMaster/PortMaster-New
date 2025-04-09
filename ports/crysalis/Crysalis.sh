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
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="/${directory}/ports/crysalis"
GAMEDATADIR="${GAMEDIR}/gamedata"
CONFDIR="${GAMEDIR}/conf/"
TOOLSDIR="${GAMEDIR}/tools.${DEVICE_ARCH}"
RTP_PKG_URL="https://dl.komodo.jp/rpgmakerweb/run-time-packages/RPGVXAce_RTP.zip"

mkdir -p "$CONFDIR"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

exec > >(tee "${GAMEDIR}/log.txt") 2>&1

cd $GAMEDIR

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="${CONFDIR}"
export XDG_DATA_HOME="${GAMEDATA}"
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig}"
export LD_LIBRARY_PATH="${GAMEDIR}/libs.${DEVICE_ARCH}:${LD_LIBRARY_PATH}"

# Check if RPG Maker VX Ace Run Time Package is installed
if [ ! -d "$GAMEDATADIR/Fonts" ]; then

  ${TOOLSDIR}/text_viewer -f 25 -w -t "Run Time Package missing" -m "RPG Maker VX Ace Run Time Package will be installed"

  # Check if RPG Maker VX Ace Run Time Package instalation exists and extract it
  rtp_zip=`find ./ -iname "*RPGVXAce*RTP*.zip"`

  if [ ! -f "$rtp_zip" ]; then

    ${TOOLSDIR}/text_viewer -f 25 -w -t "File not found" -m "RPGVXAce_RTP.zip not found. Will try to download RPGVXAce_RTP.zip (187 MB). Please be patient"
    
    echo "Real Time Package not found. Downloading..."    
    wget --no-check-certificate "${RTP_PKG_URL}" -O "RPGVXAce_RTP.zip"
    [ $? -ne 0 ] && ${TOOLSDIR}/text_viewer -e -f 25 -w -t "Download error" -m "${RTP_PKG_URL} cannot be download. Please check your internet connexion" && exit 1
    rtp_zip="RPGVXAce_RTP.zip"

  fi

  [ -d "$GAMEDATADIR" ] && ${TOOLSDIR}/text_viewer -e -f 25 -w -t "Previous installation detected" -m "Remove gamedata folder first" && exit 1

  echo "Extracting Run Time Package..."
  ${TOOLSDIR}/text_viewer -f 25 -w -t "Run Time Package installation" -m "RPG Maker VX Ace Run Time Package will be extracted. Please be patient."

  unzip "${rtp_zip}"
  [ $? -ne 0 ] && ${TOOLSDIR}/text_viewer -e -f 25 -w -t "Extraction error" -m "Zip file cannot be extracted" && exit 1
  ${TOOLSDIR}/innoextract -e "RTP100/Setup.exe"
  [ $? -ne 0 ] && ${TOOLSDIR}/text_viewer -e -f 25 -w -t "Extraction error" -m "Setup.exe cannot be extracted" && exit 1

  mv "app" "$GAMEDATADIR" || exit 1
  rm -rf "RTP100"
  rm -f "$rtp_zip"


fi

if [ ! -f "$GAMEDATADIR/Game.exe" ]; then
  # Check if the Crysalis.exe file exists
  crysalis_exe=`find ./ -iname "*crysalis*.exe"`

  [ ! -f "$crysalis_exe" ] && ${TOOLSDIR}/text_viewer -e -f 25 -w -t "File not found" -m "Crysalis.exe not found" && exit 1

  ${TOOLSDIR}/text_viewer -f 25 -w -t "Game installation" -m "Extracting game. Please be patient."
  # Extract the contents of the archive file
  ${TOOLSDIR}/cabextract $crysalis_exe -d "${GAMEDATADIR}"
  [ $? -ne 0 ] && ${TOOLSDIR}/text_viewer -e -f 25 -w -t "Extraction error" -m "Cab cannot be extracted" && exit 1

  rm "${crysalis_exe}"

fi

if [ ! -f "$GAMEDATADIR/falcon_mkxp.bin" ];then
  cp "${TOOLSDIR}/falcon_mkxp.bin" "${GAMEDATADIR}/" || exit 1
fi

cp "${CONFDIR}/mkxp.conf" "${GAMEDATADIR}/"

$GPTOKEYB "falcon_mkxp.bin" -c "./crysalis.gptk" &
${GAMEDIR}/gamedata/falcon_mkxp.bin

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
