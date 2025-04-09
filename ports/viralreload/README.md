## Notes

Thanks to [Retrocade Media](https://retrocademedia.itch.io/) for creating this game. You can purchase Viral Reload at: https://retrocademedia.itch.io/viral-reload. This has been tested with the *Viral Reload Linux.zip*, Jan 26, 2022 release.

**Note** that this game takes a while to start (even on a PC).


## Controls

| Button              | Action   |
| --------------------| -------- |
| D-PAD or LEFT-STICK | Movement |
| A/X/R1/R2           | Fire     |
| B/Y/L1/L2           | Dash     |
| START               | Start    |
| SELECT              | Options  |


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

