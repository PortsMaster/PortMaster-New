  -- Wizznic! --
 - An implementation of the arcade classic Puzznic,
   for Gp2X Wiz, Linux and Windows.

-- Index --
1.0 Wizznic Info and License
1.0.1 Unofficial ports.
1.0.2 How to install/compile
1.0.3 Running Wizznic! Command line parameters
1.0.4 How to use OpenGL scaling
1.1 Objective
1.2 Controls and Keys
1.3 How do I clear the highscore?

2.0 User created content
2.0.1 How to make new levels
2.0.2 How to make a pack
2.2 How to submit my level for inclusion into the official game ?
2.3 How to make new themes
2.4 Sound files needed!

3.0 Contributors and Credits

4.0 Frequently Asked Questions (FAQ)

------------------------------------

1.0 Wizznic Info
Author: Jimmy Christensen
Web site: http://wizznic.org/

License:
Code, Graphics, Levels are GPLv3
See data/media-licenses.txt for soundfiles (GPLv3)

Wizznic is my hobby project, I'm using it to learn C and SDL,
don't flame me for my ugly code, if you don't like it, dont
read it.. :)

------------------------------------

1.0.1 Unofficial Ports
There are several high quality ports of wizznic for other platforms
than the ones officially supported ( GP2XWiz / Linux / Windows ),
I'm listing the ones that I know of (please tell me about if if you're
doing a port and it's not allready on the list).
The list is kept in docs/ports.txt
Please note that I can not give you any support or advice on those
ports, since I'm not in contact with the porters, and even then,
please contact the porter with any issues regarding unofficial ports.

------------------------------------

1.0.2 How to install/compile
Please refer to the docs/install.txt file for info on how
to compile and/or install wizznic.

------------------------------------

1.0.3 Running Wizznic! Command line parameters
The Linux and Windows versions of wizznic takes the following command line
parameters:

Wizznic saves -sw -glwidth/height -f -w and -glfilter options when it is called with
any of those parameters, if you happen to choose something that's not working,
simply call wizznic again with some other options that you suspect will.

  -f     Start in fullscreen.
  -w     Start in windowed mode.
  -z 2   Software scale to 640x480 (320*2x240*2) (More CPU intensive than OpenGL).

If Wizznic is compiled with OpenGL scaling support, these parameters are available:
  -sw Disable OpenGL scaling, use this if you have trouble with OpenGL scaling.
  -gl Enable OpenGL scaling.
  -glwidth  W Enable OpenGL scaling and set width-resolution to W pixels, (use -1 for auto detection).
  -glheight H Enable OpenGL scaling and set height-resolution to H pixels, (use -1 for auto detection).
  -glfilter X (OpenGL Only) 0=Sharp/Pixelated, 1=Smooth/Soft.

This one is useful for level-creators:
  -d PACKNAME Dumps tga screenshots of each level in that pack.
     Use the tools/updatelevelpreviews.sh script for this, it will also cut
     the screenshots to size. This parameter must stand alone with it's argument,
     no other arguments are allowed at the same time.

------------------------------------

1.1 Objective
As the original game, your mission is to clear the level of
bricks, this is done by moving the bricks about, when two or
more bricks of the same kind are next to each other, or on top
of eachother, they will disappear and points will be given.
The level has to be cleared of bricks before the time runs out,
or you will lose a life.

------------------------------------

1.2 Controls and keys
On the Wiz:
D-Pad  - Navigate menus, move cursor about.
B      - Select item in menu, select brick.
SELECT - Reset level (you have infinite retries, but time won't be reset)
MENU   - Pauses the game and displays the menu.
Vol    - Adjust volume, the setting is saved.

On the Pc:
Arrows - Navigate menus, move cursor.
Ctrl   - Select item in menu, select brick.
Space  - Reset level.
Escape - Pauses the game and displays the menu.

------------------------------------
1.3 How do I clear the highscore/Progress?
Delete the .hig file in the player directory.
For instance, if you want to clear highscore/progress
for the "wizznic" pack, delete highscore/wizznic.hig

------------------------------------

2.0 User created content
There are many things that you can create for the game..
Graphics - Backgroundimages, Tile sets, Fonts, etc.
Sound    - Music, Sound Sets
Levels   - Puzzles, those are really important ;)
Packs    - A collection of graphics, sounds and levels..

