## Building notes

This is a 64-bit ARM build of the decompilation and port to modern platforms by numerous authors - see:

[https://gitlab.com/ryandwyer/perfect-dark](https://gitlab.com/ryandwyer/perfect-dark)
 [https://github.com/n64decomp/perfect_dark](https://github.com/n64decomp/perfect_dark)
 [https://github.com/fgsfdsfgs/perfect_dark](https://github.com/fgsfdsfgs/perfect_dark)


## Compile

```
cd src
./docker-setup.txt


# In docker image:

git clone https://github.com/libsdl-org/SDL.git
cd SDL
git checkout release-2.26.2
mkdir build && cd build
CC=clang-18 CXX=clang++-18 cmake ..
make -j8
make install
cd ../..

git clone https://github.com/fgsfdsfgs/perfect_dark.git
cd perfect_dark
mkdir build && cd build
CC=clang-18 CXX=clang++-18 cmake ..
make -j8
cd ../..


# The binary is perfect_dark/build/pd.arm64
# To retrieve it to the host:

docker cp pd-build:/perfect_dark/build/pd.arm64 .

```
