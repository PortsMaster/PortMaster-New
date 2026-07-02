## Build Environment

- **OS**: Debian 11 (bullseye), aarch64
- **Compiler**: GCC 12.5.0 installed at `/usr/local/bin/gcc` and `/usr/local/bin/g++` (from sid; bullseye system GCC is too old)
- **Note**: The system libstdc++ is bullseye-era and lacks GLIBCXX_3.4.29+. Binaries compiled with GCC 12 require either static linking of libstdc++ (`-static-libstdc++`) or the bundled libs in the PortMaster package to run on target devices.

## Compiling

### MyGUI 3.4.3

```sh
wget "https://github.com/MyGUI/mygui/archive/refs/tags/MyGUI3.4.3.tar.gz"
tar -xvf MyGUI3.4.3.tar.gz

cd mygui-MyGUI3.4.3
mkdir build
cd build

cmake .. -DMYGUI_RENDERSYSTEM=1 -DMYGUI_BUILD_DEMOS=OFF -DMYGUI_BUILD_TOOLS=OFF \
    -DMYGUI_BUILD_PLUGINS=OFF -DMYGUI_DONT_USE_OBSOLETE=ON

make -j$(nproc)
sudo make install
```

### OpenSceneGraph (OpenMW fork)

Vanilla OpenMW OSG fork, branch `3.6`, no custom patches.

```sh
git clone https://github.com/OpenMW/osg.git OpenSceneGraph
cd OpenSceneGraph
git checkout 3.6

mkdir build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_OSG_PLUGINS_BY_DEFAULT=0 \
    -DBUILD_OSG_PLUGIN_OSG=1 -DBUILD_OSG_PLUGIN_DAE=1 -DBUILD_OSG_PLUGIN_DDS=1 \
    -DBUILD_OSG_PLUGIN_TGA=1 -DBUILD_OSG_PLUGIN_BMP=1 -DBUILD_OSG_PLUGIN_JPEG=1 \
    -DBUILD_OSG_PLUGIN_PNG=1 -DBUILD_OSG_PLUGIN_FREETYPE=1 -DBUILD_OSG_PLUGIN_KTX=1 \
    -DBUILD_OSG_DEPRECATED_SERIALIZERS=0 \
    -DOPENGL_PROFILE=GL2

make -j$(nproc)
sudo make install
```

### OpenMW

Based on upstream OpenMW `master` (post openmw-50-rc1, commit `942315d332`) with the following custom commits on branch `portmaster-latest`:

1. **Resolution scaling** — Render at lower resolution than screen (configurable 0.1-1.0)
2. **ASTC/KTX texture support** — Texture format priority: KTX > DDS > original
3. **GCC 12 / bullseye build fixes** — Compatibility with older system libraries
4. **Remove unused OSG components** — Drop osgSim, osgFX to reduce binary size
5. **Remove COLLADA/DAE support** — Drop collada-dom dependency
6. **Disable lua profiling by default** — Performance improvement for handhelds
7. **On-screen keyboard** — Controller-navigable QWERTY keyboard for text input

```sh
git clone https://github.com/bmdhacks/openmw.git
cd openmw
git checkout portmaster-latest

mkdir build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=/usr/local/bin/gcc \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/g++ \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_LAUNCHER=OFF -DBUILD_WIZARD=OFF -DBUILD_OPENCS=OFF \
    -DBUILD_OPENCS_TESTS=OFF -DBUILD_ESSIMPORTER=OFF \
    -DBUILD_BULLETOBJECTTOOL=OFF -DBUILD_MWINIIMPORTER=OFF \
    -DBUILD_DOCS=OFF -DBUILD_ESMTOOL=OFF -DBUILD_BSATOOL=ON \
    -DBUILD_NIFTEST=OFF -DBUILD_NAVMESHTOOL=OFF \
    -DBUILD_OSG_APPLICATIONS=OFF -DBUILD_OSG_DEPRECATED_SERIALIZE=OFF \
    -DBUILD_COLLADA=OFF \
    -DBOOST_STATIC=OFF -DOPENMW_GL4ES_MANUAL_INIT=OFF \
    -DOPENGL_PROFILE=GL2 \
    -DDYNAMIC_OPENSCENEGRAPH=ON -DDYNAMIC_OPENTHREADS=OFF \
    -DOPENMW_USE_SYSTEM_BULLET=OFF \
    -DOPENMW_USE_SYSTEM_MYGUI=ON \
    -DMyGUI_LIBRARY=/usr/local/lib/libMyGUIEngine.so.3.4.3 \
    -DMyGUI_INCLUDE_DIR=/usr/local/include/MYGUI/ \
    -DOPENMW_USE_SYSTEM_OSG=ON \
    -DOpenSceneGraph_DIR=$HOME/OpenSceneGraph/build \
    -DCMAKE_PREFIX_PATH="$HOME/OpenSceneGraph/build;$HOME/OpenSceneGraph" \
    -DCMAKE_LIBRARY_PATH="$HOME/OpenSceneGraph/build/lib" \
    -DCMAKE_INCLUDE_PATH="$HOME/OpenSceneGraph/include;$HOME/OpenSceneGraph/build/include" \
    -DSDL2_DIR=/usr/lib/aarch64-linux-gnu/cmake/SDL2 \
    -DFFMPEG_LIB_DIR=/usr/lib/aarch64-linux-gnu \
    -DFFMPEG_INCLUDE_DIR=/usr/include/aarch64-linux-gnu

make -j$(nproc)
```

### Deploying

```sh
ports_dir="/path/to/ports/directory/"

# Copy binaries
cp openmw $ports_dir/openmw.aarch64
cp bsatool $ports_dir/bsatool.aarch64

# Copy resources (includes defaults.bin built from settings-default.cfg)
cp -r resources/ $ports_dir/openmw/

# Create un-modified shaders for SteamDeck/OpenGL devices
cd $ports_dir/openmw/
grep -F '+++ resources/' resources.GLES.patch | awk '{ print $2 };' | \
    tar -cjf resources.OpenGL.tar.bz2 --no-recursion -T -

# Apply shader patches for GLES
patch -i resources.GLES.patch
```
