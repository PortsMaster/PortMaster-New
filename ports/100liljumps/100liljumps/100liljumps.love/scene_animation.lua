require("./lume")
require("./math")
require("./brog")

local Object = require("./classic")

SceneAnimation = Object.extend(Object)

function SceneAnimation.new(self, game_state, steps, name, data)
    self.name = name or ""
    self.scene_animation_time = 0
    self.scene_normal_time = 0
    self.step = 1
    self.steps = steps
    self.data = data
    game_state.tile_map:add_effect(EFFECT_TYPE.cinematic, nil, {
        type = "in"
    } )
end

function SceneAnimation:update(dt)
    local target_time = self.steps[self.step].time
    local controled = self.steps[self.step].controled
    if(not controled) then
        if(self.scene_animation_time >= target_time) then
            self.scene_animation_time = 0
            self.scene_normal_time = 0
            self.step = self.step + 1
            if(self.step > #self.steps) then
                self:end_animation()

                return
            end
        end
    end

    local next_dialog_triggered = input.confirm.is_pressed

    local current_step = self.steps[self.step]
    local handle = current_step.handle
    local step_data = current_step.data
    handle(self, dt, next_dialog_triggered, step_data, self.data)

    if(self.step > #self.steps) then
        self:end_animation()

        return
    end

    self.scene_animation_time = self.scene_animation_time + dt
    self.scene_normal_time = self.scene_animation_time / self.steps[self.step].time
end

function SceneAnimation:next_step()
    self.scene_animation_time = 0
    self.scene_normal_time = 0
    self.step = self.step + 1
end

function SceneAnimation:end_animation()
    game_state.tile_map:remove_effect(EFFECT_TYPE.cinematic)
    game_state.tile_map:add_effect(EFFECT_TYPE.cinematic, 4, {
        type = "out"
    } )
    game_state.game_mode = GameMode.SIMULATING
    game_state.current_scene_animation = nil

    if(self.name == "start_animation") then
        game_state:finising_start_animation()
    end
end
