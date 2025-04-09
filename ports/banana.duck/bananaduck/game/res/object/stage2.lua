local object = object:extend()

local STAGE = "2"

local path = {
    {"back", 0, 48, ""},
    {"follow", 28, 48, ""}
}

local lines = {

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
    
    -- TODO dynamically select the last open level
    self.selection = 2



    self.size = #path
    game.shadows:add(self)
    game.hideSplash = false

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
            self.selection = self.size
        end
    end

    if input.get("ui_left") then
        self.selection = self.selection - 1
        if self.selection < 1 then
            self.selection = 1
        end
    end

    if input.get("ui_select") then
        if self.selection == 1 then
            game.selectStage = tonumber(STAGE)
            objects.splash_in(camera.x + 32, camera.y + 32, "Menu")
        elseif self.selection == 2 then
            love.system.openURL("https://twitter.com/HamdyElzanqali")
        end
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
    for index, value in ipairs(path) do
        if index == self.selection then
            color.yellow:set()
            offset = -1
        else
            color.white:set()
            offset = 0
        end
        graphics.printf(value[1], value[2], value[3] + offset, 32, "center")
    end

    color.white:set()
    for index, value in ipairs(lines) do
        dashedLine(value[1], value[2], value[3], value[4])
    end
    
    -- dashedLine(20, 15, 36, 15)
    -- graphics.print("I", 38, 12)
end

function object:remove()
    game.shadows:remove(self)
end

return object