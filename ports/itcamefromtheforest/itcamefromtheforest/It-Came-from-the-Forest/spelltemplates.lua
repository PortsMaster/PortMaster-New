local SpellTemplates = class('SpellTemplates')

function SpellTemplates:initialize()

	self.templates = {}

	self:addTemplate("lesser-heal", "Lesser heal", "player", "spelleffect-heal", 5, { ["health"] = 25 })
	self:addTemplate("full-heal", "Full heal", "player", "spelleffect-heal", 15, { ["health"] = 100 })
	self:addTemplate("firebolt", "Firebolt", "enemy", "spelleffect-fireball", 5, { ["atk"] = 10 })
	self:addTemplate("fireball", "Fireball", "enemy", "spelleffect-fireball", 15, { ["atk"] = 25 })
	self:addTemplate("town-portal", "Town portal", "player", "spelleffect-townportal", 5, {})

end

function SpellTemplates:addTemplate(id, name, target, imageid, manacost, modifiers)

	self.templates[id] = {
		id = id,
		name = name,
		target = target,
		imageid = imageid,
		manacost = manacost,
		modifiers = modifiers
	}
	
end	

function SpellTemplates:get(id)

	return table.shallow_copy(self.templates[id])
		
end

function SpellTemplates:dump()

	print(inspect(self.templates))
		
end

return SpellTemplates