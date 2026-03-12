# mcl_jukebox

## mcl_jukebox.registered_records

Table indexed by item name containing record definitions


## mcl_jukebox.register_record(record_definition)

record_definition:
{
	title = "title", --title of the track
	author = "name", --author of the track
	id = "id", -- short string used in the item registration
	image = "img.png", -- the texture of the track
	sound = "minetest_sound", -- sound file of the track
	exclude_from_creeperdrop = true, --set to true if this record should be excluded from the random drop when creepers get shot by skeletons.
}

## mcl_jukebox.register_record(title, author, identifier, image, sound, nocreeper)
This is the old way to use the register function. It is still provided for backwards compatibility reasons. It will convert the arguments to the definition format.
