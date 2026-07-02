## Notes
Cosmo Engine for Cosmo's Cosmic Adventure

A new game engine to play the MS-DOS game "Cosmo's Cosmic Adventure" on modern systems

The first episode is shareware and included. You can add episode 2 & 3 (STN,VOL, and CFG files) to the ports/cosmo-engine/data folder.

Thanks to [Eric Fry](https://github.com/yuv422/cosmo-engine) and other contributors for this open source engine.  
Thanks to Bamboozler for the porting work for portmaster.
Second and third episode launchers and x86_64 support added by Slayer366.

## Controls

| Button | Action |
|--|--| 
|D-Pad L/R|Move|
|D-Pad U/D|Look|
|Start|Menu|
|A|Jump/Select|
|B|Bomb/Cancel|

## Compile

```shell
git clone https://github.com/yuv422/cosmo-engine
cd cosmo-engine
mkdir build
cd build
cmake ..
make -j4
```
