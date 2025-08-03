## Compiling

### MyGUI 3.4.3

As of 0.49.0 it needs MyGUI 3.4.3 and to be built with `-DMYGUI_DONT_USE_OBSOLETE=ON`.

```sh
wget "https://github.com/MyGUI/mygui/archive/refs/tags/MyGUI3.4.3.tar.gz"
tar -xvf MyGUI3.4.3.tar.gz

cd mygui-MyGUI3.4.3
mkdir build
cd build

cmake .. -DMYGUI_RENDERSYSTEM=1 -DMYGUI_BUILD_DEMOS=OFF -DMYGUI_BUILD_TOOLS=OFF -DMYGUI_BUILD_PLUGINS=OFF -DMYGUI_DONT_USE_OBSOLETE=ON

make -j4

sudo make install
```

We now build it with openmw.
~~~
### OpenSceneGraph OpenMW fork

```sh
git clone https://github.com/OpenMW/osg.git

cd osg
mkdir build
cd build

cmake ..
make -j4

sudo make install

```
~~~

### OpenMW

```sh
git clone https://github.com/kloptops/openmw.git

cd openmw

# We're building 0.49.0, using my branch of `portmaster-fixes-0.49`
git checkout portmaster-fixes-0.49

mkdir build
cd build

# This is mostly right i think, modify with `ccmake ..`
cmake .. -DBUILD_LAUNCHER=OFF -DBUILD_WIZARD=OFF -DBUILD_OPENCS=OFF -DBUILD_OPENCS_TESTS=OFF -DBUILD_ESSIMPORTER=OFF -DBUILD_BULLETOBJECTTOOL=OFF -DBUILD_MWINIIMPORTER=OFF -DBUILD_DOCS=OFF -DBUILD_ESMTOOL=OFF -DBUILD_BSATOOL=ON -DBUILD_NIFTEST=OFF -DBUILD_NAVMESHTOOL=OFF -DBUILD_OSG_APPLICATIONS=OFF -DBUILD_OSG_DEPRECATED_SERIALIZE=OFF -DCMAKE_BUILD_TYPE=Release -DMyGUI_LIBRARY=/usr/local/lib/aarch64-linux-gnu/libMyGUIEngine.so.3.4.3 -DMyGUI_INCLUDE_DIR=/usr/local/include/MYGUI/ -DBOOST_STATIC=OFF -DOPENMW_GL4ES_MANUAL_INIT=OFF -DOPENMW_USE_SYSTEM_OSG=OFF -DOPENMW_USE_SYSTEM_BULLET=OFF \
    -DBUILD_COLLADA=OFF \
    -DOPENGL_PROFILE=GL2 \
    \
    -DOPENMW_USE_SYSTEM_OSG=OFF \
    -DBUILD_OSG_APPLICATIONS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DDYNAMIC_OPENSCENEGRAPH=OFF \
    -DDYNAMIC_OPENTHREADS=OFF \
    -DOPENMW_USE_SYSTEM_BULLET=OFF \
    \
    -DMyGUI_LIBRARY=/usr/local/lib/aarch64-linux-gnu/libMyGUIEngine.so.3.4.3 \
    -DMyGUI_INCLUDE_DIR=/usr/local/include/MYGUI/ \
    -DOPENMW_USE_SYSTEM_MYGUI=ON \
    \
    -DOPENGL_gl_LIBRARY=/home/klops/Source/gl4es/lib/libGL.so.1 \
    -DOPENGL_INCLUDE_DIR=/home/klops/Source/gl4es/include/ \
    \
    -DCMAKE_ARGS="\
        -DOPENGL_PROFILE=GL2 \
        -DBUILD_OSG_APPLICATIONS=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DDYNAMIC_OPENSCENEGRAPH=OFF \
        -DDYNAMIC_OPENTHREADS=OFF"

# This is the working directory for ports.
ports_dir="/path/to/ports/directory/"

# After done copy the openmw and bsatool file to the port directory as openmw.aarch64, bsatool.aarch64
cp openmw $ports_dir/openmw.aarch64
cp bsatool $ports_dir/bsatool.aarch64

# Copy all the shared libs it needs... good luck. :D
## TODO: this is hard, so many libs from different sources.

# Next copy `resources/`
cp -r resources/ $ports_dir/openmw/

cd $ports_dir/openmw/

# Create un-modified shaders for SteamDeck
grep -F '+++ resources/' resources.GLES.patch | awk '{ print $2 };' | tar -cjf resources.OpenGL2.tar.bz2 --no-recursion -T -

# Apply patches to shaders for GLES.
patch -i resources.GLES.patch

# DONE!
```
