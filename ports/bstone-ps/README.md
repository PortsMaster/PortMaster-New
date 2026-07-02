## Notes
<br/>

The full version is required to run Planet Strike.

To run the full version copy all *.VSI files into 'ports/bstone-ps/gamedata/planet_strike'.
The Steam version of these files can be found by browsing local files and entering the 'Blake Stone - Planet Strike' directory.

Thanks to [Boris I. Bendovsky](https://github.com/bibendovsky/bstone) for creating this unofficial source port.
Also thanks to Cebion, Romadu, and Slayer366 for the porting work for portmaster.
<br/>

## Controls:
<br/>

## 2 Thumbsticks
| Button | Action |
|--|--| 
|D-pad|Move/Turn|
|L-Stick|Move/Strafe|
|R-Stick|Turn|
|Start|Enter/Make selection|
|Select|Escape/Main Menu|
|A/B|Make selection/Open doors/Interact|
|X|Strafe|
|Y|Y/Answer Yes to prompt(s)|
|L1|Run|
|R1|Shoot|
|L3|Map|

<br/>

## No Thumbsticks
| Button | Action |
|--|--| 
|D-pad|Move/Turn|
|Start|Enter/Make selection|
|Select|Escape/Main Menu|
|A|Make selection/Open doors/Interact|
|B|Map|
|X|Run|
|Y|Y/Answer Yes to prompt(s)|
|L1|Strafe|
|R1|Shoot|

<br/>

## Compile
```shell
sudo apt install -y cmake gcc clang libsdl2-dev libogg-dev libvorbis-dev libvorbisfile3 libvorbisenc2 libvorbisidec-dev
git clone https://github.com/Slayer366/bstone
cd bstone/build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```
