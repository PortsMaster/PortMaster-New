# Augustus - Open Source Caeser 3

# Controls

| Button            | Command                     |
|-------------------|-----------------------------|
| **A**             | Mouse Left                  |
| **B**             | Mouse Right                 |
| **X**             | Clone building under cursor |
| **L1**            | Nothing                     |
| **L2**            | Rotate counter clock wise   |
| **R1**            | Slow down mouse             |
| **R2**            | Rotate clock wise           |
| **L1 = Select**   | Decrease game speed         |
| **L2 = Select**   | Quicksave                   |
| **R1 = Select**   | Increase game speed         |
| **R2 = Select**   | Quickload                   |
| **Start**         | Pause                       |
| **Select**        | Menu                        |
| **D-Pad**         | Move screen                 |
| **Left Analog**   | Mouse Movement              |
| **Right Analog**  | Move screen                 |


To enter text: press **Start + Down**, then use **Up** and **Down** to select the letter, **Left** and **Right** moves forwards and backwards. **Start** or **A** to finish editing.

# Game folder structure

Install the game files into `ports/augustus/data`, here are some excellent instructions [from the Julius project](https://github.com/bvschaik/julius/wiki/Running-Julius) (which Augustus is a fork of). If installing from the CD's you'll need to get the [latest patches](https://github.com/bvschaik/julius/wiki/Patches).

## Building

Either my pre-patched repo:

    git clone https://github.com/Keriew/augustus.git

    cd augustus

    git apply Force_Software_Cursor.diff

    mkdir build

    cd build

    cmake .. -DCMAKE_BUILD_TYPE=Release

    make -j4

    cd ../res

    zip -9r assets.zip assets/

At the end we need to copy `build/augustus` and `res/assets.zip` to the `Augustus/build/` directory.

# TODO:

- [x] Get a map to work!
- [x] Figure out controls - thanks @Cebion!
- [x] Test it on AmberELEC
- [x] Test it on ArkOS

# Thanks

A special thanks to the excellent folks on the [AmberELEC discord](https://discord.com/invite/R9Er7hkRMe), especially @Cebion for all the testing and figuring out the controls.
