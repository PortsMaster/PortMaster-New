--  F-1 SPIRIT REMAKE  --

0.- This version
1.- Introduction & Disclaimer
2.- How to play
3.- The main menu
4.- Game tips
5.- Improvements over the original
6.- Change log
7.- Credits
8.- Additional Information

--  0.- THIS VERSION

This is the only chapter in this document that doesn't come from BrainGames.
This version of F1 Spirit as been modified. It now support a GLES renderer, 
has C4A support (enable only on the Pandora) and works on the Pandora and ODROID.
To compile on the Pandora, using the Codeblocks Command Line PND, just type
make

To compile on the ODROID, type
make ODROID=1

To compile on x86 Linux, type
make LINUX=1

Other platform can probably be added easily (like RPi), but will need some slight 
changes in the Makefile (contact me or do a pull request if you want / have a new platform)

Here is a video of it running on an gigahertz OpenPandora
https://www.youtube.com/watch?v=ObQXqjt7518

And here running on an ODroid XU4
https://www.youtube.com/watch?v=M7I4K3dlW34

--  1.-  INTRODUCTION & DISCLAIMER  --

This game was developed for the RETRO-REMAKES REMAKE COMPETITION 2004 
organized by http://www.remakes.org

This is the unofficial remake of Konami's F-1 SPIRIT which was originally 
released in 1987 for the MSX home computer systems.

Making sure that Konami won't sue us, we are telling you that we are not
related to Konami in any way except for liking their excellent games.

Also, this is a not-for-profit remake. So, we don't get any money from 
remaking this or any other Konami titles.


--  2.-  HOW TO PLAY  --

F-1 Spirit is a racing game. You will race with many different types of cars, 
starting by Stock or Rally cars, and finishing by driving F1 cars (once you
have classified for it by passing for F3, F3000 and Endurance cars).

Specifically, there are 6 car categories:
- STOCK CARS
- RALLY CARS
- F3 CARS
- F3000 CARS
- ENDURANCE CARS
- F1 CARS

Initially, you can only race in STOCK, RALLY and F3 categories. But, as you 
win races, you will accumulate points that will allow you to play in more car
categories. Specifically, you will sum 9 points if you finish a race in 1st
position, 8 if you finish in 2nd position, etc. If you finish in 10th
position or more, you will not sum any point.

Moreover, there are 16 different tracks of F1 cars. As you win races, you
will be able to play more tracks in the F1 car category. To complete the
game, you have to win in all the 16 F1 tracks. This makes a total of 21
tracks (stock + rally + f3 + f3000 + endurance + 16*f1). The first races
are the easier races: the cars are slow, and the enemies do not drive very
well. But as you classify for new tracks, the difficulty will increase: F1
cars are impresively fast! You will need a great dexterity to win in F1
tracks. The first time you race with F1 cars it seems impossible to control
the car, but as you accumulate experience, the races start becoming easier,
and finally you are able to win any F1 race! It's time then to play in
multiplayer mode against some friends and show them how well you can control
a F1 car!!!

During a race, you can collide with other cars and with the track fences, etc.
This will damage your car. In every track, there is a zone (labelled with the
"PIT" letters) where you can replenish the fuel tank of your car and fix your
car. 

Moreover, in F-1 Spirit, you can construct your own car to play with. Later
in this document, we will explain how you can select the car that best
matches your racing habilities!

The default keys are:

CURSOR LEFT/RIGHT : turn
CURSOR UP/DOWN : shift gears
SPACE : accelerate
M : brake
ESCAPE : pause/options menu during game
F12 : exits to the OS in any moment

In order to start a new game, press SPACE in the title screen. This will
give you access to the main menu.


--  3.- THE MAIN MENU --

To browse the menus use LEFT/RIGHT or UP/DOWN arrows. ENTER or SPACE
selects an option, and ESCAPE goes back to the previous menu (in the case
of being in the main menu, it goes back to the title screen).

The first choice you will have to make is:

- NEW GAME
   If you start a new game, you will be asked to enter your name, and then
   you will start a new game from scratch. The name you enter here is the
   name that will appear in the HIGH SCORE table.
- CONTINUE GAME
   This option will only appear if you have previously started a new game.
   By continuing a game you will continue from the point that you left the
   game last time, preserving all your time records and accumulated points.
- PRACTICE
   This option allows you to play quick races. You don't have to enter a
   name, and therefore the times made in practice mode will not appear in
   the HIGH SCORE table.
- TITLE SCREEN
   Goes back to the title screen.

Once you have started a game (practice, new or continue), you will face the
main game menu:

- 1 PLAYER
   Starts single player game.
