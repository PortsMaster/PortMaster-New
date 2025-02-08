## Building notes

This is a 64-bit ARM build of doukutsu-rs, see:
 [https://github.com/doukutsu-rs/doukutsu-rs](https://github.com/doukutsu-rs/doukutsu-rs)


## Compile

```
# Ubuntu 20.04 focal aarch64, without the SDL package installed but with its
# dependencies:

cd src
./docker-setup.txt


# In docker image:

git clone https://github.com/libsdl-org/SDL
cd SDL
git checkout release-2.26.2
./configure --prefix=/usr
make
make install

cd ..

git clone https://github.com/libsdl-org/SDL_image.git
cd SDL_image
git checkout release-2.8.3
mkdir build
cd build
cmake ..
make
cmake --install . --prefix /usr

cd ../..

git clone https://github.com/doukutsu-rs/doukutsu-rs
cd doukutsu-rs
wget https://raw.githubusercontent.com/PortsMaster/PortMaster-New/refs/heads/main/ports/doukutsu-rs/doukutsu-rs/src/doukutsu-rs.patch
patch -p1 < ./doukutsu-rs.patch
cargo build --release

cd ..

# The binary is doukutsu-rs/target/release/doukutsu-rs
# To retrieve it to the host:

docker cp doukutsu-build:/doukutsu-rs/target/release/doukutsu-rs .
```
