# FreeSerf

# Controls

Dual Analog Sticks:

| Button            | Command                    |
|-------------------|----------------------------|
| **A**             | Mouse Left                 |
| **B**             | Mouse Right                |
| **X**             | Messages                   |
| **Y**             | Button 1                   |
| **L1**            | Toggle overlay             |
| **Select + L1**   | Speed Down                 |
| **L2**            | Zoom Out                   |
| **R1**            | Slow down mouse            |
| **R2**            | Zoom In                    |
| **Select + R1**   | Speed Up                   |
| **Start**         | Pause                      |
| **D-Pad Up**      | Button 1                   |
| **D-Pad Right**   | Button 2                   |
| **D-Pad Down**    | Button 3                   |
| **D-Pad Left**    | Button 4                   |
| **Select**        | Button 5                   |
| **Left Analog**   | Mouse Movement             |
| **Right Analog**  | Move Screen                |

Single Analog Stick:

| Button            | Command                    |
|-------------------|----------------------------|
| **A**             | Mouse Left                 |
| **B**             | Mouse Right                |
| **X**             | Messages                   |
| **Y**             | Button 1                   |
| **L1**            | Toggle overlay             |
| **Select + L1**   | Speed Down                 |
| **L2**            | Zoom Out                   |
| **R1**            | Slow down mouse            |
| **R2**            | Zoom In                    |
| **Select + R1**   | Speed Up                   |
| **Start**         | Pause                      |
| **Select**        | Button 5                   |
| **D-Pad**         | Move Screen                |
| **Left Analog**   | Mouse Movement             |

# Game folder structure

Copy the game files into the `ports/freeserf` folder, depending on whether you have the DOS or Amiga files:

- **DOS**: data file is dependent on the language installed: `SPAE.PA`, `SPAD.PA`, `SPAF.PA`, or `SPAU.PA`. This file has to be from the installed version of the game, use DosBox to install the game to get the file.
- **Amiga**: copy the following files: `gfxheader`, `gfxfast`, `gfxchip`, `gfxpics`, `sounds`, and `music`.

 
## Building


    git clone https://github.com/freeserf/freeserf

    git apply Ports_Patch.diff

    mkdir build

    cd build

    cmake ..

    make -j4

Then copy `FreeSerf` from the `build/src` directory.

# TODO:

- [x] Get game to work.
- [x] Figure out controls
- [x] Make text a bit more readable if possible
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially Cebion for all the testing.
