# The Wratch's Den
Turn-based dungeon-keeper roguelite by PUNKCAKE Delicieux. Design rooms, summon and upgrade minions, and defend your den from heroes.

## Installation

You'll need a legitimate Mac build of the game.

### itch.io

1. Buy The Wratch's Den on [itch.io](https://punkcake.itch.io/wratchs-den) from PUNKCAKE Delicieux.
2. From your itch library (or the itch desktop app), download the **macOS** build. You'll get a `.zip` containing `the_wratchs_den.app`. You can also use the free demo.
3. Unzip and drop `the_wratchs_den.app` (or `the_wratchs_den_demo.app`) into the port's `gamedata/` directory (see layout below).

### Steam

1. Buy The Wratch's Den on [Steam](https://store.steampowered.com/app/2881260/The_Wratchs_Den/) (if available on your region).
2. Download the Mac depot via the Steam console using following command: `download_depot 1820470 1820472 4555248748855407692`.
3. Place `the_wratchs_den.app` in the port's `gamedata/` directory:
```
wratchsden/
└── gamedata/
    └── the_wratchs_den.app/
        └── Contents/
            ├── MacOS/
            │   ├── the_wratchs_den          ← game binary
            │   ├── data.sgr                 ← game data archive
            │   ├── libSDL2-2.0.0.dylib
            │   ├── libfreetype.6.dylib
            │   └── libsteam_api.dylib
            └── Resources/
```

## Controls
The Wratch's Den has native SDL2 gamepad support — just plug in and play.

| Pad                | Action                     |
|--------------------|----------------------------|
| D-pad / Left stick | Move / navigate            |
| A                  | Use ability / confirm      |
| Select (Back/View) | Back / pause menu          |
| L/R triggers       | Switch between minions     |

## Technical Details

This port uses [Machismo](https://github.com/bmdhacks/machismo) to load the arm64 Mach-O binary on aarch64 Linux. Key techniques:
- LuaJIT trampolined from statically-linked macOS build to native Linux LuaJIT
- Apple-ABI libc++ with Darwin pthread_mutex_t padding for correct struct layouts
- gl4es translates OpenGL calls to GLES 2.0 for Mali handhelds
- SDL2 and FreeType mapped directly to native Linux libraries (pure C APIs)
- Steam API stubbed out (return 0/NULL)
- `libsugar_patches.so` — NEON palette→RGBA `_flip` override, mmap'd PCM cache for `_load_ogg`, lazy vsync enable

## License
The Machismo loader is licensed under GPL v3.0. Game assets are proprietary and must be purchased from itch.io or Steam.
