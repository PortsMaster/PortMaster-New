--[[
This file specifies the add-ons that exist in the game. Add-ons can be crafted
from materials by the player and they can be installed into sockets of weapons
and armor. The bonuses of the add-ons add to the capabilities of the items to
which they are installed.

A new add-on specification can be added by calling the addon() function with a
table as its argument. The passed table contains named fields that specify
everything that needs to be known about the add-on. The recognized fields are:

  name: A string matching the name of one of the item archetypes. When you want
  to create a new add-on, you need to add a new item to item_archetypes.dat
  first and then use its name for this field.

  upgrade_cost: The number of valuable circuits it costs to upgrade an item with
  the add-on.

  require_socket: The type of the socket to which the add-on can be installed.
  The supported values are:
   * "mechanical": Fits to a mechanical or a universal socket.
   * "electric": Fits to an electric or a universal socket.
   * "universal": Fits to a universal socket.

  require_item: The type of the item to which the add-on can be installed.
  The supported values are:
   * "melee weapon": Applicable to melee weapons.
   * "ranged weapon": Applicable to ranged weapons.
   * "armor": Applicable to any armor.
   * "boots": Applicable to items that fit to the footwear slot.
   * "jacket": Applicable to items that fit to the jacket slot.
   * "shield": Applicable to items that fit to the shield slot.
   * "helmet": Applicable to items that fit to the headgear slot.

  bonuses: A table of bonuses. The keys of the table are the names of the bonuses
  and the values the corresponding attribute boost amounts. All the values are
  integers of the unit of the modified attribute. The supported bonuses are:
   * all_attributes: Adds points to strength, dexterity, physique and cooling.
   * attack: Adds points to the attack rating.
   * armor: Adds points to the armor rating.
   * cooling: Adds points to cooling.
   * cooling_rate: Decrease temperature by the given number of points per second.
   * damage: Increase the base damage by the given number of points.
   * dexterity: Adds points to dexterity.
   * experience_gain: Increases the experience gained from bots, in percentage points.
   * health: Adds points to health.
   * health_recovery: Regenerates the given number of health points per second.
   * light_radius: Increases the light radius.
   * paralyze_enemy: Paralyzes hit enemies for the given number of seconds.
   * physique: Adds points to physique.
   * strength: Adds points to strength.
   * slow_enemy: Slows hit enemies for the given number of seconds.

  materials: A table of materials required to craft the add-on. The keys of the
  table are the names of the materials and the values the required counts of the
  corresponding materials. Any item name can used as the key but, since this is
  mainly intended for bot parts, you'd typically use one or more of these:
   * ["Entropy Inverter"] = number
   * ["Plasma Transistor"] = number
   * ["Superconducting Relay Unit"] = number
   * ["Antimatter-Matter Converter"] = number
   * ["Tachyon Condensator"] = number
--]]

addon{
name = "Linarian power crank",
upgrade_cost = 30,
require_socket = "mechanical",
require_item = "melee weapon",
bonuses = { strength = 8 },
materials = { ["Entropy Inverter"] = 10 }
}

addon{
name = "Tungsten spikes",
upgrade_cost = 30,
require_socket = "mechanical",
require_item = "melee weapon",
bonuses = { damage = 3 },
materials = { ["Plasma Transistor"] = 10 }
}

addon{
name = "Tinfoil patch",
upgrade_cost = 50,
require_socket = "mechanical",
require_item = "armor",
bonuses = { cooling = 5, armor = 5 },
materials = { ["Entropy Inverter"] = 20, ["Plasma Transistor"] = 10 }
}

addon{
name = "Laser sight",
upgrade_cost = 45,
require_socket = "universal",
require_item = "ranged weapon",
bonuses = { dexterity = 15 },
materials = { ["Antimatter-Matter Converter"] = 3, ["Plasma Transistor"] = 10 }
}

addon{
name = "Exoskeletal joint",
upgrade_cost = 80,
require_socket = "universal",
require_item = "armor",
bonuses = { physique = 8, strength = 12, dexterity = -2 },
materials = { ["Superconducting Relay Unit"] = 10, ["Entropy Inverter"] = 10 }
}

addon{
name = "Heatsink",
upgrade_cost = 50,
require_socket = "mechanical",
require_item = "armor",
bonuses = { cooling = 7 },
materials = { ["Entropy Inverter"] = 10 }
}

addon{
name = "Peltier element",
upgrade_cost = 60,
require_socket = "electric",
require_item = "armor",
bonuses = { cooling_rate = 3 },
materials = { ["Tachyon Condensator"] = 15 }
}

addon{
name = "Steel mesh",
upgrade_cost = 45,
require_socket = "mechanical",
require_item = "armor",
bonuses = { armor = 10 },
materials = { ["Antimatter-Matter Converter"] = 5, ["Tachyon Condensator"] = 5 }
}

addon{
name = "Shock discharger",
upgrade_cost = 100,
require_socket = "electric",
require_item = "melee weapon",
bonuses = { damage = 5, slow_enemy = 1 },
materials = { ["Superconducting Relay Unit"] = 20, ["Tachyon Condensator"] = 5 }
}

addon{
name = "Silencer",
upgrade_cost = 30,
require_socket = "mechanical",
require_item = "ranged weapon",
bonuses = { damage = 2 },
materials = { ["Entropy Inverter"] = 25, ["Plasma Transistor"] = 10 }
}

addon{
name = "Coprocessor",
upgrade_cost = 80,
require_socket = "electric",
bonuses = { all_attributes = 3 },
materials = { ["Tachyon Condensator"] = 5, ["Plasma Transistor"] = 15 }
}

addon{
name = "Pedometer",
upgrade_cost = 40,
require_socket = "electric",
require_item = "boots",
bonuses = { dexterity = 10 },
materials = { ["Superconducting Relay Unit"] = 3, ["Plasma Transistor"] = 10 }
}

addon{
name = "Foot warmers",
upgrade_cost = 50,
require_socket = "electric",
require_item = "boots",
bonuses = { physique = 10, cooling = -3 },
materials = { ["Entropy Inverter"] = 20, ["Plasma Transistor"] = 5 }
}

addon{
name = "Circuit jammer",
upgrade_cost = 200,
require_socket = "electric",
require_item = "melee weapon",
bonuses = { paralyze_enemy = 1 },
materials = { ["Antimatter-Matter Converter"] = 8, ["Tachyon Condensator"] = 8 }
}

addon{
name = "Sensor disruptor",
upgrade_cost = 100,
require_socket = "universal",
require_item = "melee weapon",
bonuses = { slow_enemy = 5 },
materials = { ["Antimatter-Matter Converter"] = 8, ["Superconducting Relay Unit"] = 8, ["Tachyon Condensator"] = 10 }
}

addon{
name = "Headlamp",
upgrade_cost = 45,
require_socket = "electric",
require_item = "helmet",
bonuses = { light_radius = 5 },
materials = { ["Entropy Inverter"] = 15, ["Plasma Transistor"] = 5 }
}

addon{
name = "Brain stimulator",
upgrade_cost = 100,
require_socket = "electric",
require_item = "helmet",
bonuses = { experience_gain = 5 },
materials = { ["Tachyon Condensator"] = 15 }
}
