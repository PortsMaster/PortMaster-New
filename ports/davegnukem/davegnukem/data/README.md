# Dave Gnukem data subfolder

This is the 'data' subfolder for this game: https://github.com/davidjoffe/dave_gnukem

NB by default the game looks in a subfolder with name "data" (not "gnukem_data") to find its data, though that may change (and should ideally become a bit more flexibly configurable someday in future)

**NB This folder is essential for the game to run**




To use this using git, clone the main game, e.g.:


$ git clone https://github.com/davidjoffe/dave_gnukem.git gnukem

$ cd gnukem

$ git clone https://github.com/davidjoffe/gnukem_data.git data

$ cd ..


OR:


@ git clone https://github.com/davidjoffe/dave_gnukem

$ cd dave_gnukem

$ git clone https://github.com/davidjoffe/gnukem_data data

$ cd ..


Thereafter, if fetching updates, you must separately update the main folder and the data subfolder.

You can do this in one go with a command like: git pull && cd data && git pull && cd ..


# Source Files for Data

See https://github.com/davidjoffe/gnukem_datasrc



# License and Additional Credits

Most of the data/sprites for Dave Gnukem are dual-licensed under MIT license or GPL.

With respect to particular **data items**, the following license conditions apply:

* 2018-03-22 Add boots sprite made by freepik.com, from flaticon.com, license Creative Commons BY 3.0
* 2017-08-04 Add font data/fonts/simple_6x8.tga by http://www.zingot.com/ from https://opengameart.org/content/bitmap-font-pack License https://creativecommons.org/licenses/by/3.0/ (small changes made to color, and convert from PNG to TGA)
* 2016-10-30 data/sounds/soft_explode.wav From same Juhani Junkala collection as per below
* 2016-10-30 data/sounds/key_pickup.wav http://opengameart.org/content/key-pickup author Vinrax, license 'CC BY 3.0' https://creativecommons.org/licenses/by/3.0/
* 2016-10-30 data/sounds/jump.wav and data/sounds/jump_landing.wav From same Juhani Junkala collection as per below
* 2016-10-23 data/sounds/shoot\_cg1_modified.wav Slightly modified version of cg1.wav from http://opengameart.org/content/chaingun-pistol-rifle-shotgun-shots by Michel Baradari http://michel-baradari.de/
	"Sounds (c) by Michel Baradari apollo-music.de
	Licensed under CC BY 3.0 http://creativecommons.org/licenses/by/3.0/
	Hosted on opengameart.org"
* 2016-10-23 data/sounds/sfx\_weapon_singleshot7.wav by Juhani Junkala (CC0 creative commons license) ("The Essential Retro Video Game Sound Effects Collection [512 sounds]")
* 2016-10 Thanks to daveywavey @ livecoding https://www.livecoding.tv/daveywavey/ for help with setting up github repo

Apart from the abovementioned, all other data included with 'version 1' is dual-licensed under MIT license or GPL.

Additional game data credits: Apart from the abovementioned, most the sprites were done by David Joffe (with some major contributions by Evil Mr Henry http://www.emhsoft.com/ including the main character sprites). Steve Merrifield made major level editing contributions. Apologies if anyone left out.
