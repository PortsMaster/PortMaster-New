# libav*...* libsw*
git clone https://github.com/FFmpeg/FFmpeg.git FFmpeg
cd FFmpeg
./configure --disable-libdrm --disable-libxcb --enable-shared --prefix=/usr/local
make -j8
make install
cd ..

# OpenEnroth
git clone --recurse-submodules --shallow-submodules https://github.com/ben-willmore/OpenEnroth.git
cd OpenEnroth
git checkout portmaster

cd thirdparty/imgui/imgui
patch -p1 < ../../../../openenroth.imgui.patch
cd ../../..

cmake -B build -S . \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_LINKER_TYPE=LLD \
  -DOE_USE_PREBUILT_DEPENDENCIES=OFF
cmake --build build -j8 
cd ..

# copy build products
mkdir libs.aarch64
cp /usr/local/lib/libav*.so.[0-9]* ./libs.aarch64/
cp /usr/local/lib/libsw*.so.[0-9]* ./libs.aarch64/
rm ./libs.aarch64/libavdevice*
rm ./libs.aarch64/libavfilter*
rm ./libs.aarch64/*.*.*.*

mkdir -p tool-libs.aarch64
cp /usr/lib/aarch64-linux-gnu/libboost_iostreams.so.1.83.0 ./tool-libs.aarch64/
cp /usr/lib/aarch64-linux-gnu/libboost_filesystem.so.1.83.0 ./tool-libs.aarch64/
cp /usr/lib/aarch64-linux-gnu/libboost_program_options.so.1.83.0  ./tool-libs.aarch64/

# retreve build products on host machine
docker cp enroth-build:/root/OpenEnroth/build/src/Bin/OpenEnroth/OpenEnroth .
docker cp enroth-build:/root/libs.aarch64 .
docker cp enroth-build:/usr/bin/innoextract .
docker cp enroth-build:/root/tool-libs.aarch64 .
