## Notes

Special thanks to [ebuc99](https://github.com/ebuc99/pacman) for this version of Pacman!
Modified version: [Slayer366](https://github.com/Slayer366/pacman)

</br>

## Controls

| Button | Action |
|--|--| 
|D-pad/L-stick|Movement |
|A/B/Start|Menu selection/New game|
|Y/R2/Select|Main Menu/Quit|
|L1|Toggle Sound|
|R1|Toggle Music (Ghost Sirens)|
|L2|Fullscreen button if in DE (SteamDeck, etc.)|

</br>

## Compile
```shell
sudo apt install -y libsdl1.2-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev libpng-dev libpng16-16 
git clone https://github.com/slayer366/pacman
cd pacman
./autogen.sh
make -j4
```
