## Notes

Thanks to [mkxp-z](https://github.com/mkxp-z/mkxp-z) for the modern, cross-platform reimplementation of the RGSS runtime that makes running this RPG Maker XP game on a handheld possible.

This port requires the game's own files, which are not included. Download Last Scenario from https://site.scfworks.com/?page_id=8 and extract its contents (`Game.rgssad`, `Audio/`, etc.) directly into the port's game folder before launching.


## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Confirm / Use |
| B | Cancel / Menu |
| X | Show map / challenge NPC to Hex |
| L1 | Previous page (in some menus) |
| R1 | Next page (in some menus) |
| Start+Select | Quit |


## Gameplay Notes

**Stats**: Strength (physical attack), Magic (magical attack), Vitality (physical defense),
Resistance (magical defense), Speed (turn order), Skill (critical hit rate), Dexterity (evasion),
Luck (overall battle performance).

**Spellcards** provide each character's special abilities and are equipped in the Spellcard menu;
three slots start locked and are unlocked with items found during the game. Each Spellcard has a
regular skill (usable anytime with enough MP) and a more powerful Crisis skill, usable once that
character's Crisis bar fills from taking damage in battle (resets on use or on death). Some
healing Spellcards can also be used from the menu outside of battle.

There's also a card minigame, **Hex**, playable against certain NPCs on a hexagonal grid.

## Compile

The engine is [mkxp-z](https://github.com/mkxp-z/mkxp-z), built natively for aarch64 with the GLES2 graphics backend and dynamically linked against the system's own SDL2.

1. **Ruby 3.1.3 (mkxp-z's fork) and all bundled C/C++ dependencies**

   ```
   cd mkxp-z/linux
   make -j$(nproc)
   ```

   This clones and builds physfs, OpenAL Soft (SDL2 + ALSA backends, no PulseAudio/OSS), FluidSynth
   (OpenMP/ALSA/PulseAudio disabled), theora/vorbis/ogg, pixman, libpng, uchardet, iconv, and the
   SDL2_image/SDL2_ttf/SDL2_sound forks, followed by Ruby itself. A host "baseruby" (any system Ruby)
   must be installed first — Ruby's own build needs one to bootstrap itself.

2. **The engine binary**

   ```
   cd mkxp-z/linux && source vars.sh
   cd ..
   meson setup build -Dgfx_backend=gles -Denable-https=false --bindir=. --prefix=$PWD/build/local
   cd build
   ninja
   ninja install
   ```

`src/meson.build`'s `SDL2` dependency is patched to `static: false` regardless of the
`static_executable` option, so it always links against the system SDL2 rather than a bundled one.

## Patches 

The game's own v1.22 scripts have two bugs that surface under this engine's Ruby 3.1 but not the
original RGSS runtime: a syntax error in `Game_Battler 1#pdamage` (a stray argument on a
zero-argument method call), and a crash opening the Spellcard menu (`Game_System`'s
`spellcard_menu_index` is declared but never given a default value, so it's `nil` the first time
it's read). The port ships a corrected `Data/Scripts.rxdata` in `patches/`, loaded via mkxp-z's
own `"patches"` mechanism (`mkxp.json`) with priority over the same file inside `Game.rgssad` —
your `Game.rgssad` itself is never modified. The Spellcard fix is patched at both the point where
`spellcard_menu_index` gets its default value *and* the point where it's read, so it's fixed for
new games and pre-existing saves alike (an existing save's `$game_system` is restored via
`Marshal.load`, which bypasses the constructor entirely and never picks up a fix made only there).