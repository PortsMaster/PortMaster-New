## Notes

Thanks to rafalkowalski for creating this game. This game is available free at https://rafalkowalski.itch.io/pyk

Tested using *Pyk_1.0.zip* (Windows) version.


## Controls

| Button           | Action               |
| ---------------- | -------------------- |
| D-PAD/LEFT-STICK | Directional movement |
| A/START          | Enter                |
| SELECT           | M (for Menu)         |


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

