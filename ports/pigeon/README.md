## Notes

Original version by:  
https://github.com/Escada-Games/pigeonAscent

Special thanks to: Kloptops for suggesting some fix and 
the PortMaster team for helping me test it! To conclude, 
a special thanks at Cebion for making me discover this game and obviously for porting the frt runtime.

## Controls

| Button | Action               |
| ------ | -------------------- |
| A/Y    | Mouse Click/Accept   |
| B      | Scroll Down          |
| X      | Scroll Up            |
| DPAD   | Move Cursor          |

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


