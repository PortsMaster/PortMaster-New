# mcl_player
## Inventory formspecs.

### mcl_player.set_inventory_formspec (player, formspec, priority)
Set PLAYER's formspec at the priority level PRIORITY to FORMSPEC or
nil.  Formspecs of higher priorities will be displayed over those of
lower ones.

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





## Player settings

```lua
-- Register a new settings button. It will automatically be added to the player
-- settings page.
mcl_player.register_player_settings_button({

	-- The formspec field name that is listened for.
	field = "__mcl_skins",

	-- The icon to display on the button.
	icon = "mcl_skins_button.png",

	-- The tooltip text to add to the button.
	description = S("Select player skin"),

	-- Buttons are displayed in order of devreasing priority.
	priority = 1000,
})

-- Register a new player setting. It will automatically be added to the player
-- settings page.
mcl_player.register_player_setting("mcl_inventory:quick_move_to_craftgrid_", {

	-- Required type of setting. Either "boolean", "enum", or "slider".
	type = "boolean"

	-- Array of enum values with descriptions and - only for type "slider" - ranges.
	-- Required for type "enum" and "slider".
	options = {
		{ name = "0", description = S("None") },
                { min = 10, max = 100, step = 10 } -- ranges are only supported for type "slider"
		{ name = "999", description = S("Unlimited") },
	},

	-- Required short description of setting.
	short_desc = S("Quick move items to craftgrid"),

	-- Optional longer description of setting.
	long_desc = S("Moves items to crafgrid when shift-clicking in inventory instead of moving between hotbar and main inventory. Defaults to the value of the corresponding server setting."),

	-- Optional section this setting belongs to. Default ist "Misc". This
	-- string will be translated in the textdomain of mcl_player.
	section = nil,

	-- Optional callback run when the setting is changed.
	on_change = function()
	end,

	-- Default value used for intializing the settings UI when the player
	-- setting is not explicitly set. Should correspond to the actual
	-- default value used in code affected by this setting (might not always
	-- be possible).
	settings_ui_default = minetest.settings:get_bool("mcl_quick_move_to_craftgrid", false),

    -- Hide the setting for clients with protocol version less than this value.
    min_protocol_version = 47,
}

-- Get the value of a player setting. It will automatically be converted to the
-- correct type. Returns `nil` if setting hasn't been registered or isn't set
-- and no `default` parameter is specified.
mcl_player.get_player_setting(player, name, default)

-- Set the value of a player setting. Setting `value` nil will remove the
-- setting from player meta.
mcl_inventory.set_player_setting(player, name, value)

-- Show the player settings formspec.
mcl_player.show_player_settings(player)

```
