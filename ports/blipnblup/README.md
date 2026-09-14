## Notes

Thanks to [LucKey Productions](https://luckey.games) for creating Blip 'n Blup, a 3D co-op arcade platformer that pays homage to Bubble Bobble and The Lost Vikings.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move |
| A | Jump / Confirm |
| B | Bubble / Cancel |
| X | Run |
| Y | Interact |
| Start | Pause |
| Back | Switch |
| Guide | Menu |

## Compile

apt-get install qtbase5-dev qtbase5-dev-tools qt5-qmake libx11-dev libxrandr-dev libasound2-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev libgles-dev doxygen libroar-dev libjack-dev libsamplerate0-dev

git clone https://gitlab.com/cebion/dry.git Dry
cd Dry
mkdir -p include/Dry/ThirdParty/SDL
cp /usr/include/SDL2/*.h include/Dry/ThirdParty/SDL/
./script/cmake_generic.sh . -DDRY_ANGELSCRIPT=0 -DDRY_2D=0 -DDRY_SAMPLES=0 -DDRY_TOOLS=0 -DCMAKE_C_FLAGS=-fcommon -DVIDEO_WAYLAND=OFF
make -j$(nproc)
cd ..

git clone https://gitlab.com/cebion/BlipNBlup.git
cd BlipNBlup
mkdir build && cd build
qmake ../BlipNBlup.pro
make -j$(nproc)
