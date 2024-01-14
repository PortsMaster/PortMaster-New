LBreakoutHD

LBreakoutHD is a scaleable 16:9 remake of LBreakout2. You try to clear levels full of different types of bricks and extras by using your paddle to aim balls at the bricks.


Developer: Michael Speck
URL: https://lgames.sourceforge.io/LBreakoutHD/
Lbreakout2 levels available at https://sourceforge.net/projects/lgames/files/add-ons/lbreakout2/


CONTROLS
========

Start = Enter
Select = Back/Esc
Start + Select = Exit

Dpad and left stick = move left/right

A = Enter/Yes
B = No/Launch ball
X = Paddle Turbo
Y = Ball Turbo

l1/l2 = Left fire
r1/r2 = right fire







ToC
---
  Introduction
  Extras/Bricks
  Minigames
  Themes
  Troubleshooting


Introduction
------------

First and foremost to make things clear: LBreakoutHD is an HD remake 
of LBreakout2 (all levelsets and themes will work). The game itself is
completely unchanged. A new SDL2/C++11 view has been added to support 
16:9 wide screens of any resolution. Why not adding this to the existing
LBreakout2 package if the game basically remains the same? Because 
second: I wanted to clean up the code (the not really well working 
network stuff bothered me) and not mix SDL2 with SDL for dependencies.

So LBreakoutHD is a clean cut with the old core engine (still in C) and
a brand new fully scalable 16:9 view.


Extras/Bricks
-------------

All extras/bricks are listed in the in-game help but some might need a little
more explanations:

Gold Shower:	Any brick without an extra on its own will release a 1000 score
		extra when destroyed. Lasts 20 secs.

Sticky Paddle:	Balls get attached and can be released manually by pressing
		a fire key. Reflection vector is kept. Lasts 20 secs.

Energy Balls:	Balls destroy everything (no reflection) except 
		indestructible walls and bonus floor. Lasts 5 secs.
		
Extra Floor:	Adds barrier to bottom so balls can't leave the screen.
		Starts blinking three seconds before it runs out. Lasts 10 secs.
		
Frozen Paddle:	Paddle can't move for 1 sec.

Random:		Can be ANY extra, so ... do you feel lucky, punk?

Joker:		Instantly collects all good extras and destroys all neutral
		and bad ones. Some are even doubled like extra balls and score.
		
Chaotic Balls:	Balls will randomly reflect for 20 secs.

Ghost Paddle:	If not moving, paddle will disappear after 200 ms until moved
		again. So you think you can place a paddle somewhere and wait for
		the ball to hit it? Think again. Very nasty in combination with
		Frozen Paddle. Lasts 20 secs.
		
Reset:		Resets every active extra, good or bad.

Extra Time:	Will add 7 secs to all active extras.

Explosive Balls: All adjacent bricks (including multi-hit bricks) will be 
		destroyed as well (except for wall bricks). Lasts 5 secs.
		
Weak Balls:	40% chance ball does not break a brick and gets just reflected.

Regular Wall:		In contrast to the indestructible one it can be
			destroyed by energy balls.
		
Chaotic Wall:		Will reflect balls randomly. Can be destroyed by
			energy balls.

Regenerative Bricks: 	Will restore health over time if not hit again.

Explosive Bricks: 	Will destroy adjacent bricks on destruction 
			(except walls).

Growing Bricks: 	Will grow new bricks on destruction in adjacent 
			locations (if not blocked by balls). 			


Mini Games
----------
Barrier: Try to break through the barrier and hit the wall behind it. Barrier
gets faster and thicker (up to 12 layers) with every breakthrough. The faster
you succeed the more score you gain. Game is over when a barrier reaches the
paddle or you loose the ball.

Sitting Ducks: 8 ducks. A ball launched from the top. Try to hit the ducks that
is on *directly*. If you fail it is removed. If you succeed you get some score
and another duck is highlighted (ball is launched from ceiling again). Multiple
hits in a row will increase trophy price. Game is over when you loose the ball
or all ducks were destroyed.

Invaders: Clear wave after wave of 20 alien space bricks each! With each wave
more score can be gained but it also gets faster... Game is over when an invader
reaches paddle level.

Outbreak: Stop the outbreak! Each wave 20 infections occur. When 10 infections
are active simultaneously the game is over so clear them faster than they occur.
Each wave incubation time gets shorter.

Hunter: Catch the prey with the hunter. Hit the matching colors to move the
hunter left, right, up or down. If you hit the wall the game is over. There is
a time limit to catch the prey. If time runs out the game is also over. With each
successful catch you'll get more score but have less time.

Jumping Jack: Try to hit the brick before time runs out. If you succeed it jumps
to a new position. With every hit you'll gain more score but have less time. 


