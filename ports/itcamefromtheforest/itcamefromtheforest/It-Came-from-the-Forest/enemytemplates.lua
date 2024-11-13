local EnemyTemplates = class('EnemyTemplates')

function EnemyTemplates:initialize()

	self.templates = {}

	local template = {
		id = "lizard_warrior",
		name = "Lizard warrior",
		group = "melee",
		atk = 6,
		def = 5,
		hps = 50,
		mps = 0,
		exp = 30
	}
	
	self.templates[template.id] = template
	
	local template = {
		id = "lizard",
		name = "Lizard",
		group = "melee",
		atk = 3,
		def = 2,
		hps = 20,
		mps = 0,
		exp = 15
	}
	
	self.templates[template.id] = template
	
	local template = {
		id = "lizard_hatchling",
		name = "Lizard hatchling",
		group = "melee",
		atk = 1,
		def = 1,
		hps = 5,
		mps = 0,
		exp = 5
	}
	
	self.templates[template.id] = template	
	
	local template = {
		id = "lizard_wizard",
		name = "Lizard Wizard",
		group = "caster",
		range = 2,
		atk = 1,
		def = 1,
		hps = 10,
		mps = 100,
		exp = 10,
		spellbook = { "fireball" },
	}
	
	self.templates[template.id] = template		
	
	local template = {
		id = "lizard_ranger",
		name = "Lizard Ranger",
		group = "ranged",
		range = 2,
		atk = 2,
		def = 1,
		hps = 10,
		mps = 0,
		exp = 10
	}
	
	self.templates[template.id] = template		
	
end

function EnemyTemplates:get(id)

	return table.shallow_copy(self.templates[id])
		
end

return EnemyTemplates