## Building DXX-Rebirth
DXX-Rebirth was compiled with debian bookworm and debian bullseye in a WSL2 chroot.

```
apt -y install build-essential git wget python3 python3-pip python3-setuptools python3-wheel scons libglu1-mesa-dev pkg-config libpng-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libphysfs-dev libgles1
ln -s /usr/lib/aarch64-linux-gnu/libGLESv1_CM.so /usr/lib/aarch64-linux-gnu/libGLES_CM.so
git clone https://github.com/dxx-rebirth/dxx-rebirth
cd dxx-rebirth
scons -j$(nproc) sdl2=1 sdlmixer=1 opengles=1
```

If using bullseye you can instead do `git clone --branch compatibility https://github.com/JeodC/dxx-rebirth`. After building you can safely strip the binaries: `strip d1x-rebirth/d1x-rebirth / strip d2x-rebirth/d2x-rebirth`.