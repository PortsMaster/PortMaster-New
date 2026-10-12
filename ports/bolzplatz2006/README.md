## Notes

Thanks to [Xenoage Software](https://github.com/Xenoage/Bolzplatz2006) for releasing Bolzplatz 2006 (Slam Soccer 2006) under the GPL - a wonderfully silly 3D comic-style football game with a full career mode, a world cup and hand-built backyard stadiums.

The game starts in English. To play in German or French, change `<id>en</id>` to `de` or `fr` in `bolzplatz2006/data/config/language.xml`.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move player / navigate menus |
| B | Pass / confirm |
| A | Pass / confirm |
| Y | Shoot |
| R1 (hold) | Sprint |
| Start | Pause menu / back |
| Select | Pause menu / back |

## Compile

```bash
sudo apt-get install -y g++ make unzip libx11-dev libxxf86vm-dev libxext-dev libgl-dev libglu1-mesa-dev openjdk-17-jdk-headless libvecmath-java
git clone https://github.com/Cebion/Bolzplatz2006.git
cd Bolzplatz2006
./portmaster/build.sh
```

This builds the patched Irrlicht 1.2 engine and its JIRR Java binding into `portmaster/out/libs.aarch64/libirrlicht_wrap.so`, plus `portmaster/out/lib/irrlicht.jar` and `portmaster/out/game.jar`.
