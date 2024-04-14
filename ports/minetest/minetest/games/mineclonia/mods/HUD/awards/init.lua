-- Copyright (c) 2013-18 rubenwardy. MIT.

-- Internationalization support.
local S = minetest.get_translator(minetest.get_current_modname())

-- The global award namespace
awards = {
	show_mode = "hud",
	registered_awards = {},
	registered_triggers = {},
	on_unlock = {},
	translator = S,
}

-- Load files
local modpath = minetest.get_modpath(minetest.get_current_modname()).."/src"
dofile(modpath.."/data.lua")
dofile(modpath.."/api_awards.lua")
dofile(modpath.."/api_triggers.lua")
dofile(modpath.."/chat_commands.lua")
dofile(modpath.."/gui.lua")
dofile(modpath.."/triggers.lua")

awards.load()
minetest.register_on_shutdown(awards.save)

local function check_save()
	awards.save()
	minetest.after(18, check_save)
end
minetest.after(8 * math.random() + 10, check_save)


-- Backwards compatibility
awards.give_achievement     = awards.unlock
awards.getFormspec          = awards.get_formspec
awards.showto               = awards.show_to
awards.register_onDig       = awards.register_on_dig
awards.register_onPlace     = awards.register_on_place
awards.register_onDeath     = awards.register_on_death
awards.register_onChat      = awards.register_on_chat
awards.register_onJoin      = awards.register_on_join
awards.register_onCraft     = awards.register_on_craft
awards.def                  = awards.registered_awards
awards.register_achievement = awards.register_award
