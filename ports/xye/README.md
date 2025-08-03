## Notes

Thanks to Cebion for the compiling tip for ARM (use -fsigned-char argument for building)!
Thanks to Slayer366 for porting this game to PortMaster!

- [Xye](https://xye.sourceforge.net/)

## Controls

| Button | Action |
|--|--| 
|D-pad/Left Stick|Movement|
|Select|Escape/Quit|
|Start/A|Enter/Select/Restart Level|
|B|Undo last move|
|X|Show Hint|
|Y|Playback Level Solution|
|L1|Previous Level|
|R1|Next Level|
|L2|Level Select Screen|
|R2|Select Theme @Main Menu|
|L3|Fast-Forward|
|Right Stick + R3|Mouse (not required)|

## Compile
Extract the contents of the provided xye-0.12.2-src.7z archive
```shell
sudo apt install -y libsdl1.2-dev libsdl-image1.2-dev libsdl-ttf2.0-dev libpng-dev libpng16-16
cd xye-0.12.2-src (or whichever folder you chose to extract to)
make -j4
```
