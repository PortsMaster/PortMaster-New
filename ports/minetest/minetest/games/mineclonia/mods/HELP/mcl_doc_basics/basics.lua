
local S = minetest.get_translator(minetest.get_current_modname())

--
-- Basics
--

doc.add_category("basics", {
	name = S("Basics"),
	description = S("Everything you need to know to get started with playing"),
	sorting = "custom",
	sorting_data = {"quick_start", "controls", "point", "items", "inventory", "hotbar", "tools", "weapons", "nodes", "mine", "build", "craft", "cook", "hunger", "mobs", "animals", "minimap", "cam", "sneak", "players", "liquids", "light", "groups", "glossary", "minetest"},
	build_formspec = doc.entry_builders.text_and_gallery,
})

doc.add_entry("basics", "quick_start", {
	name = S("Quick start"),
	data = { text =
S("This is a very brief introduction to the basic gameplay.").."\n\n"..

S("How to play:").."\n"..
S("• Punch a tree trunk until it breaks and collect wood").."\n"..
S("• Place the wood into the 2×2 grid (your “crafting grid”) in your inventory menu and craft 4 wood planks").."\n"..
S("• Place them in a 2×2 shape in the crafting grid to craft a crafting table").."\n"..
S("• Place the crafting table on the ground").."\n"..
S("• Rightclick it for a 3×3 crafting grid").."\n"..
S("• Use the crafting guide (book icon) to learn all the possible crafting recipes").."\n"..
S("• Craft a wooden pickaxe so you can dig stone").."\n"..
S("• Different tools break different kinds of blocks. Try them out!").."\n"..
S("• Read entries in this help to learn the rest").."\n"..
S("• Continue playing as you wish. There's no real goal, but you may want to check the advancements available from the inventory screen. Have fun!").."\n\n"..

S("For the default controls, see the next section [Controls].")
}})

doc.add_entry("basics", "controls", {
	name = S("Controls"),
	data = { text =
S("These are the default controls (which can be remapped in the 'Change keys' dialog):").."\n\n"..

S("Basic movement:").."\n"..
S("• Moving the mouse around: Look around").."\n"..
S("• W: Move forwards").."\n"..
S("• A: Move to the left").."\n"..
S("• D: Move to the right").."\n"..
S("• S: Move backwards").."\n"..
S("• E: Sprint (aux1)").."\n\n"..

S("While standing on solid ground:").."\n"..
S("• Space: Jump").."\n"..
S("• Shift: Sneak").."\n\n"..

S("While on a ladder, swimming in a liquid or fly mode is active").."\n"..
S("• Space: Move up").."\n"..
S("• Shift: Move down").."\n\n"..

S("Extended movement (requires privileges):").."\n"..
S("• J: Toggle fast mode, makes you run or fly fast (requires “fast” privilege)").."\n"..
S("• K: Toggle fly mode, makes you move freely in all directions (requires “fly” privilege)").."\n"..
S("• H: Toggle noclip mode, makes you go through walls in fly mode (requires “noclip” privilege)").."\n"..
S("• E: Walk fast in fast mode").."\n\n"..

S("World interaction:").."\n"..
S("• Left mouse button: Punch / mine blocks").."\n"..
S("• Right mouse button: Build or use pointed block").."\n"..
S("• Shift+Right mouse button: Build").."\n"..
S("• Roll mouse wheel / B / N: Select next/previous item in hotbar").."\n"..
S("• 1-9: Select item in hotbar directly").."\n"..
S("• Q: Drop item stack").."\n"..
S("• Shift+Q: Drop 1 item").."\n"..
S("• I: Show/hide inventory menu").."\n\n"..

S("Inventory interaction:").."\n"..
S("See the entry “Basics > Inventory”.").."\n\n"..

S("Camera:").."\n"..
S("• F7: Toggle camera mode").."\n\n"..

S("Interface:").."\n"..
S("• Esc: Open menu window (pauses in single-player mode) or close window").."\n"..
S("• F1: Show/hide HUD").."\n"..
S("• F2: Show/hide chat").."\n"..
S("• F9: Toggle minimap").."\n"..
S("• Shift+F9: Toggle minimap rotation mode").."\n"..
S("• F10: Open/close console/chat log").."\n"..
S("• F12: Take a screenshot").."\n\n"..

S("Server interaction:").."\n"..
S("• T: Open chat window (chat requires the “shout” privilege)").."\n"..
S("• /: Start issuing a server command").."\n\n"..

S("Technical:").."\n"..
S("• +: Increase minimal viewing distance").."\n"..
S("• -: Decrease minimal viewing distance").."\n"..
S("• F3: Enable/disable fog").."\n"..
S("• F5: Enable/disable debug screen which also shows your coordinates").."\n"..
S("• F6: Only useful for developers. Enables/disables profiler")
}})

