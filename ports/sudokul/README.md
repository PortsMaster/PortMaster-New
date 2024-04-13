## Notes

Thanks to [Mode8fx](https://github.com/Mode8fx/SuDokuL) for this great version of Sudoku and [joyrider3774](https://github.com/joyrider3774) for helping to troubleshoot issues.

**Features**

* Play Sudoku puzzles of Easy, Normal, Hard, or Very Hard difficulty. These puzzles are generated on-demand using a built-in algorithm; however, to eliminate computation time on weaker devices, Hard and Very Hard puzzles have been pre-generated.
* Mouse, keyboard, controller, and touch screen support
* Supports any resolution from 240x240 and above (must be 1:1 aspect ratio or wider)
* Save data support
* Eight different scrolling backgrounds with customizable settings (size, scroll speed, angle)
* Calm and invigorating MOD music to suit your mood
* Shaded text for a nice 3D look
* Runs on a potato
* Optional auto-fill and erase-mistake cheats in case you get stuck

Cheats

On a selected cell press X or Y 8x or press B then X/Y 4x

## Controls

| Button | Action |
|--|--| 
|Dpad/Joysticks|Move|
|A|Enter/Confirm|
|B|Back|
|X/Y|Toggle mini-grid|
|L1/L2|Previous song|
|R1/R2|Next song|
|Start|Pause|
|Select|Exit to menu while paused|


## Compile

```shell
git clone https://github.com/christopher-roelofs/SuDokuL.git
cd SuDokuLVS2019
mkdir build_linux && cd build_linux
cmake ../
make -j8
```
