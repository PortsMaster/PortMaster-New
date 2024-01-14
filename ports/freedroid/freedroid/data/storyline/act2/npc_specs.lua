-- Comments after the NPC names are meant to declare alternative i18n'd names
-- those will be set in dialog scripts (via a call to set_bot_name()).
-- Those declarations are currently needed, here, due to the separation between
-- the translation domains of dialog and config files.

-- Comments after the NPC names are meant to declare alternative i18n'd names
-- those will be set in dialog scripts (via a call to set_bot_name()).
-- Those declarations are currently needed, here, due to the separation between
-- the translation domains of dialog and config files.
npc_list{
	"Yadda",                    --[[ _"Master Yadda" ]]--
	"TerminalDenied",           --[[TRM]]--
	"TerminalColemak",          --[[TRM]]--
	"Terminal",                 --[[TRM]]--
	"Stone",                    --[[ _"Mr. Stone - Shop owner" ]]--
	"Speechless",
	"SecurityChief",            --[[ _"RR Security Chief" ]]--
	"RRGateTerminal",           --[[TRM]]--
	"RRF-ManagmentTerminal",	--[[TRM]]--
	"Prologue",
	"ProgrammingChief",         --[[ _"999 RR Manager" ]]--
	"MrSaves",                  --[[ _"Mr. Saves", _"Mr. Saves, Watcher of Stories", _"Weirdo" ]]--
	"Mike",                     --[[ _"Mike" ]]--
	"IcePass-Terminal",         --[[TRM]]--
	"Friend",
	"Fred",                     --[[ _"Fred" ]]--
	"FactoryTerminal",          --[[TRM]]--
	"CryonicsBlock-Terminal",   --[[TRM]]--
	"Colemak",                  --[[ _"Colemak", _"Dvorak's acquittance - Colemak" ]]--
	"Act2-Vending-Machine",     --[[TRM]]--
	"ArenaTerminal",
	"AfterTakeover"
	}

--[[
npc_shop{
name = "Dummy",
items = {
	 {"Big kitchen knife"},
	 {"Normal Jacket", 2}
	}
}
]]--

npc_shop{
name = "Stone",
items = {
	 {"EMP Shockwave Generator"},
	 {"Electronic Noise Generator"},
     {"Teleporter homing beacon"},
	 {"Antibiotic"},
	 {"Industrial coolant"},
	 {"9x19mm Ammunition", 3},
	 {"2 mm Exterminator Ammunition", 2},
	 {"Laser power pack", 2},
	 {"Plasma energy container", 2},
	 {".50 BMG (12.7x99mm) Ammunition", 2},
	 {"Small Axe"},
	 {"Large Axe"},
	 {"Laser Rifle"},
	 {"Reinforced Jacket"},
	 {"Heavy Shield"},
	 {"Light Battle Helmet"},
	 {"Worker Shoes"}
	}
}

npc_shop{
name = "Fred",
items = {
	 {"EMP Shockwave Generator", 3},
	 {"Electronic Noise Generator"},
	 {"VMX Gas Grenade"},
	 {"Small EMP Shockwave Generator", 2},
	}
}

npc_shop{
name = "Act2-Vending-Machine",
items = {
	 {"Bottled ice", 3},
	 {"9x19mm Ammunition"},
	 {"Barf's Energy Drink"},
	 {"Diet supplement", 2},
	}
}