doc.add_entry("basics", "point", {
	name = S("Pointing"),
	data = {
		text =
S("“Pointing” means looking at something in range with the crosshair. Pointing is needed for interaction, like mining, punching, using, etc. Pointable things include blocks, players, computer enemies and objects.").."\n\n"..

S("To point something, it must be in the pointing range (also just called “range”) of your wielded item. There's a default range when you are not wielding anything. A pointed thing will be outlined or highlighted (depending on your settings). Pointing is not possible with the 3rd person front camera.").."\n\n"..

S("A few things can not be pointed. Most blocks are pointable. A few blocks, like air, can never be pointed. Other blocks, like liquids can only be pointed by special items."),
		images = {{ image = "doc_basics_pointing.png" }},
}})

doc.add_entry("basics", "items", {
	name = S("Items"),
	data = {
		text =
S("Items are things you can carry along and store in inventories. They can be used for crafting, smelting, building, mining, and more. Types of items include blocks, tools, weapons and items only used for crafting.").."\n\n"..

S("An item stack is a collection of items of the same type which fits into a single item slot. Item stacks can be dropped on the ground. Items which drop into the same coordinates will form an item stack.").."\n\n"..

S("Items have several properties, including the following:").."\n\n"..

S("• Maximum stack size: Number of items which fit on 1 item stack").."\n"..
S("• Pointing range: How close things must be to be pointed while wielding this item").."\n"..
S("• Group memberships: See “Basics > Groups”").."\n"..
S("• May be used for crafting or cooking"),

-- MCL2: Items cannot be taken by punching
		images = {{image="doc_basics_inventory_detail.png"}, {image="doc_basics_items_dropped.png"}},
}})

doc.add_entry("basics", "inventory", {
	name=S("Inventory"),
	data = {
		text =
S("Inventories are used to store item stacks. There are other uses, such as crafting. An inventory consists of a rectangular grid of item slots. Each item slot can either be empty or hold one item stack. Item stacks can be moved freely between most slots.").."\n\n"..
S("You have your own inventory which is called your “player inventory”, you can open it with the inventory key (default: [I]).").."\n"..
S("Blocks can also have their own inventory, e.g. chests and furnaces.").."\n\n"..

S("Inventory controls:").."\n\n"..

S("Taking: You can take items from an occupied slot if the cursor holds nothing.").."\n"..
S("• Left click: take entire item stack").."\n"..
S("• Right click: take half from the item stack (rounded up)").."\n"..
S("• Middle click: take 10 items from the item stack").."\n"..
S("• Mouse wheel down: take 1 item from the item stack").."\n\n"..
S("• Mouse wheel up: put 1 item in the item stack (if you're holding an item stack of the same type)").."\n\n"..

S("Putting: You can put items onto a slot if the cursor holds 1 or more items and the slot is either empty or contains an item stack of the same item type.").."\n"..
S("• Left click: put entire item stack").."\n"..
S("• Right click or mouse wheel up: put 1 item of the item stack").."\n"..
S("• Middle click: put 10 items of the item stack").."\n\n"..

S("Exchanging: You can exchange items if the cursor holds 1 or more items and the destination slot is occupied by a different item type.").."\n"..
S("• Click: exchange item stacks").."\n\n"..

S("Throwing away: If you hold an item stack and click with it somewhere outside the GUI, the item stack gets thrown away into the world.").."\n\n"..

S("Quick transfer: You can quickly transfer an item stack between a player's inventory and a block's inventory like a furnace, chest, or any other item with an inventory slot when that block's inventory is accessed. The target inventory is generally the most relevant inventory in this context.").."\n"..
S("• Sneak+Left click: Automatically transfer item stack (Sneak is by default [Shift])")
}})

doc.add_entry("basics", "hotbar", {
	name = S("Hotbar"),
	data = {
		text =
S("At the bottom of the screen you see some squares. This is called the “hotbar”, and contains the items you have put in the last row of your inventory.").."\n\n"..
S("You can change the selected item with the mouse wheel or the keyboard:").."\n"..

S("• Select previous item in hotbar: [Mouse wheel up] or [B]").."\n"..
S("• Select next item in hotbar: [Mouse wheel down] or [N]").."\n"..
S("• Select item in hotbar directly: [1]-[9]").."\n\n"..

S("The selected item is also your wielded item."),
		images = {{image="doc_basics_hotbar.png"}},
}})

