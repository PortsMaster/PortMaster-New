## Notes

Everything is included and ready to run. 
Launch Tile World, select one of the theme mods and desired display scaling and play! 

Original SDL2 port(s) attempted: [Ricardo Angeli](https://github.com/rangeli/tileworld), [Slayer366](https://github.com/Slayer366/tileworld-sdl2)
Handheld edition based on: [senquack](https://github.com/senquack/tileworld-for-handhelds)
Updated Handheld edition to 640x480: [Slayer366](https://github.com/Slayer366/tileworld-for-handhelds)
Original Game Selector by [Tekkenfede](https://github.com/Tekkenfede/gameselector)
Updated Game Selector [Slayer366](https://github.com/slayer366/gameselector)
Thanks to Chuck Sommerville for Chip's Challenge on Atari Lynx & MS Windows.
Thanks to Brian Raiter for the initial release of Tile World.

Also thanks to Slayer366 for the porting work for portmaster.

</br>

## Controls

| Button | Action |
|--|--| 
|D-pad/L-Stick/R-Stick|Move|
|A/Start|Enter/Make selection/Start level without moving|
|B/Y/Select|Back/Invoke In-game Menu|
|X|Pause|
|L1|Page Up/Previous 10 Levels|
|R1|Page Down/Next 10 Levels|
|L3/R3|Restart Level|

</br>

## Compile
```shell
sudo apt install -y libsdl1.2-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libsdl-mixer1.2-dev libpng-dev libpng16-16 libjpeg-dev libtiff-dev libtiff5-dev libmikmod-dev libfluidsynth-dev flac libmad-ocaml-dev libasound2-dev liblzma-dev zlib1g-dev libjbig-dev libsdl2-dev libopenal-dev libglib2.0-dev libjack-dev libsndfile1-dev libreadline-dev libogg-dev libvorbis-dev libvorbisfile3 libvorbisenc2 libvorbisidec-dev libslang2-dev libtinfo-dev libsndio-dev libxinerama-dev libxrandr-dev libxss-dev libwrap0-dev libxrender-dev liblz4-dev libffi-dev libgpg-error-dev
git clone https://github.com/slayer366/tileworld-for-handhelds
cd tileworld-for-handhelds/src
make -j4
```