- MULTIPLAYER
   Allows you to select 2, 3 or 4 player mode (games made in multiplayer
   mode do not accumulate points nor count for the HIGH SCORE tables).
- NETWORK
   Allows to play a multiplayer game through a local network or through
   the internet. Each comuter can be:
      - a SERVER: in each network game there must be one server. And the
	              clients connect to it. Once you create a server, you have
				  to decide whether it is DEDICATED or NORMAL (a dedicated
				  server is not used by any player to play, and is only used
				  as a hub to connect clients). After that, you have to
				  decide whether the server will be PUBLIC or PRIVATE
				  (public servers are published in the BRAINGAMES server
				  and are visible by other players). Then, you have to give
				  the server a name, and then the server is created.
				  The main server screen is a small chat-room where the
				  players can talk to decide the next race.
	  - a CLIENT: clients have to connect to a server in order to play.
				  Just give the client a name, and connect to a server.
				  The main client screen is a small chat-room.
	Notes: ensure that the ports 32124 TCP, 32125 UDP are open in order
	       to play F-1 spirit in network mode. More over, some people has
		   reported problems using:
		   - The "net bridge" feature of Windows XP.
		   - The "internet worm protection" of Norton Antivirus.
- CONFIGURE
   Allows you to change the game settings: 
      - music and SFX volume (using LEFT/RIGHT arrows)
	  - change the type of HUD (dispersed or like in the original game. By
	    default it is presented like in the original game).
	  - change the options for each one of the 4 possible players (since up
	    to 4 players are allowed to play inmultiplayer game). For each player
		you can change:
         - the CONTROLS: keyboard, joystick	  
		 - the CAMERA mode: (the default value is FOLLOW TRACK)
		    - FIXED CENTERED: the camera does not rotate, i.e. the brackground 
			         will be fixed, and only the cars will rotate.
			- FOLLOW CAR: the camera will rotate as the player car rotates.
			- FOLLOW TRACK: the camera will follow the direction of the road.
			         (FOLLOW TACK is the default mode, and is highly recomended)
			- HYBRID 1: in straight roads, the camera follows the road, and
			            in curves it follows the car.
			- HYBRID 2: symilar to HYBRID 1, but with a slight variation in
			            the curves.
		    - FIXED 2: as FIXED CENTERED, but the player car is not placed at
			         the center of the screen but with a little offset towards
					 the opposite direction of the track, so that the player
					 can better see what's in front of him.
		- the ZOOM effect (the default is SPEED STEPPED)
			- FIXED: the zoom is always 1x
			- SPEED LINEAR: the zoom decreases linearly as the speed of your
						    car increases
			- SPEED STEPPED: there are 3 different zooms, 
							 at low speeds you will see the game at 1.2x,
							 at medium speeds you will see the game at 1x,
							 and at high speeds the zoom will be 0.8x.
- HIGH SCORES
   Presents you the HIGH SCORE tables. There are 2 HIGH SCORE tables:
   - OVERALL TOP 25: is a ranking sorted by the top 25 players with the
	                 highest accumulated points. In the case of a tie, the
					 player with the lower accumulated time (the sum of
					 the times made in each race) goes upper in the table.
   - BEST TRACK TIMES: keeps a record of which player has finished each track
					   in the minimum time.
   High scores are stored in a file called "hiscores.dat", if you want to
   reset the HIGH SCORE list, just delete this file.
- WEB
   Allows you to register your player in the F-1 Spirit server, and synchro-
   nize your high score table with the server's.
   - REGISTER: will ask you to enter a password and will register the current
               player in the web (if it is already reistered, you will get
			   an error).
   - UPLOAD HIGHSCORES: will upload the highscores of the current player to
               the F-1 Spirit server (will ask you to enter the password)
   - DOWNLOAD HIGHSCORES: will download the highscore list from the F-1
               Spirit server, and will update the local highscore table.
   Notice that web operations may take a while, so have patience.
   You can also visit the game's website to consult the global high score
   table: http://www.braingames.getput.com/f1spirit
          http://www2.braingames.getput.com/f1spirit

- TITLE SCREEN
   Finishes current game and goes back to the title screen.

After you select 1, 2, 3 or 4 player mode, you will have to select the track
you want to play in. Initially, only STOCK, RALLY and F3 races are available.
But as you accumulate points, more races will become available.

Once you have selected a track, you will have to select the car with which
you want to race. There are two ways of creating a car:
- READY MADE CAR
	You will be able to select among three different reay made cars. The left
	most car will be constructed in order to be robust, easy to manage, with
	automatic gear shifting, but with a lower maximum speed. The right most
	car is weak, difficult to manage, with manual gear shifting, but with a
	higher maximum speed. The medium car is an equilibred design.