doc.add_entry("basics", "tools", {
	name = S("Tools"),
	data = { text =
S("Some items may serve as a tool when wielded. Any item which has some special use which can be directly used by its wielder is considered a tool.").."\n\n"..

S("A common subset of tools are mining tools. These are important to quickly break different types of blocks. Weapons are a kind of tool. There are of course many other possible tools. Special actions of tools are usually done by left-click or right-click.").."\n\n"..

S("When nothing is wielded, players use their hand which also acts as a (limited) mining tool and weapon with no durability.").."\n\n"..

S("Usually tools have a durability which limits the amount of uses of it. The damage is displayed in a colored bar below the item icon. If no damage bar is shown, the tool is in mint condition. Tools can be repaired to increased or restore its durability."),
		images = {{image="doc_basics_tools.png"}, {image="doc_basics_tools_mining.png"}},
}})

doc.add_entry("basics", "weapons", {
	name = S("Weapons"),
	data = { text =
S("Some items are usable as a melee weapon when wielded. Weapons share most of the properties of tools.").."\n\n"..

S("Melee weapons deal damage by punching players and other animate objects. There are two ways to attack:").."\n"..
S("• Single punch: Left-click once to deal a single punch").."\n"..
S("• Quick punching: Hold down the left mouse button to deal quick repeated punches").."\n\n"..

S("There are two core attributes of melee weapons:").."\n"..
S("• Maximum damage: Damage which is dealt after a hit when the weapon was fully recovered").."\n"..
S("• Full punch interval: Time it takes for fully recovering from a punch").."\n\n"..

S("A weapon only deals full damage when it has fully recovered from a previous punch. Otherwise, the weapon will deal only reduced damage. This means, quick punching is very fast, but also deals rather low damage. Note the full punch interval does not limit how fast you can attack.").."\n\n"..

S("There is a rule which sometimes makes attacks impossible: Players, animate objects and weapons belong to damage groups. A weapon only deals damage to those who share at least one damage group with it. So if you're using the wrong weapon, you might not deal any damage at all.")
}})

doc.add_entry("basics", "nodes", {
	name = S("Blocks"),
	data = {
		text =
S("The world is made entirely out of blocks (voxels, to be precise). Blocks can be added or removed with the correct tools.").."\n\n"..

S("Blocks can have a wide range of different properties which determine mining times, behavior, looks, shape, and much more. Their properties include:").."\n\n"..

S("• Collidable: Collidable blocks can not be passed through; players can walk on them. Non-collidable blocks can be passed through freely").."\n"..
S("• Pointable: Pointable blocks show a wireframe or a halo box when pointed. But you will just point through non-pointable blocks. Liquids are usually non-pointable but they can be pointed at by some special tools").."\n"..
S("• Mining properties: By which tools it can be mined, how fast and how much it wears off tools").."\n"..
S("• Climbable: While you are at a climbable block, you won't fall and you can move up and down with the jump and sneak keys").."\n"..
S("• Drowning damage: See the entry “Basics > Player”").."\n"..
S("• Liquids: See the entry “Basics > Liquids”").."\n"..
S("• Group memberships: Group memberships are used to determine mining properties, crafting, interactions between blocks and more"),
		images = {{image="doc_basics_nodes.png"}}
}})

doc.add_entry("basics", "mine", {
	name = S("Mining"),
	data = {
		text =
-- Text changed for MCL2
S("Mining (or digging) is the process of breaking blocks to remove them. To mine a block, point it and hold down the left mouse button until it breaks.").."\n\n"..

S("Blocks require a mining tool to be mined. Different blocks are mined by different mining tools, and some blocks can not be mined by any tool. Blocks vary in hardness and tools vary in strength. Mining tools will wear off over time. The mining time and the tool wear depend on the block and the mining tool. The fastest way to find out how efficient your mining tools are is by just trying them out on various blocks. Any items you gather by mining will drop on the ground, ready to be collected.") .. "\n\n"..

S("After mining, a block may leave a “drop” behind. This is a number of items you get after mining. Most commonly, you will get the block itself. There are other possibilities for a drop which depends on the block type. The following drops are possible:").."\n"..
S("• Always drops itself (the usual case)").."\n"..
S("• Always drops the same items").."\n"..
S("• Drops items based on probability").."\n"..
S("• Drops nothing"),
}})

