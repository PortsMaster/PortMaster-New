# dRally

A port of Death Rally (1996) running natively on Linux and BSD based operating systems.

# Controls

| Button            | Command                    |
|-------------------|----------------------------|
| **A**             | Accelerate                 |
| **B**             | Brake                      |
| **D-Pad left**    | steer left                 | 
| **D-Pad right**   | steer right                |
| **Left Analog**   | steer right/left           |
| **R1**            | Machine Gun                |
| **R2**            | Turbo Boost                |
| **L1**            | Drop Mine                  |
| **L2**            | Horn                       |
| **Start**         | Enter                      |
| **Select**        | Back                       |
| **Select R2**     | Quick Save                 |
| **Left Analog**   | Quick Load                 |
| **Start up/down** | Text input                 |
| **R1 Select**     | tab                        |

# Game folder structure

## Installation - needs original game assets

Download [Death Rally registered free windows version CHIP](https://www.chip.de/downloads/Death-Rally-Vollversion_38550689.html)

Place DeathRallyWin_10.exe into the ports/drally/ directory and it will be automatically extracted.


## Building

    git clone https://github.com/urxp/dRally.git

    make -j4

The file is named "drally_linux"

# TODO:

- [x] Get game to work.
- [x] Figure out controls
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [PortMaster discord](https://discord.gg/m2QcSkMh), and Snoopy Peter for helping with the controls.
