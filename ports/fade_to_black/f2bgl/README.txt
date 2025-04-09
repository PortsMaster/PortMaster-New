
f2bgl README
Release version: 0.2.7
-------------------------------------------------------------------------------


About:
------

f2bgl is a re-implementation of the engine used in the game Fade To Black
made by Delphine Software and released in 1995.


Running:
--------

You will need the original files of the PC release or PC demo.

By default, the program will try to load the game data files from the current
directory. The expected directory structure is :

	DELPHINE.INI
	TRIGO.DAT    - optional
	DATA/
	DATA/DRIVERS/
	DATA/SOUND/
	INSTDATA/    - optional
	TEXT/        - not present with demo version
	VOICE/       - not present with demo version

Defaults can be changed using command line switches :

    Usage: f2b [OPTIONS]...
    --datapath=PATH             Path to data files (default '.')
    --language=EN|FR|GR|SP|IT   Language files to use (default 'EN')
    --playdemo                  Use inputs from .DEM files
    --level=NUM                 Start at level NUM
    --voice=EN|FR|GR            Voice files (default 'EN')
    --subtitles                 Display cutscene subtitles
    --savepath=PATH             Path to save files (default '.')
    --fullscreen                Fullscreen display (stretched)
    --fullscreen-ar             Fullscreen display (4:3 aspect ratio)
    --soundfont=FILE            SoundFont (.sf2) file for music
    --texturefilter=FILTER      Texture filter (default 'linear')
    --texturescaler=NAME        Texture scaler (default 'scale2x')
    --mouse                     Enable mouse controls
    --no-fog                    Disable fog rendering
    --no-gouraud                Disable gouraud shading


Controls:
---------

The game can be played using a joystick, a gamepad or the keyboard.
Key mappings can be changed by editing the file 'controls.cfg'.

In-game keys (default) :

    Arrow Keys     move Conrad
    Alt / V        toggle gun mode
    Shift          walk
    Ctrl / B       shoot
    Enter          reload gun
    Space          activate
    Tab            change inventory category
    Escape         save/load menu
    I              inventory menu
    J              jump
    U              use
    1 .. 5         use item #
    S              save game state
    L              load game state
    T              take screenshot
    + and -        change game state slot


Credits:
--------

Delphine Software for creating the game.


Contact:
--------

Gregory Montoir, cyx@users.sourceforge.net