doc.add_entry("basics", "build", {
	name = S("Building"),
	data = {
		text =
S("Almost all blocks can be built (or placed). Building is very simple and has no delay.").."\n\n"..

S("To build your wielded block, point at a block in the world and right-click. If this is not possible because the pointed block has a special right-click action, hold down the sneak key before right-clicking.").."\n\n"..

S("Blocks can almost always be built at pointable blocks. One exception are blocks attached to the floor; these can only be built on the floor.").."\n\n"..

S("Normally, blocks are built in front of the pointed side of the pointed block. A few blocks are different: When you try to build at them, they are replaced."),
		images = {{image="doc_basics_build.png"}},
}})

doc.add_entry("basics", "craft", {
	name = S("Crafting"),
	data = {
		text =
S("Crafting is the task of combining several items to form a new item.").."\n\n"..

S("To craft something, you need one or more items, a crafting grid (C) and a crafting recipe. A crafting grid is like a normal inventory which can also be used for crafting. Items need to be put in a certain pattern into the crafting grid. Next to the crafting grid is an output slot (O). Here the result will appear when you placed items correctly. This is just a preview, not the actual item.").."\n\n"..

S("The crafting grid you have inside your inventory is 2x2, limiting the amount of potential recipes you can craft. To craft recipes that require a 3x3 grid you will need a crafting table.").."\n\n"..

S("To complete the craft, take the result item from the output slot, which will consume items from the crafting grid and creates a new item. It is not possible to place items into the output slot.").."\n\n"..

S("A description on how to craft an item is called a “crafting recipe”. You need this knowledge to craft. You can use the recipe book to get a list of crafting recipes available from items you have obtained.").."\n\n"..

S("Crafting recipes consist of at least one input item and exactly one stack of output items. When performing a single craft, it will consume exactly one item from each stack of the crafting grid, unless the crafting recipe defines replacements.").."\n\n"..

S("There are multiple types of crafting recipes:").."\n"..
S("• Shaped: Items need to be placed in a particular shape").."\n"..
S("• Shapeless: Items need to be placed somewhere in input, but shape and order is independent").."\n"..
S("• Cooking: Explained in “Basics > Cooking”").."\n"..
-- MCL2 change: call out specific repair percentage
S("• Repairing: Place two damaged tools into the crafting grid anywhere to get a tool which is repaired by 5%").."\n\n"..

S("In some crafting recipes, some input items do not need to be a concrete item, instead they need to be a member of a group (see “Basics > Groups”). These recipes offer a bit more freedom in the input items. For instance, crafting a furnace can be used with a number of different full cobble-like stone blocks.").."\n\n"..

S("Rarely, crafting recipes have replacements. This means, whenever you perform a craft, some items in the crafting grid will not be consumed, but instead will be replaced by another item."),
		images = {
			{image="doc_basics_craft_grid.png"}
		},
}})

doc.add_entry("basics", "cook", {
	name = S("Cooking"),
	data = {
		text =
S("Cooking (or smelting) is a form of crafting which does not involve a crafting grid. Cooking is done with a special block (like a furnace), an cookable item, a fuel item and time in order to yield a new item.").."\n\n"..

S("Each fuel item has a burning time. This is the time a single item of the fuel keeps a furnace burning.").."\n\n"..

S("Each cookable item requires time to be cooked. This time is specific to the item type and the item must be “on fire” for the whole cooking time to actually yield the result.")
}})

