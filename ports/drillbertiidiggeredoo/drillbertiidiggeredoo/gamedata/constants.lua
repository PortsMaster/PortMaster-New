local constants = {}

constants.tile_size = 16
constants.screen_size = {32, 17}

constants.spawn_tile_id = 6
constants.air_tile_id = 0
constants.level_end_tile_id = 4
constants.loot_tile_id = 5
constants.dirt_tile_id = 1
constants.deleted_placeholder_tile = -1

constants.rock_1_tile_id = 2
constants.rock_2_tile_id = 3
constants.rock_3_tile_id = 11

constants.gui_left_tile = 13
constants.gui_middle_tile = 14
constants.gui_right_tile = 15

constants.number_tiles =
{
  73,
  64,
  65,
  66,
  67,
  68,
  69,
  70,
  71,
  72,
}

constants.slash_tile = 74
constants.coin_gui = 75
constants.exclamations = 76



constants.dirt_transitions = {}
--                          UDLR
constants.dirt_transitions["0000"] = 1
constants.dirt_transitions["0001"] = 37
constants.dirt_transitions["0010"] = 39
constants.dirt_transitions["0011"] = 38
constants.dirt_transitions["0100"] = 20
constants.dirt_transitions["0101"] = 17
constants.dirt_transitions["0110"] = 19
constants.dirt_transitions["0111"] = 18
constants.dirt_transitions["1000"] = 36
constants.dirt_transitions["1001"] = 33
constants.dirt_transitions["1010"] = 35
constants.dirt_transitions["1011"] = 34
constants.dirt_transitions["1100"] = 28
constants.dirt_transitions["1101"] = 25
constants.dirt_transitions["1110"] = 27
constants.dirt_transitions["1111"] = 26

local bedrock_gap = 24

constants.bedrock_transitions = {}
constants.bedrock_transitions["0000"] = 3
constants.bedrock_transitions["0001"] = constants.dirt_transitions["0001"] + bedrock_gap
constants.bedrock_transitions["0010"] = constants.dirt_transitions["0010"] + bedrock_gap
constants.bedrock_transitions["0011"] = constants.dirt_transitions["0011"] + bedrock_gap
constants.bedrock_transitions["0100"] = constants.dirt_transitions["0100"] + bedrock_gap
constants.bedrock_transitions["0101"] = constants.dirt_transitions["0101"] + bedrock_gap
constants.bedrock_transitions["0110"] = constants.dirt_transitions["0110"] + bedrock_gap
constants.bedrock_transitions["0111"] = constants.dirt_transitions["0111"] + bedrock_gap
constants.bedrock_transitions["1000"] = constants.dirt_transitions["1000"] + bedrock_gap
constants.bedrock_transitions["1001"] = constants.dirt_transitions["1001"] + bedrock_gap
constants.bedrock_transitions["1010"] = constants.dirt_transitions["1010"] + bedrock_gap
constants.bedrock_transitions["1011"] = constants.dirt_transitions["1011"] + bedrock_gap
constants.bedrock_transitions["1100"] = constants.dirt_transitions["1100"] + bedrock_gap
constants.bedrock_transitions["1101"] = constants.dirt_transitions["1101"] + bedrock_gap
constants.bedrock_transitions["1110"] = constants.dirt_transitions["1110"] + bedrock_gap
constants.bedrock_transitions["1111"] = constants.dirt_transitions["1111"] + bedrock_gap

return constants