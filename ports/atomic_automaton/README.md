## Notes

Thanks to Pedro Fernandes, Gabriel Almeida, and [CLIIMA](https://linktr.ee/cliima_lx) for creating this game in Godot. This is my first time using Portmaster.

[Link itch.io](https://baratasoftware.itch.io/atomicautomaton)

## Description
The player must face endless waves of enemies, as long as possible in a challenging, action-packed environment.

## To compile:

wget https://downloads.tuxfamily.org/godotengine/3.5.2/godot-3.5.2-stable.tar.xz
tar xf godot-3.5.2-stable.tar.xz
cd godot-3.5.2-stable/platform
git clone https://github.com/Cebion/frt.git
cd ../
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12
strip bin/godot.frt.opt.llvm



## Controls
| Button | Action |
|--|--|
| Left-Analog | Movement |
| Right-Analog | Fire |
