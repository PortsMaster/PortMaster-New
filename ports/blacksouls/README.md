## Notes

Thanks to [Eeny, meeny, miny, moe?](https://store.steampowered.com/app/3755860/BLACK_SOULS/) for creating BLACK SOULS, a bleak retelling of Alice in Wonderland and the Brothers Grimm whose fairy tale characters hold real, tracked relationships with you that quietly reshape how the story ends.

**Playable.** Boots, plays, fights, saves and loads on an RG40XX H. Confirmed on KNULLI, on ROCKNIX with the Panfrost driver, and on muOS, dArkOS and AmberELEC by testers, the last two on an R36S, which is a different SoC entirely.

The game is paid, so only the engine ships here: mkxp-z, an open reimplementation of the RGSS runtime that RPG Maker VX Ace games run on. You supply the game's own files. The game renders at 640x480, so it is pixel for pixel on a 640x480 panel with no scaling.

## Contents

- [Installing](#installing)
  - [1. Install the port](#1-install-the-port)
  - [2. Complete your copy of the game](#2-complete-your-copy-of-the-game)
  - [3. Copy the game across](#3-copy-the-game-across)
  - [4. Play](#4-play)
- [The patches folder](#the-patches-folder)
- [Controls](#controls)
- [Compile](#compile)

## Installing

You need: your own copy of BLACK SOULS, a PC to prepare it on, and a handheld running PortMaster. Budget twenty minutes, nearly all of it copying files.

### 1. Install the port

Drop `blacksouls.zip` into PortMaster's `autoinstall` folder and run PortMaster, which unpacks it and clears the folder.

Over ssh it is one command instead:

```
harbourmaster install <url of the zip>
```

Either way you end up with `BLACK SOULS.sh` and a `blacksouls/` folder in `ports/`. The folder holds the engine and waits for the game.

### 2. Complete your copy of the game

Skip this step if you bought the game on DLsite, which ships it complete.

The Steam release is cut down: its `Game.rgss3a` declares 21 maps where the full release has 150. The publisher gives away an official patch that restores the rest, and it has to be applied to the Steam copy on your PC before the files are worth copying anywhere. Without it the port faithfully runs the reduced build, and nothing about that looks broken, which is the confusing part.

Note where the patch puts what it restores. If it updates `Game.rgss3a` itself, you are done here. If it instead leaves loose `Data/`, `Graphics/` or `Audio/` folders beside the archive, those belong in `patches/` rather than next to the engine, for the reason in [The patches folder](#the-patches-folder).

### 3. Copy the game across

From your game folder, copy into `ports/blacksouls/`, alongside the engine:

```
Audio/
Graphics/
Fonts/
Game.ini
Game.rgss3a
```

Leave behind `Game.exe`, `System/` and `installscript.vdf`. They are Windows only and the engine replaces them.

Some copies ship unpacked, with a `Data/` folder in place of `Game.rgss3a`. Copy that folder instead; the port accepts either, and the Korean release is one of them.

Copy the loose `Graphics/` folder even though nine of its files also exist inside `Game.rgss3a` and the archive wins for those nine. The rest of the folder is used, and keeping it whole means your port folder matches an untouched installation.

### 4. Play

Launch BLACK SOULS from the Ports menu. First run unpacks the Ruby standard library, so it takes a few seconds longer than the ones after it.

Saves are written next to the engine as `Save01.rvdata2` and upward. They survive reinstalling the port, as long as you keep that folder.

## The patches folder

`blacksouls/patches/` is mounted above `Game.rgss3a`. A loose folder next to the engine is not: where the same file exists in both, the archive wins. So anything meant to replace the game's own content goes in `patches/`, and the folder is empty by default, which leaves the game exactly as shipped.

Two things usually go in it: the publisher's free patch for the reduced Steam build, and a translation that replaces only part of the game. Both arrive as a set of RPG Maker folders. Put their content folders directly inside `patches/`:

```
patches/
├── Data/
├── Graphics/
├── Audio/     (only if it ships one)
└── Fonts/     (only if it ships one)
```

Some archives wrap everything in a single top level folder, in which case copy that folder's contents rather than the folder itself. Leave out anything Windows specific: `Game.exe`, `System/`, `*.dll`, `*.vdf`, `Game.rvproj2` and its own `Game.ini` are all unused here. Delete the folders again to go back.

A translation that ships the whole game instead, with its own `Data`, `Graphics` and `Audio`, is not an overlay. Put it in the port folder as the game and leave `patches/` empty. Keeping both costs twice the space for nothing.

A save can stop loading when you change this folder. Saves sit next to the engine and are never touched by what you put here, but a save stores objects of the classes the game's scripts define, so content that adds such a class makes its saves unreadable once it is removed, and the other way round. Whether it bites depends on what you installed, and neither of the translations used here did: the same save loaded with and without them. The game stays quiet when it does bite: `DataManager.load_game` swallows the error, so the load screen buzzes and sits there as though the button did nothing. Put the folder back the way it was when the save was made and it loads. This is how the game behaves on Windows too.

Content dropped here commonly bundles RGSS scripts that call `Win32API` while loading, such as Steamworks achievements or the Fullscreen++ plugin. There is no Windows DLL to load on this platform, so those calls would kill the game before the title screen; `win32stub.rb` makes them inert. Fullscreen is handled by `mkxp.json` anyway, so losing that plugin changes nothing.

Played on an RG40XX H with two different Russian translations and with `patches/` left empty, all three fine.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move, menu navigation |
| B | Confirm |
| A | Cancel, open menu |
| X | Dash |
| Start | Open menu |

Face button positions vary between handhelds, so Confirm and Cancel may sit the other way round on your device. The port does not remap anything: mkxp-z reads the pad through `SDL_GameController`, and the mapping comes from the firmware's own controller database.

## Compile

The shipped `mkxp-z.aarch64` is the aarch64 build from the PortMaster Last Scenario port. To build the engine from source instead:

1. Build the bundled dependencies and Ruby.

```
git clone --recursive https://github.com/mkxp-z/mkxp-z.git
cd mkxp-z/linux
make -j$(nproc)
source vars.sh
```

2. Link against the system SDL2 rather than mkxp-z's own static fork. In `src/meson.build` force `dependency('SDL2', static: false)`, and in `linux/Makefile` drop `sdl2` from the `sdl2image`, `sdlsound`, `sdl2ttf` and `deps-core` prerequisite lists. Verify with `readelf -d build/mkxp-z.aarch64 | grep NEEDED`, which should list `libSDL2-2.0.so.0`.

3. Build the engine itself with the GLES backend.

```
cd ..
meson setup build -Dgfx_backend=gles -Denable-https=false --bindir=. --prefix=$PWD/build/local
cd build
ninja
ninja install
```

The Ruby standard library shipped as `stdlib.tar.gz` comes from `linux/build-<arch>/lib/ruby/3.1.0`.
