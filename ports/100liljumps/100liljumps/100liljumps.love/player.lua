require("./utils")
require("./math")
require("./tile_map")
require("./lume")
require("./snail")
require("./input")
require("./animation")
require("./audio")
require("./physics")
require("./broom")
local Object = require("./classic")

Player = Object.extend(Object)

love.graphics.setDefaultFilter("nearest")

local BASE_RESOLUTION = {
    width = 320,
    height = 180
}

local witch_width = 11
local witch_height = 12

Audio.create_sound("sounds/cave_step-01.ogg", "cave_step_1", "static", 4, 0.6)
Audio.create_sound("sounds/cave_step-02.ogg", "cave_step_2", "static", 1)
Audio.create_sound("sounds/jump_base.ogg", "jump_base", "static", 6, 0.2)
Audio.create_sound("sounds/jump_cave.ogg", "jump_cave", "static", 6, 1.0)
Audio.create_sound("sounds/jungle_step-01.ogg", "jungle_step_1", "static", 6, 0.4)
Audio.create_sound("sounds/jump_jungle.ogg", "jump_jungle", "static", 6, 0.5)
Audio.create_sound("sounds/trees_step-01.ogg", "trees_step_1", "static", 6, 0.5)
Audio.create_sound("sounds/jump_trees.ogg", "jump_trees", "static", 6, 1.0)
Audio.create_sound("sounds/temple_step-01.ogg", "temple_step_1", "static", 6, 0.5)
Audio.create_sound("sounds/jump_temple.ogg", "jump_temple", "static", 6, 0.5)
Audio.create_sound("sounds/falling_platform_step.ogg", "falling_platform_step", "static", 6, 0.3)
Audio.create_sound("sounds/croak.ogg", "croak", "static", 2, 0.2)
Audio.create_sound("sounds/splash.ogg", "splash", "static", 10, 0.3)
Audio.create_sound("sounds/fly_eat.ogg", "fly_eat", "static", 6, 1)
Audio.create_sound("sounds/fly_catch.ogg", "fly_catch", "static", 6, 1)
Audio.create_sound("sounds/fly_glow.mp3", "fly_glow", "static", 1, 1)

Audio.create_sound("sounds/vine_climb.ogg", "vine_climb", "static", 6, 0.6)
Audio.create_sound("sounds/vine_climb.ogg", "vine_jump", "static", 6, 0.5)

local SOUNDS_MAX_TIME = {
    WALK_SOUNDS = 15,
    CLIMB_SOUNDS = 15,
}
local WALK_SOUNDS = {
    ground = {key = "cave_step_1"},
    jungle = {key = "jungle_step_1"},
    temple = {key = "temple_step_1", min_pitch = 0.5, max_pitch = 1.2},
    trees = {key = "trees_step_1"},
    glitch_tset = {key = "trees_step_1"},
}

local JUMP_SOUNDS = {
    ground = {key = "jump_cave"},
    jungle = {key = "jump_jungle"},
    temple = {key = "jump_temple"},
    trees = {key = "jump_trees"},
    glitch_tset = {key = "jump_trees"},
}

local LANDING_SOUNDS = {
    ground = {key = "cave_step_1"},
    jungle = nil,
    temple = {key = "temple_step_1", min_pitch = 0.5, max_pitch = 1.2},
    trees = {key = "trees_step_1"},
    falling_platform = {key = "falling_platform_step"},
    glitch_tset = {key = "cave_step_1"},
}

local EntityBelowType = {
    FallingPlatform = 0,
    FallingColumn   = 1,
    Computah        = 2,
}

local GRAVITY = 0.30 
local JUMP_FORCE = 3
local MOVE_ACCELERATION = 0.35
local MOVE_VEL_FRICTION = 0.35
local MOVE_ACC_FRICTION = 0.6
local FLY_MOVE_ACCELERATION = 0.15
local FLY_MOVE_VEL_FRICTION = 0.89
local FLY_MOVE_ACC_FRICTION = 0.6
local MAX_H_SPEED = 5.8
local MAX_H_ACC = 2.2
local FLY_MAX_H_SPEED = 2.4
local FLY_MAX_H_ACC = 2.4
local TERMINAL_VELOCITY = 4
local BOUNCER_FORCE = 5
local CLIMB_SPEED = 1
local SWIM_JUMP_VEL = 4.0
local WATER_GRAVITY_FACTOR = 0.2
local WATER_TERMINAL_VELOCITY_FACTOR = 0.8
local MAX_EAT_FLY_RANGE = TILE_SIZE*3
local IDLE_TIMER_LIMIT = 60*5
local IDLE_Z_TIMER = 60
local JUMP_BUFFER_FRAMES = 4
local STOP_JUMP_TIME = 2
Player.COYOTE_TOTAL_FRAMES = 4
Player.BOUNCE_MOMENTUM_FRICTION = 0.9

PlayerState = {
    ["IDLE"]              = 0,
    ["WALKING"]           = 1,
    ["ON_AIR"]            = 2,
    ["JUMPING"]           = 3,
    ["CLIMBING"]          = 4,
    ["FALLING_FROM_VINE"] = 5,
    ["JUMPING_FROM_VINE"] = 6,
    ["SWIMMING"]          = 7,
    ["WALKING_IN_WATER"]  = 8,
    ["CROUCHING"]         = 9,
    ["TURNING"]           = 10,
    ["DEAD"]              = 11,
    ["CROAKING"]          = 12,
    ["EATING"]            = 13,
    ["SLEEP"]             = 14,
    ["SLEEP_START"]       = 15,
    ["LAND"]              = 16,
    ["FLYING"]            = 17,
    ["FLYING_TURNING"]    = 18,
}

Player.TransitionState = {
    NONE     = 0,
    FADE_OUT = 1,
    FADE_IN  = 2,
}
Player.TransitionDuration = 0.6

function Player.new(self, pos)
    self.pos = V2(0, 0)
    self.prev_pos = V2(pos.x, pos.y)
    self.tile_pos = V2(
        math.floor(pos.x / TILE_SIZE),
        math.floor(pos.y / TILE_SIZE)
    )
    self.acc = V2(MOVE_ACCELERATION, 0)
    self.vel = V2(0, 0)

    self.pos_delta = V2(0, 0)

    self.state = PlayerState.ON_AIR
    self.jumping_timer = 0
    self.should_fall = true
    self.has_ground_below = false
    self.colliding_vine = nil
    self.colliding_vines = {}
    self.climbing_vine = nil
    self.collided_in_frame = false
    self.queued_water_collisions = {}
    
    self.jumps_counter = 0 
    self.direction = 1
    self.prev_direction = self.direction 
    self.collisions = {}
    self.adjust_collisions = {}

    self.coyote_frames_counter = 0
    self.bounce_momentum_x = 0
    self.bounce_momentum_y = 0

    self.entity_below = nil
    self.prev_entity_below = nil
    self.prev_tile_below = nil

    self.jump_buffer_frames_counter = 0
    self.triggered_jump_buffer = false
    self.ignore_land = false

    self.stop_jumping_wait_frames = 0

    self.bouncing_off_entity = false
    self.jumping_off_broom = true

    self.fixing_position_in_frame = false

    local jump_animation = Animation({
        {filename = "frog-jump-up-sheet.png", duration = 15},
        {filename = "frog-jump-air-sheet.png", duration = 30},
        {filename = "frog-jump-down-sheet.png", duration = 30},
        {filename = "frog-jump-fall-sheet.png", duration = 15},
    })

    self.animation = {
        [PlayerState.IDLE] = Animation({
            {filename = "idle-frog-sheet.png", duration = 64}
        }),
        [PlayerState.WALKING] = Animation({
            {filename = "frog-sheet.png", duration = 30},
        }),
        [PlayerState.ON_AIR] = jump_animation,
        [PlayerState.JUMPING] = jump_animation,
        [PlayerState.CLIMBING] = Animation({
            {filename = "frog-climbing-sheet.png", duration = 20}
        }),
        [PlayerState.FALLING_FROM_VINE] = Animation({
            {filename = "frog-sheet.png", duration = nil}
        }),
        [PlayerState.JUMPING_FROM_VINE] = Animation({
            {filename = "frog-sheet.png", duration = nil}
        }),
        [PlayerState.SWIMMING] = Animation({
            {filename = "frog-sheet.png", duration = nil}
        }),
        [PlayerState.WALKING_IN_WATER] = Animation({
            {filename = "idle-frog-sheet.png", duration = 64},
        }),
        [PlayerState.CROUCHING] = Animation({
            {filename = "frog-crouching-sheet.png", duration = nil}
        }),
        [PlayerState.TURNING] = Animation({
            {filename = "frog-turning-sheet.png", duration = 15},
        }),
        [PlayerState.DEAD] = Animation({
            {filename = "idle-frog-sheet.png", duration = 64}
        }),
        [PlayerState.CROAKING] = Animation({
            {filename = "frog-croaking-sheet.png", duration = 30}
        }),
        [PlayerState.EATING] = Animation({
            {filename = "idle-frog-sheet.png", duration = 1}
        }),
        [PlayerState.SLEEP] = Animation({
            {filename = "frog-sleeping-sheet.png", duration = 180}
        }),
        [PlayerState.SLEEP_START] = Animation({
            {filename = "frog-start-sleeping-sheet.png", duration = 40}
        }),
        [PlayerState.LAND] = Animation({
            {filename = "land-frog-sheet.png", duration = 8}
        }),
        [PlayerState.FLYING] = Animation({
            {filename = "idle-frog-sheet.png", duration = 64}
        }),
        [PlayerState.FLYING_TURNING] = Animation({
            {filename = "frog-turning-sheet.png", duration = 15},
        }),
    }

    local jump_animation_witch = Animation({
        {filename = "frog-jump-up-sheet-witch.png", duration = 15},
        {filename = "frog-jump-air-sheet-witch.png", duration = 30},
        {filename = "frog-jump-down-sheet-witch.png", duration = 30},
        {filename = "frog-jump-fall-sheet-witch.png", duration = 15},
    }, 1, witch_width, witch_height)

    self.witch_animation = {
        [PlayerState.IDLE] = Animation({
            {filename = "idle-frog-sheet-witch.png", duration = 64}
        }, 1, witch_width, witch_height),
        [PlayerState.WALKING] = Animation({
            {filename = "frog-sheet-witch.png", duration = 30},
        }, 1, witch_width, witch_height),
        [PlayerState.ON_AIR] = jump_animation_witch,
        [PlayerState.JUMPING] = jump_animation_witch,
        [PlayerState.CLIMBING] = Animation({
            {filename = "frog-climbing-witch.png", duration = 20}
        }, 1, witch_height, witch_width),
        [PlayerState.JUMPING_FROM_VINE] = Animation({
            {filename = "frog-sheet-witch.png", duration = nil}
        }, 1, witch_width, witch_height),
        [PlayerState.FALLING_FROM_VINE] = Animation({
            {filename = "frog-sheet-witch.png", duration = nil}
        }, 1, witch_width, witch_height),
        [PlayerState.SWIMMING] = Animation({
            {filename = "frog-sheet-witch.png", duration = nil}
        }, 1, witch_width, witch_height),
        [PlayerState.WALKING_IN_WATER] = Animation({
            {filename = "idle-frog-sheet-witch.png", duration = 64},
        }, 1, witch_width, witch_height),
        [PlayerState.CROUCHING] = Animation({
            {filename = "frog-crouching-sheet-witch.png", duration = nil}
        }, 1, witch_width, witch_height),
        [PlayerState.TURNING] = Animation({
            {filename = "frog-turning-sheet-witch.png", duration = 15},
        }, 1, witch_width, witch_height),
        [PlayerState.DEAD] = Animation({
            {filename = "idle-frog-sheet-witch.png", duration = 64}
        }, 1, witch_width, witch_height),
        [PlayerState.CROAKING] = Animation({
            {filename = "frog-croaking-witch.png", duration = 30}
        }, 1, witch_width, witch_height),
        [PlayerState.EATING] = Animation({
            {filename = "idle-frog-sheet-witch.png", duration = 1}
        }, 1, witch_width, witch_height),
        [PlayerState.SLEEP] = Animation({
            {filename = "frog-sleeping-sheet-witch.png", duration = 180}
        }, 1, witch_width, witch_height),
        [PlayerState.SLEEP_START] = Animation({
            {filename = "frog-start-sleeping-sheet-witch.png", duration = 40}
        }, 1, witch_width, witch_height),
        [PlayerState.LAND] = Animation({
            {filename = "land-frog-sheet-witch.png", duration = 8}
        }, 1, witch_width, witch_height),
        [PlayerState.FLYING] = Animation({
            {filename = "idle-frog-sheet-witch.png", duration = 64}
        }, 1, witch_width, witch_height),
        [PlayerState.FLYING_TURNING] = Animation({
            {filename = "frog-turning-sheet-witch.png", duration = 15},
        }, 1, witch_width, witch_height),
    }

    self.eating_timer = 0
    self.tongue_target = V2(0, 0)
    self.tongue_pos = V2(0, 0)
    self.targeted_fly_to_eat = nil
    self.fly_light = nil

    self.idle_timer = 0
    self.idle_z_timer = 0

    self.sound_timers = {
        WALK_SOUNDS = 0,
        JUMP_SOUNDS = 0,
        CLIMB_SOUNDS = 0,
    }

    self.is_wearing_hat = false

    self.transition_state = Player.TransitionState.NONE
    self.transition_time = 0
    self.fade_target_door_pos = nil

    Audio.create_sound("sounds/bounce_1.ogg", "bounce1", "static", 10, 0.6)
    Audio.create_sound("sounds/swing_2_alt.ogg", "jump1", "static", 1, 0.6)
    Audio.create_sound("sounds/land_1.ogg", "land_1", "static", 1, 0.2)
    Audio.create_sound("sounds/died_1.ogg", "died_1", "static", 8)
    Audio.create_sound("sounds/walk_1.ogg", "walk_1")
