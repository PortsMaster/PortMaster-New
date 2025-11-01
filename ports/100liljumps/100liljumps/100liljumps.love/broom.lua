require("./utils")
require("./math")
require("./lume")
local Object = require("./classic")

Broom = Object.extend(Object)

local MOVE_SPEED = 0.3
local GRAVITY = 0.1 
local TERMINAL_VELOCITY = 3
local TERMINAL_VERTICAL_VELOCITY = 2

Audio.create_sound("sounds/snail_explode.ogg", "snail_explode", "static", 4, 0.8)

love.graphics.setDefaultFilter("nearest")
Broom.State = {
    ["CONTROLLED"] = 0,
    ["FREE"]       = 1,
    ["ROTATING"]   = 2,
}

function Broom.new(self, pos, direction)
    self.pos = V2(pos.x, pos.y)
    self.prev_pos = V2(pos.x, pos.y)
    self.vel = V2(0, 0)

    assert(direction == 1 or direction == -1)
    self.direction = direction 

    self.width  = 28
    self.height = 6
    self.state = Broom.State.CONTROLLED
    self.animation = {
        [Broom.State.CONTROLLED] = Animation({
            {filename = "broom.png", duration = 1}
        }, nil, 29, 6),
        [Broom.State.FREE] = Animation({
            {filename = "broom.png", duration = 1}
        }, nil, 29, 6),
        [Broom.State.ROTATING] = Animation({
            {filename = "broom-turning.png", duration = 15}
        }, nil, 29, 6),
    }
    self.adjust_collisions = {}
end

function Broom:update()
    self:animate()
    if(self.state == Broom.State.CONTROLLED) then
        -- Controlled by player
    elseif(self.state == Broom.State.ROTATING) then
        if(self:current_animation().has_looped) then
            self:reset_current_animation()
            self.state = Broom.State.CONTROLLED
            self.direction = -self.direction
        end

    elseif(self.state == Broom.State.FREE) then
        self.prev_pos.x = self.pos.x
        self.prev_pos.y = self.pos.y
        
        self.vel.y = self.vel.y + GRAVITY

        self.vel.x = self.vel.x * 0.99
        self.vel.y = lume.clamp(self.vel.y * 0.90, -TERMINAL_VERTICAL_VELOCITY, TERMINAL_VERTICAL_VELOCITY)

        self.pos.x = self.pos.x + self.vel.x
        self.pos.y = self.pos.y + self.vel.y

        self.pos.x = math.floor(self.pos.x * 100) / 100 
        self.pos.y = math.floor(self.pos.y * 100) / 100 
    end

    self.adjust_collisions = {}
end

function Broom:follow_player(player)
    local player_center_x = player.pos.x + TILE_SIZE/2
    local player_center_y = player.pos.y + TILE_SIZE/2
    self.prev_pos.x = self.pos.x
    self.prev_pos.y = self.pos.y

    self.pos.x = player_center_x - self.width/2
    self.pos.y = player_center_y + 2

    self.direction = player.direction
end

function Broom:draw()
    -- hitbox
    if false then
        draw_hitbox(self)
    end

    local offset = 0
    if self.direction == -1 then offset = self.width end
    self:current_animation():draw(self.pos.x, self.pos.y, self.direction, 1)
end

function Broom:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function Broom:current_animation()
    return self.animation[self.state]
end

function Broom:reset_current_animation()
    self:current_animation():reset()
end

function Broom:rotate()
    self.state = Broom.State.ROTATING
end

function Broom:animate()
    self:current_animation():advance_step()
end

function Broom:reset_state()
    self.state = Broom.State.CONTROLLED
end

function Broom:complete_rotation()
    self:reset_current_animation()
    self:reset_state()
end

function Broom:set_free(vel)
    self.state = Broom.State.FREE
    self.vel.x = vel.x
    self.vel.y = vel.y
end

