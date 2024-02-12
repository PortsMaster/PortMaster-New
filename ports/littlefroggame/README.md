## Notes

Thanks to Jamphibious for creating this game. This game is free but the developer accepts your support by letting you pay what you think is fair for the game https://jamphibious.itch.io/little-frog-game

Tested using *Little Frog Game (Linux - FrogCon Update).zip* version, but Windows version will likely work fine, too.


## Controls

| Button | Action               |
| ------ | -------------------- |
| DPAD   | Directional movement |
| B      | Jump                 |
| A/Y    | Shoot                |


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.4.5/godot-3.4.5-stable.tar.xz  
tar xf godot-3.4.5-stable.tar.xz  
cd godot-3.4.5-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```