end

function Player:jump_and_increment_jump_counter()
    self:reset_current_animation()
    self:jump()
    self.jump_buffer_frames_counter = 0
    self.triggered_jump_buffer      = false
    local should_increment_jumps = (not game_state.jump_counter_broken and game_state.should_count_jumps)
    if(should_increment_jumps) then
        UI.show_jumps_counter()

        self.jumps_counter = self.jumps_counter + 1
        local DEFAULT_MAX_JUMP_COUNT = 100
        local map_allowed_jumps_count = game_state.tile_map.allowed_jumps
        if(map_allowed_jumps_count and self.jumps_counter > map_allowed_jumps_count) then
            game_state:reached_map_max_jump_count()
        elseif(self.jumps_counter > DEFAULT_MAX_JUMP_COUNT) then
            game_state:reached_max_jump_count()
        end
    end
end

function Player:increase_available_jumps()
    Audio.play_sound("ui_change_value")
    self.jumps_counter = math.max(self.jumps_counter - 1, 0)
end

function Player:decrease_available_jumps(amount)
    Audio.play_sound("ui_change_value")
    self.jumps_counter = math.min(self.jumps_counter + amount, 100)
end

function Player:jump()
    self:add_jumping_effects()
    self:set_state(PlayerState.JUMPING)
    self.vel.y = -JUMP_FORCE
    self.triggered_jump_buffer      = false
    self.jump_buffer_frames_counter = 0
end

function Player:fall()
    self:set_state(PlayerState.ON_AIR)
    self.coyote_frames_counter = 0
    self.triggered_jump_buffer      = false
    self.jump_buffer_frames_counter = 0
end

function Player:check_vine()
    local AUTO_CLIMB = false -- TODO: add to options
    local climbing = input.move_up.is_down or input.move_down.is_down

    if(self.colliding_vine and self.state ~= PlayerState.DEAD) then
        if(climbing or AUTO_CLIMB) then
            if not (self.state == PlayerState.CLIMBING) then
                local moving_right     = input.move_right.is_down
                local moving_left      = input.move_left.is_down
                local moving = moving_right or moving_left
                if not moving then
                    self.direction = -1 * self.direction
                end

                self.climbing_vine = self.colliding_vine
                self.climbing_vine:landed_by_player(self)
            end

            if(self.state ~= PlayerState.CLIMBING) then
                Audio.play_sound("vine_jump", 0.4, 0.4)
            end
            self:set_state(PlayerState.CLIMBING)
            self.idle_timer = 0
        end
        if(self.climbing_vine) then
            local direction_dx = {
                [1]  = TILE_SIZE/2,
                [-1] = -TILE_SIZE/2, 
            }

            self.pos_delta.x = direction_dx[self.direction]
            self.pos.x = self.climbing_vine.pos.x + self.pos_delta.x

            self.prev_pos.x = self.pos.x
            self.prev_pos.y = self.pos.y
        end
    end

    self.colliding_vine = nil
end

