## Building notes

This is a 64-bit ARM build of doukutsu-rs, see:
 [https://github.com/doukutsu-rs/doukutsu-rs](https://github.com/doukutsu-rs/doukutsu-rs)


## Compile

```
# Ubuntu 20.04 focal aarch64, without the SDL package installed but with its
# dependencies
# To setup docker image:
cd src
./docker-setup.txt


# In docker image:

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
. "$HOME/.cargo/env"

git clone https://github.com/libsdl-org/SDL
cd SDL
git checkout release-2.26.2
mkdir build
cd build
cmake ..
make -j8
cmake --install . --prefix /usr

cd ../..

git clone https://github.com/libsdl-org/SDL_image.git
cd SDL_image
git checkout release-2.8.3
mkdir build
cd build
cmake ..
make -j8
cmake --install . --prefix /usr

cd ../..

git clone https://github.com/doukutsu-rs/doukutsu-rs
cd doukutsu-rs
patch -p1 < ../doukutsu.cargo.toml.patch
patch -p1 < ../doukutsu.handheld.patch 

cargo build --release

cd ..

# The binary is doukutsu-rs/target/release/doukutsu-rs
# To retrieve it to the host:

docker cp doukutsu-build:/root/doukutsu-rs/target/release/doukutsu-rs .
```
