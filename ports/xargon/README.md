## Notes

An archaeologist named Malvineous Havershim was studying strange ruins in Madagascar, remnants of buildings constructed during the age of a long-forgotten civilization of the mysterious Blue Builders. One day Malvineous spotted glyphs on one of the structures. As he attempted to translate them, Malvineous was hit by a wave of gas and fainted. In his dream, a talking eagle named Silvertongue tried to warn him of upcoming dangers. The archaeologist awoke in a strange and hostile world, unable to understand anything. With Silvertongue's guidance, Malvineous will have to overcome all dangers and eventually confront Xargon, the tyrannical ruler of that world.

Everything is included and ready to run. 

Original port repo: [Malvineous](https://github.com/Malvineous/xargon)
Updated Xargon source port: [Slayer366](https://github.com/Slayer366/xargon)

Slayer366 source port information:
Initial patches and improvements were adapted from ptitseb's Pandora diff and Shin-Nil's fork for the GCW.
Ptitseb's diff fixes a major refresh issue in the game's world map.
Ptitseb's diff enables music playback using DOSBox' Sound Blaster OPL emulation.
Shin-Nil's fork allows both 'Enter' and 'Y' keys to be used to quit the game from the main menu.
Improved performance by caching and reducing SDL_Flip and SDL_SetPalette calls.
Improved performance with scrolls and journal entries very slow to scroll and fix graphic artifacting.
Fix flickering menu arrow cursor - make static while preserving animation.
Eliminate menu delay by only rendering borders and fill after the render loop is complete.
Enters default hi-score name and save-game name if nothing is entered to be 'controller friendly'.
Make bottom flashy screen messages flash.
Cleaned up compiler warnings and performed other various small fixes.


</br>

## Controls

| Button | Action |
|--|--|
|D-pad/L-Stick/R-Stick|Move|
|Start/Y|Enter/Make selection/Inventory|
|Select/L2|Esc/Invoke in-game menu|
|A/L1|Jump|
|B/R1|Fire|
|X|Buy-menu/Store|
|R2|Pause|


</br>

## Compile
```shell
sudo apt install -y libsdl1.2-dev libsdl-image1.2-dev libboost-dev libboost-system-dev libboost-all-dev xmlto portaudio19-dev
```

Build libgamecommon first and install it:
```shell
git clone https://github.com/Malvineous/libgamecommon
cd libgamecommon
git checkout v1.x
./autogen.sh
# If on aarch64:
  ./configure --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu/
# If on x86_64:
  ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make -j$(nproc)
sudo make install
```

Build libgamemusic second and install it:
```shell
git clone https://github.com/Malvineous/libgamemusic
cd libgamemusic
git checkout v1.x
./autogen.sh
# If on aarch64:
  ./configure --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu/
# If on x86_64:
  ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make -j$(nproc)
sudo make install
```

Now Xargon may be built with gamemusic enabled:
```shell
git clone https://github.com/slayer366/xargon
cd xargon
./autogen.sh
./configure --with-libgamemusic
make -j$(nproc)
```
