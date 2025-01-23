## Building notes

This is a build of doukutsu-rs, see:
 [https://github.com/doukutsu-rs/doukutsu-rs](https://github.com/doukutsu-rs/doukutsu-rs)

Thanks to Studio Pixel/Nicalis for the original game and Cave Story+. Thanks to the doukutsu-rs team for the amazing reimplementation.


## Compile

```
# Ubuntu 20.04 focal, without SDL installed but with its dependencies.
# 20.04 was used because the port does not work on ArkOS, and performance
# may be better.
#
# For dependencies, see src/Dockerfile

mkdir shared/doukutsu-build
cd shared/doukutsu-build

git clone https://github.com/libsdl-org/SDL
cd SDL
git checkout release-2.26.2
./configure --prefix=/usr
make
sudo make install

cd ..

git clone https://github.com/libsdl-org/SDL_image.git
cd SDL_image
git checkout release-2.8.3
mkdir build
cd build
cmake ..
make
sudo cmake --install . --prefix /usr

cd ../..

git clone https://github.com/doukutsu-rs/doukutsu-rs
cd doukutsu-rs
patch -p1 < ../src/doukutsu-rs.patch
cargo build --release

cd ..

# binary is doukutsu-rs/target/release/doukutsu-rs
```