function Player:update()
    self.collided_in_frame = false
    if self.pos.y > BASE_RESOLUTION.height + 2*TILE_SIZE then
        game_state:player_touched_spikes()
    end
    local moving_right     = bool_to_number(input.move_right.is_down)
    local moving_left      = -bool_to_number(input.move_left.is_down)
    --local release_vine     = love.keyboard.isDown( "c" )
    local release_vine     = love.keyboard.isDown( "z" )
    local jumping          = input.jump.is_down
    local climbing_up      = input.move_up.is_down
    local climbing_down    = input.move_down.is_down
    local dir = (moving_right + moving_left)
    self.fixing_position_in_frame = false

    if(dev_mode and input.increase_jumps.is_pressed) then
        self:increase_available_jumps()
    end
    if(dev_mode and input.decrease_jumps.is_pressed) then
        self:decrease_available_jumps(10)
    end

    -- Debug effects
    if(dev_mode) then
        if input.release.is_pressed then
            game_state:apply_screenshake()
            game_state:apply_exploding_particles()
            game_state:apply_shockwave()
            game_state:apply_chromatic_aberration()
        end
    end

    function check_move()
        self.prev_pos = V2(self.pos.x, self.pos.y)
        self.acc.x = self.acc.x*MOVE_ACC_FRICTION
        self.acc.x = lume.clamp(self.acc.x + MOVE_ACCELERATION*dir, -MAX_H_ACC, MAX_H_ACC)

        if(math.abs(self.bounce_momentum_x) > 0 or math.abs(self.bounce_momentum_y) > 0) then
            self.bounce_momentum_x = self.bounce_momentum_x*Player.BOUNCE_MOMENTUM_FRICTION
            self.bounce_momentum_y = self.bounce_momentum_y*Player.BOUNCE_MOMENTUM_FRICTION
            if(math.abs(self.bounce_momentum_x) < 1) then self.bounce_momentum_x = 0 end
            if(math.abs(self.bounce_momentum_y) < 1) then self.bounce_momentum_y = 0 end
        end

        self.vel.x = self.vel.x + self.bounce_momentum_x
        self.vel.y = self.vel.y + self.bounce_momentum_y

        self.vel.x = self.vel.x*MOVE_VEL_FRICTION

        self.vel.x = lume.clamp(self.vel.x + self.acc.x, -MAX_H_SPEED, MAX_H_SPEED)
        if(math.abs(self.vel.x) < 0.3) then
            self.vel.x = 0
        end
        self.pos.x = math.floor((self.pos.x + self.vel.x) * 100) / 100 

        if(self.pos.x == self.prev_pos.x) then
            self.pos.x = math.floor(self.pos.x)
            self.prev_pos.x = math.floor(self.pos.x)
        end
    end

    function check_flying_move()
        self.prev_pos = V2(self.pos.x, self.pos.y)
        self.acc.x = self.acc.x*FLY_MOVE_ACC_FRICTION
        self.acc.x = lume.clamp(self.acc.x + FLY_MOVE_ACCELERATION*dir, -FLY_MAX_H_ACC, FLY_MAX_H_ACC)

        local moving_up   = -bool_to_number(input.move_up.is_down)
        local moving_down = bool_to_number(input.move_down.is_down)
        local v_dir = (moving_up + moving_down)
        self.acc.y = self.acc.y*FLY_MOVE_ACC_FRICTION
        self.acc.y = lume.clamp(self.acc.y + FLY_MOVE_ACCELERATION*v_dir, -FLY_MAX_H_ACC, FLY_MAX_H_ACC)

        if(math.abs(self.bounce_momentum_x) > 0 or math.abs(self.bounce_momentum_y) > 0) then
            self.bounce_momentum_x = self.bounce_momentum_x*Player.BOUNCE_MOMENTUM_FRICTION
            self.bounce_momentum_y = self.bounce_momentum_y*Player.BOUNCE_MOMENTUM_FRICTION
            if(math.abs(self.bounce_momentum_x) < 1) then self.bounce_momentum_x = 0 end
            if(math.abs(self.bounce_momentum_y) < 1) then self.bounce_momentum_y = 0 end
        end

        self.vel.x = self.vel.x + self.bounce_momentum_x
        self.vel.y = self.vel.y + self.bounce_momentum_y

        self.vel.x = self.vel.x*FLY_MOVE_VEL_FRICTION
        self.vel.y = self.vel.y*FLY_MOVE_VEL_FRICTION

        self.vel.x = lume.clamp(self.vel.x + self.acc.x, -FLY_MAX_H_SPEED, FLY_MAX_H_SPEED)
        self.vel.y = lume.clamp(self.vel.y + self.acc.y, -FLY_MAX_H_SPEED, FLY_MAX_H_SPEED)
        if(math.abs(self.vel.x) < 0.3) then
            self.vel.x = 0
        end

        self.pos.x = math.floor((self.pos.x + self.vel.x) * 100) / 100 
        self.pos.y = math.floor((self.pos.y + self.vel.y) * 100) / 100 

        if(self.pos.x == self.prev_pos.x) then
            self.pos.x = math.floor(self.pos.x)
            self.prev_pos.x = math.floor(self.pos.x)
        end
        if(self.pos.y == self.prev_pos.y) then
            self.pos.y = math.floor(self.pos.y)
            self.prev_pos.y = math.floor(self.pos.y)
        end
    end

    function check_air(g)
        self.vel.y = lume.clamp(self.vel.y + g, -(TERMINAL_VELOCITY*1.5), TERMINAL_VELOCITY)
        self.pos.y = self.pos.y + self.vel.y
    end

    function check_direction()
        if dir and dir ~= 0 then 
            self.prev_direction = self.direction
            self.direction = dir
        end
    end

    function check_fly()
        local flies_with_length = {}
        for _, fc in pairs(game_state.tile_map.fly_clusters) do
            for _, fly in pairs(fc.flies) do
                local length = v2_length(v2_sub(fly.pos, self.pos))
                if length < MAX_EAT_FLY_RANGE then
                    table.insert(flies_with_length, { fly = fly, length = length } )
                end
            end
        end

        local min_length = nil 
        local closer_fly = nil 
        for _, f in pairs(flies_with_length) do
            if( ( not min_length ) or ( f.length < min_length ) ) then
                min_length = min_length
                closer_fly = f.fly
            end
        end

        return closer_fly
    end

    self:animate()

    if(self.broom) then
        self.broom:update()
    end

    if(self.state == PlayerState.ON_AIR) then
        if(self.triggered_jump_buffer) then
            self.jump_buffer_frames_counter = self.jump_buffer_frames_counter + 1
        else
            self.jump_buffer_frames_counter = 0
        end

        if dir and dir ~= 0 then 
            self.prev_direction = self.direction
            self.direction = dir
        end
        check_move()
        check_air(GRAVITY)

        self:check_vine()


        -- TODO: check only when fall and not when jump
        -- or not, is kind of funny for speedrun
        -- if you jump really fast after a coyote, and are inside the 4 frames window
        -- then you can perform a double jump
        if(input.jump.is_pressed) then
            if(self.coyote_frames_counter < Player.COYOTE_TOTAL_FRAMES) then
                self:jump_and_increment_jump_counter()

                -- TODO: move to reset jump buffer function
                self.triggered_jump_buffer      = false
            end
        end
        if(input.jump.is_pressed) then
            self.triggered_jump_buffer = true
        end

        self.coyote_frames_counter = math.min(self.coyote_frames_counter + 1, Player.COYOTE_TOTAL_FRAMES)

    elseif(self.state == PlayerState.IDLE) then
        self.idle_timer = self.idle_timer + 1
        self:kill_momentum()
        if dir and dir ~= 0 then 
            if(dir ~= self.direction) then
                self:reset_current_animation()
                self:set_state(PlayerState.TURNING)
            else
                self.prev_direction = self.direction
                self.direction = dir
            end
        end
        check_move()
        if(
            input.move_left.is_pressed
            or input.move_right.is_pressed
            or input.move_left.is_down
            or input.move_right.is_down
        ) then
            self.idle_timer = 0
            self:reset_current_animation()
            self:set_state(PlayerState.WALKING)
            self:reset_walk_state()
        end
        if(input.move_down.is_down) then
            self.idle_timer = 0
            self:reset_current_animation()
            self:set_state(PlayerState.CROUCHING)
        end
        -- TODO: somehow queue jumps before touching ground
        --       or maybe dont use is_pressed but rather
        --       count how many frames the jump should be disabled
        if(input.jump.is_pressed) then
            self.idle_timer = 0
            self:jump_and_increment_jump_counter()

        elseif(not self.has_ground_below) then
            self.idle_timer = 0
            self:fall()
        end

        if(input.croak.is_pressed) then
            self.idle_timer = 0
            local closer_fly = check_fly()
            if closer_fly then
                -- start transition, etc
                self.eating_timer = 0
                self.targeted_fly_to_eat = closer_fly
                Audio.play_sound("fly_catch", 0.8, 1.0)
                self:set_state(PlayerState.EATING)
            else
                if(self.state == PlayerState.IDLE) then
                    Audio.play_sound("croak", 0.8, 1.0, 0.5)
                    self:reset_current_animation()
                    self:set_state(PlayerState.CROAKING)
                end
            end
        end

        self:check_vine()
        if((self.idle_timer >= IDLE_TIMER_LIMIT) and (self:current_state_animation().has_looped) ) then
            self:reset_current_animation()
            self.idle_timer = 0
            self:set_state(PlayerState.SLEEP_START)
        end


    elseif(self.state == PlayerState.WALKING) then
        if dir and dir ~= 0 then 
            if(dir ~= self.direction) then
                self:reset_current_animation()
                self:set_state(PlayerState.TURNING)
            else
                self.prev_direction = self.direction
                self.direction = dir
            end
        end
        check_move()
        local tile_below = self:tile_below_tileset_name()

        if(self.sound_timers.WALK_SOUNDS == 0) then
            if tile_below then
                local key = WALK_SOUNDS[tile_below].key
                local min_pitch = WALK_SOUNDS[tile_below].min_pitch or 0.8
                local max_pitch = WALK_SOUNDS[tile_below].max_pitch or 1.4
                Audio.play_sound(key, min_pitch, max_pitch)
                self:set_entity_below(nil)
            end

            local entity_below_to_play_sound = self.entity_below or self.prev_entity_below
            if(entity_below_to_play_sound) then
                if(entity_below_to_play_sound == EntityBelowType.FallingPlatform) then
                    Audio.play_sound("falling_platform_step", 0.5, 1.0)
                end
            end
            self.sound_timers.WALK_SOUNDS = self.sound_timers.WALK_SOUNDS + 1
        else
            self.sound_timers.WALK_SOUNDS = self.sound_timers.WALK_SOUNDS + 1
            if(self.sound_timers.WALK_SOUNDS > SOUNDS_MAX_TIME.WALK_SOUNDS) then
                self.sound_timers.WALK_SOUNDS = 0
            end
        end

        if(not input.move_left.is_down and not input.move_right.is_down) then
            self:reset_current_animation()
            self:set_state(PlayerState.IDLE)
        end
        if(input.move_down.is_down) then
            self:reset_current_animation()
            self:set_state(PlayerState.CROUCHING)
        end
        if(input.jump.is_pressed) then
            self:jump_and_increment_jump_counter()

        elseif(not self.has_ground_below) then
            self:fall()
        end

        self:check_vine()

    elseif(self.state == PlayerState.JUMPING) then
        if(self.triggered_jump_buffer) then
            self.jump_buffer_frames_counter = self.jump_buffer_frames_counter + 1
        else
            self.jump_buffer_frames_counter = 0
        end
        tmp_frames = tmp_frames or 0
        if(not jumping) then
            self.stop_jumping_wait_frames = self.stop_jumping_wait_frames + 1

            if(self.stop_jumping_wait_frames >= STOP_JUMP_TIME) then
                self:set_state(PlayerState.ON_AIR)
                self.triggered_jump_buffer      = false
                self.jump_buffer_frames_counter = 0
                self.stop_jumping_wait_frames = 0
            end
        else
            self.stop_jumping_wait_frames = 0
        end
        check_direction()
        check_move()
        if(self.bouncing_off_entity) then
            check_air(GRAVITY*0.8)
        else
            check_air(GRAVITY*0.5)
        end

        self:check_vine()

    elseif(self.state == PlayerState.CLIMBING) then
        check_direction()
        self.prev_pos = V2(self.pos.x, self.pos.y)

        local should_fall = true
        for _, vine in pairs(self.colliding_vines) do
            if(vine == self.climbing_vine) then
                should_fall = false
            end
        end
        if(should_fall) then
            self:set_state(PlayerState.FALLING_FROM_VINE)
            self.pos_delta = V2(0, 0)

            local moving_right     = input.move_right.is_down
            local moving_left      = input.move_left.is_down
            local moving = moving_right or moving_left
            if not moving then
                self.direction = -1 * self.direction
            end
        end
        if((climbing_up and (not climbing_down)) or ((not climbing_up) and climbing_down)) then
            if self.colliding_vine then
                self.colliding_vine:climbed_by_player(self)
            end
        end
        self:check_vine()
        self:kill_momentum()
        if(climbing_up) then
            self.pos.y = self.pos.y - CLIMB_SPEED
        end
        if(climbing_down) then
            self.pos.y = self.pos.y + CLIMB_SPEED
        end

        if(climbing_up or climbing_down) then
            if(self.sound_timers.CLIMB_SOUNDS == 0) then
                Audio.play_sound("vine_climb", 0.5, 1.3)
            end

            self.sound_timers.CLIMB_SOUNDS = self.sound_timers.CLIMB_SOUNDS + 1
            if(self.sound_timers.CLIMB_SOUNDS > SOUNDS_MAX_TIME.CLIMB_SOUNDS) then
                self.sound_timers.CLIMB_SOUNDS = 0
            end
        else
            self.sound_timers.CLIMB_SOUNDS = 0
        end
        if(not climbing_down and not climbing_up) then
            self:reset_current_animation()
        end
        if(release_vine) then
            self:set_state(PlayerState.ON_AIR)
            self.pos_delta = V2(0, 0)
            self.triggered_jump_buffer      = false
            self.jump_buffer_frames_counter = 0
        end
        if(input.jump.is_pressed) then
            self:jump()
            self.vel.y = -JUMP_FORCE
            self:set_state(PlayerState.JUMPING_FROM_VINE)
            Audio.play_sound("jump_base", 0.8, 1.0)
            Audio.play_sound("vine_jump", 0.8, 1.0)
            self.pos_delta = V2(0, 0)
        end

    elseif(self.state == PlayerState.JUMPING_FROM_VINE) then
        check_direction()
        -- count frames?
        check_move()
        self.vel.y = math.min(self.vel.y + GRAVITY, TERMINAL_VELOCITY)
        self.pos.y = self.pos.y + self.vel.y

        local left_colliding_vine = false
        if self.colliding_vine then
            local delta = math.abs(self.pos.x - self.colliding_vine.pos.x)
            if delta > TILE_SIZE then
                left_colliding_vine = true
            end
        end

        if not self.colliding_vine or left_colliding_vine then
            self:set_state(PlayerState.JUMPING)
        end
        self:remove_colliding_vine()

    elseif(self.state == PlayerState.FALLING_FROM_VINE) then
        check_direction()
        self:set_state(PlayerState.ON_AIR)
        self.triggered_jump_buffer      = false
        self.jump_buffer_frames_counter = 0

    elseif(self.state == PlayerState.SWIMMING) then
        check_direction()
        if(input.jump.is_pressed) then
            self.vel.y = self.vel.y - SWIM_JUMP_VEL

        elseif(input.jump.is_down) then
            self.vel.y = math.max(self.vel.y - 0.2*SWIM_JUMP_VEL, -0.4*SWIM_JUMP_VEL)

        elseif(input.move_down.is_down) then
            self.vel.y = math.min(self.vel.y + 0.2*SWIM_JUMP_VEL, 0.4*SWIM_JUMP_VEL)
        end
        self.prev_pos = V2(self.pos.x, self.pos.y)
        self.vel.x = self.vel.x*MOVE_VEL_FRICTION
        self.vel.x = lume.clamp(self.vel.x + 1.1*MOVE_ACCELERATION*dir, -MAX_H_SPEED, MAX_H_SPEED)
        self.pos.x = self.pos.x + self.vel.x

        self.vel.y = self.vel.y*0.9
        self.vel.y = lume.clamp(self.vel.y + WATER_GRAVITY_FACTOR*GRAVITY, -WATER_TERMINAL_VELOCITY_FACTOR*TERMINAL_VELOCITY, WATER_TERMINAL_VELOCITY_FACTOR*TERMINAL_VELOCITY)
        self.pos.y = self.pos.y + self.vel.y

        local still_in_water = false
        for _, collision in pairs(self.collisions) do
            if(collision.tile.type == TileType.WATER) then
                still_in_water = true
            end
        end
        if not still_in_water then
            self:set_state(PlayerState.JUMPING)
            self:splash()
        end

        if(game_state.tile_map.top_water_y) then
            if(not Audio.should_apply_underwater and self.pos.y > (game_state.tile_map.top_water_y)) then
                Audio.set_underwater_filter()
            elseif(Audio.should_apply_underwater and (self.pos.y < (game_state.tile_map.top_water_y - 4) ) ) then
                Audio.remove_underwater_filter()
            end
        else
            Audio.remove_underwater_filter()
        end

    elseif(self.state == PlayerState.WALKING_IN_WATER) then
        check_direction()
        self.prev_pos = V2(self.pos.x, self.pos.y)
        self.vel.x = self.vel.x*MOVE_VEL_FRICTION
        self.vel.x = lume.clamp(self.vel.x + 0.9*MOVE_ACCELERATION*dir, -MAX_H_SPEED, MAX_H_SPEED)
        self.pos.x = self.pos.x + self.vel.x

        self.vel.y = 0
        if(input.jump.is_pressed) then
            self.vel.y = -SWIM_JUMP_VEL
            self:set_state(PlayerState.SWIMMING)
            self:jump_and_increment_jump_counter()
            self.vel.y = self.vel.y*0.9
            self.vel.y = lume.clamp(self.vel.y + WATER_GRAVITY_FACTOR*GRAVITY, -WATER_TERMINAL_VELOCITY_FACTOR*TERMINAL_VELOCITY, WATER_TERMINAL_VELOCITY_FACTOR*TERMINAL_VELOCITY)
        end

        if(self.should_fall) then
            self:set_state(PlayerState.SWIMMING)
        end

        for _, collision in pairs(self.collisions) do
            if(collision.tile.type == TileType.WATER) then
                still_in_water = true
            end
        end
    elseif(self.state == PlayerState.CROUCHING) then
        self:kill_momentum()
        check_direction()
        if(input.move_down.is_up) then
            self:set_state(PlayerState.IDLE)
        end
        if(input.jump.is_pressed) then
            self:jump_and_increment_jump_counter()

        elseif(not self.has_ground_below) then
            self:fall()
        end
    elseif(self.state == PlayerState.TURNING) then
        check_move()
        if(self:current_state_animation().has_looped) then
            self:reset_current_animation()
            self:set_state(PlayerState.WALKING)
            self:reset_walk_state()
            self.direction = -self.direction
        end

        if(input.jump.is_pressed) then
            self:jump_and_increment_jump_counter()

        elseif(not self.has_ground_below) then
            self:fall()
        end

        self:check_vine()
    elseif(self.state == PlayerState.EATING) then
        local EATING_TIMER_TIME = 30
        self.eating_timer = self.eating_timer + 1 

        if(self.direction == 1) then
            self.tongue_pos = V2(self.pos.x + TILE_SIZE - 1, self.pos.y + TILE_SIZE/2 - 1)
        else
            self.tongue_pos = V2(self.pos.x + 1, self.pos.y + TILE_SIZE/2 - 1)
        end

        if self.eating_timer < (EATING_TIMER_TIME / 2) then
            self.tongue_target.x = lume.lerp(self.tongue_pos.x, self.targeted_fly_to_eat.pos.x, self.eating_timer / (0.5*EATING_TIMER_TIME) )
            self.tongue_target.y = lume.lerp(self.tongue_pos.y, self.targeted_fly_to_eat.pos.y, self.eating_timer / (0.5*EATING_TIMER_TIME) )
        else
            self.tongue_target.x = lume.lerp(self.targeted_fly_to_eat.pos.x, self.tongue_pos.x, (self.eating_timer - EATING_TIMER_TIME*0.5) / (EATING_TIMER_TIME - EATING_TIMER_TIME*0.5) )
            self.tongue_target.y = lume.lerp(self.targeted_fly_to_eat.pos.y, self.tongue_pos.y, (self.eating_timer - EATING_TIMER_TIME*0.5) / (EATING_TIMER_TIME - EATING_TIMER_TIME*0.5) )
            self.targeted_fly_to_eat:follow_tongue(self.tongue_target.x, self.tongue_target.y)
        end

        if self.eating_timer >= (3*EATING_TIMER_TIME/4) then
            Audio.play_sound("fly_eat", 1, 1, 2)

            if self.targeted_fly_to_eat.luminiscent and not game_state.player_eaten_light_fly then
                Audio.play_sound("fly_glow")
                self:create_fly_light()
            end

            self.targeted_fly_to_eat.cluster:eat_fly(self.targeted_fly_to_eat, game_state)
            self.eating_timer = 0
            self.tongue_target.x = 0
            self.tongue_target.y = 0
            self.targeted_fly_to_eat = nil
            self:set_state(PlayerState.IDLE)
            self:reset_current_animation()
        end

    elseif(self.state == PlayerState.SLEEP_START) then
        if self:current_state_animation().has_looped then
            self:reset_current_animation()
            self:set_state(PlayerState.SLEEP)
        end
        if(
            input.move_left.is_pressed
            or input.move_right.is_pressed
            or input.move_left.is_down
            or input.move_right.is_down
        ) then
            self.idle_timer = 0
            self:reset_current_animation()
            self:set_state(PlayerState.WALKING)
            self:reset_walk_state()
        end

        if(input.move_down.is_down) then
            self.idle_timer = 0
            self:reset_current_animation()
            self:set_state(PlayerState.CROUCHING)
        end
        if(input.jump.is_pressed) then
            self.idle_timer = 0
            self:jump_and_increment_jump_counter()

        elseif(not self.has_ground_below) then
            self.idle_timer = 0
            self:reset_current_animation()
            self:fall()
        end
    elseif(self.state == PlayerState.SLEEP) then
        self.idle_z_timer = self.idle_z_timer + 1
        local left_x_delta = 0
        local right_x_delta = TILE_SIZE - 3
        local spawn_x = 0

        if self.direction == 1 then
            spawn_x = self.pos.x + right_x_delta
        else
            spawn_x = self.pos.x + left_x_delta
        end

        if (self.idle_z_timer >= IDLE_Z_TIMER) then
            game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
                particle_emitter = ParticleEmitter( {
                    pos = V2(spawn_x, self.pos.y + TILE_SIZE/2),
                    particle_type = ParticleType.exploding,
                    particle_variant = ParticleVariant.sleep,
                    gravity = 0.01,
                    data = {
                        dir = self.direction 
                    },
                } ),
            })
            self.idle_z_timer = 0
        end

        local c = (input.move_right.is_down
            or input.move_left.is_down
            or input.move_up.is_down
            or input.move_down.is_down
            or input.jump.is_down
            or input.croak.is_down
        )

        if c then
            self:reset_current_animation()
            self:set_state(PlayerState.IDLE)
        end

    elseif(self.state == PlayerState.LAND) then
        self:kill_momentum()

        check_move()
        if(
            input.move_left.is_pressed
            or input.move_right.is_pressed
            or input.move_left.is_down
            or input.move_right.is_down
        ) then
            if(self:current_state_animation().stage == 1) then
                self:reset_current_animation()
                self:set_state(PlayerState.WALKING)
                self:reset_walk_state()
            end
        end
        if(input.move_down.is_down) then
            self:reset_current_animation()
            self:set_state(PlayerState.CROUCHING)
        end
        if(input.jump.is_pressed) then
            self.idle_timer = 0
            self:jump_and_increment_jump_counter()
        end

        if(self:current_state_animation().has_looped) then
            self:reset_current_animation()
            self:set_state(PlayerState.IDLE)
        end

    elseif(self.state == PlayerState.FLYING) then
        check_flying_move()
        self.broom:follow_player(self)

        if dir and dir ~= 0 then 
            if(dir ~= self.direction) then
                self:reset_current_animation()
                self:set_state(PlayerState.FLYING_TURNING)
                self.broom:rotate()
            else
                self.prev_direction = self.direction
                self.direction = dir
            end
        end

        -- Fun mechanic that I removed because is was buggy
        -- and I didn't find cool design ideas that mix well
        -- with the jump limits
        --
        -- The only idea that I had was that you needed to
        -- left the broom to pass throught a tiny space that you
        -- couldn't pass on the broom
        -- and break some falling platforms, fall down, get on the broom
        -- and fly to the top before the falling platforms began solid again 

        -- if(input.jump.is_pressed) then
        --     self:jump_off_broom()
        -- end

    elseif(self.state == PlayerState.FLYING_TURNING) then
        if(self:current_state_animation().has_looped) then
            self:reset_current_animation()
            self:set_state(PlayerState.FLYING)
            self:reset_walk_state()
            self.direction = -self.direction
        end

        check_flying_move()
        self.broom:follow_player(self)

    elseif(self.state == PlayerState.CROAKING) then
        if(self:current_state_animation().has_looped) then
            self:set_state(PlayerState.IDLE)
        end
    end

    self:handle_queued_water_collisions()

    if self.fly_light then
        self.fly_light.pos = self:light_position()
        self.fly_light.radius = Player.FLY_LIGHT_RADIUS * easeOut(game_state.eaten_light_fly_time)
        self.fly_light.intensity = Player.FLY_LIGHT_INTENSITY * easeOut(game_state.eaten_light_fly_time)
    end

    -- TODO notify of all colitions or use events
    self.should_fall = true
    self.collisions = {}
    self.adjust_collisions = {}
