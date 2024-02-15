The legend of Lumina (https://wizbane.itch.io/the-legend-of-lumina)
===========

Original version by:  
https://wizbane.itch.io/the-legend-of-lumina (linux V1.2.3.zip)

Description
===========

Explore an ancient forest, push blocks to solve puzzles, and search for a way to end the curse on your land..

To compile:
===========

wget https://downloads.tuxfamily.org/godotengine/3.5.2/godot-3.5.2-stable.tar.xz  
tar xf godot-3.5.2-stable.tar.xz  
cd godot-3.5.2-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm

Controls:
===========

DPAD    = Directional movement
SELECT  = Open menu
B       = Undo
A       = Interact