## Notes

Thanks to [Kenta Cho](https://www.asahi-net.or.jp/~cs8k-cyu/windows/tt_e.html) for creating this game, a high-speed tunnel shooter where the charge shot that wipes out bullets also works as your brake. Thanks to [M-HT](https://github.com/M-HT/torus_trooper) for the D2 and SDL2 port this build is based on.

The music files are repacked losslessly: the original 2001 encoding uses an old Vorbis residue type that the stb_vorbis decoder in many SDL_mixer builds plays back muffled. The repacked files decode to exactly the same samples.

On the title screen, Left/Right picks the grade (Normal, Hard, Extreme) and Up/Down the starting level. B shows a replay of your last game; during a replay, Left/Right changes the view and Up/Down shows or hides the status display.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Steer; Up/Down move the ship forward and back, hold Up to accelerate |
| A | Shot (hold for automatic fire), start a game on the title screen |
| B | Charge shot (hold to charge, release to fire; also brakes), replay on the title screen |
| Start | Pause |
| Select | Back to the title screen; quit from the title screen |

## Compile

Build on Debian 11 (bullseye) arm64, natively or in a chroot.

```
sudo apt install gdc bison libsdl2-dev libsdl2-mixer-dev git curl dpkg-dev
```

### libBulletML (Debian's source, which carries the D interface)

```
curl -LO http://deb.debian.org/debian/pool/main/b/bulletml/bulletml_0.0.6-7.dsc
curl -LO http://deb.debian.org/debian/pool/main/b/bulletml/bulletml_0.0.6.orig.tar.gz
curl -LO http://deb.debian.org/debian/pool/main/b/bulletml/bulletml_0.0.6-7.debian.tar.xz
dpkg-source -x bulletml_0.0.6-7.dsc bulletml
make -C bulletml/src/tinyxml
make -C bulletml/src libbulletml.a
```

### Torus Trooper

```
git clone -b portmaster https://github.com/Knifethrower/torus_trooper.git
cd torus_trooper/sources
BULLETML=../../bulletml sh buildPortMaster.sh
```
