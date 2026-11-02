## Notes

Requires **Cuphead for macOS, version 1.3.4, from GOG or Steam**, with or without The Delicious Last
Course. The Windows version does not work (its shaders are Direct3D only). On Steam without a Mac,
the macOS version downloads from Steam's console (`steam://open/console`): `download_depot 268910 268912`, and the DLC with `download_depot 268910 1117851`; put both downloaded folders (`depot_268912`, `depot_1117851`) into `gamedata/`.

Copy GOG's macOS installers (`.pkg`) or the installed `Cuphead.app` (GOG or Steam) into
`ports/cuphead/gamedata/` and start Cuphead. The first launch builds the game on the handheld (one
to a few hours, once; about 10 GB free on the card during the setup, about 2.5 GB afterwards): it
converts the game's shaders, textures and audio for the handheld and removes the copied game when it
is done. No Wi-Fi and no PortMaster runtime are needed: Unity's Android player comes from the
port's donors (`donor/`: small games of the port's own, built with Unity), and the setup's tools are
a small native program (`setup/pmu`). If the setup is interrupted (a flat battery, a restart),
start Cuphead again: it continues where it stopped (log: `ports/cuphead/patchlog.txt`).

The game runs on Unity's own Android player, loaded natively on the handheld's Linux by the port's
runtime (no Android, no emulation). On a firmware without 32-bit (armhf) support the setup builds a
64-bit version instead (about 12 GB free during the setup), which runs the game's code on Unity's
Mono for 64-bit ARM. Steam's achievements and cloud saves are not available.

**The DLC later:** put GOG's DLC installer (`.pkg`), or a `Cuphead.app` with the DLC (Steam: the
DLC depot's files), into `ports/cuphead/gamedata/` and start Cuphead: it adds the DLC to the built
game by itself (about half an hour, once; the game is not built again).

The setup asks for the texture quality, the resolution and, where the screen is not 16:9, the
picture shape. Resolution: the device's (default), or 5/6, 3/4 or 1/2 of it, scaled up to the full
screen (softer but faster); `ports/cuphead/resolution.txt` changes it later (`device`, or a share
such as `0.75`). Shape: on 3:2 and 16:10 screens the picture fills the screen with the sides
cropped a little (default) or keeps the game's 16:9 bars; on 4:3 and square screens it keeps the bars
(default), shows a 4:3 picture (smaller bars, the sides cropped a little) or fills the screen with
more of the sides cropped (`crop`; `1:1` on square screens; the menus and HUD always fit);
`ports/cuphead/aspect.txt` changes it later (`fill`, `16:9`, `crop`, or a shape such as `4:3`).

Saves: `ports/cuphead/data/` (64-bit build: `ports/cuphead/arm64/data/`).

Source and build instructions: https://github.com/wild1walker/portmaster-cuphead

Thanks to StudioMDHR for Cuphead, and to the PortMaster team.

## Controls

The buttons work by position, as on an Xbox pad; Options > Controls changes them.

| Button (Nintendo layout) | Action |
|--|--|
| B (bottom) | Jump / Confirm |
| Y (left) | Shoot |
| A (right) | EX shot / Back |
| X (top) | Dash |
| L1 | Switch weapon |
| R1 | Lock |
| Start | Pause |
| Select + Start | Quit |
