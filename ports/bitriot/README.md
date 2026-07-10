## Notes

Thanks to [VenKamikaze](https://github.com/VenKamikaze/BitRiot) for porting this game to SDL2 

## Controls

| Key | Action |
|--|--|
| W | Up |
| S | Down |
| A | Left |
| D | Right |
| Left Ctrl | Use Weapon |
| Left Shift | Lay Egg |

## Compile

```shell
git clone --recurse-submodules https://github.com/VenKamikaze/BitRiot.git
cd BitRiot
cd ext/RmlUi/RmlUi                                                                                                                                           mkdir Build && cd Build
  cmake .. -DBUILD_LUA_BINDINGS=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_SAMPLES=OFF -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release
  make 
  cp libRmlCore.a ../../lib/
  cp libRmlDebugger.a ../../lib/

  cd BitRiot/
  mkdir build && cd build
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make
```