- ORIGINAL DESIGN
	You will be able to select 5 parts of your car:
	- BODY: 3 different bodies, stronger but heavyer bodies or weaker but
	        lighter bodies.
	- ENGINE: 6 different motors with different power and fuel consumption
	          values. Basically, you have to look at two parameters:
			   - The cubicage of the motor (in cc), that is proportional
			     to the fuel consumption of the car.
			   - The power of the motor (in ps).
	- BRAKES: 3 different settings
	- SUSPENSION: 3 different settings that determine the sharpness of the
	              turns you can do.
	- GEAR: 3 different settings for the gear shifting box.

The next thing after selecting a car is to race!


--  4.-  GAME TIPS  --

- The most important one: THE BRAKE IS YOUR BEST FRIEND 
  (Specially in the F1 tracks).

- Use the PIT STOPS if you have a very damaged car. For instance, having
  the engine damaged, your peak speed will decrease, making you lose time
  in each lap.

- When you are in the PIT STOP, if you hold down the DOWN arrow, the fuel
  replenishmend will slow down, but the car repair will speed up.

- The fuel consumption is a function of the RPM at witch the motor is
  turning (as in real cars), moreover, your car only consumes fuel when you
  press the acceleratioin pedal. Keep this two things in mind while you race
  to save fuel.

- F1 tracks cannot be won at the frist race unless you are an ACE driver.
  To win an F1 race, try to memorize each curve, play several times to each
  race to know where you can run at higher speeds and where you have to
  brake.


--  5.-  IMPROVEMENTS OVER THE ORIGINAL  --

- Improved Graphics
- Improved Music
- More realitic physics
- Tracks have the real shape shown in the maps
- Camera rotation
- Camera zoom
- Highscore table
- Multiplayer up to 4 players in a single computer with split screen
- Replay saving
- On-line scores

Future improvements (planned but not implemented):
    - networked multiplayer up to 32 players


--  6.-  CHANGE LOG  --

Version AC6:
- You are noticed if you beat a record
- When you finish a track, you have the chance to race again
- increased the speed of fuel recharge and repair in pit stops 
- improved online highscores:
  - best lap is also stored
  - personal results: best lap, position, and points per track
  - password is only asked once
- adjusted the difficulty of tracks F3, F3000 and ENDURANCE
- new hud
- new graphics
- new musics
- extra bonus tracks when you compelte the game
- several bugs fixed


Version AC5:
- improved online highscores: accumulated time, top 3 best times per track
- player with best time shown at track selection menu
- several bugs fixed


Version AC4:
- "final lap" message
- preview replay of each track
- added the "FOLLOW TRACK 2" camera mode
- added the "locked" sign to the tracks you cannot access
- added a display to see how many points you have collected
- Shown the point requirements for each unavailable track
- better enemy AI driving
- online highscore table
- several bugs fixed


Version AC3:
- New rally and stock songs
- New background image in the menu
- Created the website of the game
- It is now possible to access the options menu during the game
- Enemy cars explode it they hit you hard from the back
- Improved the main menu
- Added a game icon in Windows
- Configuration file, now the game remeber if the user executed it in 
  fullscreen or windowed mode.
- car spinning
- updated track maps
- alpha blended semaphore
- added the "FIXED 2" camera mode
- Several bugs fixed


Version AC2:
- Reduced CPU usage
- improved compatibility of replays
- added the JAPAN and AUSTRALIA tracks
- Enemy cars reappear after a crash
- Several bugs fixed

--  7.-  CREDITS  --

The BRAIN GAMES team:

Programming: Santi "Popolon" Ontañón
Graphics: RamonMSX, Miikka "MP83" Poikela, Valerian, Olivier "Picili",
          Matriax
Music/SFX: Jorrith "Jorito" Schaap 
Beta Testing: 
	- JEames, Jorito, MP83, Daedalus, Pakoto, Vampier, Chocobo2k, 
	  Silver Sword, Valerian, theNestruo, RamonMSX, Lars the 18th, Konamito,
	  AcesHigh, Kelesisv, Matriax, Ruboslav
Special Thanks to:
	- Jason "JEames" Eames: Web hosting
	- Joram "Daedalus" van Hartingsveldt: png format reduction tools
	- Lars the 18th: game font, mirroring
	- Valerian: website design
	- Ootini: scaned original manual of F1-Spirit


--  8.- ADDITIONAL INFORMATION --

The game starts in windowed mode, switch to fullscreen by pressing ALT+ENTER

To quit the game at ANY moment, press F12

Check http://www.braingames.getput.com to be updated
in future versions of the game.

