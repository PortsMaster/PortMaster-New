## Notes

Thanks to [Geisha Studios](https://www.geishastudios.com/games/monochromeworlds/) (code by Jordi Fita) for Monochrome Worlds, and to Tatsuya Koyama for the original Flash game Monochro Observer, its graphics and music.

Stage progress (`settings.ini`) is saved in the port's `conf/` folder after every cleared stage.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick Left/Right | Move the selected character |
| D-Pad / Left Stick Up/Down | Menu navigation |
| A | Move the block in front of the character to the other world, menu select |
| B | Undo the last fall or block move |
| Y | Switch character |
| X | Show / hide the stage tip |
| L1 | Restart the stage |
| Start / Select | Pause menu, back |

## Compile

```bash
wget http://www.geishastudios.com/download/monochromeworlds-1.0.2.tar.bz2
tar xjf monochromeworlds-1.0.2.tar.bz2
cd monochromeworlds-1.0.2
patch -p1 < /path/to/patches/monochromeworlds-portmaster.patch
mkdir build && cd build
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_BINARY_RELOCATION=OFF -DCMAKE_C_FLAGS="-DPORTMASTER" -DCMAKE_CXX_FLAGS="-DPORTMASTER"
make -j$(nproc)
strip -o monochromeworlds.aarch64 src/monochromeworlds
```

Builds against the system SDL 1.2 and SDL_mixer 1.2 dev packages. The port ships sdl12-compat as `libSDL-1.2.so.0` with SDL_mixer 1.2, libogg and libvorbis.

The patch:
- replaces the removed Boost.Signals with the header-only Boost.Signals2
- lets the CMake version script build without a Mercurial checkout
- loads data from the working directory
- runs fullscreen with the mouse cursor hidden
- names the gamepad buttons in the title screen and stage tips instead of keyboard keys
- turns off the game's raw joystick handling so gptokeyb2 drives all input
- saves progress on every change, not only on a clean exit

Game data (`gamedata.tar.gz`): `data/gfx/*.tga`, `data/music/*.ogg`, `data/sfx/*.ogg`, `data/stages/*.mws`.
