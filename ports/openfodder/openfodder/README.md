# OpenFodder

Cannon Fodder is an action-strategy shoot 'em up game developed by Sensible Software and published by Virgin Interactive.

The game is military-themed and based on shooting action but with a strategy game-style control system. The player directs troops through numerous missions, battling enemy infantry, vehicles and installations.

Open Fodder is an open source version of the Cannon Fodder engine, for modern operating systems.

# Controls

| Button            | Command                    |
|-------------------|----------------------------|
| **A / R1**        | Move                       |
| **B / L1**        | Shoot                      |
| **Y**             | Switch Weapon              |
| **Up**            | Select Squad 1             |
| **Left**          | Select Squad 2             |
| **Right**         | Select Squad 3             |
| **Down**          | Show Map                   |
| **Start**         | Pause                      |
| **Select**        | Escape                     |
| **Select + A**    | Save                       |
| **Left Analog**   | Mouse Movement             |


To enter text: press **Start + Down**, then use **Up** and **Down** selects the letter, **Left** and **Right** moves forwards and backwards. **Start** or **A** to finish editing.


# Game folder structure

The game comes with demo files, to install the full versions:

## Dos CD Version

Copy `CF_ENG.DAT` from the CD (or the GOG install destination) to the `roms/openfodder/Data/Dos_CD` folder.

## Amiga Versions

See [here](https://github.com/OpenFodder/openfodder/blob/master/INSTALL.md#amiga) for details on doing so.
 
## Building

    git clone https://github.com/OpenFodder/openfodder

    cd openfodder

    mkdir build

    cd build

    cmake ..

    make -j4

    strip openfodder


# TODO:

- [x] Get game to work.
- [x] Figure out controls
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially Cebion and Snoopy for all the testing.