doc.add_entry("basics", "hunger", {
	name = S("Hunger"),
	data = { text =
S("Hunger affects your health and your ability to sprint. Hunger is not in effect when damage is disabled.").."\n\n"..

S("Core hunger rules:").."\n\n"..
S("• You start with 20/20 hunger points (more points = less hungry)").."\n"..
S("• Actions like combat, jumping, sprinting, etc. decrease hunger points").."\n"..
S("• Food restores hunger points").."\n"..
S("• If your hunger bar decreases, you're hungry").."\n"..
S("• At 18-20 hunger points, you regenerate 1 HP every 4 seconds").."\n"..
S("• At 6 hunger points or less, you can't sprint").."\n"..
S("• At 0 hunger points, you lose 1 HP every 4 seconds (down to 1 HP)").."\n"..
S("• Poisonous food decreases your health").."\n\n"..


S("Details:").."\n\n"..
S("You have 0-20 hunger points, indicated by 20 drumstick half-icons above the hotbar. You also have an invisible attribute: Saturation.").."\n"..
S("Hunger points reflect how full you are while saturation points reflect how long it takes until you're hungry again.").."\n\n"..

S("Each food item increases both your hunger level as well your saturation.").."\n"..
S("Food with a high saturation boost has the advantage that it will take longer until you get hungry again.").."\n"..
S("A few food items might induce food poisoning by chance. When you're poisoned, the health and hunger symbols turn sickly green. Food poisoning drains your health by 1 HP per second, down to 1 HP. Food poisoning also drains your saturation. Food poisoning goes away after a while or when you drink milk.").."\n\n"..

S("You start with 5 saturation points. The maximum saturation is equal to your current hunger level. So with 20 hunger points your maximum saturation is 20. What this means is that food items which restore many saturation points are more effective the more hunger points you have. This is because at low hunger levels, a lot of the saturation boost will be lost due to the low saturation cap.").."\n"..
S("If your saturation reaches 0, you're hungry and start to lose hunger points. Whenever you see the hunger bar decrease, it is a good time to eat.").."\n\n"..

S("Saturation decreases by doing things which exhaust you (highest exhaustion first):").."\n"..
S("• Regenerating 1 HP").."\n"..
S("• Suffering food poisoning").."\n"..
S("• Sprint-jumping").."\n"..
S("• Sprinting").."\n"..
S("• Attacking").."\n"..
S("• Taking damage").."\n"..
S("• Swimming").."\n"..
S("• Jumping").."\n"..
S("• Mining a block").."\n\n"..

S("Other actions, like walking, do not exaust you.")

}})

doc.add_entry("basics", "mobs", {
	name = S("Mobs"),
	data = { text =
S("Mobs are the living beings in the world. This includes animals and monsters.").."\n\n"..

S("Mobs appear randomly throughout the world. This is called “spawning”. Each mob kind appears on particular block types at a given light level. The height also plays a role. Peaceful mobs tend to spawn at daylight while hostile ones prefer darkness. Most mobs can spawn on any solid block but some mobs only spawn on particular blocks (like grass blocks).").."\n\n"..

S("Like players, mobs have hit points and sometimes armor points, too (which means you need better weapons to deal any damage at all). Also like players, hostile mobs can attack directly or at a distance. Mobs may drop random items after they die.").."\n\n"..

S("Most animals roam the world aimlessly while most hostile mobs hunt players. Animals can be fed, tamed and bred.")
}})

doc.add_entry("basics", "animals", {
	name = S("Animals"),
	data = { text =
S("Animals are peaceful beings which roam the world aimlessly. You can feed, tame and breed them.").."\n\n"..

S("Feeding:").."\n"..
S("Each animal has its own taste for food and doesn't just accept any food. To feed, hold an item in your hand and rightclick the animal.").."\n"..
S("Animals are attraced to the food they like and follow you as long you hold the food item in hand.").."\n"..
S("Feeding an animal has three uses: Taming, healing and breeding.").."\n"..
S("Feeding heals animals instantly, depending on the quality of the food item.").."\n\n"..

S("Taming:").."\n"..
S("A few animals can be tamed. You can generally do more things with tamed animals and use other items on them. For example, tame horses can be saddled and tame wolves fight on your side.").."\n\n"..

S("Breeding:").."\n"..
S("When you have fed an animal up to its maximum health, then feed it again, you will activate “Love Mode” and many hearts appear around the animal.").."\n"..
S("Two animals of the same species will start to breed if they are in Love Mode and close to each other. Soon a baby animal will pop up.").."\n\n"..

S("Baby animals:").."\n"..
S("Baby animals are just like their adult couterparts, but they can't be tamed or bred and don't drop anything when they die. They grow to adults after a short time. When fed, they grow to adults faster.")

}})

