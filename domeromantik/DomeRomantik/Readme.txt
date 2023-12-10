Dome romantik Portmaster Release (https://github.com/christianhaitian/PortMaster) 
=========================

Original version by:
	https://bippinbits.itch.io/dome-romantik

Portmaster Version: 	

- tekkenfede https://github.com/Tekkenfede/PortMaster
	
Special thanks to: A heartfelt thank you goes out to René from Bippinbits for granting authorization for this port and its distribution. And obviously a big thanks at the portmaster team for testing it.

To compile:
===========

wget https://downloads.tuxfamily.org/godotengine/3.5.2/godot-3.5.2-stable.tar.xz
tar xf godot-3.5.2-stable.tar.xz
cd godot-3.5.2-stable/platform
git clone https://github.com/Cebion/frt.git
cd ../
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12
strip bin/godot.frt.opt.llvm

Instructions:
=============

To run the game start Domeromantik.sh from your ports folder.


Controls:
=============

A/B/X/Y	     = Collect/OK
Dpad-RAnalog = Move cursor
LAnalog      = Move
R1 = Mouse click
L1 = Hide Mouse