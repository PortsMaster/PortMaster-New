# Rusty Seas

## Port Information

**Game:** Rusty Seas
**Developer:** AyGee
**Porter:** raidon
**Source:** https://aygee.itch.io/rusty-seas (also available on Steam)

---

## Description

A retro-style game reminiscent of the 16-bit console era with a splash of 90s computer gaming. You play as Mirig, a diner waitress who takes an offer to collect high-tech salvage from the beaches of Northshore, competing with a colourful cast of adversaries. Features action gameplay, visual novel story segments, and isometric pixel art.

---

## Installation

This port requires a purchased copy of **Rusty Seas**.

1. Purchase the game from [itch.io](https://aygee.itch.io/rusty-seas) or Steam.
2. Extract the game zip and locate `data.win`.
3. Copy `data.win` into `rustyseas/assets/`.
4. Launch the game. Patching runs automatically on the first start (requires ~200MB free space and a few seconds).

---

## Controls

| Controller        | Action          |
|-------------------|-----------------|
| Left Analog / D-Pad | Move          |
| A                 | Confirm / Action |
| B                 | Cancel / Back   |
| Start             | Pause / Menu    |

*Controls are handled natively by the game via SDL gamepad input.*

---

## Technical Notes

This port runs the original GMS2 Android runner (`libyoyo.so`) via [gmloader-next](https://github.com/JeodC/gmloader-next). The following patches are applied to `data.win` on first run:

- BGND tileset field reordering for the ARM64 runner
- BGND separation value correction for correct tile UV mapping
- Android-specific room and string data

A binary patch to `libyoyo.so` fixes the GMS2TileIds array pointer offset (`add x9, x20, #0x40` → `#0x48`), correcting tile rendering for all ground and wall tilesets.

---

## Licenses

- **gmloader-next**: GPL-2.0 — see `license/gmloader-next.LICENSE`
- **Android Bionic**: BSD — see `license/bionic.LICENSE`
- **Rusty Seas**: © AyGee — all rights reserved. Game assets are not included.

---

## Credits

A huge thank you to **AyGee** for creating Rusty Seas — a charming and well-crafted indie game well worth your time and money. Please support the developer by purchasing the game.

Thanks to the **PortMaster** and **gmloader-next** communities for the tools and infrastructure that make ports like this possible.
