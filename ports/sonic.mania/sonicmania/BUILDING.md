## Building Sonic Mania & RSDKv5
This guide assumes you will be using WSL2 or similar with debian bullseye chroot. The Plus content is disabled in distributions and must be built by the end user.

To build Mania:
```
apt install build-essential cmake libglew-dev libglfw3-dev libtheora-dev libdrm-dev libgbm-dev
git clone --recursive https://github.com/RSDKModding/Sonic-Mania-Decompilation
cd Sonic-Mania-Decompilation
cmake -B build -DRETRO_REVISION=2 -DRETRO_DISABLE_PLUS=on -DRETRO_SUBSYSTEM=SDL2 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG" -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG"
cmake --build build --config release
```

To build Plus:
```
apt install build-essential cmake libglew-dev libglfw3-dev libtheora-dev libdrm-dev libgbm-dev
git clone --recursive https://github.com/RSDKModding/Sonic-Mania-Decompilation
cd Sonic-Mania-Decompilation
cmake -B build -DRETRO_REVISION=2 -DRETRO_DISABLE_PLUS=off -DRETRO_SUBSYSTEM=SDL2 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG" -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG"
cmake --build build --config release
```

In both cases, when the build is completed, retrieve the following files:

`Sonic-Mania-Decompilation\build\libGame.so` -- Copy to `ports/sonicmania` as `Game.so`
`Sonic-Mania-Decompilation\build\dependencies\RSDKv5\RSDKv5` -- Copy to `ports/sonicmania` as `sonicmania`
