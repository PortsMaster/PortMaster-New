## Notes

Thanks to [Azaan Lambkin](https://taylorritenour.itch.io) for creating this game and making it available for free!


## Controls

| Button | Action             |
| ------ | -------------------|
| D-PAD  | Direction/movement |
| A/B    | Jump               |
| R1     | Restart level      |
| SELECT | Pause              |
| START  | Enter/proceed      |


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

