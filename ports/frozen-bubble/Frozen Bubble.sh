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

GAMEDIR="/$directory/ports/frozen-bubble"
CONFDIR="${GAMEDIR}/conf/"
GFXDIR="${GAMEDIR}/gfx"
PERLDIR="${GAMEDIR}/perl"
GFXFILE="gfx.squashfs"
PERLFILE="perl.squashfs"

mkdir -p "${CONFDIR}"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="${GAMEDIR}/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

export PATH="${PERLDIR}/bin/${DEVICE_ARCH}-linux-gnu:${PATH}"
export PERL5LIB="${PERLDIR}/lib/aarch64-linux-gnu/perl-base"
export PERL5LIB="${PERL5LIB}:${PERLDIR}/lib/${DEVICE_ARCH}-linux-gnu/perl/5.30.0"
export PERL5LIB="${PERL5LIB}:${PERLDIR}/lib/perl5"

mkdir -p "${GFXDIR}"
mkdir -p "${PERLDIR}"

$ESUDO umount "${GFXFILE}" || true
$ESUDO mount "${GFXFILE}" "${GFXDIR}"
$ESUDO umount "${PERLFILE}" || true
$ESUDO mount "${PERLFILE}" "${PERLDIR}"

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "perl" -c "./frozen-bubble.gptk"  &

perl frozen-bubble --fullscreen 2>&1

$ESUDO umount "${GFXDIR}"
$ESUDO umount "${PERLDIR}"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
