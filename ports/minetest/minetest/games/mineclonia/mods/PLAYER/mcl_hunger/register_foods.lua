-- Apply food poisoning effect as long there are no real status effect.
-- TODO: Remove this when food poisoning a status effect in mcl_potions.
-- Normal poison damage is set to 0 because it's handled elsewhere.

mcl_hunger.register_food("mcl_mobitems:rotten_flesh",		4, "", 30, 0, 100, 80)
mcl_hunger.register_food("mcl_mobitems:chicken",		2, "", 30, 0, 100, 30)
mcl_hunger.register_food("mcl_fishing:pufferfish_raw",		1, "", 15, 0, 300)
