About
=====

Doom2D:Rembo is a Linux port of Doom2D game,
free DOS two-dimensional arcade created by Russian game company "Prikol Software"
in early 1996 being inspired by original DOOM game by id Software.

Authors
=======

Original Doom2D authors were Aleksey Volynskov, Vladimir Kalinin and Eugeniy Kovtunov.
They called themselves as Prikol Software company.
Aleksey Volynskov worked under game engine.
Vladimir Kalinin created unique sounds.
Eugeniy Kovtunov helped them both with graphics.
Most of game levels were designed by Vladimir Kalinin, other ones is Aleksey Volynskov's.

Over some time boys dropped Doom2D developing.
Soon Aleksey Volynskov opened source code and
shared it at Gaijin Entertainment site.
Some remakes were designed and gathered at Doom2D forum.

In summer 2011 <ARembo@gmail.com> decided to port Doom2D to Linux and
started work under Doom2D:Rembo project at code.google.com.
Andriy Shinkarchuck <adriano32.gnu@gmail.com> helped him with documentation and
some other things.

Installation
============

For installation instructions see INSTALL file in source tree.

Game modes
==========

In Doom2D:Rembo like in original Doom2D you can select
to start "One player" or "Two player" new game.
When "Two player" selected, you can select "Cooperative" (play like a team) or
"Deathmatch" (against each other) game.

Configuration
=============

Doom2D:Rembo like original Doom2D can be configured both with config file and
command line parametres.

For default config file see /usr/share/doom2d-rembo/default.cfg.

Below all acceptable config options and command line parametres are listed.

Config options:

   screenshot=[on|off]

      Allow to make screenshots by pressing F1 key. You should not use F1 for pl1_* and
      pl2_* options with this option.
      Screenshots will be saved to $HOME/.doom2d-rembo directory.

   sound_volume=<0-128>

      Specify sounds volume level from 0 to 128.

   music_volume=<0-128>

      Specify music volume level from 0 to 128.

   fullscreen=[on|off]

      Launch in fullscreen.

   sky=[on|off]

      Enable background rendering.

   gamma=<0-4>

      Specify brightness level from 0 to 4.

   screen_width=<numerical value>

      Specify launched window width in pixels.

   screen_height=<numerical value>

      Specify launched window height in pixels.

   music_random=[on|off]

      Enable random music selection.

   music_time=<numerical value>

      Specify each music track duration in minutes.

   music_fade=<numerical value>

      Specify fade between music tracks in seconds.

   pl1_left=<key>
   pl1_right=<key>
   pl1_up=<key>
   pl1_down=<key>
   pl1_jump=<key>
   pl1_fire=<key>
   pl1_next=<key>
   pl1_prev=<key>
   pl1_use=<key>

   pl2_left=<key>
   pl2_right=<key>
   pl2_up=<key>
   pl2_down=<key>
   pl2_jump=<key>
   pl2_fire=<key>
   pl2_next=<key>
   pl2_prev=<key>
   pl2_use=<key>

      Specify first and second players' keys respectively for left and right moving,
      up and down looking, jumping, shooting, weapon change forward and back,
      switching controls.

   Avaliable keys for pl1_* and pl2_* config file options are listed below.

   Single word keys (typed here in lines by groups):

      backspace tab clear return pause escape space
      ! " # $ & ' ( ) * + , - . /
      0 1 2 3 4 5 6 7 8 9
      : ; < = > ? @ [ \ ] ^ _ `
      a b c d e f g h i j k l m n o p q r s t u v w x y z
      delete
      [0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [.] [/] [*] [-] [+]
      enter equals up down right left insert home end page up page down
      f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15
      numlock
      break menu power euro undo compose help

   Double word keys (it means that following keys consists of two words and
   you should write e.g.
   `pl1_left=caps lock'
   without quotes in your custom config):

      caps lock
      scroll lock
      right shift
      left shift
      right ctrl
      left ctrl
      right alt
      left alt
      right meta
      left meta
      left super
      right super
      alt gr
      print screen
      sys req

Command line parametres:

   -file <file.wad>

      Specify custom .wad or .lmp file.

   -config <config_file.cfg>

      Specify custom config file.

   -warp <numerical value>

      Specify start map number.

   -vga

      Allow to make screenshots by pressing F1 key. You should not use F1 for pl1_* and
      pl2_* options with this option.   
      Screenshots will be saved to $HOME/.doom2d-rembo directory.

   -sndvol <0-128>

      Specify sounds volume level from 0 to 128.

   -musvol <0-128>

      Specify music volume level from 0 to 128.

   -fullscr

      Launch in fullscreen.

   -window

      Launch in window mode.

   -gamma <0-4>

      Specify brightness level from 0 to 4.

   -width <numerical value>

      Specify launched window width in pixels.

   -height <numerical value>

      Specify launched window height in pixels.

   -cheat

      Allow cheats in two player mode.

   -mon

      Allow monsters in two player mode "Deathmatch".
