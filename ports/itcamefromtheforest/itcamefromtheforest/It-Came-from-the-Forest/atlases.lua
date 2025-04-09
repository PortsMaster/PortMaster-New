local Atlases = class('Atlases')

function Atlases:initialize()
    self.images = {}
    self.jsondata = {}
end

function Atlases:load(tileset)
    local filenames = {}
    local numerrors = 0
    local path = "files/atlases/"

    -- Clear old images to free memory
    for key, image in pairs(self.images) do
        image:release()  -- Free the texture memory
        self.images[key] = nil  -- Dereference images for garbage collection
    end
    
    -- Reset jsondata
    self.jsondata = {}

    -- Define filenames based on the tileset
    if tileset == "city" then
        filenames = {
            "enemies",
            "common-props",
            "city-environment",
            "city-props",
            "npc",
        }    
    elseif tileset == "forest" then
        filenames = {
            "forest-environment",
            "forest-props",
            "enemies",
            "common-props",
            "npc",
        }    
    elseif tileset == "dungeon" then
        filenames = {
            "dungeon-environment",
            "forest-props",
            "dungeon-props",
            "enemies",
            "common-props",
            "npc",
        }    
    end

    -- Load images and JSON files
    for _, filename in ipairs(filenames) do
        -- Load atlas graphics
        local imagePath = path .. filename .. ".png"
        if love.filesystem.getInfo(imagePath) then
            self.images[filename] = love.graphics.newImage(imagePath, {mipmaps = true})  -- Enable mipmaps
        else
            print("Unable to load: " .. imagePath)
            numerrors = numerrors + 1
        end
        
        -- Load atlas JSONs
        local jsonPath = path .. filename .. ".json"
        local file, err = io.open(jsonPath, "rb")

        if file then
            local jsondata = file:read("*all")
            file:close()
            local data = json.parse(jsondata)

            -- Store JSON layers
            self.jsondata[filename] = { layer = {} }
            for _, layer in ipairs(data.layers) do
                self.jsondata[filename].layer[layer.name] = layer
            end
        else
            print("Unable to load: " .. jsonPath)
            numerrors = numerrors + 1
        end    
    end

    return numerrors == 0
end

return Atlases
