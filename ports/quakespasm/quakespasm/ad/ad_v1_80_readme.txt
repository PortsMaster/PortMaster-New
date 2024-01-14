==============================================================================

Title        : AD v1.80 - (Arcane Dimensions)
Date         : October 2020
MOD Team     : Simon OCallaghan - Art, Code and Level Design
             : Maik Franz Xaver - Art and Level Design
             : Corey Jones - Animation and Code Support
             : Matthew Breit - Animation, Art, Code Support and Level Design
             : Sean Campbell, Gavin Edgington, Noel Lacaillade - Level Design
             : Henrik Oresten, Andrey Saenko, Dmitry Svetlichny - Level Design
             : Eric Wasylishen - LD Compiler Support and Level Design
             : Andrew Denner - Art, Compiler tools and Code Support
             : Benoit Stordeur - Art and Level Design
			 
Additional   : Bengt Jardrup for WinQuake support and Code Support
thanks       : John Fitzgibbons for Rubicon2 Art assets and Code functions
             : Kristian Duske for editor/map GTK conversion tools
             : Kell McDonald for Quoth Art assets & Madfox for Art assets
             : Stas Kuznetsov for all the g/v player weapon models
             : Louis Manning for Animation, Art and Code Support
             : Renier Banninga for Animation and Art
             : Benjamin Hale for new texture set (ad_tears)
             : Michael Markie for Music, Ambient Sounds and Chaos mode idea 
             : Jose Carlos Rodriguez for Jump Boots idea from modjam1
             : Romain Barrilliot for help with gameplay balance/testing
             : Dan Ellis for creating and verifying the 1.7 FGD editor files

Please note  : This is an alternative universe of Quake, many assets and
             : features have changed, even though it may look the same in 
             : places this code base and assets are very much different.
			 
Shotguns     : All of the shotguns have been changed to projectiles instead of
             : hitscan impact. If you don't like this change use impulse 130
             : to switch between either system or edit the quake.rc file.

Name and QC  : Do not use the AD (Arcane Dimension) name for your own mod
             : All the QC files are included and covered under GPL
			 
Additional   : The majority of the textures are based on existing Quake assets
Compilers &  : BSP/VIS Compilers - by Kevin Shanahan/Eric Wasylishen
Dev tools    : Latest Version - ericwa.github.io/tyrutils-ericw/
             : FP map format - (www.voidspark.net/projects/bjptools_xt/)
             : TexMex 3.4 by Mike Jackman (organize textures)
             : AdQuedit 1.3 by Hicks Goldrush (updating skins)
             : QME 3.1 patch 2 by Rene Post (Change/update models)
             : Quake C FTEQCC Compiler (fte.triptohell.info/)

Engines      : The MOD is designed to work with the QS-Spike Engine
               Other engines offer partial support of features

