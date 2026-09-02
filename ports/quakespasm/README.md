## Notes

Thanks to [Ozkan Sezer](https://github.com/sezero/quakespasm) for this awesome source port for Quake.

Source: [Slayer366](https://github.com/Slayer366/quakespasm-for-GL4ES)

Get Quake, Scourge of Armagon, Dissolution of Eternity, Dimension of the Past, and Dimension of the Machine from:
[Steam](https://store.steampowered.com/app/2310/Quake/)
OR
[GOG](https://www.gog.com/en/game/quake_the_offering)

NOTE: As of August 2026, Dawn of the Machine can only be obtained through the Steam release.

Get Arcane Dimensions for free from moddb [simonoc](https://www.moddb.com/mods/arcane-dimensions)

It is recommended to use an RK3566 or faster CPU to run Arcane Dimensions, Dimension of the Machine, or Dawn of the Machine.

To invert right joystick look, set mouse-look invert option in the game's options menu.

Quakespasm supports mp3, ogg, flac, and more.


Game files needed:

Quake:
- quakespasm/id1/pak0.pak
- quakespasm/id1/pak1.pak &nbsp; (Not needed if using pak0.pak from the Nightdive re-release)
- quakespasm/id1/music/track02.ogg
- quakespasm/id1/music/track03.ogg
- quakespasm/id1/music/track04.ogg
- quakespasm/id1/music/track05.ogg
- quakespasm/id1/music/track06.ogg
- quakespasm/id1/music/track07.ogg
- quakespasm/id1/music/track08.ogg
- quakespasm/id1/music/track09.ogg
- quakespasm/id1/music/track10.ogg
- quakespasm/id1/music/track11.ogg

Scourge of Armagon:
- quakespasm/hipnotic/pak0.pak
- quakespasm/hipnotic/music/track02.ogg
- quakespasm/hipnotic/music/track03.ogg
- quakespasm/hipnotic/music/track04.ogg
- quakespasm/hipnotic/music/track05.ogg
- quakespasm/hipnotic/music/track06.ogg
- quakespasm/hipnotic/music/track07.ogg
- quakespasm/hipnotic/music/track08.ogg
- quakespasm/hipnotic/music/track09.ogg

Dissolution of Eternity:
- quakespasm/rogue/pak0.pak
- quakespasm/rogue/music/track02.ogg
- quakespasm/rogue/music/track03.ogg
- quakespasm/rogue/music/track04.ogg
- quakespasm/rogue/music/track05.ogg
- quakespasm/rogue/music/track06.ogg
- quakespasm/rogue/music/track07.ogg
- quakespasm/rogue/music/track08.ogg
- quakespasm/rogue/music/track09.ogg

Dimension of the Past:
- quakespasm/dopa/pak0.pak

Arcane Dimensions:
- quakespasm/ad/pak0.pak
- quakespasm/ad/pak1.pak
- quakespasm/ad/pak2.pak

Dimension of the Machine:
- quakespasm/QuakeEX.kpf
- quakespasm/mg1/pak0.pak

Dawn of the Machine:
- quakespasm/QuakeEX.kpf
- quakespasm/mg3/pak0.pak
- quakespasm/mg3/music/track02.ogg
- quakespasm/mg3/music/track03.ogg
- quakespasm/mg3/music/track04.ogg
- quakespasm/mg3/music/track05.ogg
- quakespasm/mg3/music/track06.ogg
- quakespasm/mg3/music/track07.ogg
- quakespasm/mg3/music/track08.ogg
- quakespasm/mg3/music/track09.ogg
- quakespasm/mg3/music/track10.ogg
- quakespasm/mg3/music/track11.ogg
- quakespasm/mg3/music/track12.ogg
- quakespasm/mg3/music/track13.ogg

## Controls

| Button | Action |
|--|--| 
|Select|Menu/Esc|
|Start|Enter|
|A|Next Weapon|
|B|Previous Weapon|
|X|Run/Walk|
|Y|Swim Down|
|L1|Jump|
|L2|Quick Save|
|R2|Quick Load|
|R1|Fire|
|Up|Menu Up/Move Forward|
|Down|Menu Down/Move Back|
|Left|Menu Left/Strafe Left|
|Right|Menu Right/Strafe Right|
|Left Analog|Move|
|Right Analog|Look|
|L3 (Left Thumb button)|Level Stats|
|R3 (Right Thumb button)|Center View|

## Compile

```shell
git clone https://github.com/slayer366/quakespasm-for-gl4es
cd quakespasm-for-gl4es/Quake
sudo apt install libpng-dev libsdl2-dev libflac-dev libmikmod-dev libmad0-dev
make -j$(nproc)
```