end

function Player:kill_momentum()
    self.vel.x = 0
    self.vel.y = 0
    self.acc.x = 0
    self.acc.y = 0
end

function Player:draw()
    -- hitbox
    if false then
        local top_x = self:hitbox().top_left.x
        local top_y = self:hitbox().top_left.y
        local bottom_x = self:hitbox().bottom_right.x
        local bottom_y = self:hitbox().bottom_right.y
        local width = math.abs(bottom_x - top_x)
        local height = math.abs(bottom_y - top_y)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 0.5, 1.0)
        love.graphics.rectangle("fill", top_x, top_y, width, height)
        love.graphics.setColor(1, 1, 0.5, 0.2)
        love.graphics.rectangle("fill", self.prev_pos.x, self.prev_pos.y, TILE_SIZE, TILE_SIZE)
    end

    -- fly range
    if false then
        love.graphics.setColor(1, 1, 0.5, 0.2)
        love.graphics.circle("fill", self.pos.x + TILE_SIZE/2, self.pos.y + TILE_SIZE/2, MAX_EAT_FLY_RANGE)
    end

    local scale = 1
    local alpha = 1

    local transition_offset = V2(0, 0)

    if self.transition_state == Player.TransitionState.NONE then
        -- Use 1 as scale and alpha

    elseif self.transition_state == Player.TransitionState.FADE_IN then
        self.transition_time = self.transition_time + game_state.delta_time
        local t = lume.lerp(0, 1, self.transition_time / Player.TransitionDuration)
        scale = t
        alpha = t
        if self.fade_target_door_pos then
            local x_delta = self.fade_target_door_pos.x - self.pos.x
            local y_delta = self.fade_target_door_pos.y - self.pos.y
            local x_offset = x_delta * (1 - t)
            local y_offset = y_delta * (1 - t)
            transition_offset = V2(x_offset, y_offset)
        end

        if self.transition_time >= Player.TransitionDuration then
            scale = 1
        end

    elseif self.transition_state == Player.TransitionState.FADE_OUT then
        self.transition_time = self.transition_time + game_state.delta_time
        local t = 1 - lume.lerp(0, 1, self.transition_time / Player.TransitionDuration)
        scale = t
        alpha = t

        local x_delta = self.fade_target_door_pos.x - self.pos.x
        local y_delta = self.fade_target_door_pos.y - self.pos.y
        local x_offset = x_delta * (1 - t)
        local y_offset = y_delta * (1 - t)
        transition_offset = V2(x_offset, y_offset)

        if self.transition_time >= Player.TransitionDuration then
            scale = 0
        end
    end

    love.graphics.setColor(1, 1, 1)
    if(self.state ~= PlayerState.DEAD) then
        local animation = self.animation[self.state]
        local witch_animation = self.witch_animation[self.state]

        local light_color_str = "#00ff00"
        if(self.is_wearing_hat and witch_animation) then
            -- Hat wearing animation starts with a margin
            -- because the hat extrudes 2 pixels to the left
            -- and 1 pixel to the right
            local walking_right_margin = -2 
            local walking_left_margin  = -1

            if(self.direction == -1) then
                x_offset = walking_left_margin
            else
                x_offset = walking_right_margin
            end

            local y_offset = 0
            local climbing_facing_left_offset  = -4 
            local climbing_facing_right_offset = 1
            if self.state == PlayerState.CLIMBING then
                y_offset = 3

                if self.direction == -1 then
                    x_offset = climbing_facing_left_offset
                else
                    x_offset = climbing_facing_right_offset
                end
            end

            witch_animation:draw(
                lume.round(self.pos.x) + x_offset + transition_offset.x,
                lume.round(self.pos.y) - 4 + y_offset + transition_offset.y,
                self.direction, 1, alpha, scale
            )
            if game_state.player_eaten_light_fly then
                love.graphics.setBlendMode("add")
                witch_animation:draw(
                    lume.round(self.pos.x) + x_offset + transition_offset.x,
                    lume.round(self.pos.y) - 4 + y_offset + transition_offset.y,
                    self.direction, 1, 0.5 * easeOut(game_state.eaten_light_fly_time), scale, light_color_str
                )
                love.graphics.setBlendMode("alpha")
            end
        else
            animation:draw(
                lume.round(self.pos.x) + transition_offset.x,
                lume.round(self.pos.y) + transition_offset.y,
                self.direction, 1, alpha, scale
            )
            if game_state.player_eaten_light_fly then
                love.graphics.setBlendMode("add")
                animation:draw(
                    lume.round(self.pos.x) + transition_offset.x,
                    lume.round(self.pos.y) + transition_offset.y,
                    self.direction, 1, 0.5 * easeOut(game_state.eaten_light_fly_time), scale, light_color_str
                )
                love.graphics.setBlendMode("alpha")
            end
        end
    end
    --self.animation[self.state]:draw((self.pos.x), (self.pos.y), self.direction)

    if( (self.state == PlayerState.EATING) and (self.tongue_target.x > 0) ) then
        love.graphics.setColor(lume.color("#ba1111"))
        love.graphics.setDefaultFilter("nearest")
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("rough")
        love.graphics.line(self.tongue_pos.x, self.tongue_pos.y, self.tongue_target.x, self.tongue_target.y)
        love.graphics.rectangle("fill", self.tongue_pos.x - 1, self.tongue_pos.y, 2, 1)
        love.graphics.setColor(1, 1, 1)
    end

    if(self.broom) then
        self.broom:draw(self.direction)
    end

