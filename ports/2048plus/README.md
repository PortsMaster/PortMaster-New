A feature-packed implementation of the classic puzzle game 2048, built using the LÖVE framework.

This project is inspired by and references the popular open-source [2048 Android](https://github.com/tpcstld/2048) game by tpcstld, which itself is based on the original web game by Gabriele Cirulli. While taking visual and design references from the Android version, this codebase was written from the ground up in Lua for the LÖVE engine. In addition to the classic gameplay, I have introduced numerous new features, including multiple game modes, an achievement system, and a wide variety of themes to enhance the overall experience.

This project was originally developed for muOS and subsequently ported to PortMaster. The original repository is available at https://github.com/saitamasahil/2048-muos.

## Features

- **Game Selection Mode**: A beautifully animated carousel menu screen for seamlessly selecting between Classic, Plus, and Arcade modes.
- **Classic & Plus Modes**: Enjoy the original 2048 puzzle experience, or switch to the new Plus Mode which introduces strategic powerups!
- **Plus Mode Powerups**: In Plus Mode, earn Bomb, Swap, and Undo powerups by reaching new tile milestones (128, 256, 512, etc.). Use them to destroy unwanted tiles, swap adjacent tiles, or revert mistakes.
- **Arcade Modes**: Choose from 4 unique game modes — each with its own rules, challenges, and exclusive unlockable themes:
  - **Time Attack**: Race against a 60-second countdown clock. Merge larger tiles (32+) to earn time extensions.
  - **Huge Mode (5x5)**: A spacious 5×5 grid for a more relaxed play style.
  - **No Mercy**: Hardcore mode — no undos, no powerups, two tiles spawn every move.
  - **Goose Mode**: A chaotic mode where a silly Goose tile waddles around the board, blocking random cells.
- **Procedural Sound Effects**: Rich chiptune audio effects generated dynamically with zero file size overhead.
- **Unified Settings Menu**: Grouped text size toggles, sound, and a suite of preference parameters under a clean, unified Settings sub-menu:
  - **Sound**: Toggle audio effects on/off.
  - **Gameplay Animation Speed**: Choose between Slow (0.24s), Normal (0.12s), Fast (0.06s), or Instant (0s).
  - **Screen Transitions**: Toggle menu transition animations on/off.
  - **Undo Limit**: Adjust undo limitations (1-Move, Unlimited, or Disabled) to customize your strategic difficulty.
  - **Time Attack Max Limit**: Adjust the Time Attack starting and maximum threshold ceiling (30s, 60s, 90s).
  - **Vibration**: Toggle haptic rumble feedback on supported devices.
  - **CRT Shader**: Toggle retro curved screen curvature, scanline, and phosphor mask post-processing filters.
- **Advanced Undo History Stack**: Refactored the gameplay engine to support rolling backward history logs all the way up to 100 consecutive turns.
- **Achievements & Unlockable Themes**: Track your progress by unlocking 23 unique achievements, ranging from reaching high tiles to mastering arcade modes. Completing achievements rewards you with beautifully crafted custom themes — 25 themes total!
- **Statistics Dashboard**: Tracks real-time statistics including highest score, highest tile reached, games started per mode, total play time, moves, merges, undos, and power-up usage persistently.
- **Dynamic Animated Backgrounds**: Premium themes (Aurora, Nebula, Inferno, Honk, Matrix, Glitch) feature layered, animated background effects like aurora curtains, twinkling starfields, rising embers, water ripples, falling green digital rain, and cyberpunk glitch effects.
- **Themes**: Instantly toggle between unlocked themes with a beautifully animated reveal. Your theme preference is saved automatically!
- **Auto-Save & Resume**: Your progress, board state, and score are saved automatically after every move. Close the game anytime and pick up right where you left off.
- **Interactive Pause Menu**: A built-in pause overlay makes it easy to safely quit the app or restart a new game cleanly.
- **Accurate Aesthetics**: Uses the exact color palette, typography, and smooth slide/merge animations from the beloved Android version, complete with an elegant glowing win animation.

*Note: Perhaps a well-known secret sequence of buttons might reveal something special...?*

## Controls

| Button | Action |
|--|--| 
|D-Pad / Left Stick|Swipe tiles (Move Up, Down, Left, or Right)|
|A|Confirm / Continue / Confirm Powerup Target|
|B|Undo previous move|
|Y|Cycle through unlocked themes|
|L1|Activate Swap Powerup (Plus Mode)|
|R1|Activate Bomb Powerup (Plus Mode)|
|Start / Select|Open Pause Menu (Restart / Quit / Resume)|
|Menu + Start|Exit the game safely (force quit)|

*Note: Your progress is automatically saved after every move. You can safely close the game and pick up exactly where you left off.*

## Credits & Acknowledgements

- Original Web Game: [Gabriele Cirulli](https://github.com/gabrielecirulli/2048)
- Android Port Reference: [tpcstld - 2048](https://github.com/tpcstld/2048)
- Built using the [LÖVE Framework](https://love2d.org/).
