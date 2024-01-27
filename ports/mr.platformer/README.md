Mr. Platformer (https://terrycavanagh.itch.io/mr-platformer)
===========

Original version by:  
https://terrycavanagh.itch.io/mr-platformer (bespoke 4.1.3 release for this port)

Description
===========

Run! Jump? Swim?! Mr. Platformer can do it all! Game files are already included and ready to go. Many thanks to Terry Cavanagh for the 4.1.3 version and permission to distribute the game files.

To compile:
===========

wget https://downloads.tuxfamily.org/godotengine/4.1.3/godot-4.1.3-stable.tar.xz  
tar xf godot-4.1.3-stable.tar.xz  
cd godot-4.1.3-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm

Controls:
===========

DPAD        = Movement  
A/B         = Jump  
R1          = Quick restart

