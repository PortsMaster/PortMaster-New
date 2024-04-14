## Groups
This document explains all the groups used in this game.

### Special groups

* `not_in_creative_inventory=1`: Item will not be shown in creative inventory
* `not_in_craft_guide=1`: Item will not be shown as result or fuel item in crafting guide (but still may be shown as ingredient)

### Digging time groups

The basic digging time groups determine by which tools a node can be dug.

* `pickaxey`: Diggable by pickaxe. The rating is for the possible tool materials in which the node will make its useful drop:
    * `pickaxey=1`: Wood, gold, stone, iron and diamond
    * `pickaxey=2`: Gold, stone, iron and diamond
    * `pickaxey=3`: Stone, iron and diamond
    * `pickaxey=4`: Iron and diamond
    * `pickaxey=5`: Diamond
* `axey`: Axe. Rating is same as for `pickaxey`
* `shovely`: Shovel. Rating is same as for `pickaxey`
* `swordy=1`: Diggable by sword (any material), and this node is *not* a cobweb
* `swordy_cobweb=1`: Diggable by sword (any material), and this node is a cobweb
* `shearsy=1`: Diggable by shears, and this node is *not* wool
* `shearsy_wool=1`: Diggable by shears, and this node is wool
* `handy=1`: Breakable by hand and this node gives it useful drop when dug by hand. All nodes which are breakable by pickaxe, axe, shovel, sword or shears are also automatically breakable by hand, but not neccess
* `creative_breakable=1`: Block is breakable by hand in creative mode. This group is implied if the node belongs to any other digging group

Please read <http://minecraft.gamepedia.com/Breaking> to learn how digging times work in Minecraft, as Mineclonia is based on the same system.

### Groups for interactions

* `crush_after_fall=1`: For falling nodes. These will crush whatever they hit after falling, not dropping as an item
* `falling_node_damage=1`: For falling nodes. Hurts any objects it hits while falling. Damage is based on anvils
* `dig_by_water=1`: Blocks with this group will drop when they are near flowing water
* `destroy_by_lava_flow=1`: Blocks with this group will be destroyed by flowing lava
* `dig_by_piston=1`: Blocks which will drop as an item when pushed by a piston. They also cannot be pulled by sticky pistons
* `cultivatable=2`: Block will be turned into Farmland by using a hoe on it
* `cultivatable=1`: Block will be turned into Dirt by using a hoe on it
* `flammable`: Block spreads fire
    * `flammable>0`: Gets destroyed by fire
    * `flammable=-1` Does not get destroyed by fire
* `fire_encouragement`: How quickly this block catches fire
* `fire_flammability`: How fast the block will burn away
* `path_creation_possible=1`: Node can be turned into grass path by using a shovel on it
* `spreading_dirt_type=1`: A dirt-type block with a cover (e.g. grass) which may spread to neighbor dirt blocks
* `dirtifies_below_solid=1`: This node turns into dirt immediately when a solid or dirtifier node is placed on top
* `dirtifier=1`: This node turns nodes the above group into dirt when placed above
* `converts_to_moss=1`: Block may turn into moss when nearby a moss block that had bone meal used on it.
* `non_mycelium_plant=1`: A plant which can't grow on mycelium. Placing it on mycelium fails and if mycelium spreads below it, it uproots
* `soil=1`: Saplings and other small plants can grow on it
* `soil_sapling=2`: Soil for saplings. Intended to be natural soil. All saplings will grow on this
* `soil_sapling=1`: Artificial soil (such as farmland) for saplings. Some saplings will not grow on this
* `soil_sugarcane=1`: Sugar canes will grow on this near water
* `soil_nether_wart=1`: Nether wart will grow on this
* `enderman_takable=1`: Block can be taken and placed by endermen
* `disable_suffocation=1`: Disables suffocation for full solid cubes (1)
* `destroys_items=1`: If an item happens to be *inside* this node, the item will be destroyed
* `no_eat_delay=1`: Only for foodstuffs. When eating this, all eating delays are ignored.
* `can_eat_when_full=1`: Only for foodstuffs. This item can be eaten when the user has a full hunger bar
* `attached_node_facedir=1`: Like `attached_node`, but for facedir nodes
* `supported_node=1`: Like `attached_node`, but can be placed on any nodes that do not have the `drawtype="airlike"` attribute.
* `cauldron`: Cauldron. 1: Empty. 2-4: Water height
* `anvil`: Anvil. 1: No damage. 2-3: Higher damage levels
* `no_rename=1`: Item cannot be renamed by anvil
* `comparator_signal=X`: If set, this node outputs a constant (!) comparator signal output of strength X.
* `piston=X`: Piston (main body) (1 = normal, 2 = sticky)
* `piston_pusher=X`: Piston pusher (1 = normal, 2 = sticky)
* `hopper=X`: Hopper (1 = downwards, 2 = sideways)
* `portal=1`: Portal (node that teleports players and things by standing inside)
* `end_portal_frame=X`: End portal frame (1 = no eye, 2 = with eye)
* `coral=X`: Coral (any type) (1 = alive, 2 = dead)
* `coral_plant=X`: Coral in the "plant" shape (1 = alive, 2 = dead)
* `coral_fan=X`: Coral fan (1 = alive, 2 = dead)
* `coral_block=X`: Coral block (1 = alive, 2 = dead)
* `coral_species=X`: Specifies the species of a coral; equal X means equal species
* `set_on_fire=X`: Sets any (not fire-resistant) mob or player on fire for X seconds when touching
* `compostability=X`: Item can be used on a composter block; X (1-100) is the % chance of adding a level of compost
* `leaves=X`: Node will spotaneously decay if no tree trunk nodes remain within 6 blocks distance.
* `leaves_orphan`: See above, these nodes are in the process of decayed.

