## Building from source

To build the game from source and make it compatible you will need to clone the repo [sdlpal](https://github.com/sdlpal/sdlpal).

After that, edit the file `unix/pal_config.h` and change the following line:

```cpp
#  define PAL_HAS_JOYSTICKS    1
```

To:

```cpp
#  define PAL_HAS_JOYSTICKS    0
```

Navigate to the folder `unix` by doing:

```bash
cd unix
```

Compile the game by running the following:

```bash
make -j$(nproc) # if 'nproc' is missing, just remove the '-j$(nproc)' part
```

The compile game will be at: `unix/sdlpal`.

## Notes
<br/>

Thanks to the [sdlpal](https://github.com/sdlpal/sdlpal) team for the SDL-based reimplementation of the classic Chinese-language RPG known as PAL.

<br/>
