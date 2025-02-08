## Building notes

This is a 64-bit ARM build of the decompilation and port to modern platforms by numerous authors - see:

[https://gitlab.com/ryandwyer/perfect-dark](https://gitlab.com/ryandwyer/perfect-dark)
 [https://github.com/n64decomp/perfect_dark](https://github.com/n64decomp/perfect_dark)
 [https://github.com/fgsfdsfgs/perfect_dark](https://github.com/fgsfdsfgs/perfect_dark)


## Compile

```
# Ubuntu 24.04 focal aarch64, with libsdl-dev installed
# 24.04 was used because the port does not work on ArkOS, and performance
# may be better.

cd src
./docker-setup.txt


# In docker image:

git clone https://github.com/fgsfdsfgs/perfect_dark.git
cd perfect_dark
cmake -G'Unix Makefiles' -Bbuild .
cd build
make

# The binary is perfect_dark/build/pd.arm64
# To retrieve it to the host:

docker cp perfectdark-build:/perfect_dark/build/pd.arm64 .

```
