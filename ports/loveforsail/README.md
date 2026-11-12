## Notes

Thanks to The Mighty Troglodytes and Vivendi Games Mobile for Leisure Suit Larry: Love for Sail!, a cheeky 2007 mobile adventure that puts Larry Laffer on a cruise ship full of puzzles and minigames.

The game is not included. Copy your own J2ME `.jar` of the game into `ports/loveforsail`. Any phone version works (the 128x128 Nokia version, 176x208, 176x220, 240x320, ...) and the file name doesn't matter. 
The small Nokia version looks simpler and has ringtone melodies instead of full MIDI music: it's a different build of the game, not a port problem. 

Button prompts in the 240x320 version and both 128x128 Nokia versions are rewritten to the gamepad buttons below.

Music plays through the TimGM6mb General MIDI SoundFont (GPL-2, included). In the later versions the sound menu starts on OFF: press Up for ON.

Saves go to `ports/loveforsail/savedata/<jar name>/`.

## Controls

The gamepad acts as the phone keypad:

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move (keypad 2/4/6/8) |
| A | Select / action (keypad 5) |
| B | Keypad 0 |
| X | Inventory (keypad *) |
| Y | Help (keypad #) |
| L1 | Keypad 1 |
| R1 | Keypad 3 |
| L2 | Keypad 7 |
| R2 | Keypad 9 |
| Start | Pause menu (right soft key) |
| Select | Left soft key |

## Compile

Needs a JDK (11 or newer), gcc and the SDL2 development package.

```bash
git clone https://github.com/Cebion/loveforsail.git
cd loveforsail
./build.sh
```

This produces `build/lovesail-portmaster.jar` (plain Java, `--release 11`) and `build/libsdl2bridge.so` (aarch64).
