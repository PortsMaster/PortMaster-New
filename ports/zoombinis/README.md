## Notes

Thanks to [slippedandmissed](https://github.com/slippedandmissed/zbtools) for decompiling Logical Journey of the Zoombinis back into C++, a children's logic game whose puzzles stay hard enough to stump adults.

You need a Windows CD: the original (version 1.0), the Deluxe (version 1.1), the 2001 rerelease (Zoombinis: Logical Journey, version 2.0) the 2002 French edition (L'Odyssée des Zoombinis) and the English/French/German CD (Die Abenteuer der Zoombinis) all install. 
The 2001 rerelease has no MIDI music, so the game plays without music from it.
 With a French or German CD the game is in that language (voices, pictures and texts; only the credits stay English).

 A CD with several languages installs English unless `gamedata` also holds a `language.txt` naming one, e.g. `german` or `french`. 
 Copy it into `ports/zoombinis/gamedata` as an `.iso`, a `.bin`/`.cue` pair, or all the files on the CD. On first launch the port installs the game from it into `ports/zoombinis/game`, after which the files in `gamedata` can be deleted. 
 To install from another CD (or in another language) later, delete `ports/zoombinis/game` and launch again; saved games are kept. The Broderbund logo movie at startup is skipped. Saved games are kept in `ports/zoombinis/conf`.

Music plays with the [GeneralUser GS](https://github.com/mrbumpy409/GeneralUser-GS) SoundFont by S. Christian Collins.

## Controls

| Button | Action |
|--|--|
| Left Stick | Move the pointer |
| A | Click |
| B | Right click |
| X | Slow pointer (hold) |
| Y / Start | Enter (OK in dialogs, pick a key on the on-screen keyboard) |
| Select | Escape (cancel a dialog) |
| D-Pad | Move the pointer (on the on-screen keyboard: move between keys) |
| L1 | Switch letters/numbers on the on-screen keyboard |
| R1 | Backspace |
| L2 | Open/close the on-screen keyboard (saved-game names) |

## Compile

The port is built from zbtools with `patches/zbtools-portmaster.patch`, which adds a fullscreen build option, fixes the saved-game name buffers (from zbtools PR #36), keeps a current directory per drive (saved games went to C:\ and vanished on restart) and uses a French or German CD's own texts (TEXTSTR.MHK). The game needs clang, CMake 3.24 or later, Ninja and the SDL2 development package.

```bash
git clone https://github.com/slippedandmissed/zbtools.git
cd zbtools
git checkout e3c55c74
git apply /path/to/zoombinis/patches/zbtools-portmaster.patch
cmake -S port -B build/portmaster -G Ninja \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release \
  -DZB_DEBUG=OFF -DZB_FULLSCREEN=ON -DZB_SYSTEM_SDL=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++"
cmake --build build/portmaster
strip -o zoombinis.aarch64 build/portmaster/zoombinis
```

The disc installer:

```bash
clang++ -std=c++17 -O2 -static-libstdc++ -o zbinstall.aarch64 /path/to/zoombinis/patches/zbinstall.cpp -lz
strip zbinstall.aarch64
```
