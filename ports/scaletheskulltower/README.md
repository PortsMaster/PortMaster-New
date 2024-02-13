## Notes

Tested using *Scale the Skull Tower JAM VERSION (LINUX).zip* version. Thanks to cortok (https://cortok.itch.io/) for creating this fantastic free game.


## Controls

| Button | Action               |
| ------ | -------------------- |
| DPAD   | Directional movement |
| A      | Sword                |
| B      | Jump                 |
| Start  | Start                |


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.2.3/godot-3.2.3-stable.tar.xz  
tar xf godot-3.2.3-stable.tar.xz  
cd godot-3.2.3-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```

