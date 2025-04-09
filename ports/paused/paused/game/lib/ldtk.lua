-- A basic LDtk loader for LÖVE created by Hamdy Elzonqali
-- Last tested with LDtk 0.9.3
--
-- ldtk.lua
--
-- Copyright (c) 2021 Hamdy Elzonqali
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--



----------- Loading JSON ------------
-- Remember to put json.lua in the same directory as ldtk.lua

-- Current folder trick
local currentFolder = (...):gsub('%.[^%.]+$', '')

local jsonLoaded = false

if json then
    jsonLoaded = true
end

-- Try to load json
if not jsonLoaded then
    jsonLoaded, json = pcall(require, "json")
end

-- Try to load relatively
if not jsonLoaded then
    jsonLoaded, json = pcall(require, currentFolder .. ".json")
end


local ldtk = {
    levels = {},
    levelsNames = {},
    tilesets = {},
    currentLevelIndex = nil,
    currentLevelName  = '',
    flipped = false
}

local cache = {
    tilesets = {

    },
    quods = {

    },
    batch = {

    }
}

local _path

--------- LAYER OBJECT ---------
--This is used as a switch statement for lua. Much better than if-else pairs.
local flipX = {
    [0] = 1,
    [1] = -1,
    [2] = 1,
    [3] = -1
}

local flipY = {
    [0] = 1,
    [1] = 1,
    [2] = -1,
    [3] = -1
}

local oldColor = {}

--creates the layer object from data. only used here. ignore it
local function create_layer_object(self, data, auto)
    
    self._offsetX = {
        [0] = 0,
        [1] = data.__gridSize,
        [2] = 0,
        [3] = data.__gridSize,
    }

    self._offsetY = {
        [0] = 0,
        [1] = 0,
        [2] = data.__gridSize,
        [3] = data.__gridSize,
    }

    --getting tiles information
    if auto then
        self.tiles = data.autoLayerTiles
    else 
        self.tiles = data.gridTiles
    end

    self._tilesLen = #self.tiles

    self.relPath = data.__tilesetRelPath
    self.path = ldtk.getPath(data.__tilesetRelPath)

    self.id = data.__identifier
    self.x, self.y = data.__pxTotalOffsetX, data.__pxTotalOffsetY
    self.visible = data.visible
    self.color = {1, 1, 1, data.__opacity}

    --getting tileset information
    self.tileset = ldtk.tilesets[data.__tilesetDefUid]

    --creating new tileset if not created yet
    if not cache.tilesets[data.__tilesetDefUid] then
        --loading tileset
        cache.tilesets[data.__tilesetDefUid] = love.graphics.newImage(self.path)
        --creating spritebatch
        cache.batch[data.__tilesetDefUid] = love.graphics.newSpriteBatch(cache.tilesets[data.__tilesetDefUid])

        --creating quads for the tileset
        cache.quods[data.__tilesetDefUid] = {}
        local count = 0
        for ty = 0, self.tileset.__cHei - 1, 1 do
            for tx = 0, self.tileset.__cWid - 1, 1 do
                cache.quods[data.__tilesetDefUid][count] =
                    love.graphics.newQuad(
                        self.tileset.padding + tx * (self.tileset.tileGridSize + self.tileset.spacing),
                        self.tileset.padding + ty * (self.tileset.tileGridSize + self.tileset.spacing),
                        self.tileset.tileGridSize,
                        self.tileset.tileGridSize,
                        cache.tilesets[data.__tilesetDefUid]:getWidth(),
                        cache.tilesets[data.__tilesetDefUid]:getHeight()
                    )
                count = count + 1
            end
        end
    end
end

--draws tiles
local function draw_layer_object(self)
    if self.visible then
        --Saving old color
        oldColor[1], oldColor[2], oldColor[3], oldColor[4] = love.graphics.getColor()

        --Clear batch
        cache.batch[self.tileset.uid]:clear()

        -- Fill batch with quads
         for i = 1, self._tilesLen do
            cache.batch[self.tileset.uid]:add(
                cache.quods[self.tileset.uid][self.tiles[i].t],
                self.x + self.tiles[i].px[1] + self._offsetX[self.tiles[i].f],
                self.y + self.tiles[i].px[2] + self._offsetY[self.tiles[i].f],
                0,
                flipX[self.tiles[i].f],
                flipY[self.tiles[i].f]
            )
        end
        
        --Setting layer color 
        love.graphics.setColor(self.color)
        --Draw batch
        love.graphics.draw(cache.batch[self.tileset.uid])

        --Resotring old color
        love.graphics.setColor(oldColor)
    end
