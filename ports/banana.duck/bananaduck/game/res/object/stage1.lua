local object = object:extend()

local STAGE = "1"

local path = {
    {"back", 0, 13, "Menu"},
    {"I", 22, 13, "S" .. STAGE .. "_L1"},
    {"II", 22, 32, "S" .. STAGE .. "_L2"},
    {"III", 42, 32, "S" .. STAGE .. "_L3"},
    {"IV", 74, 32, "S" .. STAGE .. "_L4"},
    {"V", 74, 14, "S" .. STAGE .. "_L5"},
    {"VI", 96, 14, "S" .. STAGE .. "_L6"},
    {"VII", 96, 32, "S" .. STAGE .. "_L7"},
    {"VIII", 130, 32, "S" .. STAGE .. "_L8"},
    {"IX", 130, 14, "S" .. STAGE .. "_L9"},
    {"X", 153, 14, "S" .. STAGE .. "_L10"},
    {"XI", 153, 32, "S" .. STAGE .. "_L11"},
    {"XII", 172, 32, "S" .. STAGE .. "_L12"}
}

local lines = {
    {22, 16, 30, 16},
    {33, 21, 33, 31},
    {39, 35, 48, 35},
    {61, 35, 81, 35},
    {85, 30, 85, 20},
    {89, 17, 104, 17},
    {107, 30, 107, 20},
    {115, 35, 134, 35},
    {141, 30, 141, 20},
    {146, 17, 162, 17},
    {164, 30, 164, 20},
    {169, 35, 178, 35},
    {190, 35, 200, 35},
}
local function dashedLine(x1, y1, x2, y2)
    love.graphics.setPointSize(1)
  
    local x, y = x2 - x1, y2 - y1
    local len = math.sqrt(x^2 + y^2)
    local stepx, stepy = x / len, y / len
    x = x1
    y = y1
  
    for i = 1, len / 2 do
      love.graphics.rectangle("fill", math.round(x), math.round(y), 1, 1)
      x = x + stepx * 2
      y = y + stepy * 2
    end
end

function object:create(ldtkEntity)
    gamedata.set("S" .. tostring(STAGE), true, "game.sav")
    
    self.crown = sprite("objects/crown-small.png")
    
    self.size = #path
    game.shadows:add(self)
    game.hideSplash = false
    
    
    self.crowns = {}
    for i = 2, self.size, 1 do
        self.crowns[i] = gamedata.get("crown_" .. path[i][4], "game.sav")
    end

    self.maxSelection = 2
    self.levels = {}
    self.levels[2] = true
    for i = 3, self.size, 1 do
        self.levels[i] = gamedata.get(path[i][4], "game.sav")
        if not self.levels[i] then
            self.levels[i] = false
        end
        self.maxSelection = self.levels[i] and i or self.maxSelection
    end
    self.levels[self.size + 1] = gamedata.get("S" .. tostring(tonumber(STAGE) + 1), "game.sav")

    self.selection = self.levels[self.size + 1] and 1 or self.maxSelection


    if self.selection > 4 then
        camera.x = 64
        if self.selection > 8 then
            camera.x = 128
        end
    else
        camera.x = 0
    end
end

function object:update(dt)
    if input.get("ui_right") then
        self.selection = self.selection + 1
        if self.selection > self.size then
            -- Change stage
            self.selection = self.size
        elseif self.selection > self.maxSelection then
            self.selection = self.maxSelection
        end
        game.playSound("menu-select.wav")
    end

    if input.get("ui_left") then
        self.selection = self.selection - 1
        if self.selection < 1 then
            self.selection = 1
        end
        game.playSound("menu-select.wav")
    end

    if input.get("ui_select") then
        if self.selection == 1 then
            game.selectStage = tonumber(STAGE)
        end
        objects.splash_in(camera.x + 32, camera.y + 32, path[self.selection][4])
        game.playSound("menu-choose.wav")
    end

    if self.selection > 4 then
        camera.x = 64
        if self.selection > 8 then
            camera.x = 128
        end
    else
        camera.x = 0
    end
end

local offset
function object:draw()
    for i = 1, self.size do
        if self.levels[i] == false then
            break
        end

        if i == self.selection then
            color.yellow:set()
            offset = -1
        else
            color.white:set()
            offset = 0
        end
        graphics.printf(path[i][1], path[i][2], path[i][3] + offset, 24, "center")
    end

    color.white:set()
    for index, value in ipairs(lines) do
        if self.levels[index + 1] == false then
            break
        end
        dashedLine(value[1], value[2], value[3], value[4])
    end

    for i = 1, self.size, 1 do
        if self.crowns[i] then
            color.white:set()
            self.crown:draw(path[i][2] + 8, path[i][3] - 5 + (i == self.selection and -1 or 0))
        end
    end
    
    -- dashedLine(20, 15, 36, 15)
    -- graphics.print("I", 38, 12)
end

function object:remove()
    game.shadows:remove(self)
end

return object