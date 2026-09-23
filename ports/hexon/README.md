## Notes

Thanks to [LucKey Productions](https://luckey.games) for creating heXon, a free and open
source twin-stick-shooter. All edges of the hexagonal arena are
connected to its opposite like portals - fly well, avoid the Notyous, and destroy them with
your Whack-o-Slack blast battery.

## Controls

| Button | Action |
|--|--|
| Left Stick | Move |
| Right Stick | Aim / Fire (8-directional) |
| A | Ram |
| B | Repel |
| X | Dive |
| Y | Depth Charge |
| Start | Pause |
| L1+R1 | Join / Leave |
| D-Pad | Menu navigation |

## Compile

apt-get install qtbase5-dev qtbase5-dev-tools qt5-qmake libx11-dev libxrandr-dev libasound2-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev libgles-dev doxygen libroar-dev libjack-dev libsamplerate0-dev

git clone https://gitlab.com/luckeyproductions/Dry
cd Dry
mkdir -p include/Dry/ThirdParty/SDL
cp /usr/include/SDL2/*.h include/Dry/ThirdParty/SDL/
./script/cmake_generic.sh . -DDRY_ANGELSCRIPT=0 -DDRY_2D=0 -DDRY_SAMPLES=0 -DDRY_TOOLS=0 -DCMAKE_C_FLAGS=-fcommon -DVIDEO_WAYLAND=OFF
make -j$(nproc)
cd ..

git clone https://gitlab.com/luckeyproductions/heXon.git
cd heXon
cp -a ../Dry .
mkdir build && cd build
qmake ../heXon.pro
make -j$(nproc)

Note: `heXon.pro`'s `unix{}` block is patched to link `-lGLESv2 -lSDL2` instead of `-lGL`
(never add `-lGLESv1_CM` alongside `-lGLESv2` - see the project's GLESv1/GLESv2 gotcha notes),
and `LIBS`/`INCLUDEPATH` point at the relative `Dry/` copy above rather than a `DRY_HOME`
environment variable. heXon also needs the `Dry/include/Dry/ThirdParty/Bullet` include path,
since `src/enemy/baphomech.cpp` calls Bullet's `btHingeConstraint` directly.
