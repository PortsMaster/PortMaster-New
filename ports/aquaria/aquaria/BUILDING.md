## Building notes

This is a build of AquariaOSE, see:

[https://github.com/AquariaOSE/Aquaria](https://github.com/AquariaOSE/Aquaria)


## Compile

```
# Ubuntu 20.04 focal, with libopenal-dev, and without the SDL package 
# installed but with its dependencies:

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


git clone https://github.com/AquariaOSE/Aquaria.git
cd Aquaria
wget https://raw.githubusercontent.com/ben-willmore/PortMaster-New/refs/heads/aquaria/ports/aquaria/aquaria/src/aquaria.patch
patch -p1 < aquaria.patch
mkdir build && cd build
cmake .. -DAQUARIA_USE_SDL2=ON
make

cd ..

# The binary is Aquaria/build/aquaria
# To retrieve it to the host:

docker cp aquaria-build:/Aquaria/build/aquaria ./aquaria.aarch64
```
