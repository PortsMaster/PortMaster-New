# mcl_player
## Globalsteps

`mcl_player.register_globalstep(function(player, dtime))`
Functions registered this way will be run on every globalstep for each player.

`mcl_player.register_globalstep_slow(function(player, dtime))`
Functions registered this way will be run every 0.5 seconds for each player.

## Animations
The player API can register player models and update the player's appearence.

`mcl_player.player_register_model(name, def)`

 * Register a new model to be used by players.
 * name: model filename such as "character.x", "foo.b3d", etc.
 * def: See [#Model definition]

`mcl_player.registered_player_models[name]`

 * Get a model's definition
 * see [#Model definition]

`mcl_player.player_set_model(player, model_name)`

 * Change a player's model
 * `player`: PlayerRef
 * `model_name`: model registered with player_register_model()

`mcl_player.player_set_animation(player, anim_name [, speed])`

 * Applies an animation to a player
 * anim_name: name of the animation.
 * speed: frames per second. If nil, default from the model is used

`mcl_player.player_set_textures(player, textures)`

 * Sets player textures
 * `player`: PlayerRef
 * `textures`: array of textures, If `textures` is nil, the default textures from the model def are used

mcl_player.player_get_animation(player)

 * Returns a table containing fields `model`, `textures` and `animation`.
 * Any of the fields of the returned table may be nil.
 * player: PlayerRef

### Model Definition

	{
		animation_speed = 30,            -- Default animation speed, in FPS.
		textures = {"character.png", },  -- Default array of textures.
		visual_size = {x = 1, y = 1},    -- Used to scale the model.
		animations = {
			-- <anim_name> = {x = <start_frame>, y = <end_frame>},
			foo = {x = 0, y = 19},
			bar = {x = 20, y = 39},
		-- ...
		},
	}

