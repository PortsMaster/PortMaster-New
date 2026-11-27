## Notes

Thanks to [snauts](https://github.com/snauts/shmupacabra) (Arturs Grebstelis) for Shmupacabra, a free bullet hell shooter written in C and Lua. The game is MIT licensed.

Highscore-style name entry does not exist in this game, so there is no on-screen keyboard.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move, menu navigation |
| A | Shoot (tap for spread shot) |
| B | Bomb |
| X | Skip |
| Y | Pause |
| Start | Select / confirm |
| Select | Back / pause menu |

Controls can also be rebound in the game's Setup menu.

## Compile

```bash
git clone https://github.com/snauts/shmupacabra.git
cd shmupacabra
git apply /path/to/patches/gl-proc-lookup-via-dlsym.patch
make BIN=sos-aarch64
strip -o shmupacabra.aarch64 sos/sos-aarch64
patch -p0 sos/config.lua < /path/to/patches/config-no-native-joystick.patch
```

Built against the normal system SDL 1.2, SDL_mixer 1.2 and SDL_image 1.2. At runtime the port uses the `sdl12-compat` shim (`libSDL-1.2.so.0`) over the device's SDL2 and gl4es for OpenGL.
