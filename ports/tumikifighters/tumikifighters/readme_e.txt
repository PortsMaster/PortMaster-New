TUMIKI Fighters  readme_e.txt
for Windows98/2000/XP(OpenGL required)
ver. 0.2
(C) Kenta Cho

Stick more enemies and become much stronger. 
Sticky 2D shooter, 'TUMIKI Fighters'.


- How to install.

Unpack tf0_2.zip, and execute 'tf.exe'.
(If the game is too heavy for your PC, please try 'tf_lowres.bat'.
 This batch file launches the game in the low resolution mode.)


- How to play.

 - Movement     Arrow / Num / [WASD]   / Joystick
 - Shot         [Z][L-Ctrl][.]         / Trigger 1, 4, 5, 8
 - Slow/Pull in [X][L-Alt][L-Shift][/] / Trigger 2, 3, 6, 7
 - Pause        [P]

At the title screen, push a shot key to start the game.

Control your ship and destroy enemies.
You can catch the enemy's broken piece.
Pieces are stuck to your ship and counterattack to enemies.
You can earn the bonus score by keeping many pieces stuck.
Stuck pieces are destroyed when they touch a enemy's bullet.

While holding a slow key, the ship becomes slow and 
the ship direction is fixed.
Stuck pieces are pulled in and you can prevent a crash of them, 
but the bonus score reduces to one fifth.
Enemy's pieces are not stuck while holding this key.

If you stick many pieces, enemies become more offensive and
tend to fire more bullets.

The ship is destroyed when it is hit by a bullet.
The body of the enemy has no collision damage.

The ship extends at 200,000 and every 500,000 points.

These options are available:
 -brightness n  Set the brightness of the screen.(n = 0 - 100, default = 100)
 -res x y       Set ths screen resolution to (x, y).
 -nosound       Stop the sound.
 -window        Launch the game in the window, not use the full-screen.
 -reverse       Reverse the shot key and the slow key.


- Comments

If you have any comments, please mail to cs8k-cyu@asahi-net.or.jp


- Webpage

TUMIKI Fighters webpage:
http://www.asahi-net.or.jp/~cs8k-cyu/windows/tf_e.html


- Acknowledgement

TUMIKI Fighters is written in the D Programming Language.
 D Programming Language
 http://www.digitalmars.com/d/index.html

libBulletML is used to parse BulletML files.
 libBulletML
 http://user.ecc.u-tokyo.ac.jp/~s31552/wp/libbulletml/index_en.html
 
Simple DirectMedia Layer is used for the display handling. 
 Simple DirectMedia Layer
 http://www.libsdl.org/

SDL_mixer and Ogg Vorbis CODEC to play BGM/SE. 
 SDL_mixer 1.2
 http://www.libsdl.org/projects/SDL_mixer/
 Vorbis.com
 http://www.vorbis.com/

Using D Header files at D - porting for OpgnGL, SDL and SDL_mixer.
 D - porting
 http://user.ecc.u-tokyo.ac.jp/~s31552/wp/d/porting.html

Mersenne Twister to create the random number.
 http://www.math.keio.ac.jp/matumoto/emt.html


- History

2004  5/15  ver. 0.2
            Add the pull in feature.
            Add the rank feature that increases
             corresponding to the total size of pieces.
            The range of stuck pieces destruction are limited to 
             where the enemy bullet hits.
            Stuck pieces fly in around when the ship is destroyed.
            Adjust the barrage of enemies.
            Fix the problem that the ship destroyed at the stage end scene.
2004  4/11  ver. 0.11
            Fix the problem broken pieces stick in midair.
            Fix problems with messages.
            Add the continue feature.
2004  4/ 3  ver. 0.1
            First released version.


-- License

License
-------

Copyright 2004 Kenta Cho. All rights reserved. 

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