doc.add_entry("basics", "minimap", {
	name = S("Minimap"),
	data = {
		text =
S("The minimap allows you to get an overhead view of your surroundings, as a HUD that appears in the top right corner.").."\n\n"..

S("Press [F9] to make a minimap appear on the top right. The minimap helps you to find your way around the world. Press it again to select different minimap modes and zoom levels. The minimap also shows the positions of other players.").."\n\n"..

S("There are 2 minimap modes and 3 zoom levels.").."\n\n"..

S("Surface mode (image 1) is a top-down view of the world, roughly resembling the colors of the blocks this world is made of. It only shows the topmost blocks, everything below is hidden, like a satellite photo. Surface mode is useful if you got lost.").."\n\n"..

S("Radar mode (image 2) is more complicated. It displays the “denseness” of the area around you and changes with your height. Roughly, the more green an area is, the less “dense” it is. Black areas have many blocks. Use the radar to find caverns, hidden areas, walls and more. The rectangular shapes in image 2 clearly expose the position of a dungeon.").."\n\n"..

S("There are also two different rotation modes. In “square mode”, the rotation of the minimap is fixed. If you press [Shift]+[F9] to switch to “circle mode”, the minimap will instead rotate with your looking direction, so “up” is always your looking direction.").."\n\n"..

S("• Toggle minimap mode: [F9]").."\n"..
S("• Toggle minimap rotation mode: [Shift]+[F9]"),
		images = {{image="doc_basics_minimap_map.png"}, {image="doc_basics_minimap_radar.png"}, {image="doc_basics_minimap_round.png"}},
}})

doc.add_entry("basics", "cam", {
	name = S("Camera"),
	data = {
		text =
S("There are 3 different views which determine the way you see the world. The modes are:").."\n\n"..

S("• 1: First-person view (default)").."\n"..
S("• 2: Third-person view from behind").."\n"..
S("• 3: Third-person view from the front").."\n\n"..

S("These camera modes can be toggled between by default pressing [F7].").."\n\n"..
S("To zoom in the camera, you can use the Spyglass item.").."\n\n"..

S("• Switch camera mode: [F7]")
}})

doc.add_entry("basics", "sneak", {
	name = S("Sneaking"),
	data = { text =
S("Sneaking makes you walk slower and prevents you from falling off the edge of a block.").."\n"..
S("To sneak, hold down the sneak key (default: [Shift]). When you release it, you stop sneaking. Careful: When you release the sneak key at a ledge, you might fall!").."\n\n"..

S("Sneaking only works when you stand on solid ground, are not in a liquid and don't climb."),
}})

doc.add_entry("basics", "players", {
	name = S("Players"),
	data = {
		text =
S("Players are the characters which users control.").."\n\n"..

S("Players are living beings. They start with a number of health points (HP) and a number of breath points (BP).").."\n"..
S("Players are capable of walking, sneaking, jumping, climbing, swimming, diving, mining, building, fighting and using tools and blocks.").."\n"..

S("Players can take damage for a variety of reasons:").."\n"..

S("• Taking fall damage").."\n"..
S("• Touching a block which causes direct damage").."\n"..
S("• Drowning").."\n"..
S("• Being attacked by another player").."\n"..
S("• Being attacked by a computer enemy").."\n\n"..

S("At a health of 0, the player dies. The player can just respawn in the world, but their items will be lost at the place of death and will need to be retrieved. (unless mcl_keepInventory is enabled)").."\n\n"..

S("Some blocks reduce breath. While being with the head in a block which causes drowning, the breath points are reduced by 1 for every 2 seconds. When all breath is gone, the player starts to suffer drowning damage. Breath is quickly restored in any other block.").."\n\n"..

S("Damage can be disabled on any world. Without damage, players are immortal and health and breath are unimportant.").."\n\n"..

S("In multiplayer, the name of other players is written above their head."),
		images = {{image="doc_basics_players_sam.png"}},
}})

