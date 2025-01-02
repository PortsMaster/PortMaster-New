PARSEC47  readme_e.txt
for Windows98/2000/XP(OpenGL required)
ver. 0.2
(C) Kenta Cho

Defeat retro enemies modenly.
Retromodern hispeed shmup, 'PARSEC47'.


- How to install.

Unpack p47_0_2.zip, and execute 'p47.exe'.
(If the game is too heavy for your PC, please try 'p47_lowres.bat'.
 This batch file launches the game in the low resolution mode.)


- How to play.

 - Movement          Arrow/Num key       / Joystick
 - Shot              [Z][L-Ctrl]         / Trigger 1, 4, 5, 8
 - Slow / Roll, Lock [X][L-Alt][L-Shift] / Trigger 2, 3, 6, 7
 - Pause             [P]

Select the stage by a keyboard or a joystick.
Press a shot key to start the game.
All stages are endless and created randomly each time.
The game continues until you lose all ships.

Control your ship and destroy enemies.
While holding a slow key, the ship becomes slow.

You can also select the game mode from 2 types.
Press a slow key in the title screen to change the game mode.
Each mode has a different barrage pattern.

. Roll mode
Hold a slow key to charge the roll shot energy.
The roll shot is fired when you release the key.

. Lock mode
While holding a slow key, you can shot the lock-on laser
that aims an enemy in the front of your ship.

The ship extends 200,000 and every 500,000 points.

These options are available:
 -brightness n  Set the brightness of the screen.(n = 0 - 100, default = 100)
 -luminous n    Set the luminous intensity.(n = 0 - 100, default = 0)
 -lowres        Use the low resolution mode.
 -nosound       Stop the sound.
 -window        Launch the game in the window, not use the full-screen.
 -reverse       Reverse the shot key and the slow key.
 -slowship      Use the slow speed ship in all game modes.
 -nowait        Disable the intentional slowdown.


- Comments

If you have any comments, please mail to cs8k-cyu@asahi-net.or.jp


- Webpage

PARSEC47 webpage:
http://www.asahi-net.or.jp/~cs8k-cyu/windows/p47_e.html


- Acknowledgement

PARSEC47 is written in the D Programming Language.
 D Programming Language
 http://www.digitalmars.com/d/index.html

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

Using D Header files at DedicateD for OpgnGL and SDL, and 
at D - porting for SDL_mixer.
 DedicateD
 http://int19h.tamb.ru/files.html
 D - porting
 http://user.ecc.u-tokyo.ac.jp/~s31552/wp/d/porting.html

Mersenne Twister to create the random number.
 http://www.math.keio.ac.jp/matumoto/emt.html


- History

2004  1/ 1  ver. 0.2
            Add the lock mode.
            Adjust barrages.
            Fix the bullets' disappearance bug.
2003 12/21  ver. 0.13
            Add the '-slowship' option.
            A slow bullet disappears after a while.
            Fix the screen resize bug.
2003 12/ 5  ver. 0.12
            Adjust the enemies' appearance position.
            Adjust barrages.
2003 11/30  ver. 0.11
            Fix the incorrect line draw function.
            Adjust the size of the field.
            Adjust barrages.
            The roll shot power weaken.
2003 11/29  ver. 0.1


-- License

License
-------

Copyright 2003 Kenta Cho. All rights reserved. 

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
