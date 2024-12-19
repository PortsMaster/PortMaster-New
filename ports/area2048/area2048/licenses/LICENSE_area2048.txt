AREA2048  readme_e.txt
for Windows98/2000/XP(OpenGL required)
ver. 1.0
(C) HELLO WORLD PROJECT

On all sides eight that absolute siege.
All direction shooting "AREA2048".


- How to install.

Unpack a2k.zip, and execute 'a2k.exe'.


- How to play.

 - TYPE 1 -
 - Movement  Arrow/Num key
 - Shot      [Z]
 - Wide SHot [X]
 - Pause     [P]

 - TYPE 2 -
 - Movement  'WASD'/Num key
 - Shot      back slash
 - Wide SHot right shift
 - Pause     [P]

 - TYPE 3 -
 - Movement  Arrow/Num key
 - Shot      left shift
 - Wide SHot left ctrl
 - Pause     [P]

 - TYPE 4 -
 - Movement  Arrow/Num key
 - Shot      space
 - Wide SHot left alt
 - Pause     [P]

 - Movement  Joystick
 - Shot      Trigger 1
 - Wide SHot Trigger 2
 - Pause     Trigger 3

It will be a scene clearance if all the enemies that are in a scene are
destroyed.
A self-opportunity will be destroyed if enemy shells and an enemy main
part are contacted.
It is an area clearance when 10 scene clearance is carried out.
It is a game clearance when five area is cleared.
If all area clearances cannot be carried out in the time limit, regardless of
left, it becomes game over.


- Comments

If you have any comments, please mail to ads00721@nifty.com


- Webpage

http://homepage2.nifty.com/isshiki/prog_win_d.html


- Acknowledgement

AREA2048 is written in the D Programming Language.
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

2008  2/12  ver  1.03  2 types of key assign added.

2005  1/17  ver  1.02  voice data update.
                       compile for dmd ver 0.110
                       The demonstration play was mounted. 
                       It was made not to lock to the enemy in the state without
                       the hit judgment. 

2005  1/ 9  ver  1.01  I supply a voice than Andrew Walker.

2004  9/15  ver. 1.0


-- License

License
-------

Copyright 2004 HELLO WORLD PROJECT (Jumpei Isshiki). All rights reserved. 

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