#### Footnotes

1. Normally, all walkable blocks with the default 1×1×1 cube as a collision box (e.g. sand,
   gravel, stone, but not fences) will damage the players while their head is inside. This
   is called “suffocation”. Setting this group disables this behaviour

### Groups (mostly) used for crafting recipes

* `sand=1`: Sand (any color)
* `sandstone=1`: Sandstone (any color) and related nodes (chiseled and the like) (only full blocks)
* `normal_sandstone=1`: “Normal” (yellow) sandstone and related nodes (chiseled and the like) (only full blocks)
* `red_sandstone=1`: Red sandstone and related nodes (chiseled and the like) (only full blocks)
* `hardened_clay=1`: Terracotta (any color)
* `quartz_block=1`: Quartz Block and variants (chiseled, pillar, etc.) (only full blocks)
* `stonebrick=1`: Stone Bricks and related nodes (only full blocks)
* `shulker_box=1`: Block is a shulker box
* `tree=1`: Oak Wood, Birch Wood, etc. (tree trunks)
* `wood=1`: Oak Wood Planks, Birch Wood Planks, etc. (only full blocks)
* `wood_slab=1`: Slabs made out of a kind of wooden planks
* `wood_stairs=1`: Stairs made out of a kind of wooden planks
* `coal=1`: Coal of any kind (lumps only, not blocks)
* `wool=1`: Wool (only full blocks)
* `carpet=1:` (Wool) carpet
* `stick=1`: Stick
* `water_bucket=1`: Bucket containing a liquid of group “water”
* `enchantability=X`: How good the enchantments are the item gets (1 equals book)
* `enchanted=1`: The item is already enchanted, meaning that it can't be enchanted using an enchanting table
* `cobble=1`: Cobblestone of any kind
* `soul_block`: Fire burning on these blocks turns to soul fire, can be used to craft soul torch

### Material groups

These groups correspond to the Minecraft materials. They classify the block into a type, indicating what the block is “made off”.

* `material_stone=1`: Stone
* `material_wood=1`: Wood
* `material_sand=1`: Sand
* `material_glass=1`: Glass

Currently, these groups are used for the note block.
Note that not all Minecraft materials are used so far. More Minecraft materials will lilely only be added when they are needed for a concrete use case.

### Declarative groups
These groups are used mostly for informational purposes