doc.add_entry("basics", "liquids", {
	name = S("Liquids"),
	data = {
		text =
S("Liquids are special dynamic blocks. Liquids like to spread and flow to their surrounding blocks. Players can swim and drown in them.").."\n\n"..

S("Liquids usually come in two forms: In source form (S) and in flowing form (F).").."\n"..
S("Liquid sources have the shape of a full cube. A liquid source will generate flowing liquids around it from time to time, and, if the liquid is renewable, it also generates liquid sources. A liquid source can sustain itself. As long it is left alone, a liquid source will normally keep its place and does not drain out.").."\n"..
S("Flowing liquids take a sloped form. Flowing liquids spread around the world until they drain. A flowing liquid can not sustain itself and always comes from a liquid source, either directly or indirectly. Without a liquid source, a flowing liquid will eventually drain out and disappear.").."\n"..

S("All liquids share the following properties:").."\n"..
S("• All properties of blocks (including drowning damage)").."\n"..
S("• Renewability: Renewable liquids can create new sources").."\n"..
S("• Flowing range: How many flowing liquids are created at maximum per liquid source, it determines how far the liquid will spread. Possible are ranges from 0 to 8. At 0, no flowing liquids will be created. Image 5 shows a liquid of flowing range 2").."\n"..
S("• Viscosity: How slow players move through it and how slow the liquid spreads").."\n\n"..

S("Renewable liquids create new liquid sources at open spaces (image 2). A new liquid source is created when:").."\n"..
S("• Two renewable liquid blocks of the same type touch each other diagonally").."\n"..
S("• These blocks are also on the same height").."\n"..
S("• One of the two “corners” is open space which allows liquids to flow in").."\n\n"..

S("When those criteria are met, the open space is filled with a new liquid source of the same type (image 3).").."\n\n"..

S("Swimming in a liquid is fairly straightforward: The usual direction keys for basic movement, the jump key for rising and the sneak key for sinking.").."\n\n"..

S("The physics for swimming and diving in a liquid are:").."\n"..
S("• The higher the viscosity, the slower you move").."\n"..
S("• If you rest, you'll slowly sink").."\n"..
S("• There is no fall damage for falling into a liquid as such").."\n"..
S("• If you fall into a liquid, you will be slowed down on impact (but don't stop instantly). Your impact depth is determined by your speed and the liquid viscosity. For a safe high drop into a liquid, make sure there is enough liquid above the ground, otherwise you might hit the ground and take fall damage").."\n\n"..

S("Liquids are often not pointable. But some special items are able to point all liquids."),
		images = {
			{ image="doc_basics_liquids_types.png",
			  caption="A source liquid and its flowing liquids" },
			{ image="doc_basics_liquids_renewable_1.png",
			  caption="Renewable liquids need to be arranged like this to create a new source block" },
			{ image="doc_basics_liquids_renewable_2.png",
			  caption="A new liquid source is born" },
			{ image="doc_basics_liquids_nonrenewable.png",
			  caption="Non-renewable liquids creates a flowing liquid (F) instead" },
			{ image="doc_basics_liquids_range.png",
			  caption="Liquid with a flowing range of 2" },
		},
	},
})

doc.add_entry("basics", "light", {
	name = S("Light"),
	data = { text =
S("As the world is entirely block-based, so is the light in the world. Each block has its own brightness. The brightness of a block is expressed in a “light level” which ranges from 0 (total darkness) to 15 (as bright as the sun).").."\n\n"..

S("There are two types of light: Sunlight and artificial light.").."\n\n"..

S("Artificial light is emitted by luminous blocks. Artificial light has a light level from 1-14.").."\n"..
S("Sunlight is the brightest light and always goes perfectly straight down from the sky at each time of the day. At night, the sunlight will become moonlight instead, which still provides a small amount of light. The light level of sunlight is 15.").."\n\n"..

S("Blocks have 3 levels of transparency:").."\n\n"..

S("• Transparent: Sunlight goes through limitless, artificial light goes through with losses").."\n"..
S("• Semi-transparent: Sunlight and artificial light go through with losses").."\n"..
S("• Opaque: No light passes through").."\n\n"..

S("Artificial light will lose one level of brightness for each transparent or semi-transparent block it passes through, until only darkness remains (image 1).").."\n"..
S("Sunlight will preserve its brightness as long it only passes fully transparent blocks. When it passes through a semi-transparent block, it turns to artificial light. Image 2 shows the difference.").."\n\n"..

S("Note that “transparency” here only means that the block is able to carry brightness from its neighboring blocks. It is possible for a block to be transparent to light but you can't see trough the other side."),
		images = {{image="doc_basics_light_torch.png"}, {image="doc_basics_light_test.png"}}
}})

doc.add_entry("basics", "groups", {
	name = S("Groups"),
	data = {
		text =
S("Items, players and objects (animate and inanimate) can be members of any number of groups. Groups serve multiple purposes:").."\n\n"..

S("• Crafting recipes: Slots in a crafting recipe may not require a specific item, but instead an item which is a member of a particular group, or multiple groups").."\n"..
S("• Digging times: Diggable blocks belong to groups which are used to determine digging times. Mining tools are capable of digging blocks belonging to certain groups").."\n"..
S("• Block behavior: Blocks may show a special behaviour and interact with other blocks when they belong to a particular group").."\n"..
S("• Damage and armor: Objects and players have armor groups, weapons have damage groups. These groups determine damage. See also: “Basics > Weapons”").."\n"..
S("• Other uses").."\n\n"..

S("In the item help, many important groups are usually mentioned and explained.")
}})