* QuakeSpasm : Version 0.93.0+ (Must use the latest version)
    - Download (http://quakespasm.sourceforge.net/download.htm)
* QS-Spike   : (https://fte.triptohell.info/moodles/qss/)
* MarkV      : (http://quakeone.com/markv/) - does not support protocol 999 for cinematics
* Darkplaces : Version 12 April 2018 (Check Darkplaces discord channel for latest)
    - Website  (https://hemebond.gitlab.io/darkplaces-www/)
    - Download (https://icculus.org/twilight/darkplaces/files/darkplacesengine20180412beta1.zip)

	
==============================================================================
Installation
------------------------------------------------------------------------------

* Create a new folder called "ad" in your Quake folder
* Copy the Zip file into the new folder
* Extract the contents of the zip file
* Create a shortcut to your preferred Quake engine
* Add the following to the command line

 -game ad

* The above command line is only needed if engine runs really slow 
* Run the shortcut (click icon) and make sure the engine loads
* After the start map has loaded pick your skill level

MOD Maps
------------------------------------------------------------------------------
* start        - Hodgepodge of themes and portals (Simon OCallaghan)
* ad_cruical   - Lava caves and industrial complex (Maik Franz Xaver)
* ad_dm1       - Place of Many Deaths (Gavin Edgington)
* ad_lavatomb  - Stone city gradually sinking into lava (Noel Lacaillade)
* ad_mountain  - Dark stone mountain prison (Simon OCallaghan)
* ad_necrokeep - The Necromancer Keep! (Sean Campbell/Matthew Breit)
* ad_obd       - A giant pile of neatly stacked bricks (Simon OCallaghan)
* ad_swampy    - Gigantic interconnected medieval town (Maik Franz Xaver)
* ad_end       - Final destination for AD travellers (Maik Franz Xaver)

v1.5+ Maps
------------------------------------------------------------------------------
* ad_chapters  - More themes and portals (Simon OCallaghan)
* ad_azad      - The Realm of Enceladus (Maik Franz Xaver)
* ad_tfuma     - Terror Fuma (Gavin Edgington/Eric Wasylishen)
* ad_magna     - Leptis Magna (Noel Lacaillade/Andrey Saenko)
* ad_metmon    - Arcane Monstrosity (Simon OCallaghan)
* ad_zendar    - The Horde of Zendar (Simon OCallaghan)

v1.6+ Maps
------------------------------------------------------------------------------
* ad_sepulcher - The Forgotten Sepulcher (Henrik Oresten/Simon OCallaghan)

v1.7+ Maps
------------------------------------------------------------------------------
* ad_ac       - Arcane Adamantine (Dmitry Svetlichny/Simon OCallaghan)
* ad_s1m1     - Slipgate Conundrum (Simon OCallaghan)

v1.8+ Maps
------------------------------------------------------------------------------
* ad_akalakha - Ak-Alakha (Andrey Saenko)
* ad_grendel  - Grendels' Blade (Simon OCallaghan)
* ad_scastle  - Nyarlathoteps Sand Castle (Simon OCallaghan)
* ad_tears    - Tears of the False God (Benoit Stordeur)

Remix Maps
------------------------------------------------------------------------------
* ad_dm5     - The Mire (Noel Lacaillade)
* ad_e1m1    - Hangar 16 (Sean Campbell)
* ad_e2m2    - Ogre Bastille (Simon OCallaghan)
* ad_e2m7    - The Underearth (Eric Wasylishen)

Test Maps
------------------------------------------------------------------------------
* start_test - Round brick hub map with portals in all directions (SimonOC)
* ad_test1   - Breakables, new ambush surprises and monster reactions (SimonOC)
* ad_test2   - Egyptain blast from the past hanuted by Wraiths (SimonOC)
* ad_test3   - Hipnotic rotation; cogs, wheels and medieval fans! (MFX)
* ad_test4   - Small medieval courtyard with statues and Golems (SimonOC)
* ad_test5   - Large village square guarded by Minotaurs (SimonOC)
* ad_test6   - Tall medieval courtyard full of knights and ogres (SimonOC)
* ad_test7   - Multi level library full of teleporting skull wizards (SimonOC)
* ad_test8   - Giant runic room occupied by gaunts and droles (EricW)
* ad_test9   - Dark medieval chamber guarded by hammer ogres (EricW)
* ad_test10  - Plasma gun carnage in a giant brushwork box! (SimonOC)
* ad_test11  - Shooting range to test all projectile weapons (SimonOC)
* ad_test12  - Does not exist!!! or does it ...

The Rune locations required for ad_end (secret level)
------------------------------------------------------------------------------
* D-rune in Crucial Error
* N-rune in Obsessive Brick Disorder
* S-rune in Foggy Fogbottom
* K-rune in Firetop Mountain

==============================================================================
Distribution / Copyright / Permissions 

Please do not use any of these assets in ANY COMMERCIAL PROJECT.
and remember to give credit if you use any of these assets.
				  
The QC files in this MOD are based on 1.06 source files by ID Software.
These files are released under the terms of GNU General Public License v2 or
later. You may use the source files as a base to build your own MODs as long
as you release them under the same license and make the source available.
Please also give proper credit. Check http://www.gnu.org for details.

Quake I is a registered trademark of id Software, Inc.

All of these resources may be electronically distributed only at 
NO CHARGE to the recipient in its current state and MUST include this 
readme.txt file.

===========================================================================
