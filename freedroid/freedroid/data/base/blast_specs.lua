-- The image files for the blasts are stored in graphics/blasts/
-- The filenames should be in the form name_xxxx.png, where name is a blast name
-- and xxxx is a four digit phase number (starting from 1).

-- This is default blast type.
-- It should be at the first position in the file.
blast {
	name = "iso_blast_bullet",
	phases = 20,
	animation_time = 0.6,
	do_damage = 0
}

-- This blast needs to be at the second position in the file.
-- It's used for tux and obstacle explosions.
blast {
	name = "iso_blast_droid",
	phases = 20,
	animation_time = 1.0,
	do_damage = 1,
	sound_file = "Blast_Sound_0.ogg"
}

blast {
	name = "iso_blast_exterminator",
	phases = 28,
	animation_time = 1.6,
	do_damage = 1,
	sound_file = "Blast_Sound_0.ogg"
}
