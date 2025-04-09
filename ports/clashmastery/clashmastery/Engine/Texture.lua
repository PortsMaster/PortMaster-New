local Texture = {}

-- Takes in an array of textureInfo tables
-- these tables have: filename, slice
-- slice is the width/height in pixels of each sprite in the sheet
function Texture.initialize(textureInfos)
    Texture.textures = {}
    for i,info in ipairs(textureInfos) do
        local currentImage = love.graphics.newImage("Textures/" .. textureInfos[i].filename)
        local width, height = currentImage:getDimensions()
        Texture.textures[i] = {
            image = currentImage,
            columns = width / textureInfos[i].slice,
            width = width,
            height = height,
            slice = textureInfos[i].slice
        }
    end
end
-- flip is 1 if not flipped, -1 if flipped.
function Texture.draw(texture, spr, x, y, flip, flipY, alpha, color, rotation, spriteQuad, scaleX, scaleY)
    flip = flip or 1
    -- Compute the xy coordinates of the sprite
    local tx = (spr % texture.columns) * texture.slice
    local ty = math.floor(spr / texture.columns) * texture.slice
    spriteQuad:setViewport(tx, ty, texture.slice, texture.slice, texture.width, texture.height)

    love.graphics.setColor(color[1],color[2],color[3], alpha)
    love.graphics.draw(texture.image, spriteQuad, math.floor(x), math.floor(y), rotation, flip * scaleX, flipY * scaleY, texture.slice / 2, texture.slice / 2)
end

-- convenience wrapper for anything that needs an icon
function Texture.drawSprite(textureIndex, sprite, x, y, spriteQuad, rotation, color, scaleX, scaleY)
    local texture = Texture.textures[textureIndex]
    rotation = rotation or 0
    Texture.draw(texture, sprite, x, y, 1, 1, 1, color or global_pallete.primary_color, rotation, spriteQuad, scaleX or 1, scaleY or 1)
end

-- Draw a tilemap with a single draw call
function Texture.drawTilemap(texture, x_y_sprs, spriteQuad)
    love.graphics.setColor(1,1,1,1)
    local numTiles = #x_y_sprs
    for k = 1,numTiles do
        x = x_y_sprs[k].x
        y = x_y_sprs[k].y
        spr = x_y_sprs[k].spr 
        -- Compute the xy coordinates of the sprite
        local tx = (spr % texture.columns) * texture.slice
        local ty = math.floor(spr / texture.columns) * texture.slice
        spriteQuad:setViewport(tx, ty, texture.slice, texture.slice, texture.width, texture.height)

        love.graphics.draw(texture.image, spriteQuad, math.floor(x), math.floor(y), 0, 1, 1, texture.slice / 2, texture.slice / 2)
    end
end

-- tileData is just the 'data' field of the output of Tiled's map
-- mapWidth is just the 'width' field of the tiled map
function Texture.createSpritebatchRenderer(textureIndex, drawLayer, tileData, mapWidth, ignoreTiles, color)
    -- We need a quad for each tile in the spritesheet
    local nCols = Texture.textures[textureIndex].width / 8
    local nRows = Texture.textures[textureIndex].height / 8
    local numQuadsNeeded =  nCols * nRows
    local tileQuads = {}
    for k = 0,numQuadsNeeded do
        local tx = (k % nCols) * 8
        local ty = math.floor(k / nCols) * 8
        tileQuads[k] = love.graphics.newQuad(tx,ty,8,8,nCols * 8,nRows * 8)
    end

    local spritebatch = love.graphics.newSpriteBatch(Texture.textures[textureIndex].image, numQuadsNeeded)

    local tileXYSPR = {}
    spritebatch:clear()

    -- Iterate over all tiles and add them to the spritebatch
    for i = 1,#tileData do
        if tileData[i] ~= 0 and not ignoreTiles[i] then
            local xCoordinate = ((i - 1) % mapWidth) * 8+4
            local yCoordinate = math.floor((i-1)/mapWidth) * 8+4
            table.insert(tileXYSPR, {x=xCoordinate, y=yCoordinate, spr=tileData[i]-1})
            spritebatch:add(tileQuads[tileData[i]-1],xCoordinate, yCoordinate)
        end
    end
    spritebatch:flush()

    local tilemapRenderer = GameObjects.newGameObject(-1, 0, 0, 0, true, drawLayer)
    tilemapRenderer.color = color or {1,1,1,1}
    tilemapRenderer.spritebatch = spritebatch
    function tilemapRenderer:draw()
        love.graphics.setColor(tilemapRenderer.color)
        love.graphics.draw(tilemapRenderer.spritebatch, math.floor(tilemapRenderer.x)-4, math.floor(tilemapRenderer.y)-4, 0, 1, 1)
    end
    return tilemapRenderer
end


return Texture