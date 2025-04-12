# Sonic 3 AIR - PortMaster Build Guide
The following steps assume https://github.com/Eukaryot/sonic3air/pull/34 has been merged and the cmake options are still valid.

```
git clone https://github.com/Eukaryot/sonic3air && cd sonic3air/Oxygen/sonic3air/build/_cmake
mkdir build && cd build
cmake -G Ninja -DUSE_GLES=ON -DBUILD_SDL_STATIC=OFF -DUSE_DISCORD=OFF -DUSE_IMGUI=OFF -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j $(nproc)
cd ../../.. && strip sonic3air_linux
```
