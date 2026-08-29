## Notes

Thanks to [Stephen Sweeney / Parallel Realities](https://github.com/stephenjsweeney/waterCloset) for creating Water Closet, a clone-based puzzle-platformer that took 1st place for Overall Fun Factor and Completeness of Experience at itch.io's Linux Game Jam 2019.

## Controls

| Button | Action |
|--|--|
| D-Pad Left/Right | Move |
| D-Pad Up/Down | Menu navigation |
| B | Jump |
| A | Enter |
| X | Interact |
| Y | Create clone and reset |
| Start | Reset stage |
| Select | Back / Menu |

## Compile

git clone https://github.com/stephenjsweeney/waterCloset.git
cd waterCloset
git apply /path/to/watercloset-portmaster.patch
cp /path/to/ubuntu.condensed.ttf fonts/
rm fonts/EnterCommand.ttf
make

`watercloset-portmaster.patch` (top level of this port) carries the source changes made for
this port: disabling the game's raw joystick input in favour of gptokeyb2, fullscreen sized from
the real desktop resolution instead of a hardcoded 1280x720, and the font path swap.