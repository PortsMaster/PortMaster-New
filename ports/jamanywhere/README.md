# Jam Anywhere

A portable, lightweight 4-key (4K) rhythm game built natively with the LÖVE framework. Enjoy your favorite tracks on the go with customizable controls, multiple resolutions, and adjustable scroll speeds!

## Features
* **Custom Mapping:** Play your own generated tracks or import existing osu!mania 4K maps.
* **Highly Customizable:** Change scroll speeds, note sizes, play styles (Vertical Lanes or 4-Way Center), and map your own gamepad/keyboard inputs.
* **Scoring System:** Track your accuracy (Perfect, Good, Bad, Miss), max combos, and beat your local high scores.

## How to Add Songs
You can easily add your own music to the game using two methods:

### Method 1: Web Studio Generator
1. Go to the official generator: `mrozkar.github.io/JamAnywhere/`
2. Upload any `.ogg` audio file to automatically generate a playable map.
3. Download the provided `.zip` file and extract it.

### Method 2: osu!mania Custom Maps
1. Download any **4K (4-key) map** from `osu.ppy.sh`.
2. Rename the downloaded `.osz` archive to `.zip` and extract it. 
3. *Note: Most archives contain multiple `.osu` files with different difficulty levels. Just keep them all in the extracted folder!*

### File Placement
Place your extracted song folders directly into your console's SD card directory:
`/ports/jamanywhere/songs/`

*(Example: `/ports/jamanywhere/songs/My Awesome Song/`)*

## Default Controls
* **D-Pad / ABXY:** Hit notes (fully remappable in Settings)
* **Start / Select:** Pause Game
* **Y / Select (in Menu):** Open Settings
* **X (in Menu):** Open Setup Instructions