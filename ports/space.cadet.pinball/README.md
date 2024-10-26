## Notes
Thanks to [Muzychenko Andrey](https://github.com/k4zmu2a/SpaceCadetPinball) for the reversed engineering work of this.  Also thanks to [Jetup](https://github.com/Jetup13/SpaceCadetPinball) and [romadu](https://github.com/romadu/SpaceCadetPinball) for the porting work for portmaster.

The menu bar will be hidden after the first launch.

## Controls

| Button | Action |
|--|--| 
|Dpad|Shake|
|A|Launch / OK|
|B|Cancel|
|Y|New game|
|X|Menu bar|
|Select|Quit|
|Start|Pause|


## Build

```bash
git clone https://github.com/k4zmu2a/SpaceCadetPinball.git
cd SpaceCadetPinball
mkdir build
cmake ../
make
ls -l ../bin/SpaceCadetPinball
```
