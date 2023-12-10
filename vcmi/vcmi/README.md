# VCMI - Heroes of Might and Magic 3

# Controls

| Button            | Command                    |
|-------------------|----------------------------|
| **A / R1**        | Mouse Left                 |
| **B / L1**        | Mouse Right                |
| **X**             | End Turn                   |
| **Y**             | Move Hero                  |
| **L2**            | Options                    |
| **R2**            | Puzzle ?                   |
| **Select + L2**   | Save                       |
| **Select + R2**   | Load                       |
| **Start**         | Accept / Enter             |
| **Select**        | Escape                     |
| **D-Pad Up**      | Underground / Overground   |
| **D-Pad Down**    | Dig                        |
| **D-Pad Left**    | Cast spell                 |
| **D-Pad Right**   | Next Hero                  |
| **Left Analog**   | Mouse Movement             |
| **Right Analog**  | Move Hero                  |


# Game folder structure

VCMI will automatically copy and extract the required files, you can either install from CD1 & CD2, GoG or an installed copy of the game. This requires about 2-3 gb of free space.

For the **gog version** copy `setup_heroes_of_might_and_magic_3_complete_4.0_(28740)-1.bin` and `setup_heroes_of_might_and_magic_3_complete_4.0_(28740).exe` into `ports/vcmi`.

For the **cd version** copy the contents of **cd1** into `ports/vcmi/cd1` and optionally **cd2** into `ports/vcmi/cd2`.

For the **installed version** copy installed game files into `ports/vcmi/install`.

So far I have only reliably tested the GoG version, so your mileage may vary.

## Building


    git clone -b develop --recursive https://github.com/vcmi/vcmi.git

    git apply DATA_PATHS.diff

    mkdir build
    cd build

    cmake .. -DBIN_DIR:FILE="bin" -DCMAKE_INSTALL_PREFIX:FILE="." -DCOPY_CONFIG_ON_BUILD="ON" -DENABLE_DEBUG_CONSOLE="OFF" -DENABLE_EDITOR="OFF" -DENABLE_ERM="OFF" -DENABLE_GITVERSION="ON" -DENABLE_LAUNCHER="OFF" -DENABLE_LUA="ON" -DCMAKE_BUILD_TYPE="RelWithDebInfo" -DENABLE_MONOLITHIC_INSTALL="OFF" -DENABLE_MULTI_PROCESS_BUILDS="ON" -DENABLE_NULLKILLER_AI="ON" -DENABLE_PCH="OFF" -DENABLE_SINGLE_APP_BUILD="OFF" -DENABLE_STATIC_AI_LIBS="OFF" -DENABLE_STRICT_COMPILATION="OFF" -DENABLE_TEST="OFF" -DENABLE_TRANSLATIONS="OFF" -DFL_BACKTRACE="ON" -DFL_BUILD_BINARY="OFF" -DFL_BUILD_SHARED="OFF" -DFL_BUILD_STATIC="ON" -DFL_BUILD_TESTS="OFF" -DFL_USE_FLOAT="OFF" -DFORCE_BUNDLED_FL="ON" -DLUA_INCLUDE_DIR:PATH=/usr/include/lua5.2 -DLUA_LIBRARY:FILEPATH=/usr/lib/aarch64-linux-gnu/liblua5.2.so


    make -j4


# TODO:

- [x] Get game to work.
- [x] Figure out controls
- [x] Make text a bit more readable if possible
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially [Cebion](https://github.com/Cebion) for all the testing.