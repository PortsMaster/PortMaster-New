local Texture = {}

-- Takes in an array of textureInfo tables
-- these tables have: filename, width, height, slice
-- slice is the width/height in pixels of each sprite in the sheet
function Texture.initialize(textureInfos)
    Texture.textures = {}
    for i,info in ipairs(textureInfos) do
        Texture.textures[i] = {
            image = love.graphics.newImage(textureInfos[i].filename),
            columns = textureInfos[i].width / textureInfos[i].slice,
            width = textureInfos[i].width,
            height = textureInfos[i].height,
            slice = textureInfos[i].slice
        }
    end
end
-- flip is 1 if not flipped, -1 if flipped.
function Texture.draw(texture, spr, x, y, flip, alpha, color, rotation, spriteQuad)
    flip = flip or 1
    -- Compute the xy coordinates of the sprite
    local tx = (spr % texture.columns) * texture.slice
    local ty = math.floor(spr / texture.columns) * texture.slice
    spriteQuad:setViewport(tx, ty, texture.slice, texture.slice, texture.width, texture.height)

    love.graphics.setColor(color[1],color[2],color[3], alpha)
    love.graphics.draw(texture.image, spriteQuad, math.floor(x), math.floor(y), rotation, flip, 1, texture.slice / 2, texture.slice / 2)
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

        love.graphics.draw(texture.image, spriteQuad, math.floor(x), math.floor(y), 0, flip, 1, texture.slice / 2, texture.slice / 2)
    end
end


return Texture