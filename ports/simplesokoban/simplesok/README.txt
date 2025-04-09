Simple Sokoban

Simple Sokoban is a (simple) Sokoban game aimed at playability and portability
across systems. It is written in ANSI C89, using SDL2 for user interactions.
I developed it primarily for Linux, but it should compile and work just fine
on virtually anything that has a C compiler and supports SDL2. A Windows build
is provided for Linux-deficient gamers.

 Features:
  - animated movements,
  - unlimited level solutions,
  - unlimited undos,
  - 3 embedded level sets,
  - support for external *.xsb levels (possibly RLE compressed),
  - support for levels of size up to 62x62,
  - copying levels to clipboard,
  - save/load,
  - skins supports,
  - ...

URL: http://simplesok.osdn.io/


CONTROLS
========

dpad/left joystick = movement

Start = Select/Confirm
Select = ESC

A button = Select/Confirm
B button = Undo move
Y button = Show solution if available
X button = Reset levels

Right joystick up = Zoom in
Right joystick down = Zoom out

L1/L2 = Load level state
R1/R2 = Save level state