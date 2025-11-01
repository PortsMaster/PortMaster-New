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
  nextobjectid = 733,
  properties = {
    ["name"] = "jungle_secret_03"
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
        0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0,
        1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0,
        1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,
        0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 1180, 0, 0, 1271, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 1180, 1271, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1303, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1285, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1285, 1271, 1285, 1285, 1285, 1271, 1269, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1285, 1285, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1269, 1269, 1285, 1285, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 770, 770, 770,
        0, 0, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 770, 770, 770,
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 733, 770, 770,
        0, 0, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 780, 782, 783,
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 734, 759, 760,
        0, 0, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 779, 0, 0,
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1158, 1158, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1158, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1158, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 1253, 1269, 1253, 1253, 1271, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1285, 1158, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 1253, 1253, 1285, 1253, 1253, 1288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1158, 1158, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 1253, 1253, 1253, 1253, 1285, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1179, 1271, 1253, 1253, 1285, 1253, 1253, 1271, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1195, 0, 763, 763, 763, 763, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1285, 1285, 1285, 1285, 1285, 1285, 1285,
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1303, 1285, 1253, 0, 1288, 1285, 0, 0, 1285, 1285, 1285, 1285,
        0, 0, 0, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 762, 709, 709, 709, 709, 709, 0, 0, 0, 0, 1285, 1285, 1285, 1285, 1285, 1285, 1303, 1285, 0, 0, 0, 0, 1285, 1285, 1285,
        0, 0, 0, 1181, 0, 0, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1181, 1290, 1291, 1292, 1290, 1291, 1292, 0, 0, 1285, 1303, 1285, 1285, 1285, 1285, 1285, 1285, 1285, 0, 0, 0, 1227, 1228, 1285, 1285,
        709, 709, 770, 1197, 0, 0, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1197, 1258, 1259, 1260, 1258, 1259, 1260, 0, 0, 1285, 1285, 1285, 0, 0, 0, 0, 1285, 1285, 1285, 1285, 0, 1243, 1244, 1285, 1285,
        0, 709, 709, 709, 709, 770, 0, 0, 0, 1115, 0, 1115, 1180, 0, 0, 1181, 1274, 1275, 1276, 1274, 1275, 1276, 0, 1285, 1285, 1285, 1285, 0, 0, 0, 0, 0, 709, 709, 709, 709, 709, 709, 709, 709,
        0, 0, 0, 0, 0, 770, 0, 0, 0, 1131, 0, 1131, 1196, 0, 0, 1197, 1290, 1291, 1292, 1290, 1291, 1292, 0, 0, 0, 709, 709, 709, 709, 709, 709, 709, 0, 0, 709, 709, 0, 0, 709, 709,
        0, 0, 0, 0, 0, 0, 0, 770, 709, 709, 709, 709, 709, 709, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 709, 709, 0, 0, 0, 0, 0, 0, 709, 709, 0, 0, 0, 709,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 709, 709, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 709, 709, 0, 0, 0, 0
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1132, 1195, 1132,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1116, 1179, 1116,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1132, 1195, 1132,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1116, 1179, 1116,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1132, 1195, 1132,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1116, 1179, 1116,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1132, 1195, 1132,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1116, 1179, 1116,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1132, 1195, 1132,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158, 1158, 1158,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1285, 1285,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1285,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1089, 1090, 1083, 1084, 1085, 1086, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1159, 1105, 1106, 1099, 1100, 1101, 1102, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 1126, 1176, 1158, 1126, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1126, 1126, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1253, 1253, 1176, 1126, 1126, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1176, 1258, 1259, 1260, 1258, 1259, 1260,
        1285, 1285, 1253, 1253, 1253, 1126, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1158, 1103, 1087, 1087, 1087, 1087, 1087, 1104, 1126, 1126, 1253, 1274, 1275, 1276, 1274, 1275, 1276,
        1285, 1285, 1285, 0, 1285, 1253, 1126, 1159, 1158, 1126, 1126, 1176, 1174, 1126, 1158, 1126, 1158, 1126, 1158, 1126, 1126, 1126, 1158, 1158, 1174, 1126, 1158, 1158, 1176, 1126, 1126, 1126, 1285, 1253, 1290, 1291, 1292, 1290, 1291, 1292,
        1285, 1285, 1285, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1285, 1253, 1285, 1285, 1285, 1253, 1253, 1253, 1285, 1285, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1258, 1259, 1260, 1258, 1259, 1260,
        1253, 1253, 1253, 1285, 1253, 1253, 1253, 1285, 1253, 1253, 1253, 1253, 1253, 1285, 1285, 1253, 1285, 1285, 1253, 1253, 1253, 1253, 1253, 1253, 1285, 1253, 1253, 1253, 1253, 1285, 1285, 1285, 1285, 1253, 1274, 1275, 1276, 1274, 1275, 1276
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
          id = 659,
          name = "1-2",
          type = "door",
          shape = "rectangle",
          x = 312,
          y = 144,
          width = 8,
          height = 32,
          rotation = 0,
          gid = 21,
          visible = true,
          properties = {
            ["direction"] = -1,
            ["jumps_to_unlock"] = 0,
            ["spawn_pos_dx"] = -2,
            ["spawn_pos_dy"] = -2,
            ["target_door_name"] = "2-1",
            ["target_level_name"] = "jungle_secret_02",
            ["visible"] = false
          }
        },
        {
          id = 732,
          name = "2-1",
          type = "door",
          shape = "rectangle",
          x = 0,
          y = 136,
          width = 8,
          height = 32,
          rotation = 0,
          gid = 21,
          visible = true,
          properties = {
            ["direction"] = 1,
            ["jumps_to_unlock"] = 0,
            ["spawn_pos_dx"] = 2,
            ["spawn_pos_dy"] = -2,
            ["target_door_name"] = "1-2",
            ["target_level_name"] = "jungle_secret_04",
            ["visible"] = false
          }
        },
        {
          id = 660,
          name = "",
          type = "bouncer",
          shape = "rectangle",
          x = 192,
          y = 152,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 18,
          visible = true,
          properties = {}
        },
        {
          id = 661,
          name = "",
          type = "bouncer",
          shape = "rectangle",
          x = 64,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 18,
          visible = true,
          properties = {}
        },
        {
          id = 662,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 216,
          y = 152,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 665,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 248,
          y = 152,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 667,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 168,
          y = 160,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 669,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 104,
          y = 160,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 671,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 144,
          y = 104,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 663,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 220,
          y = 152,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 664,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 252,
          y = 152,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 666,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 172,
          y = 160,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 668,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 108,
          y = 160,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 670,
          name = "",
          type = "spike",
          shape = "rectangle",
          x = 148,
          y = 104,
          width = 4,
          height = 4,
          rotation = 0,
          gid = 51,
          visible = true,
          properties = {}
        },
        {
          id = 672,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 673,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 674,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 675,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 676,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 677,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 678,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 679,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 680,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 681,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 682,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 683,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
          y = 88,
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
          id = 684,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 685,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 686,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 687,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 688,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 689,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 690,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 691,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 692,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 693,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 694,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 695,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 696,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 697,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 698,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 699,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 700,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 701,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 702,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 703,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 704,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 706,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 707,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 708,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 709,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 710,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 711,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 712,
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
          id = 713,
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
          id = 714,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 715,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 716,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 717,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 718,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 719,
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
          id = 720,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 721,
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
          id = 722,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 723,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 724,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 725,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 726,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
          y = 72,
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
          id = 727,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
          y = 64,
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
          id = 728,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
          y = 72,
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
          id = 729,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
          y = 72,
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
          id = 730,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
          y = 64,
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
          id = 731,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
          y = 56,
          width = 8,
          height = 8,
          rotation = 0,
          gid = 35,
          visible = true,
          properties = {
            ["level"] = 3
          }
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 165, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 821, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 821, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 332, 333, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 332, 0, 0, 824, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 165, 0, 0, 0, 165, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 165, 0, 0, 0, 822, 0, 0, 0, 165, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