Themes
------
The most boring part first: IF you use other people's artwork please check that
the license allows you to change and share it (e.g., GPL, PD, CC, OFL, ...)
and give proper credits in a file named CREDITS (or something like that).
If this is not done, a theme will not be accepted. For your own artwork please
choose a proper license (e.g., GPLv3 will match the package's license).

Ok, that's that. Now, to get started quickly, look at the Standard theme and
keep its dimensions for a 1080p theme. It's pretty much self-explanatory.

To get the fine details, read on.

It's still pixel-based (rasterizing SVG sometimes leads to artifacts and limits
to vector graphics only, so ...). Whatever resolution the images have they
get scaled to the screen/window size. Just bear a few things in mind:

theme.ini allows to set various things. All options have default values
matching LBreakout2 so they are not mandatory. But, e.g., for 1080p assets
you MUST at least provide

brickWidth = 90
brickHeight = 45

Otherwise 40x20 will be assumed which will look very funny. For a 4k theme you
would use 180x90 (remember everything gets scaled up or down to fit the
actual screen resolution).

In general, all images can use alpha for transparency. Black is no longer
used as color key (only for old LBreakout2 themes). For missing files 
Standard theme assets are used as fallback except for the frame (see below).

Assets in bricks.png and extras.png MUST match the given brick size 
exactly. All assets must be in one row (extra space to the right
or bottom hand side doesn't matter).

backX.png (or jpg is now ok, too) are wallpapers or full backgrounds.
They get scaled by the brickScreenSize to brickFileSize ratio. So the 
resolution should match bricks.png and extras.png (so that full wallpapers
will be scaled in the correct ratio to always fill the whole screen).
Maximum number is 10. Background numbers must be consecutive (e.g., 
back0.png, back1.png, back3.png will only load the first two).

menuback.png (or jpg) works the same for the menu background.

The main frame comes in three flavors:
1) frame.png contains the full frame (fitting 16:9).
2) fr_left.png, fr_top.png, fr_right.png build a 4:3 frame (see old 
LBreakout2 frames). Boxes for hiscores, score and active extras are
automatically added.
3) No frame files at all will lead to a standard brick frame.

If you want to create a full frame image here are the measures for the info
boxes (bw = brick width, bh = brick height) given as x,y,w,h: 
	Box 1: Setname+Hiscores: 16*bw, bh, 13/3*bw, 12*bh
	Box 2: Name+Score: 16*bw, 14*bh, 13/3*bw, 3*bh
	Box 3: Active extras: 16*bw, 18*bh, 13/3*bw, 5*bh
So, e.g., hiscores box for 1080p (brick size 90x45) has 1440,45,390,540.

paddle.png needs to be FOUR rows (normal, sticky, frozen, unused) of 
three square tiles (left, middle, right). Some old LBreakout2 themes
have two paddles in one row and I started out with an extra paddle so
it is now required to get the proper dimensions automatically.
Paddle gets scaled to 90% of brick height. E.g., for 1080p tile size
should be 40x40 to avoid unnecessary scaling.

ball.png is one row of square balls (normal, energy, explosive, weak,
chaotic). No extra rows allowed as height is used to determine dimensions.
Balls get scaled to 60% of brick height. E.g., for 1080p tile size
should be 27x27 to avoid unnecessary scaling.

shot.png is a row of frames (shotAnim.frames or default 4). You can set
animation speed by shotAnim.delay (default 200 ms). 
Shots get scaled square to 50% of brick height. E.g., for 1080p frame size
should be 22x22 to avoid unnecessary scaling.

weapon.png is a row of frames (weaponAnim.frames or default 4). You can set
animation speed by weaponAnim.delay (default 200 ms). 
Weapon gets scaled square to 90% of brick height. E.g., for 1080p frame size
should be 40x40 to avoid unnecessary scaling.

explosions.png are rows of frames (explAnim.frames or default 9) for an
explosion. You can set explosion speed by explAnim.delay (default 50 ms).
Explosions can have any size but must be square.

life.png contains two brick sized, vertically arranged icons for displaying the 
player's lives. The first icon shows a possible extra paddle, the second shows
an actual life. It is added at the lower left-hand side of the frame.

warp.png is a brick sized icon used to indicate warp is ready.

You can specify the small and normal text font (default: fsmall.otf and 
fnormal.otf) and their size (default: 14 and 18 pixels in theme resolution).
You can set the colors with fontColorNormal (default white) and 
fontColorHighlight (default yellow) as red,green,blue,alpha values.
Use GIMP to mix colors or translate #...... hex values.

menu.* in theme.ini allows to modify some menu position stuff. All values are in
pixels in theme resolution. Just play around with the values if you're 
interested in changing it.


Troubleshooting
---------------

1) If the screen is cut off this might be due to an older non-16:9 
resolution like 1366x768. Either switch to 1280x720 or play in window mode.

Enjoy,
Michael

