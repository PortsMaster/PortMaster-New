# ubuntu 20.04
# apt install libsdl2-dev libfreetype-dev
# update cmake

git clone https://github.com/elasota/Aerofoil
cd Aerofoil
patch -p1 < aerofoil.patch
mkdir build
cd build
cmake -DCMAKE_EXE_LINKER_FLAGS=-Wl,--copy-dt-needed-entries ..
make -j8

# retrieve build products
docker cp aerofoil-build:/Aerofoil/build/AerofoilX .
docker cp aerofoil-build:/Aerofoil/build/Packaged .

