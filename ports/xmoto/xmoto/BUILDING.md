git clone https://github.com/xmoto/xmoto
cd xmoto
git checkout v0.6.2
patch -p1 < ../xmoto.patch
patch -p1 < ../xmoto.profile.patch

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release ..
make -j8

make install

cd ../..

# Retrieve build products on host machine
docker cp xmoto-build:/usr/local/bin/xmoto .
mkdir share
docker cp xmoto-build:/usr/local/share/xmoto ./share/
