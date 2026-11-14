## Notes

Lix is free and open source (public domain via CC0; the DejaVu font and some
music tracks have their own licenses, see [`doc/copying.txt`](https://github.com/SimonN/LixD/blob/master/doc/copying.txt)).
Thanks to Simon Naarmann and the Lix contributors: https://www.lixgame.com

Built with Allegro 5 using its SDL2 + OpenGL ES 2 backend.

## Launcher

A settings launcher opens before the game: mouse cursor size (Normal, 2x, 3x, 4x), mouse speed (Slow, Normal, Fast, Faster), hardware (default) or software fullscreen, and the controls image. Choose Play, or wait for it to start the game.

## Controls

| Button | Action |
|--|--|
| A | Click |
| B | R-click |
| X | Pause |
| Y | Fast |
| L1 | Rewind 1s |
| R1 | Skip 10s |
| L2 | Restart |
| R2 | Turbo |
| Start | Enter |
| Select | Back |
| Left stick | Mouse |
| D-pad | Arrow keys |
| Right stick | Arrow keys |

A (left click) assigns skills and presses buttons. Y fast-forwards. Hold B (right click) to scroll the level; B also inverts skill priority. X is also okay in menus. The D-pad forces lix left/right and moves through menus. All keys can be remapped in Lix's options menu.

## Compile

Built with [PortMaster-Build-Templates](https://github.com/monkeyx-net/PortMaster-Build-Templates) from [SimonN/LixD](https://github.com/SimonN/LixD). The recipe folder [recipes/ports/lix](https://github.com/monkeyx-net/PortMaster-Build-Templates/tree/main/recipes/ports/lix) holds `build.sh`, which reads `recipe.json` and applies the patches and files in that folder before running the build command:

```sh
dub build -f -b release --compiler=ldc2
```
