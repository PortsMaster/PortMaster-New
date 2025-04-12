Noiz2sa  readme_e.txt
for Windows98/2000/XP
ver. 0.52
(C) Kenta Cho

Abstract shootem up game, 'Noiz2sa'.


- How to install.

Unpack noiz2sa0_52.zip, and execute 'noiz2sa.exe'.


- How to play.

Select the stage by a keyboard or a joystick.

 - Movement  Arrow key / Joystick
 - Fire      [Z]       / Trigger 1, Trigger 4
 - Slowdown  [X]       / Trigger 2, Trigger 3
 - Pause     [P]

Press a fire key to start the game.

Control your ship and avoid the barrage.
A ship is not destroyed even if it contacts an enemy main body.
A ship becomes slow while holding the slowdown key.

A green star is the bonus item.
A score of the item(displayed at the left-up corner) increases 
if you get items continuously.

When all ships are destroyed, the game is over.
The ship extends 200,000 and every 500,000 points.

These command line options are available:
 -nosound       Stop the sound.
 -window        Launch the game in the window, not use the full-screen.
 -reverse       Reverse the fire key and the slowdown key.
 -brightness n  Set the brightness of the sceen(n=0-256).
 -accframe      Use the alternative framerate management algorithm.
                (If you have a problem with framerate, try this option.)

- Add your original barrage patterns.

You can add your own barrage patterns to Noiz2sa.
In the 'noiz2sa' directory, there are 3 directories named
'zako', 'middle' and 'boss'.
In these directories, the barrage pattern files are placed.

The barrage pattern files are written by BulletML.
About BulletML, see the page:

BulletML
http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html

A 'zako' directory is for the small enemies.
A 'middle' directory is for the middle class enemies.
A 'boss' directory is for the boss type enemies.

You should adjust the difficulty of the barrage
by using a $rank variable properly.
A $rank variable is used to control the difficulty
of each scene in Noiz2sa.


- Comments

If you have any comments, please mail to cs8k-cyu@asahi-net.or.jp.


- Acknowledgement

libBulletML is used to parse BulletML files.
 libBulletML
 http://user.ecc.u-tokyo.ac.jp/~s31552/wp/libbulletml/
 
Simple DirectMedia Layer is used for the display handling. 
 Simple DirectMedia Layer
 http://www.libsdl.org/

SDL_mixer and Ogg Vorbis CODEC to play BGM/SE. 
 SDL_mixer 1.2
 http://www.libsdl.org/projects/SDL_mixer/
 Vorbis.com
 http://www.vorbis.com/


- History

2019  3/ 1  ver. 0.52
            Update SDL.dll.
2003  8/10  ver. 0.51
            Update libBulletML.
2003  2/12  ver. 0.5
            Add the accframe option.
            Add new barrages.
2003  1/ 3  ver. 0.42
            Adjust barrages.
2003  1/ 3  ver. 0.41
            Adjust barrages.
2002 12/31  ver. 0.4
            Add an endless insane mode.
            Add new barrages.
2002 11/23  ver. 0.32
            Adjust an invincible time.
2002 11/ 9  ver. 0.31
            Adjust the limits of movement of the ship.
            Add the brightness option.
2002 11/ 3  ver. 0.3


-- License

License
-------

Copyright 2002 Kenta Cho. All rights reserved. 

Redistribution and use in source and binary forms, 
with or without modification, are permitted provided that 
the following conditions are met: 

 1. Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer. 

 2. Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
