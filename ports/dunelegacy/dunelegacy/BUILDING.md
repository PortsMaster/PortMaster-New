git clone https://git.code.sf.net/p/dunelegacy/code dunelegacy-code
cd dunelegacy-code

# vanilla (rocknix only)
patch -p1 < ../dunelegacy.flicker.patch
patch -p1 < ../dunelegacy.path.patch

autoreconf -fi
./configure
make -j8
make install
make clean

# sim cursor
patch -p1 < ../dunelegacy.cursor.patch
autoreconf -fi
./configure
make -j8

# retrieve build products on host machine
docker cp dune2-build:/usr/local/share/dunelegacy ./data

mkdir vanilla
docker cp dune2-build:/usr/local/bin/dunelegacy ./vanilla
mkdir sim-cursor
docker cp dune2-build:/root/dunelegacy-code/src/dunelegacy ./sim-cursor