end

function Player:queue_water_collision(x, y)
    local tile_pos = V2(x, y)
    table.insert(self.queued_water_collisions, tile_pos)
end

function Player:collided_with_tile(x, y, tile)
    -- in tile space
    local collision = {
        x = x,
        y = y,
        tile = tile,
    }
    table.insert(self.collisions, collision)
    if(tile.type == TileType.AIR) then
    elseif Tile.is_solid_tile(tile) then
        self.collided_in_frame = true
        if(self.prev_pos.x >= x*TILE_SIZE + TILE_SIZE) then
            self.vel.x = 0
            self.acc.x = 0
            self.bounce_momentum_x = 0
            self.pos.x = (x+1)*TILE_SIZE
            self.fixing_position_in_frame = true
        elseif(self.prev_pos.x + TILE_SIZE <= x*TILE_SIZE ) then
            self.vel.x = 0
            self.acc.x = 0
            self.bounce_momentum_x = 0
            self.pos.x = x*TILE_SIZE - TILE_SIZE
            self.fixing_position_in_frame = true
        elseif(self.prev_pos.y >= y*TILE_SIZE + TILE_SIZE) then
            self.vel.y = 0
            self.pos.y = (y+1)*TILE_SIZE
            self.fixing_position_in_frame = true
        elseif((self.prev_pos.y + TILE_SIZE) <= y*TILE_SIZE) then
            if(self.state == PlayerState.WALKING_IN_WATER) then
            elseif(self.state == PlayerState.SWIMMING) then
                self:set_state(PlayerState.WALKING_IN_WATER)
                self.vel.y = 0
            elseif(self.state == PlayerState.CLIMBING) then
            else
                -- TODO: move to state machine
                self:reset_current_animation()
                self.pos.y = (y-1)*TILE_SIZE
                local tile_below = self:tile_below_tileset_name()
                self:add_landing_effects(tile_below)
                if(self.triggered_jump_buffer and (self.jump_buffer_frames_counter < JUMP_BUFFER_FRAMES)) then
                    self.ignore_land = true
                    self:jump_and_increment_jump_counter()
                else
                    if(not self.ignore_land) then
                        self:set_state(PlayerState.LAND)
                        self.vel.y = 0
                    else
                        self.ignore_land = false
                    end
                end
            end
            self.pos.y = (y-1)*TILE_SIZE
            self.fixing_position_in_frame = true
        end
    elseif(tile.type == TileType.WATER) then
        self:queue_water_collision(x, y)
    end
