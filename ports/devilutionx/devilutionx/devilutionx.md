## Notes

Copy `DIABDAT.MPQ` from your CD or GOG installation, or extract it from the GOG installer, into `/roms/ports/devilutionx/`.

To run the Diablo: Hellfire expansion, also copy `hellfire.mpq`, `hfmonk.mpq`, `hfmusic.mpq`, and `hfvoice.mpq` into `/roms/ports/devilutionx/`.

Some locales require extra assets. For example, `zh_CN` and `zh_TW` require `fonts.mpq` from the official [devilutionx-assets releases](https://github.com/diasurgical/devilutionx-assets/releases). Without this file, DevilutionX exits with a missing fonts error.

The port uses DevilutionX SDL controller support for gameplay. The included `devilutionx.gptk` file leaves gameplay controls unassigned in gptokeyb, while keeping the PortMaster Start+Select kill switch available if the game freezes. Do not delete the `gamecontrollerdb.txt` file in `/roms/ports/devilutionx/` if it is present, or there will be no controller support in the game.

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
