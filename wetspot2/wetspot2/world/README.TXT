                            
                        WETSPOT II - README.TXT file

                 Version 1.3 - by Enhanced Creations 1997-98

             Suggestions, hints or bug reports are to be sent to
                
                   Angelo Mottola - angelillo@geocities.com

     For other informations on this game, extra stuff and more, visit the
Enhanced Creations home, the QuickBasic Enhanced Programming Page located at:

              http://www.geocities.com/SiliconValley/Lakes/7303


TABLE OF CONTENTS ___________________________________________________________

1 - Running the game
 1.1 - The freeware concept
 1.2 - Game requirements
 1.3 - Installing the game
 1.4 - The SETUP program
2 - Playing WetSpot 2
 2.1 - Your goal
 2.1 - The game menu
 2.3 - Controls
 2.4 - External worlds
3 - Program informations
 3.1 - How this was possible in QB
 3.2 - Credits
 3.3 - Program history
 3.4 - Final words
APPENDIX A - Default keys
APPENDIX B - Error messages
APPENDIX C - Known bugs and problem resolutions
APPENDIX D - Hints and cheat codes
_____________________________________________________________________________


=============================================================================
1 - RUNNING THE GAME
=============================================================================

1.1 - The freeware concept

WETSPOT 2 IS A FREEWARE PROGRAM. THIS MEANS THE AUTHOR GIVES YOU ALL HIS WORK
WITHOUT GAINING SOME MONEY, AND ENCOURAGES YOU TO GIVE IT TO YOUR FRIENDS.
IF YOU THINK MY GAME IS REALLY GOOD AND YOU WANT TO MAKE A DONATION, FEEL
FREE OF DOING SO, AND CONTACT ME VIA E-MAIL.
THIS PROGRAM WAS MADE USING LOTS OF ADVANCED QB PROGRAMMING TECHNIQUES, AND
USES CALLS TO ASSEMBLY ROUTINES AND INTERRUPTS. A BAD USE OF IT MAY CAUSE YOUR
SYSTEM TO CRASH, BUT YOU SHOULD HAVE NO PROBLEMS IF YOU READ CAREFULLY THE
INSTRUCTIONS CONTAINED WITHIN THIS SMALL MANUAL. ANYWAY, THE AUTHOR IS NOT
LIABLE FOR ANY DAMAGES CAUSED BY AN IMPROPER USE OF THIS SOFTWARE.


1.2 - Game requirements

Since QB is a slow language, and this game does a lot of calculations, a
medium-high end computer is required to play at a decent speed.

The minimum configuration to run the compiled version is:
- a 486DX2 based machine
- about 370000 bytes of free base memory
- 1344 Kbytes of free EMS memory
With this configuration you'll be able to run the game, but it will go really
slow; needless to say, a better machine should be your choice...

For optimal performances, you should have:
- a Pentium based machine or better
- about 370000 bytes of free base memory
- 1344 Kbytes of free EMS memory
- a Sound Blaster compatible sound card
- a joypad (a joystick will fit as well)

I've made the game on my K6-200 with a SB16, and with such a configuration it
works great; I've also tried it on a P133, and the results were the same.
If you've problems with EMS, try looking at the "APPENDIX C - Known bugs and
problem resolution" section of this manual. Remember also that to run the
game under QB, you'll need a copy of QuickBasic 4.5, because of the advanced
routines used and the multiple modules; in this case, you'll also need about
590000 bytes of free base memory, because the IDE is really a memory-eater.
Anyway I suggest you to use always the compiled version, because it's faster.


1.3 - Installing the game

After unzipping the game packet file, you should have all the files into the
same directory; this can be anywhere on your HD as well as on a floppy disk.

WetSpot II requires expanded memory (EMS) to run; if you don't know what I'm
talking about, try adding the following lines at the very beginning of your
CONFIG.SYS file:

DEVICE=C:\WINDOWS\HIMEM.SYS
DEVICE=C:\WINDOWS\EMM386.EXE 2000 RAM

