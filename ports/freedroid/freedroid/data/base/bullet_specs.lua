--[[

This file specifies the bullets that exist in the game. Bullets can be fired by
weapon or skill.

A bullet is defined by the following fields:

	name (string)
	-- The name of the bullet. Must be unique and not empty.
	-- Must be the first part of the complete filename of images.

	sound (string)
	-- Played when bullet is fired.
	-- Must be the filename of the sound.

	phases (int)
	-- The number of different images used by the animation.

	phases_per_second (double)
	-- The speed of the animation in image/second.

	blast_type (string)
	-- The blast of the bullet.

Bullet assets:

	Image relative path = /graphics/bullets/iso_bullet_%name%_%direction%_%phase%.png
	-- Number of direction = 16
	-- %phase% start from 0 to number of phases specified.

	Sound relative path = /sound/effects/%sound%

--]]

bullet_list {

-- this is the 476 standard shot
{
	name = "single",
	sound = "Single_Pulse.ogg",
},

-- this is the double 821 military shot
{
	name = "military",
	sound = "Military.ogg",
},

-- this is the exterminator, the 883 uses
{
	name = "exterminator",
	sound = "Exterminator.ogg",
	blast_type = "iso_blast_exterminator",
},

-- this is the laser rifle of the 614
{
	name = "laser_rifle",
	sound = "Phaser.ogg",
},

-- this is half of the influencer primitive rifle
{
	name = "half_pulse",
	sound = "Single_Laser.ogg",
},

-- this is even less than half of the influencer shot, only a white ball so far
{
	name = "plasma_white",
	sound = "Plasma_Pistol.ogg",
},

-- this is the electro laser shoot of the Electro Laser Rifle
{
	name = "electro_laser",
	sound = "Exterminator.ogg",
	blast_type = "iso_blast_droid",
},

-- this is the 12-gauge shotgun bullet, showing nice spread
{
	name = "shotgun",
	sound = "Single_Pulse.ogg",
	phases = 4,
	phases_per_second = 6,
},

-- this is the yellow-red laser sword
{
	name = "NO BULLET IMAGE - melee",
},

-- this is the yellow-red laser axe
{
	name = "NO BULLET IMAGE - axe",
},

-- end of bullet_list
}
