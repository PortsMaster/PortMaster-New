return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "left-down",
  width = 40,
  height = 23,
  tilewidth = 8,
  tileheight = 8,
  nextlayerid = 12,
  nextobjectid = 821,
  properties = {
    ["name"] = "jungle_secret_04"
  },
  tilesets = {
    {
      name = "collision",
      firstgid = 1,
      filename = "../../tiled_project/collision.tsx"
    },
    {
      name = "entities-sheet",
      firstgid = 17,
      filename = "../../tiled_project/entities-sheet.tsx"
    },
    {
      name = "spike-sheet",
      firstgid = 49,
      filename = "../../tiled_project/spike-sheet.tsx"
    },
    {
      name = "ground",
      firstgid = 53,
      filename = "../../tiled_project/ground.tsx"
    },
    {
      name = "trees",
      firstgid = 309,
      filename = "../../tiled_project/trees.tsx",
      exportfilename = "../tile_sets/trees.lua"
    },
    {
      name = "jungle",
      firstgid = 565,
      filename = "../../tiled_project/jungle.tsx"
    },
    {
      name = "deco",
      firstgid = 821,
      filename = "../../tiled_project/deco.tsx"
    },
    {
      name = "glitch_tset",
      firstgid = 1077,
      filename = "../../tiled_project/glitch_tset.tsx"
    }
  },
  layers = {
    {
      type = "imagelayer",
      image = "../glitch-background.png",
      id = 10,
      name = "background",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      repeatx = false,
      repeaty = false,
      properties = {}
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 23,
      id = 1,
      name = "collision",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0,
        0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0,
        1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 23,
      id = 11,
      name = "back_2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1285, 1285, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1285, 1285, 1285, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 23,
      id = 6,
      name = "back_1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1303, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 1253, 0, 0, 1288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 1271, 1253, 0, 0, 0, 1288, 1253, 0, 0, 0, 0, 1253, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1271, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1286, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 1253, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 0, 0, 0, 0, 0, 1253, 1271, 0, 0, 0, 0, 0, 0, 0, 0, 1286, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1115, 1116, 0, 0, 1285, 1285, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0,
        0, 0, 0, 0, 1131, 1132, 0, 0, 1285, 1285, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253,
        0, 0, 0, 0, 1115, 1116, 0, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253,
        0, 0, 0, 0, 1131, 1132, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 1253,
        0, 0, 0, 0, 1115, 1116, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1286, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 1253, 1253,
        0, 0, 0, 0, 1131, 1132, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 1253, 1253, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 1253, 1253, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 1253, 1253, 1253, 1253, 1253, 1253,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 1253, 1253
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 23,
      id = 4,
      name = "deco_1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 0, 0, 1126, 1126, 1126, 0, 0, 1126, 1126, 1126, 0, 0, 1126, 1126, 0, 0, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 0, 0, 1126, 1126, 1126, 0, 0, 1126, 1126, 1126, 0, 0, 1126, 1126, 0, 0, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 0, 0, 1126, 0, 1126, 0, 0, 1126, 0, 1126, 0, 0, 1126, 1126, 0, 0, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1129, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1253, 1158, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126,
        1285, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126,
        1253, 1256, 1176, 1129, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126,
        1253, 1253, 1253, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 1253,
        1253, 1285, 1303, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1271,
        1269, 1285, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1253,
        1285, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1083, 1086, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1159, 1253, 1253,
        1253, 1286, 1174, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1099, 1102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1253,
        1253, 1253, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1303, 1253,
        1303, 1253, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 0, 0, 0, 1083, 1086, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1161, 1174, 1253,
        1285, 1285, 1129, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 0, 0, 0, 1099, 1102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126,
        1253, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1083, 1086, 0, 0, 0, 1126, 1176, 0, 0, 0, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1158, 1176, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1099, 1102, 0, 0, 0, 1126, 1126, 0, 0, 0, 1136, 1122, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1158, 0, 0, 0, 1159, 1158, 0, 0, 0, 1152, 1138, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158, 1126,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158, 1176, 0, 0, 0, 1126, 1126, 0, 0, 0, 1158, 1154, 0, 0, 1089, 1090, 0, 0, 0, 0, 0, 0, 0, 1129, 1126, 1126, 1253,
        1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 1158, 1126, 0, 0, 0, 1158, 1126, 0, 0, 0, 1126, 1126, 0, 0, 1105, 1106, 0, 0, 0, 0, 0, 1126, 1144, 1126, 1256, 1253, 1253,
        1253, 1253, 1253, 1253, 1253, 1253, 1253, 1126, 1126, 0, 0, 0, 0, 1129, 1158, 0, 0, 0, 1126, 1126, 0, 0, 0, 1176, 1126, 0, 0, 1126, 1126, 0, 0, 0, 0, 1126, 1158, 1253, 1253, 1253, 1253, 1253,
        1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1126, 1126, 0, 0, 0, 1126, 1126, 0, 0, 0, 1176, 1126, 0, 0, 0, 1126, 1158, 0, 0, 1159, 1126, 0, 0, 1126, 1159, 1126, 1253, 1253, 1253, 1253, 1253, 1286
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "entities",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 733,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 786,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 734,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 788,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 735,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 790,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 736,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 792,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 817,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 144,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 793,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 819,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
          y = 136,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 737,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 791,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 816,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 144,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 794,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 818,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 136,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 740,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 789,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 741,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 787,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 742,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 785,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 743,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 762,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 752,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 761,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 184,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 744,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 764,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 753,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 763,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 176,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 745,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 766,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 754,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 765,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 168,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 746,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 768,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 755,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 767,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 747,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 770,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 756,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 769,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 748,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 144,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 772,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 144,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 757,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 144,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 771,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 144,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 749,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 136,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 774,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 136,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 779,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 112,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 758,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 136,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 773,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 136,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 780,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 112,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 750,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 128,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 776,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 128,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 781,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 104,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 759,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 128,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 775,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 128,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 782,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 104,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 751,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 120,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 778,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 120,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 783,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
          y = 96,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 760,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 120,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 777,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 120,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 784,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
          y = 96,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 795,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
          y = 8,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 796,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
          y = 16,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 797,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
          y = 24,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 798,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
          y = 32,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 799,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
          y = 24,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 800,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
          y = 24,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 801,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
          y = 40,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 802,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
          y = 56,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 803,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
          y = 16,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 804,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
          y = 32,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 805,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
          y = 32,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 806,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
          y = 40,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 807,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
          y = 48,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 808,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
          y = 48,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 809,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
          y = 48,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
        },
        {
          id = 810,
          name = "1-2",
          type = "door",
          shape = "rectangle",
          x = 312,
          y = 144,
          width = 8,
          height = 16,
          rotation = 0,
          gid = 21,
          visible = true,
          properties = {
            ["direction"] = -1,
            ["jumps_to_unlock"] = 0,
            ["spawn_pos_dx"] = -2,
            ["spawn_pos_dy"] = 0,
            ["target_door_name"] = "2-1",
            ["target_level_name"] = "jungle_secret_03",
            ["visible"] = false
          }
        },
        {
          id = 811,
          name = "2-1",
          type = "door",
          shape = "rectangle",
          x = 0,
          y = 160,
          width = 8,
          height = 16,
          rotation = 0,
          gid = 21,
          visible = true,
          properties = {
            ["direction"] = 1,
            ["jumps_to_unlock"] = 0,
            ["spawn_pos_dx"] = 2,
            ["spawn_pos_dy"] = -1,
            ["target_door_name"] = "1-2",
            ["target_level_name"] = "jungle_secret_05",
            ["visible"] = false
          }
        },
        {
          id = 812,
          name = "",
          type = "falling_column",
          shape = "rectangle",
          x = 144,
          y = 16,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 33,
          visible = true,
          properties = {}
        },
        {
          id = 813,
          name = "",
          type = "falling_column",
          shape = "rectangle",
          x = 184,
          y = 16,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 33,
          visible = true,
          properties = {}
        },
        {
          id = 814,
          name = "",
          type = "falling_column",
          shape = "rectangle",
          x = 216,
          y = 16,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 33,
          visible = true,
          properties = {}
        },
        {
          id = 815,
          name = "",
          type = "falling_column",
          shape = "rectangle",
          x = 104,
          y = 16,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 33,
          visible = true,
          properties = {}
        },
        {
          id = 820,
          name = "",
          type = "falling_column",
          shape = "rectangle",
          x = 48,
          y = 16,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 33,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "spikes",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {}
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 23,
      id = 5,
      name = "deco_2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1227, 1228, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1243, 1244, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
