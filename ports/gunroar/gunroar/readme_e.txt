Gunroar  readme.txt
for Windows98/2000/XP(OpenGL required)
ver. 0.15
(C) Kenta Cho

Guns, Guns, Guns!
360-degree gunboat shooter, 'Gunroar'.


* How to start

Unpack gr0_15.zip, and run 'gr.exe'.
Press a gun key to start a game.


* How to play

Steer a boat and sink enemy fleet.

You can select a game mode by pressing up/down keys or
a lance key at the title screen. (NORMAL / TWIN STICK / DOUBLE PLAY / REPLAY)

- Controls (NORMAL mode)

o Move
 Arrow / Num / [WASD] / [IJKL]  / Stick

o Fire guns / Hold direction
 [Z][L-Ctrl][R-Ctrl][.]         / Trigger 1, 4, 5, 8, 9, 12

 Hold a key to open automatic fire and hold the direction of a boat.
 Tap a key to take a turn while firing.

o Fire lance
 [X][L-Alt][R-Alt][L-Shift][R-Shift][/][Return] / Trigger 2, 3, 6, 7, 10, 11

 Lance is a single-shot weapon. You have to tap a key to fire a next lance.
 You can't fire a next lance while a first lance is in a screen.

- Controls (TWIN STICK mode)

It is strongly recommended to use twin analog sticks.

o Move
 [WASD]   / Stick1 (Axis 1, 2)

o Fire guns
 [IJKL]   / Stick2 (Axis 3 or 5, 4)

 You can control the concentration of guns by the analog stick.
 (If you have a problem with the direction of the stick2, try 
  '-rotatestick2' and '-reversestick2' oprtions.
  e.g. '-rotatestick2 -90 -reversestick2')
 (If you are using xbox 360 wired controller, use
  '-enableaxis5' option.)

- Controls (DOUBLE PLAY mode)

Control two boats at a time.

o Move boat1
 [WASD]   / Stick1 (Axis 1, 2)

o Move boat2
 [IJKL]   / Stick2 (Axis 3 or 5, 4)

- Controls (MOUSE mode)

Steer a ship with a keyboard or a pad, and
control a sight with a mouse.

o Move
 Arrow / Num / [WASD] / [IJKL]  / Stick

o Control sight
 Mouse

o Fire guns (narrow)
 Mouse left button

o Fire guns (wide)
 Mouse right button

- Controls(In every mode)

o Pause
 [P]

o Quit a game / Back to title
 [ESC]

- Rank multiplier

Rank multiplier (displayed in the upper right) is a bonus multiplier
that increases with a difficulty of a game.
You can increase a rank multiplier faster by going forward faster.

- Boss appearance timer

Boss appearance timer (displayed in the upper left) is a remaining time
before a boss ship appears.


* Options

These command-line options are available:

 -brightness n  Set the brightness of the screen. (n = 0 - 100, default = 100)
 -luminosity n  Set the luminous intensity. (n = 0 - 100, default = 0)
 -res x y       Set the screen resolution to (x, y). (default = 640, 480)
 -nosound       Stop the sound.
 -window        Launch the game in the window, not use the full-screen.
 -exchange      Exchange a gun key and a lance key.
 -turnspeed n   Adjust the turning speed. (n = 0 - 500, default = 100) (NORMAL mode)
 -firerear      Fire to the rear of the ship. (NORMAL mode)
 -rotatestick2 n
   Rotete the direction of the stick2 in n degrees. (TWIN STICK, DOUBLE PLAY mode)
 -reversestick2
   Reverse the direction of the stick2. (TWIN STICK, DOUBLE PLAY mode)
 -enableaxis5
   Use the input of axis 5 to fire shots.
   (for xbox 360 wired controller) (TWIN STICK, DOUBLE PLAY mode)


* Comments

If you have any comments, please mail to cs8k-cyu@asahi-net.or.jp


* Webpage

Gunroar webpage:
http://www.asahi-net.or.jp/~cs8k-cyu/windows/gr_e.html


* Acknowledgement

Gunroar is written in the D Programming Language(ver. 0.149).
 D Programming Language
 http://www.digitalmars.com/d/index.html

Simple DirectMedia Layer is used for media handling.
 Simple DirectMedia Layer
 http://www.libsdl.org

SDL_mixer and Ogg Vorbis CODEC are used for playing BGMs/SEs.
 SDL_mixer 1.2
 http://www.libsdl.org/projects/SDL_mixer/
 Vorbis.com
 http://www.vorbis.com

D Header files at D - porting are for use with OpenGL, SDL and SDL_mixer.
 D - porting
 http://shinh.skr.jp/d/porting.html

Mersenne Twister is used for creating a random number.
 Mersenne Twister: A random number generator (since 1997/10)
 http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html


* History

2006  3/18  ver. 0.15
            Added '-enableaxis5' option. (for xbox 360 wired controller)
2005  9/11  ver. 0.14
            Added mouse mode.
            Changed a drawing method of a game field.
            Fixed a problem with a score reel size in a double play mode.
            Increased the number of smoke particles.
2005  7/17  ver. 0.13
            Added double play mode.
2005  7/16  ver. 0.12
            Added '-rotatestick2' and '-reversestick2' options.
            Fixed a BGM problem in the replay mode.
2005  7/ 3  ver. 0.11
            Added twin stick mode.
            Added '-turnspeed' and '-firerear' options.
            Adjusted a position a scrolling starts.
            A score reel becomes small when a ship is in the bottom right.
            Added a field color changing feature.
2005  6/18  ver. 0.1
            First released version.


* License

License
-------

Copyright 2005 Kenta Cho. All rights reserved. 

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
