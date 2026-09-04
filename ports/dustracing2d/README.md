## Notes

Thanks to [Jussi Lind](https://github.com/juzzlin) for creating Dust Racing 2D, a tile-based 2D racing game with smooth car physics and a built-in track editor.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Steer / Accelerate / Brake |
| A | Accelerate |
| B | Brake |
| Y | Pause |
| Start | Confirm |
| Back | Quit / Back |

## Compile

DustRacing2D needs a Qt6 build with `eglfs`/`wayland` enabled and desktop OpenGL disabled - a stock distro Qt6 package won't work. Build the runtime first, then the game against it.

### 1. Qt6 (eglfs + KMS/GBM, no desktop OpenGL)

```bash
apt-get install libinput-dev
git clone git://code.qt.io/qt/qt5.git qt6
cd qt6
git checkout 6.6
./init-repository --module-subset=qtbase,qttools
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/qt6-eglfs -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_DISABLE_FIND_PACKAGE_Clang=ON \
  -DFEATURE_eglfs=ON -DFEATURE_kms=ON -DFEATURE_gbm=ON -DFEATURE_eglfs_egldevice=ON \
  -DFEATURE_linuxfb=ON -DFEATURE_libinput=ON -DFEATURE_xkbcommon=ON \
  -DFEATURE_opengl_desktop=OFF -DFEATURE_opengl_dynamic=OFF \
  -DFEATURE_opengles2=ON -DFEATURE_opengles3=ON \
  -DFEATURE_eglfs_x11=OFF -DFEATURE_egl_x11=OFF -DFEATURE_xkbcommon_x11=OFF \
  -DFEATURE_vulkan=OFF -DFEATURE_eglfs_mali=OFF \
  -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF
cmake --build . --parallel $(nproc)
cmake --install .
```

### 2. Qt Wayland module

Needed for devices where the CFW already runs a Wayland compositor (e.g. Sway on ROCKNIX) - plain `eglfs` conflicts with an already-running compositor over DRM master.

```bash
git clone git://code.qt.io/qt/qtwayland.git
cd qtwayland
git checkout 6.6
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/opt/qt6-eglfs -DCMAKE_INSTALL_PREFIX=/opt/qt6-eglfs -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel $(nproc)
cmake --install .
```

### 3. OpenAL-soft (with PipeWire/PulseAudio backends)

The distro-packaged OpenAL only supports ALSA/OSS/sndio - devices whose audio server is PipeWire (with no ALSA-compat plugin installed) get no sound at all without this. Needs gcc-12 (the C++20 code in `common/dynload.cpp` fails to build on gcc-11).

```bash
apt-get install gcc-12 g++-12 libpipewire-0.3-dev
git clone https://github.com/kcat/openal-soft.git
cd openal-soft
mkdir build && cd build
cmake .. -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/openal-soft \
  -DALSOFT_BACKEND_PIPEWIRE=ON -DALSOFT_BACKEND_PULSEAUDIO=ON \
  -DALSOFT_BACKEND_ALSA=ON -DALSOFT_BACKEND_OSS=ON -DALSOFT_BACKEND_SNDIO=ON \
  -DALSOFT_UTILS=OFF -DALSOFT_EXAMPLES=OFF
cmake --build . --parallel $(nproc)
cmake --install .
```

Copy the resulting `libopenal.so.1` into the runtime's own `lib/` bundle (alongside the Qt6 libraries), replacing any earlier copy there.

### 4. Dust Racing 2D

```bash
git clone --recurse-submodules https://github.com/juzzlin/DustRacing2D.git
cd DustRacing2D
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DGLES=ON -DDisableFramebufferBlits=ON -DCMAKE_PREFIX_PATH=/opt/qt6-eglfs
make
```

`-DDisableFramebufferBlits=ON` matters: without it, shadow rendering silently depends on `glBlitFramebuffer` (GLES3+/desktop-GL only), which no-ops under a GLES2 context and roughly doubles render cost even when it is available.
