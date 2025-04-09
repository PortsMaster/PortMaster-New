## Notes

Tested using *windows.zip* version. Thanks to slimewitch (https://slimewitch.itch.io) for creating this fantastic free game.


## Controls

| Button | Action               |
| ------ | -------------------- |
| DPAD   | Directional movement |
| A/B    | Jump                 |


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.5.2/godot-3.5.2-stable.tar.xz  
tar xf godot-3.5.2-stable.tar.xz  
cd godot-3.5.2-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```

