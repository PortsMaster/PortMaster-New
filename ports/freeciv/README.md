# Thanks
Thanks to the [FreeCiv Team](https://freeciv.org/) for making this game and making it available for free.
Also special thanks to @kloptops for the initial packaging! 

## Controls

| Button | Action |
|--|--| 
|DPAD| Move|
|Analogue Sticks| Mouse Movement| 
|A| Mouse Left|
|B| Mouse Right|
|X| Slow Down Mouse (hold) 
|Select + a| End Turn|

## Building

```
    git clone https://github.com/freeciv/freeciv

    git apply JANKY_STUFF.diff

    mkdir build

    cd build

    CFLAGS="-DALWAYS_ROOT" ../configure --enable-client=sdl2 --enable-fcmp=no --prefix="$PWD/engine"

edit gen_headers/fc_config.h, comment out `FREECIV_STORAGE_DIR`

edit gen_headers/freeciv_config.h, modify the line with `FREECIV_STORAGE_DIR` to:

    #undef BINDIR
    #define BINDIR "bin"

    /* Location for freeciv to store its information */
    #define FREECIV_STORAGE_DIR "saves"

then you can continue making:

    make -j4

    make install

    cd engine

    mv shared/freeciv data
    strip bin/*

the files you want are `bin/` and `data/`

```
