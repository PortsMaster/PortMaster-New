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

GAMEDIR="/$directory/ports/petsciirobotsmsx"
BIOSDIR="$GAMEDIR/share/systemroms"

cd $GAMEDIR

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ] && [ "${CFW_NAME^^}" != "KNULLI" ]; then
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.${DEVICE_ARCH}/libEGL.so.1"
fi 

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO chmod +x "$GAMEDIR/bin/openmsx.${DEVICE_ARCH}"
$ESUDO chmod +x "$GAMEDIR/text_viewer.${DEVICE_ARCH}"
$ESUDO chmod +x "$GAMEDIR/7zzs.${DEVICE_ARCH}"

# Extract game files on 1st run
if [ ! -d "$GAMEDIR/share/machines" ]; then
    "$GAMEDIR/7zzs.${DEVICE_ARCH}" x "$GAMEDIR/openmsxdata.7z" -o"$GAMEDIR/"
    sleep 1
    #rm -f "$GAMEDIR/openmsxdata.7z"
fi

[ ! -d ~/.openMSX ] && $ESUDO mkdir -m777 -p ~/.openMSX
bind_directories ~/.openMSX/share $GAMEDIR/share

if [ ! -f "$BIOSDIR/fs-a1gt_firmware.rom" ] || [ ! -f "$BIOSDIR/fs-a1gt_kanjifont.rom" ] || [ ! -f "$BIOSDIR/yrw801.rom" ]; then
    ./text_viewer.${DEVICE_ARCH} -f 20 -w -t "Instructions" --input_file "$GAMEDIR/needbios.txt"
fi

$GPTOKEYB "openmsx.${DEVICE_ARCH}" -c "$GAMEDIR/petscii.gptk" &
pm_platform_helper "$GAMEDIR/bin/openmsx.${DEVICE_ARCH}"
$GAMEDIR/bin/openmsx.${DEVICE_ARCH} -machine Panasonic_FS-A1GT -ext moonsound -ext gfx9000 -carta carts/MSXdev23_AttackofthePetsciiRobots_v1.2.rom -command "set videosource GFX9000"

pm_finish
