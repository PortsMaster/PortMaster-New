This project is inspired by and references the popular open-source [2048 Android](https://github.com/tpcstld/2048) game by tpcstld, which itself is based on the original web game by Gabriele Cirulli. While taking visual and design references from the Android version, this codebase was written from the ground up in Lua for the LÖVE engine. In addition to the classic gameplay, I have introduced numerous new features, including multiple game modes, an achievement system, and a wide variety of themes to enhance the overall experience.

This project was originally developed for muOS and subsequently ported to PortMaster. The original repository is available at https://github.com/saitamasahil/2048-muos.

## Features

- **Game Modes**: Classic, Plus Mode (with Bomb, Swap, and Undo powerups), and 4 Arcade Modes (Time Attack, 5x5 Huge, No Mercy, Goose).
- **Achievements & Themes**: 28 unlockable achievements and 30 custom themes, with select themes featuring dynamic animated backgrounds.
- **Audio & Visuals**: Embedded lo-fi BGM playlist with track info popups, procedural SFX, CRT shader, and smooth handheld-optimized animations.
- **Stats & Settings**: Comprehensive player statistics tracking, 100-move undo stack, and customizable gameplay speed and limits.
- **Quality of Life**: Auto-save & resume after every move, interactive pause menu, instant theme switching.

*Note: Perhaps a well-known secret sequence of buttons might reveal something special...?*

## Controls

| Button | Action |
|--|--| 
|D-Pad / Left Stick|Swipe tiles (Move Up, Down, Left, or Right)|
|A|Confirm / Continue / Confirm Powerup Target|
|B|Undo previous move|
|Y|Cycle through unlocked themes|
|L1|Activate Swap Powerup (Plus Mode) / Skip BGM Track (Pause State)|
|R1|Activate Bomb Powerup (Plus Mode) / Skip BGM Track (Pause State)|
|Start / Select|Open Pause Menu (Restart / Quit / Resume)|
|Menu + Start|Exit the game safely (force quit)|

*Note: Your progress is automatically saved after every move. You can safely close the game and pick up exactly where you left off.*

## Credits & Acknowledgements

- Original Concept By: [Gabriele Cirulli](https://github.com/gabrielecirulli/2048)
- Android Port Reference: [tpcstld - 2048](https://github.com/tpcstld/2048)
- Built using the [LÖVE Framework](https://love2d.org/)
- Background Music tracks provided via [Chosic](https://www.chosic.com/) by authors: AudioCoffee, Ghostrifter, Purrple Cat, Roa, Sakura Girl, and Tokyo Music Walker.