doc.add_entry("basics", "glossary", {
	name = S("Glossary"),
	data = {
		text =
S("This is a list of commonly used terms:").."\n\n"..

S("Controls:").."\n"..
S("• Wielding: Holding an item in hand").."\n"..
S("• Pointing: Looking with the crosshair at something in range").."\n"..
S("• Dropping: Throwing an item or item stack to the ground").."\n"..
S("• Punching: Attacking with left-click, is also used on blocks").."\n"..
S("• Sneaking: Walking slowly while (usually) avoiding to fall over edges").."\n"..
S("• Climbing: Moving up or down a climbable block").."\n\n"..

S("Blocks:").."\n"..
S("• Block: Cubes that the worlds are made of").."\n"..
S("• Mining/digging: Using a mining tool to break a block").."\n"..
S("• Building/placing: Putting a block somewhere").."\n"..
S("• Drop: Items you get after mining a block").."\n"..
S("• Using a block: Right-clicking a block to access its special function").."\n\n"..

S("Items:").."\n"..
S("• Item: A single thing that players can possess").."\n"..
S("• Item stack: A collection of items of the same kind").."\n"..
S("• Maximum stack size: Maximum amount of items in an item stack").."\n"..
S("• Slot / inventory slot: Can hold one item stack").."\n"..
S("• Inventory: Provides several inventory slots for storage").."\n"..
S("• Player inventory: The main inventory of a player").."\n"..
S("• Tool: An item which you can use to do special things with when wielding").."\n"..
S("• Range: How far away things can be to be pointed by an item").."\n"..
S("• Mining tool: A tool which allows to break blocks").."\n"..
S("• Craftitem: An item which is (primarily or only) used for crafting").."\n\n"..

S("Gameplay:").."\n"..
S("• “heart”: A single health symbol, indicates 2 HP").."\n"..
S("• “bubble”: A single breath symbol, indicates 1 BP").."\n"..
S("• HP: Hit point (equals half 1 “heart”)").."\n"..
S("• BP: Breath point, indicates breath when diving").."\n"..
S("• Mob: Computer-controlled enemy").."\n"..
S("• Crafting: Combining multiple items to create new ones").."\n"..
S("• Crafting guide: A helper which shows available crafting recipes").."\n"..
S("• Spawning: Appearing in the world").."\n"..
S("• Respawning: Appearing again in the world after death").."\n"..
S("• Group: Puts similar things together, often affects gameplay").."\n"..
S("• noclip: Allows to fly through walls").."\n\n"..

S("Interface").."\n"..
S("• Hotbar: Inventory slots at the bottom").."\n"..
S("• Statbar: Indicator made out of half-symbols, used for health and breath").."\n"..
S("• Minimap: The map or radar at the top right").."\n"..
S("• Crosshair: Seen in the middle, used to point at things").."\n\n"..

S("Online multiplayer:").."\n"..
S("• PvP: Player vs Player. If active, players can deal damage to each other").."\n"..
S("• Griefing: Destroying the buildings of other players against their will").."\n"..
S("• Protection: Mechanism to own areas of the world, which only allows the owners to modify blocks inside").."\n\n"..

S("Technical terms:").."\n"..
S("• Minetest: This game engine").."\n"..
S("• Minetest Game: A game for Minetest by the Minetest developers").."\n"..
S("• Game: A complete playing experience to be used in Minetest; such as a game or sandbox or similar").."\n"..
S("• Mod: A single subsystem which adds or modifies functionality; is the basic building block of games and can be used to further enhance or modify them").."\n"..
S("• Privilege: Allows a player to do something").."\n"..
S("• Node: Other word for “block”")
}})

doc.add_entry("basics", "minetest", {
	name = S("Minetest"),
	data = {
		text =
S("Minetest is a free software game engine for games based on voxel gameplay, inspired by InfiniMiner, Minecraft, and the like. Minetest was originally created by Perttu Ahola (alias “celeron55”).").."\n\n"..

S("A core feature of Minetest is the built-in modding capability, which all games consist of too. They can be as simple as adding a few decorational blocks or be very complex by e.g. introducing completely new gameplay concepts, generating a completely different kind of world, and many other things.").."\n\n"..

S("Minetest can be played alone or online together with multiple players. Online play will work out of the box with any mods, with no need for additional software as they are entirely provided by the server.").."\n\n"..

S("MineClonia is a game that is built on top of the Minetest engine that intends to create a game that is as close to Minecraft as possible. There are many other games for Minetest however, that can be installed from the main menu content browser.")
}})

