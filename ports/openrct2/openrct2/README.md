# Open Roller Coaster Tycoon 2

# Controls

| Button            | Command                    |
|-------------------|----------------------------|
| **A**             | Mouse Left                 |
| **B**             | Mouse Right                |
| **Y**             | Rotate construction object |
| **X**             | Close top window           |
| **X + Select**    | Close all windows          |
| **L2**            | Rotate clock wise          |
| **R1**            | Slow down mouse            |
| **R2**            | Rotate counter clock wise  |
| **L2 + Select**   | Zoom out                   |
| **R2 + Select**   | Zoom in                    |
| **R1 + Select**   | Save                       |
| **Start**         | Pause                      |
| **Select**        | Cancel construction        |
| **D-Pad Up**      | Build water                |
| **D-Pad Down**    | Build footpaths            |
| **D-Pad Left**    | Build scenery              |
| **D-Pad right**   | Build rides                |
| **Left Analog**   | Mouse Movement             |
| **Right Analog**  | Map Move                   |


To enter text: press **Start + Down**, then use **Up** and **Down** selects the letter, **Left** and **Right** moves forwards and backwards. **Start** or **A** to finish editing.

# Game folder structure

Install your Roller Coaster Tycoon 2 game files into `{PORTS}/openrct2/RCT2`, **these files are required**, and optionally your Roller Coaster Tycoon 1 game files into `{PORTS}/openrct2/RCT1`.

For help getting the game files for [RCT2 on macOS & Linux](https://github.com/OpenRCT2/OpenRCT2/wiki/Installation-on-Linux-and-macOS), and for help getting game files for [RCT1](https://github.com/OpenRCT2/OpenRCT2/wiki/Loading-RCT1-scenarios-and-data).

## Required libs

- the following libraries from Debian 11 Bullseye Aarch64
  - libicudata.so.67
  - libicuuc.so.67
  - libzip.so.4

 
## Building

Either my pre-patched repo:

    git clone https://github.com/kloptops/OpenRCT2.git

or clone the latest version and apply the patch

    git clone https://github.com/OpenRCT2/OpenRCT2.git

    git apply PATH_TO_HERE/SDL_sim_cursor.diff

then just run:

    cd openrct2

    mkdir build

    cd build

    cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DDISABLE_GOOGLE_BENCHMARK="ON" -DDISABLE_DISCORD_RPC="ON" -DPORTABLE="ON" -DCMAKE_INSTALL_PREFIX:FILE="engine"

    make -j4

    make install

    rm -f engine.zip
    rm -f engine/bin/libopenrct2.a
    rm -f engine/bin/openrct2-cli

    zip -9r engine.zip engine/

    At the end, you want the `engine.zip`.

# TODO:

- [x] Get a map to work!
- [x] Figure out controls
- [x] Make text a bit more readable if possible
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially Cebion for all the testing.
