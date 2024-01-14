# Portmaster-GemRB

This is the configuration files and the required steps to build the GemRB engine for handheld emulator devices (Anbernic RG351V/MP, RG353P/V/M, RG552, etc.) using the PortMaster scripts for launching.

# Installation

Use PortMaster to install gemrb, copy the desired game or games into `{PORTFOLDER}/gemrb/games/{GAME_ID}`. On launch it will ask you to choose the game if it detects multiple games.

# Controls

## Baldur's Gate I & II

| Button            | Command                    |
|-------------------|----------------------------|
| **R1/A**          | Left Click                 |
| **L1/B**          | Right Click                |
| **L2**            | Priest spells              |
| **R2**            | Wizard spells              |
| **X**             | Inventory                  |
| **Y**             | Character Record           |
| **Select+L1**     | Quick Save                 |
| **Start**         | Pause                      |
| **Select**        | Options                    |
| **Up**            | mappings                   |
| **Down**          | Journal                    |
| **Left**          | Toggle AI                  |
| **Right**         | Character Arbitration      |
| **Left Stick**    | Move cursor                |
| **Right Stick**   | Move screen                |

## Planescape Torment

| Button            | Command                    |
|-------------------|----------------------------|
| **R1/A**          | Left Click                 |
| **L1/B**          | Right Click                |
| **L2**            | Priest spells              |
| **R2**            | Wizard spells              |
| **X**             | Inventory                  |
| **Y**             | Toggle Run                 |
| **Select+L1**     | Quick Save                 |
| **Start**         | Pause                      |
| **Select**        | Options                    |
| **Up**            | mappings                   |
| **Down**          | Journal                    |
| **Left**          | Toggle AI                  |
| **Right**         | Character Arbitration      |
| **Left Stick**    | Move cursor                |
| **Right Stick**   | Move screen                |


To enter text: press **Start + Down**, then use **Up** and **Down** selects the letter, **Left** and **Right** moves forwards and backwards. **Start** or **A** to finish editing.

# Game folder structure

When you install the game to your sd-card in `{PORTFOLDER}/gemrb/games/{GAME_ID}`, the recommended directory names are as below:

- **bg1** for Baldur's Gate 1
- **bg2** for Baldur's Gate 2
- **iwd** for Icewind Dale
- **iwd2** for Icewind Dale 2
- **pst** for Planescape Torment

The game selection system will do its best to figure out the name of the game if you don't follow these instructions.

## Required libs

- the following libraries from Debian 11 Bullseye Aarch64
  - libpython3.9 & library files

 
## Building

    git clone https://github.com/gemrb/gemrb.git

    cd gemrb

    git apply CORE_fixes.diff
    git apply GLES2_fixes.diff

    mkdir build

    cd build

    cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DLAYOUT=home  -DUSE_ICONV=OFF -DDISABLE_VIDEOCORE=ON -DUSE_LIBVLC=OFF -DSDL_BACKEND=SDL2 -DUSE_SDL_CONTROLLER_API="OFF" -DSDL_RESOLUTION_INDEPENDANCE="ON" -DCMAKE_INSTALL_PREFIX:FILE="engine" -DOPENGL_BACKEND="GLES"

    make -j4

    make install

    cd engine

    zip -9r ../engine.zip engine/

    cd ..

At the end, you want the `engine.zip`.

# TODO:

- [x] Get a game to work!
- [ ] Add per game configs where needed
- [ ] Add per game gptokeyb mappings if needed
- [x] Fix flickering cursor

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), and the nice people over at [GemRB](https://gemrb.org/) for accepting the patches so we can keep this up to date.