function Broom:collided_with_tile(x, y, tile)
    -- Calculate which type of movement should do
    local tile_left_x   = x*TILE_SIZE
    local tile_right_x  = (x+1)*TILE_SIZE

    local tile_top_y    = y*TILE_SIZE
    local tile_bottom_y = (y+1)*TILE_SIZE

    local collision = {
        x = x,
        y = y,
        adjust_direction = nil,
    }

    local prev_x = (self.prev_pos.x)
    local prev_y = (self.prev_pos.y)

    function was_on_right(pos_x)
        return pos_x >= tile_right_x
    end

    function was_on_left(pos_x)
        return pos_x + self.width <= tile_left_x
    end

    function was_on_bottom(pos_y)
        return pos_y >= tile_bottom_y
    end

    function was_on_top(pos_y)
        return (pos_y + self.height) <= tile_top_y
    end

    if(was_on_right(prev_x)) then
        collision.adjust_direction = "right"

    elseif(was_on_left(prev_x)) then
        collision.adjust_direction = "left"

    elseif(was_on_bottom(prev_y)) then
        collision.adjust_direction = "down"

    elseif(was_on_top(prev_y)) then
        collision.adjust_direction = "up"

    else
        return
    end

    table.insert(self.adjust_collisions, collision)
end

function Broom:adjust_required_collisions()
    if(#self.adjust_collisions == 1) then
        self:resolve_single_adjustment(self.adjust_collisions[1], self.width, self.height)

    elseif(#self.adjust_collisions == 2) then
        self:resolve_double_adjustment(self.adjust_collisions, self.width, self.height)

    elseif(#self.adjust_collisions > 3) then
        local first_collision = self.adjust_collisions[1]
        local second_collision = self.adjust_collisions[2]

        if(first_collision.x ~= second_collision.x and first_collision.y ~= second_collision.y) then
            self:resolve_double_adjustment({first_collision, second_collision}, self.width, self.height)
        else
            local found = false
            for i = 3, #self.adjust_collisions do
                local c = self.adjust_collisions[i]
                local diferent_from_first = c.x ~= first_collision.x and c.y ~= first_collision.y
                local diferent_from_second = c.x ~= second_collision.x and c.y ~= second_collision.y

                if(diferent_from_first) then
                    self:resolve_double_adjustment({first_collision, c}, self.width, self.height)
                    found = true
                    break
                elseif(diferent_from_second) then
                    self:resolve_double_adjustment({second_collision, c}, self.width, self.height)
                    found = true
                    break
                end
            end

            if(not found) then
                self:resolve_double_adjustment({first_collision, second_collision}, self.width, self.height)
            end
        end
    end
end

function Broom:resolve_single_adjustment(adjustment, width, height)
    snap_to(self, adjustment.adjust_direction, adjustment.x, adjustment.y, width, height, true)
end

function Broom:resolve_double_adjustment(adjustments, width, height)
    local adjustment_a = adjustments[1]
    local adjustment_b = adjustments[2]
    local is_horizontal = adjustment_a.y == adjustment_b.y
    local is_vertical = adjustment_a.x == adjustment_b.x
    local is_both = not (is_horizontal or is_vertical)
    local vertical_adjustment = nil
    local horizontal_adjustment = nil
    local a_direction = adjustment_a.adjust_direction
    local b_direction = adjustment_b.adjust_direction

    if(a_direction == "up" or a_direction == "down") then
        vertical_adjustment = adjustment_a
    elseif(b_direction == "up" or b_direction == "down") then
        vertical_adjustment = adjustment_b
    end

    if(a_direction == "right" or a_direction == "left") then
        horizontal_adjustment = adjustment_a
    elseif(b_direction == "right" or b_direction == "left") then
        horizontal_adjustment = adjustment_b
    end

    if(is_horizontal) then
        snap_to(self, vertical_adjustment.adjust_direction, vertical_adjustment.x, vertical_adjustment.y, width, height, true)

    elseif(is_vertical) then
        snap_to(self, horizontal_adjustment.adjust_direction, horizontal_adjustment.x, horizontal_adjustment.y, width, height, true)

    elseif(is_both) then
        snap_to(self, adjustment_a.adjust_direction, adjustment_a.x, adjustment_a.y, width, height, true)
        snap_to(self, adjustment_b.adjust_direction, adjustment_b.x, adjustment_b.y, width, height, true)
    end
end