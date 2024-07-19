## Notes

All files included and ready to run. Thanks to [Taylor Ritenour]( https://taylorritenour.itch.io/hebi-hebi) for the fantastic game and permission to distribute the files.


## Controls

| Button  | Action                     |
| ------- | -------------------------- |
| D-PAD   | Direction/movement         |
| START   | Enter/proceed              |
| A/B     | Undo                       |
| X/Y     | Navigate back through menu |
| R1      | Pause                      |


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

