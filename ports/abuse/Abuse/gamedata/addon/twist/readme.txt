Twisted Minds - Demo of some objects and the DEATH RAY
------------------------------------------------------

I am releasing this because i am excited due to the success of making the Death
Ray work. I will make further releases when i come across other breakthroughs.

You need registered Abuse v2.0 for this to work!
You can now press right shift to save!

This addon is still HEAVILY under construction. There are bound to be bugs.

I did not do the sounds for the new objects except for Death Ray.

The files contained in this archive are demos only! The levels are not actual
levels (except l01s02.lvl) and are for demo purposes only!

Play through the four levels through edit mode. Use god mode for the first few
tries.


RUNNING
-------

Play the game directly:
% abuse -a twist

Use the addon in the editor:
% abuse -a twist -edit -nosound


NOTES
-----

level1:	demo stuff
	use god mode.
	you will first run through a series of sensors.
	these sensors behave differently. i place a pointer
	to where these sensors are. or you could just go to
	edit mode.
	
	you will then receive weapons. (if you don't have the
	weapon, you can't fire even if you take ammo!)
	i finally managed to make the last weapon work!!!:))))))
	it will release a burst	of energy.
	it's a big round orb of purple coloured energy
	(i got the gfx from doom - the bfg bullet. i just change the hue).
	The Death Ray (what we will call that bullet) will eat through
	everything until it hits the wall. The bullet has a lifetime of
	100 state_time (i don't know how long that is. maybe 10 secs).
	It will destroy most objects in the nearby areas and will release
	a beam of light to an enemy and kill it (got idea from doom/quake2).

	you will then encounter a large amount of blocks. stand back
	and release one Death Ray (this is to show you what i mean
	in the previous paragraph). you will see the death ray hit the block,
	destroy it, and continues it's path. it doesn't dies out when it hits
	the enemy :) one single blast could kill as many as 50+ ants provided
	they are all bunched up together.

	next is the walk rob. it can only be hurt when it is walking. so you
	have to make it chase you and fire. once it dies, it will detach its head.
	it moves like a flyer.

	after that, you will see 3 switches beside someone who looks like you.
	you can change the color by changing the aitype (0-9; note that 6,8,9 dosen't
	work).
	you may encounter some other objects that could change its color by changing
	the aitype.

level2:	super mario bros
	this is meant to be a secret level in Twisted Minds!
	
	for first few tries, don't use god mode.

	it's no fun when you use those fancy weapons. if mario can get through,
	a big tough guy like you should have no problem. try to use the 1st weapon.

	tileset + characters from super mario bros.
	some pipes can be entered by pressing down.
	if you fall into any pits, you should die instantly.
	if you have god mode on just hit 'j' to jump to cursor position.

	just like any mario, there is a warp zone. just know how to get to it.

level3: raider demo
	this is a quickly done level to show one of the vehicles.
	it demonstrates some properties and fun stuff that the normal
	player probably could not do.
	once you reach the end, you will automatically go to next level.

level4: redant demo
	another quickly done level.
	you don't need god mode to be on (trust me)
	in the beginning of the level, do not turn on the switch.
	move towards the crack and 50 ants will come out.
	you can kill them all by jumping. if you got the fly power,
	just right click and move from left to right, touching the ants.

	if its getting late, go to a corner, and blast a death ray. see
	all 50 ants die.

	turn on the switch to end game.


OBJECTS
-------

i'm not listing down all the new objects i made;
just some of the ones i think you should know.

obj_cheat:	this object will automatically position itself to
		the player's x y cords. you can perform cheats
		by holding the right mouse button and type:
			vitalize	-add health
			arms		-all weapons
			reload		-full ammo
			steroids	-power fast
			liftoff		-power fly
			mirage		-power sneaky
			elixir		-power health
			visor		-power flare (not implemented yet)
			outcome		-completes the whole game

		if you press any direction button, you will have to
		retype the whole thing again
		status: REMOVED

obj_force:	use together with obj_holder.
		hold an object together with obj_force.
		you can make blocks that don't move, move.
		see level 1 for example.

sensor_gravity:	if you stand in the sensor, you will be affected
		by the gravity stated in its ai. you can make
		the player heavier or lighter.

sensor_music:	the music will change to the one stated in the ai.

sensor_health:	if you stand in the sensor, your life will decrease/increase
		according to its ai. use negative number to add health.

sensor_level:	will change the level if you are within sensor's range.
		in the ai, you will be asked for level and sector.
		level is the first 2 digits of the filename and sector
		is the last 2 digit of the file name. so if level = 2
		and sector = 5, it will load "L02s05.lvl"

sensor_teleport:behaves just like tele2 only that it will work when within
		range. you can state whether pressing the action key is required
		or not.
		NOTE: do not link sensor_teleport to another sensor_teleport if
		both of them do not need action key to activate!!! If the player
		is in range, he will switch back and fourth continously.

CHAT CONSOLE
------------

While playing the game, press 'C' to toggle chat window (it now works even when not in multiplayer mode). type the commands on the chat window then enter.

game stuff:
/quit			quits game
/break			breaks game
/save			saves a game (new! no more searching for save consoles!)
/map mapname		loads a level

cheat stuff:
/god			toggles god mode
/notarget		toggles no target... enemy wont target you (not working properly yet)
/noclip			toggles clipping
/jump			jumps player to location of mouse

/give all		gives all weapons and ammo

/give weapons		gives all weapons
/give lasergun		gives weapon lasergun
/give grenadelauncher	gives weapon grenade launcher
/give rocketlauncher	gives weapon rocket launcher
/give firebomb		gives weapon firebomb
/give plasmagun		gives weapon plasmagun
/give lightsabre	gives weapon light sabre
/give deathfrizbee	gives weapon death frizbee
/give deathray		gives weapon deathray

/give ammo		gives all ammo
/give bullets		gives ammo bullets
/give grenades		gives ammo grenades
/give rockets		gives ammo rockets
/give gasoline		gives ammo gasoline
/give plasmacells	gives ammo plasma cells
/give sabrecharger	gives ammo sabre charger
/give frizbees		gives ammo frizbees
/give bfgcells		gives ammo bfg cells

/give powernone		player gets no power
/give powerfast		player gets power fast
/give powerfly		player gets power fly
/give powersneaky	player gets power sneaky
/give powerhealth	player gets power health

/give compass		player gets compass

/give ant		try it!
/give death		try it!
/power overwhelming	try it!
/there is no cow level	try it!
/iddqd			try it!
/idkfa			try it!
/idclev			try it!

/profound		displays about
/munir			displays about
/about			displays about

/tip			displays random game tip


NEW UPDATES
-----------

You can now press right shift at any time to save game!

In the previous update, you will need to find the gun before you can shoot,
even if you already have the ammo. This is okay for twisted minds but there
are people who may want to use the death ray code to work on their own or the
Abuse's original levels. If the original level is loaded into twisted minds,
the player will have difficulty as he cannot get weapons as ammo is nothing
without it. I made some changes and it should work now. If you play twisted
minds, you will still need the gun but if you load twisted minds with the -f
command to load external levels, you wont need the gun to shoot anymore. Also
note that in the original Abuse, there are no death ray ammo so if you want
to use it, you have to cheat a little. Under the chat window, type "/give
deathray" <enter> followed by "/give bfgcells" <enter>. There you have it!