Here I suppose you have Windows 95 under the WINDOWS directory, so there you
should have these files. HIMEM.SYS is used by EMM386.EXE, which is an
expanded memory manager (EMM). The "2000 RAM" parameter passed to this driver
specifies the amount of EMS memory in kbytes to make available under DOS
(2000 are more than enough to play the game).

If you have a sound card, and you want to hear the MIDI musics, you'll need
to load the SBMIDI.EXE driver provided within the package, before running
the game. This driver must be loaded from DOS and it must be resident into
interrupt 80h, so if you have such an interrupt already used, free it, or
you'll have to disable the musics.

To load the game under QB 4.5, run the IDE with the /L option. This will load
the default quicklibrary which holds the interrupt and assembly call routines.
If this is the first time you run the game, you'll need to run the SETUP.BAS
program before executing it; see the next section for details.
Once the game settings have been choosen with the SETUP, load WETSPOT2.BAS,
which is the main game module; run this to play WetSpot 2.
The file WETSPOT2.MAK is the project file and contains the file names of the
other modules, so that QB can load them all when the main one is loaded into
the IDE. The WETSPOT2.BI file is the include file needed by all the modules,
and contains SUBs, FUNCTIONs, constants and common variables declarations. If
you want to compile the game, remember to change the value of the constant
COMPILED from "FALSE" to "TRUE" in this file; this will slow down the program
because an EXE is faster than the interpreted code.


1.4 - The SETUP program

Before playing the game for the first time, you'll have to run this program.
It allows you to change a lot of settings according to the hardware of your
computer; several detection routines will detect the available devices to
ensure a safe configuration.
To navigate the menus, use the arrow keys to move the highlighted option and
the <ENTER> key to select it.

þ The SOUNDS menu will be activated if a sound card is detected. This will
let you change its settings, such as the base address (can be 210,220,230 or
240), the low DMA channel used to play sounds (can be 0,1,2 or 3) and if they
must be on or off.

þ The CONTROLS menu will let you reset the keys to default (see sections
"2.3 - Controls" and "APPENDIX A - Default keys" for details), and if a
joystick/joypad is available, to change its resolution and to test it.

Once you've made your changes, select the "SAVE SETTINGS AND EXIT" option
from the main menu. Now you should be able to run WetSpot 2 without errors;
anyway, if you have any trouble, try looking at sections APPENDIX B - Error
messages, and APPENDIX C - Known bugs and problem resolutions.


=============================================================================
2 - PLAYING WETSPOT 2
=============================================================================

2.1 - Your goal

If you have ever played WetSpot, the prequel to this game, you should already
know how to play. Anyway, you control a small crab and your target is to kill
every monster on the current level. Since you have no weapons, to accomplish
your job you must use the same bricks that forms the walls of the level you
are into. How? Simple. Just go towards a brick and push the fire button; the
brick in front of you will begin moving in that direction, and will stop its
run only when it hits another brick. Needless to say, if one of this bricks
runs over an enemy, that enemy dies, and the same happens for the players.
If you push a brick while another brick is on the other side (i.e. the brick
you're pushing can't move), the first will be destroyed, maybe releasing a
hidden bonus. Not all bricks can be moved or destroyed; usually moveable
blocks (which can be destroyed) can be easily recognized from the fixed blocks
(which cannot be destroyed), but sometimes you'll have to find it by yourself.
There are a lot of hidden bonuses, from the simple score bonus to the extra
life, as well as special objects with particular effects. The letters for
example: there are 5 letters that form the word "BONUS", and once you've got
them all, you gain a life. Try them out!

Once an enemy dies, it releases an extra bonus; when all the enemies are gone,
you pass the level. WetSpot worlds are made of areas (the standard world
contains 10 areas for example), and each of them contains 5 levels with the
same graphics and the same music. When you complete an area, a password is
given, allowing you to continue the game from the first level of the new area,
without having to complete the previous levels. Passwords can be inserted with
the INSERT PASSWORD option of the game main menu; see the next section for
details.

