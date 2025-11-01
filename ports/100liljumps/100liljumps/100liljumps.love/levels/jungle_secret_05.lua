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
  nextobjectid = 1424,
  properties = {
    ["name"] = "jungle_secret_05"
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
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0,
        1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1227, 1228, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1243, 1244, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1221, 1222, 1223, 1224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1237, 1238, 1239, 1240, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1180, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0,
        1253, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1195, 0, 0, 0,
        1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1179, 0, 0, 0,
        1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1195, 0, 0, 0,
        1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1179, 0, 0, 0,
        0, 1253, 1253, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 1195, 0, 0, 0,
        0, 1253, 1253, 1253, 0, 0, 0, 0, 0, 1179, 0, 0, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 1179, 0, 0, 0,
        0, 0, 1253, 1253, 0, 0, 0, 0, 0, 1195, 0, 0, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 1195, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 1253, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 0, 0, 1179, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0,
        1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0,
        1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0,
        1253, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 1195, 0, 0, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0,
        1253, 1253, 1253, 0, 1253, 0, 0, 0, 0, 1179, 0, 0, 0, 1253, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1179, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 0, 0, 0, 0, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 0, 1179, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1195, 0, 0, 0, 0, 0, 0, 1253, 1253, 1253, 0, 0, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 0, 0, 0, 0, 1195, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1253, 1253, 0, 0, 0, 0, 0, 1253, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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
        1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1288, 1253, 1253, 1253, 1253, 1271, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1269, 1253, 1253, 1253, 1303, 1253, 1253, 1253, 1253,
        1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1288, 1253, 1253, 1253, 1253, 1301, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253,
        1126, 1126, 1126, 1126, 1174, 1126, 1126, 1126, 1126, 1126, 1126, 1158, 1158, 1158, 1158, 1158, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1161, 1126, 1126, 1253,
        1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        1161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        1126, 0, 0, 0, 1126, 1144, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 0, 1126, 1126, 1126, 1126, 1126, 1144, 1126, 1126, 1158, 1158, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1301,
        1126, 0, 0, 0, 0, 0, 0, 0, 1158, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 1126, 1126, 1158, 1126, 1126, 1158, 1158, 1126, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        1158, 0, 0, 0, 0, 0, 0, 0, 1158, 0, 0, 1126, 1126, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        1158, 1126, 1126, 1126, 1126, 0, 0, 0, 1158, 1126, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        1253, 1253, 1301, 1253, 1126, 0, 0, 0, 1126, 1253, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 1126, 1126, 1126, 1158, 1158, 1158, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 1161, 1253,
        1253, 1271, 1253, 1253, 1126, 0, 0, 0, 1161, 1269, 1253, 1126, 1126, 1126, 1174, 1126, 1126, 1126, 0, 0, 0, 0, 0, 1126, 1253, 1253, 1269, 1253, 1253, 1253, 1253, 1253, 1126, 1126, 0, 0, 0, 0, 1126, 1253,
        1253, 1253, 1253, 1253, 1161, 0, 0, 0, 1126, 1253, 1253, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 0, 0, 0, 0, 0, 1126, 1253,
        1126, 1126, 1126, 1126, 1126, 0, 0, 0, 1126, 1253, 1253, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1253, 1126, 0, 0, 0, 0, 1126, 1126, 1158, 1158, 1158, 1144, 1126, 1126, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253,
        0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1158, 1158, 1158, 1253,
        1126, 1126, 1144, 1126, 1126, 1126, 0, 0, 1126, 1253, 1253, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1253, 1253,
        1253, 1253, 1253, 1253, 1253, 1174, 0, 0, 1126, 1126, 1126, 1126, 1158, 1126, 0, 0, 0, 1126, 1126, 1126, 1126, 0, 0, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1161, 1126, 1158, 0, 0, 0, 1126, 1126, 1126, 1126,
        1253, 1253, 1253, 1253, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1303, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1253, 1253, 1253, 1253, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1126, 1253, 1253, 1126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1253, 1253, 1253, 1253, 1253, 1126, 1144, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1158, 1158, 1158, 1126, 1253, 1253, 1126, 1126, 1126, 1126, 1144, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1126, 1161,
        1253, 1288, 1301, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1269, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1258, 1259, 1260, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1303, 1253,
        1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1274, 1275, 1276, 1253, 1301, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253,
        1253, 1253, 1253, 1253, 1271, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1303, 1253, 1253, 1253, 1253, 1290, 1291, 1292, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253, 1253
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
          id = 812,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1228,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1220,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1143,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 995,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1222,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1182,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 875,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1221,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1150,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1004,
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
          id = 1223,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 843,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1112,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 964,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1183,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 844,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1151,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1005,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 827,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1128,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 980,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1184,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 860,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1152,
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
          id = 1006,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 828,
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
          id = 1113,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 965,
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
          id = 1185,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 845,
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
          id = 1153,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1007,
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
          id = 1048,
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
          id = 819,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1224,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1136,
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
          id = 988,
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
          id = 1186,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 868,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1154,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1008,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 836,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1114,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 966,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1187,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1040,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 846,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1155,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1036,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1009,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1044,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 820,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1129,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 981,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1188,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 861,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1156,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1010,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 829,
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
          id = 1115,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 967,
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
          id = 1189,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 940,
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
          id = 1107,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 959,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 1190,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 847,
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
          id = 1157,
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
          id = 1011,
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
          id = 1049,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 945,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 1145,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 999,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 815,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1225,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1140,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 992,
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
          id = 1191,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 872,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1158,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1012,
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
          id = 840,
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
          id = 1116,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
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
          id = 968,
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
          id = 1192,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
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
          id = 1041,
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
          id = 848,
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
          id = 1159,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
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
          id = 1037,
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
          id = 1013,
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
          id = 1045,
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
          id = 824,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1130,
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
          id = 982,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1193,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 862,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1160,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1014,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 830,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1117,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 969,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1194,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 849,
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
          id = 1161,
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
          id = 1015,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1050,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 816,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 1137,
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
          id = 989,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 1195,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 869,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 1162,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 1016,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 837,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1118,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 970,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1196,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 850,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1163,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1017,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 821,
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
          id = 1131,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
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
          id = 983,
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
          id = 1197,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
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
          id = 863,
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
          id = 1164,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
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
          id = 1018,
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
          id = 831,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 1119,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 971,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 1198,
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
          id = 941,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 1108,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 960,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 1199,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 950,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1078,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1092,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 956,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1082,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1096,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1102,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1062,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1088,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 851,
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
          id = 1165,
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
          id = 1019,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 1051,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 946,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 1146,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 1000,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 280,
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
          id = 953,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1080,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1094,
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
          id = 1100,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1058,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1086,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
          y = 80,
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
          id = 996,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1084,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1098,
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
          id = 1104,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1066,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 1090,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 304,
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
          id = 813,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1227,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1142,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 994,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1200,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 874,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1166,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1020,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 842,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1120,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 972,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1201,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1042,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 852,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1167,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1038,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1021,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1046,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 826,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1132,
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
          id = 984,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1202,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 864,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1168,
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
          id = 1022,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 832,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1121,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 973,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1203,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 853,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1169,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1023,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1052,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 818,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1138,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 990,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1204,
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
          id = 870,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1170,
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
          id = 1024,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 838,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1122,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 974,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1205,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 854,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1171,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1025,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 822,
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
          id = 1133,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
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
          id = 985,
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
          id = 1206,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
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
          id = 865,
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
          id = 1172,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
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
          id = 1026,
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
          id = 833,
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
          id = 1123,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 975,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 1207,
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
          id = 942,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 1109,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 961,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 1208,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 951,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 1106,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 957,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 1209,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 1063,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 855,
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
          id = 1173,
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
          id = 1027,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 1053,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 947,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 1147,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 1001,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 272,
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
          id = 954,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 1144,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 1059,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 997,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 1067,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 296,
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
          id = 814,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1226,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1141,
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
          id = 993,
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
          id = 1210,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 873,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1174,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1028,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 841,
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
          id = 1124,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
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
          id = 976,
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
          id = 1211,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
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
          id = 1043,
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
          id = 856,
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
          id = 1175,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
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
          id = 1039,
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
          id = 1029,
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
          id = 1047,
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
          id = 825,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1134,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 986,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1212,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 866,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1176,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1030,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 834,
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
          id = 1125,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 977,
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
          id = 1213,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 943,
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
          id = 1110,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 962,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 1214,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 857,
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
          id = 1177,
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
          id = 1031,
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
          id = 1054,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 948,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 1148,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 1002,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 1055,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 817,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 1139,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 991,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 1215,
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
          id = 871,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 1178,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 1032,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 839,
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
          id = 1126,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 978,
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
          id = 1216,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 858,
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
          id = 1179,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1033,
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
          id = 1056,
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
          id = 823,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 1135,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 987,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 1217,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 867,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 1180,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 1034,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 835,
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
          id = 1127,
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
          id = 979,
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
          id = 1218,
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
          id = 944,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1111,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 963,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1219,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1064,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 952,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1079,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1093,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 958,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1083,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1097,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1103,
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
          id = 1065,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1089,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 859,
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
          id = 1181,
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
          id = 1035,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 1057,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 949,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1149,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1061,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1003,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 1068,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 288,
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
          id = 955,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1081,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1095,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1101,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1060,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1087,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
          y = 80,
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
          id = 998,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1085,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1099,
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
          id = 1105,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1069,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1091,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 312,
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
          id = 1229,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1230,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1231,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1232,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 48,
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
          id = 1233,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1234,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 56,
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
          id = 1235,
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
          id = 1236,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1237,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1238,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1239,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
          y = 80,
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
          id = 1240,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1241,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1242,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1243,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1244,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1245,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1246,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 64,
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
          id = 1247,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1248,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1249,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1250,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1252,
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
          id = 1253,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1254,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1255,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1256,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1257,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1258,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1259,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1260,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1261,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1262,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1263,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1264,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1265,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1266,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1267,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1268,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1269,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1270,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1271,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
          y = 80,
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
          id = 1272,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
          y = 80,
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
          id = 1273,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 72,
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
          id = 1274,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 80,
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
          id = 1275,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
          y = 80,
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
          id = 1276,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1277,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1278,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1279,
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
          id = 1280,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1281,
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
          id = 1282,
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
          id = 1283,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1284,
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
          id = 1285,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1286,
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
          id = 1287,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1290,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1291,
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
          id = 1292,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1293,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
          y = 80,
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
          id = 1294,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
          y = 80,
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
          id = 1297,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
          y = 80,
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
          id = 1298,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
          y = 80,
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
          id = 1299,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1300,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1301,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1302,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1303,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1304,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1305,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1306,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1307,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 40,
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
          id = 1308,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1309,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1310,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1311,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1312,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 32,
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
          id = 1313,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1314,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1315,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 16,
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
          id = 1316,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 24,
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
          id = 1317,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 8,
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
          id = 1318,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 0,
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
          id = 1319,
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
          id = 1320,
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
          id = 1321,
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
          id = 1322,
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
          id = 1323,
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
          id = 1324,
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
          id = 1325,
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
          id = 1326,
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
          id = 1327,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1328,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1329,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1330,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1331,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1332,
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
          id = 1333,
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
          id = 1334,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1335,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1336,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1337,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1338,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1339,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1340,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1341,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1342,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
          y = 80,
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
          id = 1343,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
          y = 80,
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
          id = 1344,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
          y = 80,
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
          id = 1345,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
          y = 80,
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
          id = 1346,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
          y = 80,
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
          id = 1349,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1350,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1351,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1352,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 1353,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 1354,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 1355,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1356,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 1357,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 1358,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 1359,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 1360,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
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
          id = 1361,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
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
          id = 1362,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 264,
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
          id = 1363,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 256,
          y = 80,
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
          id = 1364,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 248,
          y = 80,
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
          id = 1365,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
          y = 80,
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
          id = 1366,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 240,
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
          id = 1367,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 1368,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 1369,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
          y = 80,
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
          id = 1370,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
          y = 80,
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
          id = 1373,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
          y = 80,
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
          id = 1374,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
          y = 80,
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
          id = 1375,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 232,
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
          id = 1376,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 224,
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
          id = 1377,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 216,
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
          id = 1378,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1379,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 208,
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
          id = 1380,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1381,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 200,
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
          id = 1382,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1383,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 192,
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
          id = 1384,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1385,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 184,
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
          id = 1386,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1387,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 176,
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
          id = 1388,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1389,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 168,
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
          id = 1390,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1393,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 160,
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
          id = 1396,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
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
          id = 1397,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 152,
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
          id = 1398,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
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
          id = 1399,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 144,
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
          id = 1400,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1401,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1402,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1403,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1404,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1405,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 1406,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
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
          id = 1409,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1410,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1411,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
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
          id = 1412,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1413,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
          y = 80,
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
          id = 1414,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 88,
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
          id = 1415,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 96,
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
          id = 1417,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 104,
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
          id = 1418,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 112,
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
          id = 1419,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 120,
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
          id = 1420,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 128,
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
          id = 1421,
          name = "",
          type = "glitch_block",
          shape = "rectangle",
          x = 136,
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
          id = 1422,
          name = "1-2",
          type = "door",
          shape = "rectangle",
          x = 312,
          y = 152,
          width = 8,
          height = 16,
          rotation = 0,
          gid = 21,
          visible = true,
          properties = {
            ["direction"] = -1,
            ["jumps_to_unlock"] = 0,
            ["spawn_pos_dx"] = -2,
            ["spawn_pos_dy"] = -1,
            ["target_door_name"] = "2-1",
            ["target_level_name"] = "jungle_secret_04",
            ["visible"] = false
          }
        },
        {
          id = 1423,
          name = "2-1",
          type = "door",
          shape = "rectangle",
          x = 0,
          y = 120,
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
            ["target_level_name"] = "jungle_secret_06",
            ["visible"] = false
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
