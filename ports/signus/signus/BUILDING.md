# autoconf
wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz
tar xf autoconf-2.72.tar.xz
cd autoconf-2.72
./configure
make -j8
make install
cd ..

# signus
git clone https://github.com/signus-game/signus

# vanilla
cd signus/signus


./bootstrap
./configure
make -j8
mkdir vanilla
mv src/signus vanilla/
cd ..

patch -p1 < ../../signus.patch
cd signus
make -j8
mkdir sim-cursor
mv src/signus sim-cursor/
cd ..


cd ../signus-data/
./bootstrap
./configure
make -j8
make install

# retrieve build products on host machine
docker cp signus-build:/root/signus/signus/vanilla .
docker cp signus-build:/root/signus/signus/sim-cursor .
docker cp signus-build:/usr/local/share/signus/1.96 ./data
docker cp signus-build:/root/signus/signus/etc/default_signus.ini ./data/
