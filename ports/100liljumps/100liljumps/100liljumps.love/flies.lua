require("./utils")
require("./math")
require("./animation")
require("./lume")
require("./point_light")
local Object = require("./classic")

Fly = Object.extend(Object)
FlyCluster = Object.extend(Object)

local CLUSTER_RADIUS = 60
Audio.create_sound("sounds/flies.ogg", "flies", "static", 1, 0.1, true)

function FlyCluster.new(self, pos, amount, luminiscent)
    self.pos = V2(pos.x, pos.y)
    self.flies = {}
    local amount = amount or 5
    local luminiscent = luminiscent or false

    for i = 1, amount do
        local r = CLUSTER_RADIUS*math.random()
        local a = 2*math.pi*math.random()
        local x = r*math.cos(a) + self.pos.x
        local y = r*math.sin(a) + self.pos.y

        local fly = Fly(V2(x, y), self, luminiscent)
        table.insert(self.flies, fly)
    end
end

function FlyCluster:draw()
    -- love.graphics.setColor(0.2, 0.2, 0, 0.2)
    -- love.graphics.circle("fill", self.pos.x, self.pos.y, CLUSTER_RADIUS)

    love.graphics.setColor(1, 1, 1)
    for _, fly in pairs(self.flies) do
        fly:draw()
    end
end

function FlyCluster:update()
    for _, fly in pairs(self.flies) do
        fly:update()
    end
end

function FlyCluster:eat_fly(fly, game_state)
    for i, f in pairs(self.flies) do
        if f == fly then
            if fly.luminiscent then
                game_state.player_eaten_light_fly = true
            end
            game_state.tile_map:remove_point_light(fly.light)
            table.remove(self.flies, i)
        end
    end
end

function Fly.new(self, pos, cluster, luminiscent)
    self.cluster = cluster
    self.current_center = V2(pos.x, pos.y)
    self.pos = V2(pos.x, pos.y)
    self.luminiscent = luminiscent or false
    if(luminiscent) then
        self.light = PointLight(
            self.pos,
            "#44ff22",
            0.25,
            0.3 
        )
        self.luminiscent = luminiscent or false
    end
end

function Fly:update()
    local new_x = self.pos.x + lume.round(1.2*(math.random() - 0.5))
    local new_y = self.pos.y + lume.round(1.2*(math.random() - 0.5))
    local distance = v2_length(v2_sub(self.cluster.pos, V2(new_x, new_y)))

    if distance < CLUSTER_RADIUS then
        self.pos.x = new_x
        self.pos.y = new_y
    end
end

function Fly:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.pos.x - 1, self.pos.y, 3, 1)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, 1, 1)
    love.graphics.setColor(1, 1, 1)
end

function Fly:follow_tongue(x, y)
    self.pos.x = x
    self.pos.y = y
end
