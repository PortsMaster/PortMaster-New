
BUILDING.md — Luanti Compilation
==============================================

---------------------------------------------------------------------
DEPENDENCIES
---------------------------------------------------------------------
Required libraries:
- freetype
- curl
- irrlichtmt
- sqlite3
- zlib
- jpeg
- png
- openal
- vorbis, ogg
- luajit

---------------------------------------------------------------------
1. COMPILE IRRLICHTMT
---------------------------------------------------------------------
Commands:

```
git clone https://github.com/minetest/irrlicht
cd irrlicht
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release
make -j4
sudo make install
```

---------------------------------------------------------------------
2. BUILD LUANTI
---------------------------------------------------------------------
Clone and configure:

```
git clone https://github.com/minetest/minetest.git luanti
cd luanti
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_UNITTESTS=OFF -DENABLE_SYSTEM_JSONCPP=FALSE -DENABLE_SYSTEM_GMP=FALSE -DENABLE_LUAJIT=TRUE
make -j4
```

---------------------------------------------------------------------
3. APPLY THE PATCH
---------------------------------------------------------------------
Apply mouse pointer patch

```
patch -p1 < meowmeow5.diff
```

---------------------------------------------------------------------
4. PREPARE PORTMASTER DIRECTORY
---------------------------------------------------------------------
Copy compiled binary:

```
cp bin/luanti /roms/ports/luanti/bin/luanti
```

Copy required shared libraries:

```
ldd bin/luanti
```
(then copy missing .so files into the port directory)

Copy Luanti resources:

```
cp -r ../builtin   /roms/ports/luanti/
cp -r ../games     /roms/ports/luanti/
cp -r ../textures  /roms/ports/luanti/
```

Clone Mineclonia game repo to /roms/ports/luanti/games
```
git clone https://codeberg.org/mineclonia/mineclonia.git
```

(Optional) Create mods folder:

```
mkdir /roms/ports/luanti/mods
```

---------------------------------------------------------------------
5. CREATE RUN SCRIPT
---------------------------------------------------------------------
Create file: luanti.sh

```
#!/bin/bash
# PORTMASTER: minetest.zip, Minetest.sh

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

GAMEDIR="/$directory/ports/minetest"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

export TERM=linux
printf "\033c" > /dev/tty0

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

CUR_TTY=/dev/tty0

ARCHIVE_FILE="$GAMEDIR/data.tar.gz"
SEVENZIP="${controlfolder}/7zzs.aarch64"

if [[ -f "$ARCHIVE_FILE" ]]; then
    echo "Extracting game data, this will take some time..." > "$CUR_TTY"

    if "$SEVENZIP" x "$ARCHIVE_FILE"; then
        TAR_FILE="${ARCHIVE_FILE%.gz}"

        if "$SEVENZIP" x "$TAR_FILE" -o"./"; then
            echo "Game data extracted successfully" > "$CUR_TTY"

            # cleanup
            rm -f "$ARCHIVE_FILE"
            rm -f "$TAR_FILE"
        else
            echo "ERROR!!!  Failed to extract TAR contents." > "$CUR_TTY"
            sleep 5
            exit 1
        fi
    else
        echo "ERROR!!!  Failed to decompress GZIP." > "$CUR_TTY"
        sleep 5
        exit 1
    fi
fi

ifconfig lo up
if [ "$CFW_NAME" = "ROCKNIX" ]; then
	swaymsg seat seat0 hide_cursor 0
fi
chmod +x ./bin/luanti
$GPTOKEYB "luanti" -c "$GAMEDIR/minetest.gptk.$ANALOG_STICKS" &
./bin/luanti
if [ "$CFW_NAME" = "ROCKNIX" ]; then
	swaymsg seat seat0 hide_cursor 1000
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0


Make executable:

chmod +x luanti.sh
```

---------------------------------------------------------------------
DONE
---------------------------------------------------------------------