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
export PORT_32BIT="Y"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/nfs2se
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export LD_LIBRARY_PATH="/usr/lib/arm-linux-gnueabihf/":"/usr/lib32":"$GAMEDIR/libs/":"$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO rm -rf ~/.nfs2se
ln -sfv /$directory/ports/nfs2se/conf/.nfs2se  ~/


# Process directories
find . -depth -type d | grep -e "[A-Z]" | while read -r dir; do
    newdir=$(echo "$dir" | tr '[A-Z]' '[a-z]' | sed 's/-1$//')
    
    # Simple progress message
    echo "Renaming $dir" > "$CUR_TTY"
    
    mv "$dir" "$dir-1" > "$CUR_TTY"
    mv "$dir-1" "$newdir" > "$CUR_TTY"
done

# Process files
find . -type f | grep -e "[A-Z]" | while read -r file; do
    newfile=$(echo "$file" | tr '[A-Z]' '[a-z]' | sed 's/-1$//')
    
    # Simple progress message
    echo "Renaming $file" > "$CUR_TTY"
    
    mv "$file" "$file-1" > "$CUR_TTY"
    mv "$file-1" "$newfile" > "$CUR_TTY"
done

#export TEXTINPUTINTERACTIVE="Y"

$GPTOKEYB "nfs2se" -c "./nfs2se.gptk" &
$GAMEDIR/nfs2se
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
