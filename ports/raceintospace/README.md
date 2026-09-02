## Notes

Thanks to the [Race into Space team](https://github.com/raceintospace/raceintospace) for keeping this free software recreation of Interplay's *Buzz Aldrin's Race into Space* alive, a deep turn-based strategy game where you run the US or Soviet space program head-to-head in the race to land on the Moon.

## Controls

| Button | Action |
|--|--|
| Left Analog | Move mouse cursor |
| A | Left click |
| B | Enter (confirm) |
| X | Slow mouse (precision aiming) |
| D-Pad | Arrow keys (menu navigation) |
| Start | Enter (confirm) |
| Back | Escape (cancel/back) |
| L2 | Toggle on-screen keyboard (for save/player name entry) |
| R1 | Cycle keyboard charset (while on-screen keyboard is open) |

## Compile

Install build dependencies:

    sudo apt-get install cmake libsdl1.2-dev libboost-dev libboost-test-dev libpng-dev libjsoncpp-dev libogg-dev libvorbis-dev libtheora-dev libphysfs-dev libcereal-dev

Clone and build:

    git clone --recurse-submodules https://github.com/raceintospace/raceintospace.git
    cd raceintospace
    cmake --preset linux-release -DPBEM=OFF -DCMAKE_C_FLAGS=-fsigned-char -DCMAKE_CXX_FLAGS=-fsigned-char
    cmake --build --preset linux-release

`-fsigned-char` is required on AArch64: plain `char` is unsigned by default there (signed on x86_64), and
several `cereal`-serialized struct fields (e.g. `mStr::Alt`/`PCat` in `src/game/data.h`, loaded from
`data/gamedata/mission.json`) hold negative values, which crashes with a RapidJSON `GetUint()` assertion
failure on the very first mission-data read without this flag.