2.0.1 Creating a level
To create a level, select the level-editor in the menu, the controls for the
level-editor are written in the top of the screen. Your levels are saved to the
directory called "editorlevels"
When you've made some levels, you can open them in a text-editor (like notepad/kate/nano/vi/emacs)
and edit the properties to your liking.
If you're making a lot of levels, it might be helpful for you to edit the
properties in the data/empty.wzp file (also just open with a text-editor)
If you're wondering what all the properties does, or how to use them, check out wizznic/data/empty.wzp,
there you will find comments and instructions on all properties a level can have.

2.0.2 Creating a pack
A pack contains a collection of levels, and (optionally) graphics and sounds.
The easiest way to create a pack containing graphics, is to copy the "packs/wizznic"
dir, and call it something else, like "myawesomepack" and then edit the "packs/myawesomepack/info.ini"
and then edit the other files in the pack, like replacing the levels with your own ones
and drawing some new graphics..
It's not nessicary to create all the graphics..
For example, if you don't want to replace the cursor, simply delete the file from
your pack, then the game will just use the default one from "packs/wizznic" instead.
The same is also true for sound files.

------------------------------------
2.2 How to contribute?
So you've made a level, or a pack ? Cool!
I'd love to bundle your stuff with the game (as long as you're not stealing copyrighted stuff)..
So, to get your stuff included in the downloadable contents section, or in the main release of the game:
Simply go to this address:
https://sourceforge.net/tracker/?func=add&group_id=286702&atid=1216626
Create a tracker item and attach your stuff to it!

Thank you! :)

------------------------------------
2.3 How to make new themes
A theme consists of two parts: Background-images, and Tiles/Animations.
Levelfiles can request a background-image from theme Zebra, and use the Tiles/Animations from theme Giraffe.

Background-Images:
Background images are the simplest part of a theme, just create a 320x240 image, with your graphics, use an
existing board as a template, or use the template.png from the srcgfx folder.
You're done, now all you need is to submit your awesome background, and hope somebody will use it (I will!)
oh, you want to create some bricks that match it? Read on..

Tiles/Animations:
Main file: themename.png
There are two required files nessicary to make a functioning brick-set, that's the "themename.png" and
"themename-expl0.png" files.
"themename" is the name of your theme, for example "wood.png" could be the image with the main tileset
then the themename would be "wood", thus, the animation for dissapearing bricks, would be "wood-expl0.png"
and so forth. (there can be one animation for each type of bricks, if there is not, then the -expl0.png one is used)

Inside of the "themename.png" file, the tiles are in this order:
1-10 : The bricks that are moved around.
11: Up/Down transporter
12: Left/Right transporter
13: One way only, (bricks are pushed left)
14: One way only, (bricks are pushed right)
15: Magnet, brick sticks and can't be moved.
16: A floating wall (no neighbour walls) (If there are no themename-walls.png file, then this is used for all wall tiles)
17: This brick is reserved, and never shown in the game (but it's sometimes used for debugging, can be left blank)
18: Teleport-Source, any brick that enters this will be transported to some destination (there's no graphics for the destination tile)

The color Cyan ( 00FFFF in html notation ) is transperant.

Explosion file: themename-expl0.png
This is the explosion/destruct animation for the first brick (if this is the only file, then it will be used
for all bricks when they are destroyed), there are 16 frames in the file, after frame 8, the brick will no
longer be rendered. (the last 8 frames are rendered too), so if you want to make something that "covers" the brick,
use the first 8 frames for that.

Extra-Walls File: themename-walls.png
If you called your main theme file giraffe.png then your wall file have to be called giraffe-walls.png
You don't have to create this file, but if you do, it's simly some more wall-pieces.

2.4 Sound files needed!
I'm really awful at sound-work (worse than at coding or doing gfx, wow!!:P) so please, if you have the skills
and want to help me out, please have a look at the files in data/snd/ many of them are just a template "click" sound
and could be much better... If you make a sound-theme, I'm pretty sure it will be better than what I've got, and
I'll be happy to use your theme as the default sound-theme :)

------------------------------------

4.0 Contributors and Credits
  See doc/credits.txt

------------------------------------
