git clone https://github.com/libsdl-org/SDL.git
cd SDL
git checkout release-2.30.9
mkdir -p build-focal-2.30.9
cd build-focal-2.30.9
cmake ..
make -j8
make install
cd ../..

git clone https://github.com/libsdl-org/SDL_image.git
cd SDL_image
git checkout release-2.6.3
mkdir -p build-focal-2.6.3
cd build-focal-2.6.3
cmake ..
make -j8
make install
cd ../..

# old version doesn't work with cmake
git clone https://github.com/libsdl-org/SDL_mixer.git
cd SDL_mixer
git checkout release-2.0.4
./configure
make -j8
make install
cd ..

git clone https://github.com/verhoevenv/OpenNotrium.git

cd OpenNotrium
patch -p1 < ../notrium.fixes.patch

mkdir -p build
cd build

cmake ..
make -j8

cd ..
mkdir opennotrium
cp build/OpenNotrium opennotrium
cp -r runtime_files/* opennotrium

# retrieve build products on host machine
docker cp notrium-build:/root/OpenNotrium/opennotrium .
