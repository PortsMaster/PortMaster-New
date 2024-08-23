## Building Sonic Mania & RSDKv5
This guide assumes you will be using WSL2 or similar with debian bullseye chroot. The Plus content is disabled in distributions and must be built by the end user.

To build Mania:
```
apt install build-essential cmake libglew-dev libglfw3-dev libtheora-dev
git clone https://github.com/RSDKModding/Sonic-Mania-Decompilation
cd Sonic-Mania-Decompilation
git submodule update --init --recursive
cmake -B build -DRETRO_REVISION=2 -DRETRO_DISABLE_PLUS=on -DRETRO_SUBSYSTEM=SDL2
cmake --build build --config release
```

To build Plus:
```
apt install build-essential cmake libglew-dev libglfw3-dev libtheora-dev
git clone https://github.com/RSDKModding/Sonic-Mania-Decompilation
cd Sonic-Mania-Decompilation
git submodule update --init --recursive
cmake -B build -DRETRO_REVISION=2 -DRETRO_DISABLE_PLUS=off -DRETRO_SUBSYSTEM=SDL2
cmake --build build --config release
```

In both cases, when the build is completed, retrieve the following files:

`Sonic-Mania-Decompilation\build\libGame.so` -- Copy to `ports/sonicmania` as `Game.so`
`Sonic-Mania-Decompilation\build\dependencies\RSDKv5\RSDKv5` -- Copy to `ports/sonicmania` as `sonicmania`
