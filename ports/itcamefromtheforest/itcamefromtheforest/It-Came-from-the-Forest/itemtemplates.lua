local ItemTemplates = class('ItemTemplates')

function ItemTemplates:initialize()

	self.templates = {}

	-- start equipment

	self:addTemplate("sword-1", "Wooden training sword", "weapon", { ["atk"] = 1})

	-- forest-1 (150 gold, 2 healing-potion)

	self:addTemplate("ring-1", "Ring", "finger", { ["atk"] = 1 })
	self:addTemplate("cape-1", "Cape", "back", { ["def"] = 1 })

	-- dungeon 1 (50 gold)

	self:addTemplate("compass", "Compass", "compass", {})

	-- city (250 gold, 1 healing-potion, 1 mana-potion)

	self:addTemplate("dagger-1", "Dagger", "weapon", { ["atk"] = 2 })

	self:addTemplate("boots-1", "Boots", "feet", { ["def"] = 1 })
	self:addTemplate("gloves-1", "Gloves", "hands", { ["def"] = 1, ["maxmp"] = 5 })
	self:addTemplate("armor-1", "Armor", "torso", { ["def"] = 2 })
	self:addTemplate("helmet-1", "Helmet", "head", { ["def"] = 1 })
	self:addTemplate("spellbook-1", "Ancient tome I", "offhand", {})

	self:addTemplate("map", "Map", "map", {})
	
	-- forest-2 (2000 gold, 5 healing-potion, 5 mana-potion)
	
	self:addTemplate("sword-2", "Short sword", "weapon", { ["atk"] = 3 })
	self:addTemplate("axe-1", "Axe", "weapon", { ["atk"] = 3, ["def"] = 1 })

	self:addTemplate("belt-1", "Belt", "waist", { ["def"] = 1 })
	self:addTemplate("boots-2", "Boots", "feet", { ["def"] = 2 })
	self:addTemplate("cape-2", "Cape", "back", { ["def"] = 2, ["maxmp"] = 5 })
	self:addTemplate("armor-2", "Armor", "torso", { ["def"] = 4, ["maxhp"] = 5 })
	self:addTemplate("gloves-2", "Gloves", "hands", { ["def"] = 2 })

	self:addTemplate("necklace-1", "Necklace", "neck", { ["def"] = 1, ["atk"] = 1, ["maxmp"] = 5 })
	
	-- dungeon-2

	self:addTemplate("spellbook-2", "Ancient tome II", "offhand", {["maxmp"] = 10})
	
	-- dungeon-3
	
	self:addTemplate("sword-3", "Sword", "weapon", { ["atk"] = 4 })
	self:addTemplate("ring-2", "Ring", "finger", { ["atk"] = 2 })

	-- dungeon-4m
	
	self:addTemplate("club", "Club", "weapon", { ["atk"] = 4, ["def"] = 1 })
	self:addTemplate("belt-2", "Belt", "waist", { ["def"] = 2, ["atk"] = 1 })
	
	-- dungeon-5
	
	self:addTemplate("boots-3", "Boots", "feet", { ["def"] = 3, ["atk"] = 2 })
	self:addTemplate("necklace-2", "Necklace", "neck", { ["def"] = 2, ["atk"] = 2, ["maxhp"] = 5 })
	
	-- dungeon-6

	self:addTemplate("ring-3", "Ring", "finger", { ["def"] = 3, ["maxhp"] = 5, ["maxmp"] = 5 })
	self:addTemplate("helmet-2", "Helmet", "head", { ["def"] = 2 })

	-- not in use

	self:addTemplate("dagger-2", "Dagger", "weapon", { ["atk"] = 4 })
	self:addTemplate("mace", "Mace", "weapon", { ["atk"] = 4 })
	self:addTemplate("sword-4", "Sword", "weapon", { ["atk"] = 8 })

	-- dungeon-7

	self:addTemplate("ring-4", "Ring", "finger", { ["def"] = 2 })
	self:addTemplate("cape-3", "Cape", "back", { ["def"] = 3, ["atk"] = 1 })
	self:addTemplate("spellbook-3", "Ancient tome III", "offhand", {["maxmp"] = 20})
	
	-- dungeon-8

	self:addTemplate("gloves-3", "Gloves", "hands", { ["def"] = 3, ["atk"] = 1 })
	self:addTemplate("axe-2", "Battle axe", "weapon", { ["atk"] = 5, ["def"] = 2 })
	self:addTemplate("armor-3", "Armor", "torso", { ["def"] = 6, ["maxhp"] = 5 })

	-- dungeon-9

	self:addTemplate("helmet-3", "Helmet", "head", { ["def"] = 3 })
	self:addTemplate("sword-5", "Diamond sword", "weapon", { ["atk"] = 15 })
	self:addTemplate("belt-3", "Belt", "waist", { ["def"] = 3, ["atk"] = 2 })
	self:addTemplate("necklace-3", "Necklace", "neck", { ["def"] = 3, ["atk"] = 3 })
	self:addTemplate("armor-4", "Armor", "torso", { ["def"] = 8 })

	-- keys

	self:addTemplate("key-1", "Chest key", "key", {})
	self:addTemplate("key-2", "Emerald key", "key", {})
	self:addTemplate("key-3", "Steel key", "key", {})
	self:addTemplate("key-4", "Ruby key", "key", {})

	--

	self:addTemplate("healing-potion", "Healing potion", "potion", {})
	self:addTemplate("mana-potion", "Mana potion", "potion", {})



end

function ItemTemplates:addTemplate(id, name, slot, modifiers)

	self.templates[id] = {
		id = id,
		name = name,
		slot = slot,
		modifiers = modifiers
	}
	
end	

function ItemTemplates:get(id)

	return table.shallow_copy(self.templates[id])
		
end

return ItemTemplates