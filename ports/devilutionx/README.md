## Notes

Copy diabdat.mpq from your CD or GoG installation (or extract it from the GoG installer) into /roms/ports/devilution folder. 

Do not delete the gamecontrollerdb.txt file in the /roms/ports/devilution folder or there will be no controller support in the game! For controls, see here

If you experience issues after a version upgrade, backup your save file and uninstall/reinstall the port.

If you make a config change that crashes the game, you can delete the ini file to get the game back to a good state

Thanks to the [diasurgical](https://github.com/diasurgical/devilutionX) team for the source port that makes this possible.


```sh
# Instructions adapted from https://github.com/christianhaitian/rk3326_core_builds/blob/03467ea85acaa9bde9255a74a317a0bd7a6ad501/scripts/devilutionx.sh

DEVILUTION_VERSION="1.5.2"

wget https://github.com/diasurgical/devilutionX/releases/download/$DEVILUTION_VERSION/devilutionx-src.tar.xz

tar -xf devilutionx-src.tar.xz

cd "devilutionx-src-$DEVILUTION_VERSION"

cmake -Bbuild -DCMAKE_BUILD_TYPE="Release" -DDISABLE_ZERO_TIER=ON -DBUILD_TESTING=OFF -DBUILD_ASSETS_MPQ=OFF -DDEBUG=OFF -DPREFILL_PLAYER_NAME=ON

cmake --build build -j4

# Output files here:
cp build/devilution "destionation_path/devilution"
cp -r build/assets/ "destionation_path/assets"

```