end

function Player:prev_position_hitbox()
    return Rectangle(
        V2(self.prev_pos.x, self.prev_pos.y),
        V2(self.prev_pos.x + TILE_SIZE, self.prev_pos.y + TILE_SIZE)
    )
end

function Player:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + TILE_SIZE, self.pos.y + TILE_SIZE)
    )
end

function Player:fall_check_hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y + TILE_SIZE),
        V2(self.pos.x + TILE_SIZE, self.pos.y + 1.5*TILE_SIZE)
    )
end

function Player:touched_bouncer(bouncer)
    self.bouncing_off_entity = true
    self:set_state(PlayerState.JUMPING)
    self:reset_current_animation()
    self:kill_momentum()
    self.bounce_momentum_x = 0
    self.bounce_momentum_y = 0
    self.fixing_position_in_frame = true

    if(bouncer.orientation == Bouncer.Orientation.UP) then
        self.pos.y = bouncer.pos.y - TILE_SIZE
        self.bounce_momentum_x = 0
        self.vel.y = -BOUNCER_FORCE
    end
    if(bouncer.orientation == Bouncer.Orientation.DOWN) then
        self.pos.y = bouncer:hitbox().bottom_right.y + TILE_SIZE
        self.bounce_momentum_x = 0
        self.vel.y = BOUNCER_FORCE
    end
    if(bouncer.orientation == Bouncer.Orientation.LEFT) then
        self.bounce_momentum_x = -2*BOUNCER_FORCE 
        self.vel.y = -0.7*BOUNCER_FORCE
    end
    if(bouncer.orientation == Bouncer.Orientation.RIGHT) then
        self.bounce_momentum_x = 2*BOUNCER_FORCE 
        self.vel.y = -0.7*BOUNCER_FORCE
    end
end

function Player:touched_snail(snail, player_subframe_hitbox)
    -- from physics we receive a subframe player position
    -- in which it detected a colition
    local player_subframe_pos = player_subframe_hitbox.top_left
    local player_bottom_y = player_subframe_pos.y + TILE_SIZE
    local is_below_margin = player_bottom_y > (snail.pos.y + Snail.SNAIL_BOUNCE_MARGIN)

    if is_below_margin then
        game_state:player_died()
        return
    end

    local prev_vel_y = self.vel.y
    self.bouncing_off_entity = true
    self:set_state(PlayerState.JUMPING)
    local MIN_SNAIL_BOUNCE_VEL = -3
    self.vel.y = math.min( -prev_vel_y + MIN_SNAIL_BOUNCE_VEL, MIN_SNAIL_BOUNCE_VEL)
    self.pos.y = snail.pos.y - TILE_SIZE
    snail:killed_by_player()
end

function Player:die()
    trigger_vibration_feedback(0.8, 0.3)
    Audio.play_sound("died_1")
    self:remove_colliding_vine()
    if self.fly_light then
        game_state.tile_map:remove_point_light(self.fly_light)
    end
    if(self.broom) then
        self.broom:set_free(self.vel)
    end
end

function Player:reset_colliding_vines()
    self.colliding_vines = {}
end

function Player:touched_vine(vine)
    table.insert(self.colliding_vines, vine)
    if(self.state ~= PlayerState.DEAD) then
        self.colliding_vine = vine
    end
end

function Player:touched_falling_platform(falling_platform)
    -- TODO: sacar esto y sacar x*TILE_SIZE
    local x = math.floor(falling_platform.pos.x / TILE_SIZE)
    local y = math.floor(falling_platform.pos.y / TILE_SIZE)

    if(self.prev_pos.x >= x*TILE_SIZE + TILE_SIZE) then
        self.vel.x = 0
        self.acc.x = 0
        self.bounce_momentum_x = 0
        self.pos.x = (x+1)*TILE_SIZE
    elseif(self.prev_pos.x + TILE_SIZE <= x*TILE_SIZE ) then
        self.vel.x = 0
        self.acc.x = 0
        self.bounce_momentum_x = 0
        self.pos.x = x*TILE_SIZE - TILE_SIZE
    elseif(self.prev_pos.y >= y*TILE_SIZE + TILE_SIZE) then
        self.vel.y = 0
        self.pos.y = (y+1)*TILE_SIZE
    elseif((self.prev_pos.y + TILE_SIZE) <= y*TILE_SIZE) then
        self.should_fall = false
        self:reset_current_animation()
        self:set_entity_below(EntityBelowType.FallingPlatform)
        self:add_landing_effects("falling_platform")
        if(self.triggered_jump_buffer and self.jump_buffer_frames_counter < JUMP_BUFFER_FRAMES) then
            self:jump_and_increment_jump_counter()
        else
            self:set_state(PlayerState.LAND)
            self.vel.y = 0
            self.pos.y = (y-1)*TILE_SIZE
        end
    end
end

function Player:touched_falling_column(falling_column)
    -- TODO: sacar esto y sacar x*TILE_SIZE
    local x = math.floor(falling_column.pos.x / TILE_SIZE)
    local y = math.floor(falling_column.pos.y / TILE_SIZE)
    local player_width = TILE_SIZE

    if(self.prev_pos.x >= falling_column.pos.x + falling_column.width) then
        self.vel.x = 0
        self.acc.x = 0
        self.bounce_momentum_x = 0
        self.pos.x = falling_column.pos.x + falling_column.width
    elseif(self.prev_pos.x + player_width <= falling_column.pos.x ) then
        self.vel.x = 0
        self.acc.x = 0
        self.bounce_momentum_x = 0
        self.pos.x = falling_column.pos.x - player_width
    elseif((self.prev_pos.y + TILE_SIZE) <= falling_column.pos.y) then
        self.should_fall = false
        self:reset_current_animation()
        self:set_entity_below(EntityBelowType.FallingColumn)
        self:add_landing_effects("temple")
        if(self.triggered_jump_buffer and self.jump_buffer_frames_counter < JUMP_BUFFER_FRAMES) then
            self:jump_and_increment_jump_counter()
        else
            self:set_state(PlayerState.LAND)
            self.vel.y = 0
            self.pos.y = falling_column.pos.y - TILE_SIZE + 1
        end
    -- better solution would be to subframe or predict
    elseif((self.prev_pos.y + 2*TILE_SIZE) > falling_column.pos.y + falling_column.height) then
        self.bounce_momentum_y = 0
        self.pos.y = falling_column.pos.y + falling_column.height
        -- check for crushing
        if check_for_crushing(game_state) then
            game_state:player_touched_spikes()
        end
    end
end

function Player:touched_computah(computah)
    local x = math.floor(computah.pos.x / TILE_SIZE)
    local y = math.floor(computah.pos.y / TILE_SIZE)
    local player_width = TILE_SIZE
    local computah_x = computah:hitbox().top_left.x
    local computah_y = computah:hitbox().top_left.y

    if(self.prev_pos.x >= computah.pos.x + computah.width) then
        self.vel.x = 0
        self.acc.x = 0
        self.bounce_momentum_x = 0
        self.pos.x = computah.pos.x + computah.width
    elseif(self.prev_pos.x + player_width <= computah.pos.x ) then
        self.vel.x = 0
        self.acc.x = 0
        self.bounce_momentum_x = 0
        self.pos.x = computah.pos.x - player_width
    elseif((self.prev_pos.y + TILE_SIZE) <= computah_y) then
        self.should_fall = false
        self:reset_current_animation()
        self:set_entity_below(EntityBelowType.Computah)
        -- TODO: fill
        --self:add_landing_effects("temple")
        if(self.triggered_jump_buffer and self.jump_buffer_frames_counter < JUMP_BUFFER_FRAMES) then
            self:jump_and_increment_jump_counter()
        else
            self:set_state(PlayerState.LAND)
            self.vel.y = 0
            self.pos.y = computah_y - TILE_SIZE + 1
        end
    -- better solution would be to subframe or predict
    elseif((self.prev_pos.y + 2*TILE_SIZE) > computah_y + computah.height) then
        self.bounce_momentum_y = 0
        self.pos.y = computah_y + computah.height
    end
end

function Player:spawn_at_door(door, game_state)
    if door.name == "initial" and game_state.tile_map.name == "level_01" then
        game_state:starting_first_level()
    end
    self.jumps_at_door_spawn = self.jumps_counter

    if(game_state.tile_map.allowed_jumps) then
        self.jumps_counter = 0
    end

    self.pos.x = door.spawn_pos.x*TILE_SIZE
    self.pos.y = door.spawn_pos.y*TILE_SIZE
    self.prev_pos.x = door.spawn_pos.x*TILE_SIZE
    self.prev_pos.y = door.spawn_pos.y*TILE_SIZE
    if(self.state ~= PlayerState.CLIMBING) then
        self.direction = door.direction
    end
    if(self.state == PlayerState.CLIMBING) then
        self.pos.x = (door.spawn_pos.x + self.direction*0.5)*TILE_SIZE
        self.pos.y = door.spawn_pos.y*TILE_SIZE
        self.prev_pos.x = (door.spawn_pos.x + self.direction*0.5)*TILE_SIZE
        self.prev_pos.y = door.spawn_pos.y*TILE_SIZE
    end

    if(self:is_flying()) then
        self.pos.y = self.pos.y - self.broom.height
        self:reset_state()
        self:reset_current_animation()
        self.broom:follow_player(self)
        self.broom:reset_current_animation()
        self.broom:reset_state()
    else
        self:reset_state()
        check_collisions(game_state.tile_map, self, game_state)
    end

    self:reset_current_animation()
    self:kill_momentum()

    if(self.broom) then
        self.state = PlayerState.FLYING
        self.broom.direction = self.direction
    end

    if game_state.player_eaten_light_fly then
        self:create_fly_light()
    end