The best feature of WetSpot 2 (W2 for short) remains the two players mode.
Player one controls the red crab, and player two the blue crab; they act
simultaneously on the same level, and believe me, this is really fun.
If you know WetSpot, you should know that when one of the two players died,
the level had to start again from the beginning, and when a player lost his
last life, the game was stopped and the "game over" message came out. How many
times have you hated this system, when your friend died and you had to end the
game with him? Well, forget it! WetSpot 2 finally has a decent two players
mode! When a player dies, the other can continue playing, and he (if other
lives are available) appears again when the other ends the level or dies.


2.2 - The game menu

Once the small intro ends, a main menu appears on the screen. The selection
bar can be moved using the arrow keys, and <ENTER> selects the highlighted
option. Here follows a brief description of the available options:

þ START ONE PLAYER GAME
        Starts the game in one player mode from the beginning
þ START TWO PLAYERS GAME
        Starts the game in two players mode from the beginning
þ ENTER PASSWORD
        Allows you to enter a password to an area of the current world. See
        above for details on how the password system works.
þ LOAD EXTERNAL WORLD
        Allows you to change the current world. For details see section
        2.4 - External worlds.
þ OPTIONS
        Brings you to the options menu. Here you can change the players
        control methods, the sound/music volume, and even customize the keys
        for the keyboard control method.
þ SHOW CREDITS
        Shows the credits of the game
þ QUIT
        Exits the game

If you don't press any key for a while, a demo of the game will begin,
followed by the credits and the top ten. During this demo, as well as during
the credits show and the top ten, press the <ENTER> key or the <ESC> key to
return back to the menu.


2.3 - Controls

Each player has its control method, and this can be set in the options menu.
There are up to 4 basic input devices, depending on the presence of joysticks:
- KEYBOARD 1
- KEYBOARD 2
- JOYSTICK 1 (where available)
- JOYSTICK 2 (where available)
Each of these can be assigned to a player; let's see them in details.

KEYBOARD 1 and KEYBOARD 2:  when no joysticks are available, the keyboard
        remains the only way to control your crabs. The way this worked in
        WetSpot is the past. Now to go in a direction, you must hold down
        a key, and this means that simultaneous keypresses are allowed.
        The default keys (see APPENDIX A - Default keys) can be changed
        with the "CUSTOMIZE KEYS" option in the options menu.
JOYSTICK 1 and JOYSTICK 2:  these are automatically detected when available.
        The best choice is a joypad, but a joystick will fit as well. In this
        last case, you'll need to set its resolution in the SETUP program;
        lower resolutions mean that the joystick is really sensible, so a
        default value should be about 20-30.

While playing, press <P> for pause (press <P> again to resume), <ESC> to
abort the current game ,<F1> to show the framerate and <F12> to save a
screenshot in the BMP format. The file will be like "SHOTxxxx.BMP", where
"xxxx" is the number of the screenshot. Each time the game is executed, this
number is reset to 0, and it increases every time you hit the <F12> key. Pay
attention about overwritings!

As in all the games of this kind, there are some cheat codes that have
particular effects. If you really want to know them, take a look at the
APPENDIX D - Hints and cheat codes.


2.4 - External worlds

If you're reading all this text file from the beginning, you should have
noticed I've said that the world can be changed. As said, a world is a
collection of areas, each containing 5 levels; well, if the standard world
(50 levels) is not enough for you, you'll like this feature. External worlds
are worlds made by other people like you, and can contain from 1 up to 20
areas! Each world is contained into one file only (MIDI musics, if available,
are the only separated files) and must be put into the same directory of the
game. Once this is done, you can load it from the "LOAD EXTERNAL WORLD" option
in the main menu; you also have to know that each world has its own top 10,
which is reset the first time you play it.
If you're interested in making new worlds, take a look at "Worlds of WetSpot",
the WetSpot 2 world editor; you can download it from my web page. Here you'll
also find a collection of worlds made by other people, for your pleasure.
Once you've made a world, send me it via E-Mail, and I'll publish it there!


=============================================================================
3 - PROGRAM INFORMATIONS
=============================================================================

3.1 - How this was possible in QB

