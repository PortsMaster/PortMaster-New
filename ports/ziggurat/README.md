## Notes

Thanks to nethead for creating this game. This game is available free at https://nethead.itch.io/ziggurat

Tested using *Ziggurat-Linux.zip* version, but Windows version will likely work fine, too.


## Controls

| Button | Action               |
| ------ | -------------------- |
| DPAD   | Directional movement |
| UP/B   | Jump                 |
| DOWN/A | Use door             |
| SELECT | Display controls     |


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

