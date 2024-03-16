## Notes

Tested using *cropsmare-linux.zip* version 4 (Oct 28, 2023). Thanks to mrkdji (https://mrkdji.itch.io/) for creating this fantastic game, available for purchase at https://mrkdji.itch.io/cropsmare


## Controls

| Button   | Action                    |
| -------- | ------------------------- |
| DPAD     | Directional movement      |
| A        | Plast seed / use item     |
| B        | Cancel selection          |
| HOLD X+C | Restart level             |
| Select   | Skip level                |
| Start    | Pause / open options menu |


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.5.3/godot-3.5.3-stable.tar.xz  
tar xf godot-3.5.3-stable.tar.xz  
cd godot-3.5.3-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```