QuickBasic 4.5 of course. If you're a QB programmer, you'll surely find this
section interesting. Here I'll try to explain the basic concepts used to
create the game; first of all the multiple module programming. Most of you
think QB can't handle big programs, but this is the counter evidence...
Just take in mind that QB can't handle modules larger than 64 Kbytes, so you
have to split your source into different modules. Here an include file is
really recommended to declare the functions and the common variables shared
between the modules.
The second great feature of WetSpot 2 is the use of EMS memory. Without it,
the game would not be possible; infact it's used to store the sprites, the
level background and even the sounds. I strongly suggest you to learn using
EMS, also because of the low memory capabilities of QB.
I've used the EMS memory together with the famous Blast! Library, and only
this allows a really flickerless graphics... Just look at this library and
the EMS routines (can be easily found over the net, and they're also up on my
page) to understand what I'm talking about.
To play the sounds (WAVs) I used the DMAplay routine, for the musics the
QMIDI routines. Contact their authors for details on how to add them to your
own programs (see the section 3.2 - Credits)
Do you think this is the best QB game ever written? The best thing you can
do for me is to share WetSpot 2 will all the people you know. Anyway, if you
feel generous, you can make a free donation; contact me!


3.2 - Credits

WetSpot 2 is a game by Enhanced Creations.
Enhanced Creations is Angelo Mottola only. Here follows the credits list:

