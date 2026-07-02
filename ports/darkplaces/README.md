## Notes

Thanks to [LadyHavoc](https://github.com/DarkPlacesEngine/DarkPlaces) for this awesome source port for Quake.  
DarkPlaces official home page: [DarkPlaces](https://hemebond.gitlab.io/darkplaces-www/)  

Source: [Slayer366](https://github.com/Slayer366/DarkPlaces)  
Forked from: [kasymovga](https://github.com/kasymovga/DarkPlacesRM)  

Get Quake, Scourge of Armagon, Dissolution of Eternity, and Dimension of the Past from:  
[Steam](https://store.steampowered.com/app/2310/Quake/)  
OR  
[GOG](https://www.gog.com/en/game/quake_the_offering)  

To invert look, set mouse-look invert option in the game's options menu.  
To enable auto-run, toggle 'Always run' in the game's options menu.  

Make sure all files are lowercase.  
The launchers will attempt to make files lowercase, but this may not work in every scenario.  

#### Game files needed:

**Quake**:
- darkplaces/id1/pak0.pak
- darkplaces/id1/pak1.pak
- darkplaces/id1/music/track02.ogg
- darkplaces/id1/music/track03.ogg
- darkplaces/id1/music/track04.ogg
- darkplaces/id1/music/track05.ogg
- darkplaces/id1/music/track06.ogg
- darkplaces/id1/music/track07.ogg
- darkplaces/id1/music/track08.ogg
- darkplaces/id1/music/track09.ogg
- darkplaces/id1/music/track10.ogg
- darkplaces/id1/music/track11.ogg

**Scourge of Armagon**:
- darkplaces/hipnotic/pak0.pak
- darkplaces/hipnotic/music/track02.ogg
- darkplaces/hipnotic/music/track03.ogg
- darkplaces/hipnotic/music/track04.ogg
- darkplaces/hipnotic/music/track05.ogg
- darkplaces/hipnotic/music/track06.ogg
- darkplaces/hipnotic/music/track07.ogg
- darkplaces/hipnotic/music/track08.ogg
- darkplaces/hipnotic/music/track09.ogg

**Dissolution of Eternity**:
- darkplaces/rogue/pak0.pak
- darkplaces/rogue/music/track02.ogg
- darkplaces/rogue/music/track03.ogg
- darkplaces/rogue/music/track04.ogg
- darkplaces/rogue/music/track05.ogg
- darkplaces/rogue/music/track06.ogg
- darkplaces/rogue/music/track07.ogg
- darkplaces/rogue/music/track08.ogg
- darkplaces/rogue/music/track09.ogg

**Dimension of the Past**:
- darkplaces/dopa/pak0.pak


#### Custom Mods:
Drop a mod folder into /ports/darkplaces/ with its contents.

Option 1:
- Make a copy of one of the DarkPlaces shell scripts 
- Rename it to match the name of the mod
- Then modify the RUNMOD entry to load your mod pointing to the mod folder (and starting map if required).

Option 2:
- Launch 'DarkPlaces - Quake' and use 'Browse Mods' in the options menu to select the mod folder.
- NOTE: Many mods will launch using this method, but there are some that may not.

Mods like Nexiuz and Xonotic should also work.


## Controls

Start and Select are the main buttons for navigating the menus.

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


</br>

## Compile
```shell
sudo apt install -y libsdl2-dev libtheora-dev
git clone https://github.com/slayer366/darkplaces
cd darkplaces
make sdl-release -j$(nproc)
```

To compile for OpenGL instead of GLESv2, edit the makefile and DELETE the following entries before running make:
```
DP_GLES2=1                           (Line 78)
ifdef DP_GLES2                       (Line 237)
  CFLAGS_GL=-DUSE_GLES2              (Line 238)
  LIB_GL=-lGLESv2                    (Line 239)
endif                                (Line 240)
```