* `solid=1`: Solid full-cube block (automatically assigned)
* `opaque=1`: Opaque block (automatically assigned)
* `not_solid=1`: Block is not solid (only assign this group for nodes which are automatically detected as “solid” in error
* `not_opaque=1`: Block is not opaque (only assign this group for nodes which are automatically detected as “opaque” in error
* `fire=1`: Fire
* `water=1`: Water
* `lava=1`: Lava
* `top_snow=X`: Top snow with X layers (1-8)
* `torch`: Torch or torch-like node
    * `torch=1`: Torch on floor
    * `torch=2`: Torch at wall
* `liquid`: Block is a liquid
    * `liquid=1`: Unspecified type
    * `liquid=2`: Water
    * `liquid=3`: Lava
* `fence=1`: Fence
* `fence_gate=1`: Fence gate
* `fence_wood=1`: Wooden fence
* `fence_nether_brick=1`: Nether brick fence
* `flower_pot`: Flower pot
   * `flower_pot=1`: Empty flower pot
   * `flower_pot=2`: Flower pot with a plant or flower
* `flower=1`: Flower
* `place_flowerlike=1`: Node has placement rules like that of a flower
* `place_flowerlike=2`: Node has placement rules like tall grass
* `cake`: Cake (rating = slices left)
* `book=1`: Book
* `pane=1`: Node is a “pane”-like node glass pane or iron bars
* `bed=1`: Bed
* `door=1`: Door
* `trapdoor=1`: Closed trapdoor
* `trapdoor=2`: Open trapdoor
* `glass=1`: Glass (full cubes only)
* `rail=1`: Rail
* `music_record`: Item is Music Disc
* `tnt=1`: Block is TNT
* `boat=1`: Boat
* `minecart=1`: Minecart
* `food`: Item is a comestible item which can be consumed (healthy or unhealthy)
    * `food=2`: Food
    * `food=3`: Drink (including soups)
    * `food=1`: Other/unsure
* `eatable`: Item can be *directly* eaten by wielding + right click (`on_use=item_eat`). Rating is the satiation gain
* `cocoa`: Node is a cocoa pod (rating is growth stage, ranging from 1 to 3)
* `ammo=1`: Item is used as ammo for a weapon
* `ammo_bow=1`: Item is used as ammo for bows
* `non_combat_armor=1`: Item can be equipped as armor, but is not made for combat (e.g. zombie head, pumpkin)
* `container`: Node is a container which physically stores items within and has at least 1 inventory
   * `container=2`: Has one inventory with list name `"main"`. Items can be placed and taken freely
   * `container=3`: Same as `container=2`, but shulker boxes can not be inserted
   * `container=4`: Furnace-like, has lists `"src"`, `"fuel"` and `"dst"`.
                    It is expected that this also reacts on `on_timer`;
                    the node timer must be started from other mods when they add into `"src"` or `"fuel"`
   * `container=5`: Left part of a 2-part horizontal connected container. Both parts have a `"main"` inventory
                    list. Both inventories are considered to belong together. This is used for large chests.
   * `container=6`: Same as above, but for the right part.
   * `container=7`: Has inventory list "`main`", no movement allowed
   * `container=1`: Other/unspecified container type
* `spawn_egg=1`: Spawn egg

* `pressure_plate=1`: Pressure plate (off)
* `pressure_plate=2`: Wooden pressure (on)
* `button=1`: Button (off)
* `button=2`: Button (on)
* `redstone_torch=1`: Redstone Torch (lit)
* `redstone_torch=2`: Redstone Torch (unlit)

* `plant=1`: Plant or part of a plant
* `double_plant`: Part of a double-sized plant. 1 = lower part, 2 = upper part

* `pickaxe=1`: Pickaxe
* `shovel=1`: Shovel
* `axe=1`: Axe
* `sword=1`: Sword
* `hoe=1`: Hoe (farming tool)
* `shears=1`: Shears

* `weapon=1`: Item is primarily (!) a weapon
* `tool=1`: Item is primarily (!) a tool
* `craftitem=1`: Item is primarily (!) used for crafting
* `brewitem=1`: Item is primarily (!) used in brewing
* `brewing_ingredient`: Item is an ingredient for brewing potions
* `transport=1`: Item is used for transportation
* `building_block=1`: Block is a building block
* `deco_block=1`: Block is a decorational block

* `blast_furnace_smeltable=1` : Item or node is smeltable by a blast furnace
* `smoker_cookable=1` : Food is cookable by a smoker.

* `attaches_to_base=1`: This node can attach to the base of other nodes.
* `attaches_to_side=1`: This node can attach to the sides of other nodes.
* `attaches_to_top=1`: This node can attach to the top of other nodes.

* `supports_mushrooms=1`: Mushrooms stay on this node regardless of light level.
## Fake item groups
These groups put similar items together which should all be treated by the gameplay or the GUI as a single item.
You should not add custom items to these groups for no good reason, this is likely to cause a ton of conflicts.

* `clock`: Clock (rating indicates the “frame”)
* `compass`: Compass (rating indicates the “frame”)

This has the following implication: If you want to use a compass or clock in a crafting recipe, you *must*
use `group:compass` or `group:clock`, respectively.