end

function Player:light_position()
    return self:center_position()
end

function Player:center_position()
    return V2(self.pos.x + TILE_SIZE/2, self.pos.y + TILE_SIZE/2)
end

function Player:shadow_casting_segments()
    -- hardcoded based on nara sprite
    if self.state == PlayerState.DEAD then
        return {}
    end
    local y_delta = 0

    if self.state == PlayerState.CROUCHING then
        y_delta = 2
    end

    return {
        create_segment( -- top
            V2(
                self.pos.x + TILE_SIZE/4,
                self.pos.y + 2 + y_delta
            ),
            V2(
                self.pos.x + 3*TILE_SIZE/4,
                self.pos.y + 2 + y_delta
            )
        ),
        create_segment( -- bottom
            V2(
                self.pos.x + TILE_SIZE/4,
                self.pos.y + TILE_SIZE
            ),
            V2(
                self.pos.x + 3*TILE_SIZE/4,
                self.pos.y + TILE_SIZE
            )
        ),
        create_segment( -- left
            V2(
                self.pos.x + TILE_SIZE/4,
                self.pos.y + 2 + y_delta
            ),
            V2(
                self.pos.x + TILE_SIZE/4,
                self.pos.y + TILE_SIZE
            )
        ),
        create_segment( -- right
            V2(
                self.pos.x + 3*TILE_SIZE/4,
                self.pos.y + 2 + y_delta
            ),
            V2(
                self.pos.x + 3*TILE_SIZE/4,
                self.pos.y + TILE_SIZE
            )
        ),
    }
end

function Player:set_die_state()
    self:set_state(PlayerState.DEAD)
end

function Player:add_landing_effects(landing_sound_key)
    local sound = LANDING_SOUNDS[landing_sound_key]
    self.sound_timers.WALK_SOUNDS = 1
    if(sound) then
        Audio.play_sound("land_1")
        Audio.play_sound(sound.key, 0.5, 0.8)
    else
        Audio.play_sound("land_1")
    end

    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.nara_landing,
            gravity = 0,
            total_time = 0.1
        } ),
    })
end

function Player:add_jumping_effects()
    local tile_below = self:tile_below_tileset_name()
    local key = nil
    if tile_below then
        jump_sound = JUMP_SOUNDS[tile_below]
        if jump_sound then
            self.prev_tile_below = tile_below
            key = jump_sound.key
        elseif self.prev_tile_below then
            key = JUMP_SOUNDS[self.prev_tile_below].key
        end
    elseif self.prev_tile_below then
        key = JUMP_SOUNDS[self.prev_tile_below].key
    end

    if key then
        Audio.play_sound("jump_base", 0.8, 1.2)
        Audio.play_sound(key, 0.8, 1.4)
    end

    local entity_below_to_play_sound = self.entity_below or self.prev_entity_below
    if(entity_below_to_play_sound) then
        if(entity_below_to_play_sound == EntityBelowType.FallingPlatform) then
            Audio.play_sound("jump_base", 0.8, 1.2)
            Audio.play_sound("falling_platform_step", 0.4, 0.8)
        end
        if(entity_below_to_play_sound == EntityBelowType.FallingColumn) then
            Audio.play_sound("jump_base", 0.8, 1.2)
            Audio.play_sound("temple_step_1", 0.4, 0.8)
        end
    end

    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.nara_landing,
            gravity = 0,
            total_time = 0.1
        } ),
    })
end

function Player:splash()
    Audio.play_sound("splash", 0.8, 1.5)
    game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
        particle_emitter = ParticleEmitter( {
            pos = self.pos,
            particle_type = ParticleType.exploding,
            particle_variant = ParticleVariant.splash,
            gravity = 0.06,
            total_time = 0.1
        } ),
    })
end

function Player:tile_below_tileset_name()
    local below_left_x_index  = math.floor(self.pos.x / TILE_SIZE) + 1
    local below_right_x_index = below_left_x_index + 1
    local below_y_index = math.floor(self.pos.y / TILE_SIZE) + 2

    function ground_tile_layer_match(layer)
        return layer.name == "deco_1"
    end
    -- TODO: move to tile_map and ask for tile below
    local ground_tile_layer = lume.match(game_state.tile_map.tile_layers, ground_tile_layer_match)
    local tileset_width = ground_tile_layer.width
    local index_1 = below_left_x_index + (below_y_index-1) * tileset_width
    local index_2 = below_right_x_index + (below_y_index-1) * tileset_width

    local tile_below_1 = ground_tile_layer.data[index_1]
    local tile_below_2 = ground_tile_layer.data[index_2]

    local tile_below_tileset = nil
    if(tile_below_1 and tile_below_1 > 0) then
        tile_below_tileset = game_state.tile_map:tileset_from_tile(tile_below_1)
    elseif(tile_below_2 and tile_below_2 > 0) then
        tile_below_tileset = game_state.tile_map:tileset_from_tile(tile_below_2)
    end

    if(tile_below_tileset) then
        return tile_below_tileset.name
    else
        return nil
    end
end

function Player:reset_walk_state()
    self.sound_timers.WALK_SOUNDS = 0
end

function Player:set_state(state)
    if(self.state == PlayerState.CLIMBING) then
        if(state ~= PlayerState.CLIMBING) then
            self:remove_colliding_vine()
        end
    end
    if(state ~= PlayerState.JUMPING and self.state == PlayerState.JUMPING) then
        self.bouncing_off_entity = false
    end

    if(self.state ~= PlayerState.DEAD) then
        self.state = state
    end
end

function Player:reset_state()
    if(self.state ~= PlayerState.CLIMBING and self.state ~= PlayerState.SWIMMING) then
        self.state = PlayerState.IDLE
        self:remove_colliding_vine()
    end
end

function Player:current_state_animation()
    local animation = self.animation[self.state]
    local witch_animation = self.witch_animation[self.state]

    if(self.is_wearing_hat and witch_animation) then
        return witch_animation
    else
        return animation
    end
end

function Player:animate()
    local animation = self.animation[self.state]
    local witch_animation = self.witch_animation[self.state]

    if(self.is_wearing_hat and witch_animation) then
        witch_animation:advance_step()
    else
        animation:advance_step()
    end
end

function Player:reset_current_animation()
    local animation = self.animation[self.state]
    local witch_animation = self.witch_animation[self.state]

    if(self.is_wearing_hat and witch_animation) then
        witch_animation:reset()
    else
        animation:reset()
    end
end

function Player:advance_current_animation_stage()
    local animation = self.animation[self.state]
    local witch_animation = self.witch_animation[self.state]

    if(self.is_wearing_hat and witch_animation) then
        witch_animation:advance_stage()
    else
        animation:advance_stage()
    end
end

function Player:pushed_brog()
    self.is_wearing_hat = true
    game_state.player_is_wearing_hat = true
    self.state = PlayerState.FLYING
    self.broom = Broom(self.pos, 1)
    self.broom:follow_player(self)

    save_game_data(game_state)
end

function Player:follow_broom()
    local broom_center_x = self.broom.pos.x + self.broom.width/2
    local broom_top_y = self.broom.pos.y

    self.pos.x = broom_center_x - TILE_SIZE/2
    self.pos.y = broom_top_y - TILE_SIZE/2 - 2
    self.prev_pos.x = broom_center_x - TILE_SIZE/2
    self.prev_pos.y = broom_top_y - TILE_SIZE/2 - 2
end

function Player:add_player_combined_collision(x, y, tile)
    -- Calculate which type of movement should do
    local tile_left_x   = x*TILE_SIZE
    local tile_right_x  = (x+1)*TILE_SIZE

    local tile_top_y    = y*TILE_SIZE
    local tile_bottom_y = (y+1)*TILE_SIZE

    local width = TILE_SIZE
    local height = TILE_SIZE

    local collision = {
        x = x,
        y = y,
        adjust_direction = nil,
        type = "player"
    }

    if(self.prev_pos.x >= tile_right_x) then
        collision.adjust_direction = "right"

    elseif(self.prev_pos.x + width <= tile_left_x ) then
        collision.adjust_direction = "left"

    elseif(self.prev_pos.y >= tile_bottom_y) then
        collision.adjust_direction = "down"

    elseif((self.prev_pos.y + height) <= tile_top_y) then
        collision.adjust_direction = "up"
    end

    table.insert(self.adjust_collisions, collision)
end

function Player:add_broom_combined_collision(x, y, tile)
    -- Calculate which type of movement should do
    local tile_left_x   = x*TILE_SIZE
    local tile_right_x  = (x+1)*TILE_SIZE

    local tile_top_y    = y*TILE_SIZE
    local tile_bottom_y = (y+1)*TILE_SIZE

    local collision = {
        x = x,
        y = y,
        adjust_direction = nil,
        type = "broom"
    }

    if(self.broom.prev_pos.x >= tile_right_x) then
        collision.adjust_direction = "right"

    elseif(self.broom.prev_pos.x + self.broom.width <= tile_left_x ) then
        collision.adjust_direction = "left"

    elseif(self.broom.prev_pos.y >= tile_bottom_y) then
        collision.adjust_direction = "down"

    elseif((self.broom.prev_pos.y + self.broom.height) <= tile_top_y) then
        collision.adjust_direction = "up"
    end

    table.insert(self.adjust_collisions, collision)
end

