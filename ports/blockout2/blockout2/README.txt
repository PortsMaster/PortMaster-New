BlockOut v2.5 by Jean-Luc PONS (jlp_38@yahoo.com)

Description
===========

  BlockOut II is an OpenbGL adaptation of the original BlockOut DOS 
  game edited by California Dreams in 1989. BlockOut II has the same features 
  than the original game with few graphic improvements. Score calculation is 
  also nearly similar to the original Game. BlockOut II has been designed by 
  an addicted player for addicted players.
  
  Have fun with BlockOut II...

  --------------------------------------------------------------------------------------
  Blockout® is a registered trademark of Kadon Enterprises, Inc., used by permission. 
  This USA company produces hands-on sets of polycubes since 1980. "www.gamepuzzles.com"
  --------------------------------------------------------------------------------------

Official Home Page
==================

http://www.blockout.net/blockout2

What do you need ?
==================

Windows platform:

  -OpenGL

Linux platform (here ubuntu packages are listed):

  -libgl1-mesa-swx11
  -libglu1-mesa
  -libxext6
  -libsdl1.2
  -libsdl-mixer1.2

  (for compilation)
  -libgl1-mesa-swx11-dev
  -libglu1-mesa-dev
  -libxext-dev
  -libsdl1.2-dev
  -libsdl-mixer1.2-dev

How to install ?
================

Widows:  - Run the Setup program

Linux:   - Extract the bl2-linux-(ARCH).tar.gz file
         - Set the BL2_HOME environment variable to the bl2 directory  

Version history
===============

  2.5:
    -64bits support
    -OpenGL is now used both on Linux and Windows
    -Little graphics improvements
    -Pratice mode improvements
    -Improved the demo mode (Bot player plays better)
    -Local data directory move from installation directory to "AppData" directory (See notes).

  2.4:
    -Added frame limiter
    -Added demo mode
    -Added pratice mode
    -Fixed replay bug
    -Fixed random generator (FLAT block set)
    -Fixed fullscreen bug (Linux)

  2.3:
    -Added player/rank name when replaying
    -New punctuation characters added
    -Little effect when rotation is blocked
    -Fixed "Cannot open blX.bl2replay for writting"
    -New style (Marble/Arcade)
    -Fixed crash when pressing [Esc]
    -Pit animation when the game is over
    -Jump to Score Details page after end of game
    -Added DOS blockout sound preset
    -New randomizer (See notes)
    
  2.2:
    -NUMPAD Key control added
    -Block transparency configurable with slider
    -Abort menu startup demo with [Esc]
    -Empty pit (Flush) in score details added
    -On-line score database (available from the game or from the home page)
    -Replay
    -Credits page added
    -Other minor updates

  2.1:
    -Fixed block descent algorithm (Game should be easier, especialy when playing at
     the top of the pit)
    -Increased a little bit drop time (It has been reported too fast)
    -Improved tuning of motion speed (Rotation speed in the options menu)
      
  2.0:
    Initial realease

How to retrieve your high score and config when moving from release 2.4 to 2.5?
===============================================================================

Uninstal Blockout.
Install 2.5 or newer release.
Launch the game (It should create the Blockout directory in C:\Users\(user name)\AppData\Local)
Go to the old blockout instalation directory (which can be the same than the 2.5 release).
Select "replay","hscore.dat","replay.idx","setup.dat".
Move them to C:\Users\(user name)\AppData\Local\Blockout.
Note that the Users and AppData directories may be hidden.

How to compile the source ?
===========================

  - BlockOut II source can be donwloaded from sourceforge http:/sourceforge.net/projects/blockout

Windows:

  - You need Microsoft VS2013
  - Set all appropriate include and lib paths in the project properties
    (for ImageLib)
  - Set the working directory to the BlockOut project root

Linux:

  - Execute make within the ImageLib source directory
  - Edit the Makefile in the blockout directory and set the appropriate PATH to the ImageLib
  - Execute make or (make _linux64=1 on 64bits OS) in the BlockOut directory
  
About Replay (.bl2replay) file
==============================

  For each high score you make, a .bl2replay file is created within
  the directory InstallPath/replay (or $(HOME)/.bl2/replay for linux).
  These files contain replay data which are needed if you want to upload
  your score to the on-line score database. A replay can be uploaded 
  only once as soon as it has been successfully registered. If you 
  abort a game by pressing [Esc], the replay file won't be saved.
  A file name starting with 'l' means local replay, with a 'r' means
  remote replay.

About Score Uploading
=====================

  To upload your high score to the online database, just go to the
  Score Details page and select Upload. You can enter a different
  name and a comment. Note that only score made with a release
  >=2.2 can be uploaded (Replay file needed).

About the Randomizer:
=====================

 The Blockout II random generator generates a sequence of all possible 
 pieces (depending on the pit dimension and block set) permuted randomly,
 as if they were drawn from a bag. Then it deals all pieces of the 
 sequence before generating another bag. It is not possible to get
 3 times the same piece. The random permuation is generated by a classic
 linear congruential generator.

About the Frame limiter and Vertical synch mode:
================================================

 To synchronize animations with the vertical blanking of the monitor 
 you have to select VSync in the frame limiter setting, to save your
 setup and to restart the application.
     
Copying
=======

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