end



----------- HELPER FUNCTIONS ------------
--LDtk uses hex colors while LÖVE uses RGB (on a scale of 0 to 1)
-- Converts hex color to RGB
function ldtk.hex2rgb(color)
    local r = loadstring("return {0x" .. color:sub(2, 3) .. ",0x" .. color:sub(4, 5) .. 
                ",0x" .. color:sub(6, 7) .. "}")()
    return {r[1] / 255, r[2] / 255, r[3] / 255}
end


--Checks if a table is empty.
local function is_empty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

----------- LDTK Functions -------------
--loads project settings
function ldtk:load(file, level)
    self.data = json.decode(love.filesystem.read(file))
    self.entities = {}
    self.x, self.y = self.x or 0, self.x or 0
    self.countOfLevels = #self.data.levels
    self.countOfLayers = #self.data.defs.layers
    
    --creating a table with the path to .ldtk file separated by '/', 
    --used to get the path relative to main.lua instead of the .ldtk file. Ignore it.
    _path = {}
    for str in string.gmatch(file, "([^"..'/'.."]+)") do
        table.insert(_path, str)
    end
    _path[#_path] = nil

    for index, value in ipairs(self.data.levels) do
        self.levels[value.identifier] = index
    end

    for key, value in pairs(self.levels) do
        self.levelsNames[value] = key
    end

    for index, value in ipairs(self.data.defs.tilesets) do
        self.tilesets[value.uid] = self.data.defs.tilesets[index]
    end

    if level then
        self:goTo(level)
    end
end

--getting relative file path to main.lua instead of .ldtk file
function ldtk.getPath(relPath)
    local newPath = ''
    local newRelPath = {}
    local pathLen = #_path

    for str in string.gmatch(relPath, "([^"..'/'.."]+)") do
        table.insert(newRelPath, str)
    end

    for i = #newRelPath, 1, -1 do
        if newRelPath[i] == '..' then
            pathLen = pathLen - 1
            newRelPath[i] = nil
        end
    end

    for i = 1, pathLen, 1 do
        newPath = newPath .. (i > 1 and '/' or '') .. _path[i]
    end

    local keys = {}
    for key, _ in pairs(newRelPath) do
        table.insert(keys, key)
    end
    table.sort(keys)


    local len = #keys
    for i = 1, len, 1 do
        newPath = newPath .. (newPath ~= '' and '/' or '') .. newRelPath[keys[i]]
    end

    return newPath
end


local types = {
    Entities = function (currentLayer, order)
        for _, value in ipairs(currentLayer.entityInstances) do
            local props = {}

            for _, p in ipairs(value.fieldInstances) do
                props[p.__identifier] = p.__value
            end

            ldtk.onEntity({
                id = value.__identifier,
                x = value.px[1],
                y = value.px[2],
                width = value.width,
                height = value.height,
                px = value.__pivot[1],
                py = value.__pivot[2],
                order = order,
                visible = currentLayer.visible,
                props = props
            })
        end
    end,

    Tiles = function (currentLayer, order)
        if not is_empty(currentLayer.gridTiles) then
            local layer = {draw = draw_layer_object}
            create_layer_object(layer, currentLayer, false)
            layer.order = order
            ldtk.onLayer(layer)
        end
    end,

    IntGrid = function (currentLayer, order)
        if not is_empty(currentLayer.autoLayerTiles) and currentLayer.__tilesetDefUid then
            local layer = {draw = draw_layer_object}
            create_layer_object(layer, currentLayer, true)
            layer.order = order
            ldtk.onLayer(layer)
        end
    end,

    AutoLayer = function (currentLayer, order)
        if not is_empty(currentLayer.autoLayerTiles) and currentLayer.__tilesetDefUid then
            local layer = {draw = draw_layer_object}
            create_layer_object(layer, currentLayer, true)
            layer.order = order
            ldtk.onLayer(layer)
        end
    end
}


--Load a level by its index (int)
function ldtk:goTo(index)
    if index > self.countOfLevels or index < 1 then
        error('There are no levels with that index.')
    end

    self.currentLevelIndex = index
    self.currentLevelName  = ldtk.levelsNames[index]

    local layers
    if self.data.externalLevels then
        layers = json.decode(love.filesystem.read(self.getPath(self.data.levels[index].externalRelPath))).layerInstances
    else
        layers = self.data.levels[index].layerInstances
    end
    
    local levelProps = {}
    for _, p in ipairs(self.data.levels[index].fieldInstances) do
        levelProps[p.__identifier] = p.__value
    end



    local levelEntry = {
        backgroundColor = ldtk.hex2rgb(self.data.levels[index].__bgColor),
        id = self.data.levels[index].identifier,
        worldX  = self.data.levels[index].worldX,
        worldY = self.data.levels[index].worldY,
        width = self.data.levels[index].pxWid,
        height = self.data.levels[index].pxHei,
        index = index,
        props = levelProps
    }

    self.onLevelLoaded(levelEntry)

    

    if self.flipped then
        for i = self.countOfLayers, 1, -1 do
            types[layers[i].__type](layers[i], i)
        end    
    else
        for i = 1, self.countOfLayers do
            types[layers[i].__type](layers[i], i)
        end
    end
    

    self.onLevelCreated(levelEntry)
end

--loads a level by its name (string)
function ldtk:level(name)
    self:goTo(self.levels[tostring(name)] or error('There are no levels with the name: "' .. tostring(name) .. '".\nDid you save? (ctrl +s)'))
end

--loads next level
function ldtk:next()
    self:goTo(self.currentLevelIndex + 1 <= self.countOfLevels and self.currentLevelIndex + 1 or 1)
end

--loads previous level
function ldtk:previous()
    self:goTo(self.currentLevelIndex - 1 >= 1 and self.currentLevelIndex - 1 or self.countOfLevels)
end

--reloads current level
function ldtk:reload()
    self:goTo(self.currentLevelIndex)
end

--gets the index of a specific level
function ldtk.getIndex(name)
    return ldtk.levels[name]
end

--get the name of a specific level
function ldtk.getName(index)
    return ldtk.levelsNames[index]
end

--gets the current level index
function ldtk:getCurrent()
    return self.currentLevelIndex
end

--get the current level name
function ldtk:getCurrentName()
    return ldtk.levelsNames[self:getCurrent()]
end

--sets whether to invert the loop or not
function ldtk:setFlipped(flipped)
    self.flipped = flipped
end

--gets whether the loop is inverted or not
function ldtk:getFlipped()
    return self.flipped
end

--remove the cahced tiles and quods. you may use it if you have multiple .ldtk files
function ldtk.removeCache()
    cache = {
        tilesets = {
            
        },
        quods = {
            
        },
        batch = {

        }
    }
    collectgarbage()
end



--------- CALLBACKS ----------
--[[
    This library depends heavily on callbacks. It works by overriding the default callbacks.
]]

--[[
    ldtk.onEntity is called when a new entity is created.
    
    entity = {
        id          = (string), 
        x           = (int), 
        y           = (int), 
        width       = (int), 
        height      = (int), 
        visible     = (bool)
        px          = (int),    --pivot x
        py          = (int),    --pivot y
        order       = (int), 
        props       = (table)   --custom fields defined in LDtk
    }
    
    Remember that colors are saved in HEX format and not RGB. 
    You can use ldtk ldtk.hex2rgb(color) to get an RGB table like {0.21, 0.57, 0.92}
]]
function ldtk.onEntity(entity)
    
end

--[[
    ldtk.onLayer is called when a new layer is created.    

    layer:draw() --used to draw the layer

    layer = {
        id          = (string), 
        x           = (int), 
        y           = (int), 
        visible     = (bool)
        color       = (table),  --the color of the layer {r,g,b,a}. Usually used for opacity.
        order       = (int),
        draw        = (function) -- used to draw the layer
    }
]]
function ldtk.onLayer(layer)
    
end

--[[
    ldtk.onLevelLoaded is called after the level data is loaded but before it's created.

    It's usually useful when you need to remove old objects and change some settings like background color

    level = {
        id          = (string), 
        worldX      = (int), 
        worldY      = (int), 
        width       = (int), 
        height      = (int), 
        props       = (table), --custom fields defined in LDtk
        backgroundColor = (table) --the background color of the level as defined in LDtk
    }
    
    props table has the custom fields defined in LDtk
]]
function ldtk.onLevelLoaded(levelData)
    
end

--[[
    ldtk.onLevelCreated is called after the level is created.

    It's usually useful when you need to call a function or manipulate the objects after they are created.

    level = {
        id          = (string), 
        worldX      = (int), 
        worldY      = (int), 
        width       = (int), 
        height      = (int), 
        props       = (table), --custom fields defined in LDtk
        backgroundColor = (table) --the background color of the level as defined in LDtk
    }
]]
function ldtk.onLevelCreated(levelData)
    
end




return ldtk
