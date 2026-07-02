## Notes
This is clone of the 1979 game space invaders part II implemented in C++ with a single file custom engine using SDL2 and Opengl 2.1. SDL2 is used for window management and to create the Opengl context whereas Opengl is used for all rendering.

The engine uses a somewhat novel approach to rendering (because I thought it would be fun, even if not fast on modern hardware) in that all fonts and sprites are rendered as pure bitmap data using glBitmap and color is added by simply setting the draw color in the context. As a consequence all sprite assets and font glyphs are just arrays of 1s and 0s saved to files.

Thanks to [Ian Murfin](https://github.com/ianmurfinxyz/space_invaders_part_ii) for creating this game.


## Controls

| Button | Action |
|--|--|
| Dpad | Move |
| Left Analog | Move|
| Right Analog | Move |
| A | Fire |
| B | Fire |
| L1 | Score |

## Compiling

Code refactored to work on aarch64  [https://github.com/monkeyx-net/space_invaders_part_ii](https://github.com/monkeyx-net/space_invaders_part_ii)