CONCEPT                         Angelo Mottola (angelillo@geocities.com)
CODING                          Angelo Mottola (angelillo@geocities.com)
SPRITE GRAPHICS                 Angelo Mottola (angelillo@geocities.com)
SPRITES GET AND PUT ROUTINES    Petter Holmberg (petter.holmberg@usa.net)
BLAST! LIBRARY                  Andrew L. Ayers (andrewa@indirect.com)
KEYBOARD HANDLING ROUTINE       Milo Sedlacek (sedlacek@execulink.com
JOYSTICK HANDLING ROUTINE       Angelo Mottola (angelillo@geocities.com)
DMAPLAY ROUTINE                 Toshihiro Horie (horie@ocf.berkeley.edu)
QMIDI LIBRARY                   Jesse Dorland (jessedorland@hotmail.com)
BMP FAST SAVING ROUTINE         Thomas Nyberg (thomas.nyberg@usa.net)

Special thanks to

PETTER HOLMBERG for the help he gave to me: the get and put assembly routines
        he made for this game, the making of area 7 and for the beta testing.
        Without your support the game would not be the same!
INGMAR NEUWIRTH for help, beta testing and hints about the game. Your interest
        in my programming was a great support for me.

Thanks to

MILO SEDLACEK (A.K.A. GRADIUS) for sharing with me his keyboard knowledge.
JESSE DORLAND for the MIDI routines; they're really great!
WALTER ARRIGHETTI for beta testing and the encouragements he gave to me in the
        making of this game.

Also thanks to all the people who sent me messages about WetSpot. Without your
support, this sequel may not even exist.


3.3 - Program history

The WetSpot 2 project was started on september 1997. Here follows a brief
history of the program, from the first alpha to the final release.

Alpha 01 - 5th Dec 1997:  This first alpha of WetSpot 2 has full players
                control, but no bonuses nor collisions detection with enemies.

Alpha 02 - 10th Dec 1997: Added normal bonuses and collisions

Alpha 03 - 12th Dec 1997: The game engine is almost complete; speed problem

Alpha 04 - 14th Dec 1997: Added a better delay control, joystick input (though
                this slows down the entire game, because standard QB joystick
                functions are used)

Alpha 05 - 27th Dec 1997: Standard QB joystick input routines no more used;
                new routines works better using INP and OUT. WetSpot 2 now
                has a demo!

Alpha 06 - 29th Dec 1997: Main menu added at last. Now the game is nearly all
                configurable, including players control selection and keys
                customization.

Alpha 07 - 3rd Jan 1998:  Great day! Main module splitted into two modules to
                avoid compiling "out of program memory" error. Now all works
                ok, except that the compiled version of the game runs too fast
                on my K6-200 - even with the speed auto detection routine...

Alpha 08 - 8th Jan 1998:  Speed problem solved again. As I try to add MOD
                music and WAV sound effects using the BWSB library (as it was
                planned), the game runs very slow on my K6!! So I have to
                find other ways to have musics and sound effects...

Alpha 09 - 10th Jan 1998: I've added the famous DMAPlay routines to play
                WAV effects directly from EMS. I've also studied some way to
                handle MIDIs, which as by now I plan to use instead of MODs.
                I'm really happy because this is the first alpha to have
                sound effects playing correctly! Minor optimizations to the
                game engine itself.

Alpha 10 - 27th Jan 1998: Ending text added, as well as more sound effects.
                Also, the "Enter password" option is now active. The code has
                been optimized a bit more, expecially keyboard player input.
                I still need to create the standard levels; as by now only
                the first 15 are ready...

Alpha 11 - 4th Feb 1998: No new areas, but now external worlds can be loaded
                instead of the standard one. The code is now splitted into
                three modules, because it's really huge!

Alpha 12 - 25th Feb 1998: Great changes! Two new areas, game over message and
                a lot of bugs fixed. Finally Enhanced Creations has a logo,
                and it looks really great! Also added a small intro, and
                improved the two players mode: now when one of the player
                dies, the other one can continue playing...
                Cheat codes are available in WetSpot 2, find them!

Alpha 13 - 4th Mar 1998: Musics at last! The QMIDI routines are really great,
                though I had some low memory problems... The game finally has
                its ending scene (looks great!), and a lot of other small bugs
                have been fixed. This will be the last alpha version, until
                the first beta is out!

Beta 1 - 12th Mar 1998: The first beta is out! The standard world is complete,
                the game looks almost complete and only a few bugs have to be
                fixed... I still haven't found any good sounds for the player
                that dies, the destruction of a block, the earthquake and the
                lightning; I also have to find a music for the main menu, then
                the game will be completed!

Beta 2 - 17th Mar 1998: Lots of hidden bugs fixed, that was really hard! The
                two players mode was giving me some problems, but now I hope
                all to be ok. I've changed the initialization routine, so now
                the game is loaded really faster... I still need some more
                sound effects!

Final 1.0 - 21st Mar 1998: Since no more bugs were found and I can't wait no
                longer to release the game, here comes the final version.
                Not all the wanted sound effects were found, nor the menu
                music was added; anyway the game works perfectly (I hope!)

Final 1.1 - 2nd Apr 1998: Minor bugs fixed; now all seems to be ok...

Final 1.2 - 15th Jun 1998: Other minor bugs fixed, added a special extra
                bonus (find it by yourself!) and direct keyboard input when
                entering passwords and highscore names.

Final 1.3 - 27th Jun 1998: Since version 1.2 had some strange bugs, here comes
                version 1.3; now all should be fixed, and I've also added a
                message that warns the user if a specified music MIDI file is
                too big to be played (world makers should understand!), plus
                new cheat codes...

3.4 - Final words

Well, what a hard work! The making of WetSpot 2 has took half a year, and I
hope you like it as I do. I also hope that you can make worlds for this game
with the editor, I'll be really glad to put them up on my web site.
What else to say? Go now, have fun with WetSpot 2, and excuse my bad english!


=============================================================================
APPENDIX A - DEFAULT KEYS
=============================================================================

The first time you'll run the game and every time you select the "RESET KEYS
TO DEFAULT" option in the SETUP program, the keys will be reset as:

KEYBOARD 1 -    Up:     <up arrow>
                Down:   <down arrow>
                Left:   <left arrow>
                Right:  <right arrow>
                Fire:   <enter>

KEYBOARD 2 -    Up:     <W>
                Down:   <S>
                Left:   <A>
                Right:  <D>
                Fire:   <tab>

These key settings can be changed with the "CUSTOMIZE KEYS" option in the
"OPTIONS" menu of the game; the new keys configuration will be saved to the
WETSPOT2.CFG file as you quit, and will be restored once you start W2 again.


=============================================================================
APPENDIX B - ERROR MESSAGES
=============================================================================

WetSpot 2 has several hardware and software identification routines, which
should provide a safe execution. If you get an error message while running
the game, refer to this table; maybe here you'll find the solution to your
problem.

Message: "A game data file is missing, program aborted. Please install again."
        þ Cause:  WetSpot 2 can't find a required game data file in the
                current directory.
        > Solution:  Be sure to have all the game files in the same directory
                and to run the game from there, otherwise you'll have to
                install again.

Message: "There was a general disk error while attempting to access a game
        file; see README.TXT for details."
        þ Cause:  This error may occur in different situations: the most
                usual one is that you're running the game from a write
                protected diskette, otherwise there's some problem with
                your device (the disk can be full!)
        > Solution:  WetSpot 2 must have free access to the disk; you must
                toggle the write protection tag or free some space on your
                disk, otherwise you'll have to install the game again.

Message: "Not enough memory to run WetSpot 2; see README.TXT for game
        requirements."
        þ Cause:  you do not have enough free base memory to run the program;
                this error should also occur during the game.
        > Solution:  Free enough base memory and load WetSpot 2 again. See
                section "1.2 - Game requirements" for details.

Message: "This program requires 1344 Kbytes of free EMS memory to run!"
        þ Cause 1:  You don't have an extended memory manager (EMM) loaded in
                memory.
        þ Cause 2:  You have the EMM, but you haven't free EMS handles or
                enough free EMS memory to run the game.
        > Solution:  Take a look at section "1.3 - Installing the game" of
                this manual and follow the instructions.

Message: "Game configuration not set, please run SETUP first."
        þ Cause:  WetSpot 2 can't find the configuration file (WETSPOT2.CFG)
                in the current directory.
        > Solution:  Run the game from its directory or execute the SETUP
                program saving your settings.

Message: "Bad game settings, please run SETUP again."
        þ Cause:  This error should never come out; it means that the
                configuration file is corrupted, probably because it was
                manually edited, or because the game was brought to another
                computer with a different hardware.
        > Solution:  Run the SETUP program again.

Message: "Unable to detect the SBMIDI driver; load it or disable musics in
        SETUP."
        þ Cause:  You turned on the musics in the SETUP program and tried to
                run the game without loading the SBMIDI driver.
        > Solution:  Load the driver before running the game or disable the
                musics in the SETUP program.

Message: "Int 80h is not being used by SBMIDI; free it or disable musics in
        SETUP."
        þ Cause:  You have interrupt 80h already occupied by a program that
                is not the SBMIDI driver. It is possible that you have loaded
                such a driver, but into another interrupt.
        > Solution:  WetSpot 2 requires the SBMIDI driver to be loaded into
                interrupt 80h, so you must free it and then load the driver
                again, assuring that it's loaded into the right int. In case
                you'll not be able to do so, you'll have to disable the musics
                in the SETUP program.

Message: "Failed to reset sound card DSP, run SETUP again."
        þ Cause:  WetSpot 2 was unable to reset the DSP of your sound card,
                or a sound card was not found on your system.
        > Solution:  Run the SETUP program again.

If you get an unexpected error message, please contact me and tell me how this
has occured; this will help me a lot in the game debugging. See also the next
appendix for the known bugs list.


=============================================================================
APPENDIX C - KNOWN BUGS AND PROBLEM RESOLUTIONS
=============================================================================

This game has been tested a lot, but some errors could occur. If it happens,
try looking at the APPENDIX B - Error messages, and then, if your error is
unavoidable, this section.
Here follows a list of the few known bugs and their possible solutions:

Problem:  The game crashes during initialization.
        þ Cause:  Probably it's a problem with your expanded memory manager;
                W2 has an EMS detection routine, but it can fail and if the
                EMM isn't loaded, the result would be this.
        > Solution:  Load an expanded memory manager at the start up of your
                computer. See section "1.3 - Installing the game" for details.

Problem:  The game runs, but I can't hear any music coming out of my speakers,
        though I think I've successfully executed the SETUP program.
        þ Cause:  You've not run correctly the SETUP program.
        > Solution:  Exit the game and run SETUP, then execute W2 again.

Problem:  I can see small flashes into the firework animations on the Top 10
        screen.
        þ Cause:  This is a small bug I still haven't fixed...
        > Solution:  This error should let you play without problems.

Problem:  My girlfriend hates me.
        þ Cause:  ??
        > Solution:  Let her hate you even more...

Problem:  Suddenly the game ended with a brief error message while I was
        playing (any world or area).
        þ Cause:  Unknown problem.
        > Solution:  Please let me know exactly how this error occured, so I
                can fix it!

Problem:  While playing with my joystick, the player moves almost randomly.
        þ Cause:  Your joystick is too sensible.
        > Solution:  Adjust the joystick resolution into the SETUP program.
                See section "2.3 - Controls" for details.

Problem:  The game crashed and before this happened I heard strange noises
        coming out of my speakers.
        þ Cause:  I've had this problem a few times, and I think it's due to
                a bad EMS or DMA channel initialization.
        > Solution:  If you hear strange noises, exit the game before it's
                too late, then start W2 again; I've never heard the noises
                after running the game twice.

Problem:  I hear the musics, but I don't hear any sounds...
        þ Cause:  You have bad sound settings.
        > Solution:  Run SETUP again and change your sound card settings.

Problem:  This game really sucks!
        þ Cause:  Me.
        > Solution:  Play it!

Problem:  The game crashed and the music was still playing...
        þ Cause:  This error may occur if you have an old sound card; I've
                heard that SB 2.0 gives this problem, and this is probably
                due to the DMA transfer before playing a sound.
        > Solution:  I'll ask to the author of the last version of DMAplay
                (Toshihiro Horie) to solve this...

Problem:  The sounds are distorted when running from Windows 95.
        þ Cause:  Bill Gates.
        > Solution:  Restart the game or load it while in plain DOS mode.

Problem:  The game still crashes while playing a sound!
        þ Cause:  Unknown.
        > Solution:  I'm not able to answer your question; you should try
                asking to Toshihiro Horie, because he's the author of the
                DMAplay routine I used to play sounds. His E-Mail address can
                be found in section "3.2 - Credits" of this manual.


=============================================================================
APPENDIX D - HINTS
=============================================================================

WetSpot 2 has 7 different kinds of enemies: each of them can attack you in
different ways. Let's examine these enemies and how to handle them:
WORM    This is the easiest enemy of the game. It moves almost randomly and
        it's easy to avoid it, since it's really slow.
BEE     Bees go slow, but are smarter than worms. The problem is that when
        they see you, they begin to run and become really hard to avoid. So
        don't let they be in your same column or line, it may be dangerous.
PENGUIN A penguin goes slow, but it's one of the smartest enemies. It fires
        eggs which can kill you, so don't let it stay in front of you!
SHARK   Those lettle purple sharks are the less intelligent enemy of the game.
        They always go into a diagonal direction, and when they hit a wall,
        they invert their run. They can't go in small passages, but they are
        fast, so be careful.
GHOST   Unlike in WetSpot 1, here ghost can't teleport themselves. They go
        slowly seeking you, and when they see their target, they fires fast
        bubbles which can trap leaving you for a little time without defences.
        Don't let they trap you!
MOUSE   Mice are intelligent and fast creatures. It can be really dangerous
        having one of them behind you... Fortunately they don't fire!
PUTTY   What are those little yellow bags? If mice were dangerous, these ones
        are terrible! They're less intelligent than mice, but they fires small
        green slimes that bounce on the walls for a little time... This is the
        hardest enemy, what else to say?

Try to be always behind a block that can move for a long distance; infact the
more enemies you hit with the same block, the more points you gain. The first
enemy will let you gain 100 pts, the second 200, the third 400 and then 800,
1600, 3200 and 6400 for each other one you hit.
Each area has its own password that lets you begin a new game where you ended
your last one. Don't forget these words!
If you're really in trouble and you can't do a level, you can use a cheat
code. Here is a list of the cheat code, so

**** DON'T READ THE FOLLOWING TEXT IF YOU WANT TO PLAY THE GAME AS IS... ****

During the game, press:
CTRL-ALT-F5     Player one gains an extra life
CTRL-ALT-F6     Player two gains an extra life (two players mode only)
CTRL-ALT-F7     Freezes all the enemies (hit again to resume them)
CTRL-ALT-F8     All the enemies are killed
CTRL-ALT-F9     You automatically pass the current area
CTRL-ALT-F10    Shows the end of the game

=============================================================================

- End of document -

