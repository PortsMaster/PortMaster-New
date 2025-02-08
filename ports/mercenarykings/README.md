## Notes

Thanks to:
* [Trubute Games](https://store.steampowered.com/developer/tributegames), the developers of Mercenary Kings.
* JanTrueno for porting and patching Mercenary Kings.
* JohnnyOnFlame for helping me set up the patches. (And much more)
* Garik816 for the initial packaging.

## Details and Information  

| Detail             | Info                 |
|-------------------|----------------------|
| Ready to Run      | No                  |
| Engine/Framework  | FNA (C#)          |
| Architectures     | Runtime              |
| Aspect Ratio      | 16:9   		|
| Rumble Support    | Untested             |
| Tested Versions   | Linux (Steam/GOG)    |
| Controls         | Native                 |
| Joysticks Required | None                |

## Compile
For patches, compiled with VisFree:
```
cd FNAPatches
export DEPS_FOLDER=deps/MercenaryKings
export MONO_PREFIX=~/mono-6.12.0.122/built
export COMPILER=VisFree/bin/Release/VisFree.exe
export CONFIGURATION=Debug
make MercenaryKings
```

Reasoning:
Audio streaming causing stutters. Work now spread out over every frame instead of 1000 ms. Thanks to JohnnyOnFlame for original ParisEngine patches.

## Controls
| Button | Action     |
|--------|------------|
| Y      | Shoot      |
| B      | Jump       |
| X      | Knife      |
| A      | Roll       |
| L      | Inventory  |
| R      | Reload     |
| Down   | Crouch     |
| Start | Pause |