function Player:adjust_required_collisions()
    local player_collisions = lume.filter(self.adjust_collisions, function(el) return el.type == "player" end)
    local broom_collisions = lume.filter(self.adjust_collisions, function(el) return el.type == "broom" end)

    if(#broom_collisions == 1) then
        self:broom_resolve_single_adjustment(broom_collisions[1], self.broom.width, self.broom.height)

    elseif(#broom_collisions == 2) then
        self:broom_resolve_double_adjustment(broom_collisions[1], broom_collisions[2], self.broom.width, self.broom.height)

    elseif(#broom_collisions > 2) then
        local first_collision = broom_collisions[1]
        local second_collision = broom_collisions[2]

        if(first_collision.x ~= second_collision.x and first_collision.y ~= second_collision.y) then
            self:broom_resolve_double_adjustment(first_collision, second_collision, self.broom.width, self.broom.height)
        else
            local found = false
            for i = 3, #broom_collisions do
                local c = broom_collisions[i]
                local diferent_from_first = c.x ~= first_collision.x and c.y ~= first_collision.y
                local diferent_from_second = c.x ~= second_collision.x and c.y ~= second_collision.y

                if(diferent_from_first) then
                    self:broom_resolve_double_adjustment(first_collision, c, self.broom.width, self.broom.height)
                    found = true
                    break
                elseif(diferent_from_second) then
                    self:broom_resolve_double_adjustment(second_collision, c, self.broom.width, self.broom.height)
                    found = true
                    break
                end
            end

            if(not found and self.broom) then
                self:broom_resolve_double_adjustment(first_collision, second_collision, self.broom.width, self.broom.height)
            end
        end
    end

    if(#player_collisions == 1) then
        self:resolve_single_adjustment(player_collisions[1], TILE_SIZE, TILE_SIZE)

    elseif(#player_collisions == 2) then
        local up_adjustment = find_first(player_collisions, function(coll) return coll.adjust_direction == "up" end)
        local down_adjustment = find_first(player_collisions, function(coll) return coll.adjust_direction == "down" end)
        local left_adjustment = find_first(player_collisions, function(coll) return coll.adjust_direction == "left" end)
        local right_adjustment = find_first(player_collisions, function(coll) return coll.adjust_direction == "right" end)

        if(up_adjustment and right_adjustment) then
            self:resolve_double_adjustment(up_adjustment, right_adjustment, TILE_SIZE, TILE_SIZE)

        elseif(up_adjustment and left_adjustment) then
            self:resolve_double_adjustment(up_adjustment, left_adjustment, TILE_SIZE, TILE_SIZE)

        elseif(down_adjustment and right_adjustment) then
            self:resolve_double_adjustment(down_adjustment, right_adjustment, TILE_SIZE, TILE_SIZE)

        elseif(down_adjustment and left_adjustment) then
            self:resolve_double_adjustment(down_adjustment, left_adjustment, TILE_SIZE, TILE_SIZE)

        elseif(up_adjustment) then
            self:resolve_single_adjustment(up_adjustment, TILE_SIZE, TILE_SIZE)
        elseif(down_adjustment) then
            self:resolve_single_adjustment(down_adjustment, TILE_SIZE, TILE_SIZE)
        elseif(right_adjustment) then
            self:resolve_single_adjustment(right_adjustment, TILE_SIZE, TILE_SIZE)
        elseif(left_adjustment) then
            self:resolve_single_adjustment(left_adjustment, TILE_SIZE, TILE_SIZE)
        end

    elseif(#player_collisions > 2) then
        local first_collision = player_collisions[1]
        local second_collision = player_collisions[2]

        if(first_collision.x ~= second_collision.x and first_collision.y ~= second_collision.y) then
            self:resolve_double_adjustment(first_collision, second_collision, TILE_SIZE, TILE_SIZE)
            return
        end

        for i = 3, #player_collisions do
            local c = player_collisions[i]
            local diferent_from_first = c.x ~= first_collision.x and c.y ~= first_collision.y
            local diferent_from_second = c.x ~= second_collision.x and c.y ~= second_collision.y

            if(diferent_from_first) then
                self:resolve_double_adjustment(first_collision, c, TILE_SIZE, TILE_SIZE)
                return
            elseif(diferent_from_second) then
                self:resolve_double_adjustment(second_collision, c, TILE_SIZE, TILE_SIZE)
                return
            end
        end
    end
end

function Player:resolve_double_adjustment(adjustment_a, adjustment_b, width, height)
    local is_horizontal = adjustment_a.y == adjustment_b.y
    local is_vertical = adjustment_a.x == adjustment_b.x
    local is_both = not (is_horizontal or is_vertical)

    if(is_horizontal) then
        snap_to(self, adjustment_a.adjust_direction, adjustment_a.x, adjustment_a.y, width, height)
        self.broom:follow_player(self)

    elseif(is_vertical) then
        snap_to(self, adjustment_b.adjust_direction, adjustment_b.x, adjustment_b.y, width, height)
        self.broom:follow_player(self)

    elseif(is_both) then
        snap_to(self, adjustment_a.adjust_direction, adjustment_a.x, adjustment_a.y, width, height)
        snap_to(self, adjustment_b.adjust_direction, adjustment_b.x, adjustment_b.y, width, height)
        self.broom:follow_player(self)
    end
end

function Player:resolve_single_adjustment(adjustment, width, height)
    snap_to(self, adjustment.adjust_direction, adjustment.x, adjustment.y, width, height)
    self.broom:follow_player(self)
end

function Player:broom_resolve_single_adjustment(adjustment, width, height)
    snap_to(self.broom, adjustment.adjust_direction, adjustment.x, adjustment.y, width, height)
    self:follow_broom()
end

function Player:broom_resolve_double_adjustment(adjustment_a, adjustment_b, width, height)
    local is_horizontal = adjustment_a.y == adjustment_b.y
    local is_vertical = adjustment_a.x == adjustment_b.x
    local is_both = not (is_horizontal or is_vertical)
    local vertical_adjustment = nil
    local horizontal_adjustment = nil
    local a_direction = adjustment_a.adjust_direction

    if(a_direction == "up" or a_direction == "down") then
        vertical_adjustment = adjustment_a
    else
        vertical_adjustment = adjustment_b
    end

    if(a_direction == "right" or a_direction == "left") then
        horizontal_adjustment = adjustment_a
    else
        horizontal_adjustment = adjustment_b
    end

    if(is_horizontal) then
        snap_to(self.broom, vertical_adjustment.adjust_direction, vertical_adjustment.x, vertical_adjustment.y, width, height)
        self:follow_broom()

    elseif(is_vertical) then
        snap_to(self.broom, horizontal_adjustment.adjust_direction, horizontal_adjustment.x, horizontal_adjustment.y, width, height)
        self:follow_broom()

    elseif(is_both) then
        snap_to(self.broom, adjustment_a.adjust_direction, adjustment_a.x, adjustment_a.y, width, height)
        snap_to(self.broom, adjustment_b.adjust_direction, adjustment_b.x, adjustment_b.y, width, height)
        self:follow_broom()
    end
end

function Player:broom_touched_falling_platform(falling_platform)
    self:add_broom_combined_collision(falling_platform.pos.x / TILE_SIZE, falling_platform.pos.y / TILE_SIZE, nil)
end

function Player:is_flying()
    return self.state == PlayerState.FLYING or self.state == PlayerState.FLYING_TURNING
end

function Player:touched_broom()
    if(not self:is_flying() and not self.jumping_off_broom) then
        self:reset_current_animation()
        self:set_state(PlayerState.FLYING)
        self:follow_broom()
    end
end

function Player:exited_broom_collision()
    self.jumping_off_broom = false
end

function Player:jump_off_broom()
    self.jumping_off_broom = true
    self:reset_current_animation()
    self.broom:complete_rotation()
    self.broom:set_free(self.vel)
    self:jump()
end

function Player:reset_state_to_lobby()
    self:reset_current_animation()

    if(self.broom) then
        self.broom = nil
    end
    self:set_state(PlayerState.IDLE)
end

function Player:remove_colliding_vine()
    if(self.climbing_vine) then
        self.climbing_vine:released()
    end
    self.colliding_vine = nil
    self.climbing_vine = nil
end

function Player:on_air()
    local AIR_STATES = {
        PlayerState.ON_AIR,
        PlayerState.JUMPING,
    }

    return table_contains(AIR_STATES, self.state)
end

function Player:jumps_since_door_spawn()
    if(self.jumps_at_door_spawn) then
        return self.jumps_counter - self.jumps_at_door_spawn
    else
        return 0
    end
end

function Player:set_transition_fade_out(target_door_pos)
    self.transition_state = Player.TransitionState.FADE_OUT
    self.transition_time = 0
    self.fade_target_door_pos = V2(target_door_pos.x, target_door_pos.y)
end

function Player:set_transition_fade_in(target_door_pos)
    self.transition_state = Player.TransitionState.FADE_IN
    self.transition_time = 0
    self.fade_target_door_pos = V2(target_door_pos.x, target_door_pos.y)
end

function Player:set_transition_none()
    self.transition_state = Player.TransitionState.NONE
    self.transition_time = 0
    self.fade_target_door_pos = nil
end

function Player:is_air_state(state)
    assert(state ~= nil)

    local air_states = {
        PlayerState.ON_AIR,
        PlayerState.JUMPING,
        PlayerState.FALLING_FROM_VINE,
    }

    return table_contains(air_states, state)
end

function Player:handle_queued_water_collisions()
    for _, water_collision in pairs(self.queued_water_collisions) do
        if self:is_air_state(self.state) then
            self:splash()
            self.vel.y = self.vel.y*0.1
            self:set_state(PlayerState.SWIMMING)
        end
    end

    self.queued_water_collisions = {}
end

Player.FLY_LIGHT_RADIUS    = 0.28
Player.FLY_LIGHT_INTENSITY = 0.5
function Player:create_fly_light()
    self.fly_light = PointLight(
        self:light_position(),
        "#44ff22",
        0.28,
        0.5
    )
    game_state.tile_map:add_point_light(self.fly_light)
end

function Player:set_entity_below(entity_type)
    self.prev_entity_below = entity_type
    self.entity_below = entity_type
end
