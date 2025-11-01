require("../scene_animation")

StartAnimation = {}
Audio.create_sound("sounds/spell.ogg", "spell", "static", 1, 0.4)

function StartAnimation.Animation(game_state)

    local data = {
        brog = Brog(V2(240, -60)),
    }

    local steps = {
        {
            time = 5,
            handle = StartAnimation.step_1_handle,
            data = StartAnimation.initial_step_1_data(),
        },
        {
            time = 1,
            handle = StartAnimation.step_2_handle,
        },
        {
            time = 200,
            handle = StartAnimation.step_3_handle,
        },
        {
            controled = true,
            time = 200,
            handle = StartAnimation.step_4_handle,
            data = StartAnimation.initial_step_4_data(),
        },
        {
            time = 2,
            handle = StartAnimation.step_5_handle,
        },
        {
            controled = true,
            time = 200,
            handle = StartAnimation.talk_with_nara_handle,
            data = StartAnimation.initial_talk_with_nara_data(),
        },
        {
            time = 2,
            handle = StartAnimation.step_6_handle,
        },
        {
            time = 200,
            handle = StartAnimation.step_7_handle,
        },
        {
            time = 2,
            handle = StartAnimation.step_8_handle,
        },
    }
    local scene_animation = SceneAnimation( game_state, steps, "start_animation", data )

    return scene_animation
end

StartAnimation.initial_step_1_data = function()
    return {
        z_timer = 0
    }
end

StartAnimation.step_1_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    data.z_timer = data.z_timer + dt
    game_state.player.state = PlayerState.SLEEP

    if(data.z_timer >= 1) then
        data.z_timer = 0
        game_state.tile_map:add_effect(EFFECT_TYPE.particles, 1.0, {
            particle_emitter = ParticleEmitter( {
                pos = V2(game_state.player.pos.x + TILE_SIZE - 3, game_state.player.pos.y + TILE_SIZE/2),
                particle_type = ParticleType.exploding,
                particle_variant = ParticleVariant.sleep,
                gravity = 0.01,
                data = {
                    dir = 1
                },
            } ),
        })
    end
    game_state.player:animate()
end

StartAnimation.step_2_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local initial_pos = V2(240, -10)
    local end_pos = V2(240, 40)
    game_state.player.state = PlayerState.SLEEP

    animation_data.brog.anchor.x = end_pos.x
    animation_data.brog.anchor.y = end_pos.y

    if(self.scene_animation_time == 0) then
        -- TODO: maybe do it directly in animation start
        game_state.tile_map:add_brog(animation_data.brog)
    end

    local t = easeOut(self.scene_normal_time, 4)
    animation_data.brog.pos.y = lume.lerp(initial_pos.y, end_pos.y, t)

    game_state.player:animate()
    animation_data.brog:animate()
end

StartAnimation.step_3_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    animation_data.brog.state = Brog.State.TURNING
    game_state.player.state = PlayerState.SLEEP
    game_state.player:animate()
    animation_data.brog:animate()

    if(animation_data.brog:current_animation().has_looped) then
        UI.clear_speech_dialog()
        self:next_step()
    end
end

StartAnimation.initial_step_4_data = function()
    return {
        step_dialog = 1,
        step_dialogs = false,
    }
end

StartAnimation.step_4_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local dialogs = {
        "Brewing potions all day can get pretty boring",
        "What can I do? mmm...",
        "Aha!!!",
        "That's it",
        "I'm gonna curse someone",
        "hehehe"
    }
    if(not data.step_dialogs) then
        data.step_dialogs = true
        UI.add_speech_dialog(dialogs[1], animation_data.brog)
    end
    animation_data.brog.state = Brog.State.IDLE
    animation_data.brog.direction = -1
    game_state.player.state = PlayerState.SLEEP
    local anchor_y = 40
    local offset = 3
    local speed = 2
    animation_data.brog.pos.x = 240
    animation_data.brog.pos.y = anchor_y + lume.round(offset*math.sin(speed*game_state.time))
    game_state.player:animate()
    animation_data.brog:animate()

    -- TODO: BUG: drawn more frames than update
    -- next_triggered is 3 draw frames in a row before
    -- input update frame (1/60)
    if(next_dialog_triggered) then
        if(data.step_dialog == #dialogs and UI.speech_dialog.is_done) then
            UI.clear_speech_dialog()
            self:next_step()
        else
            if(UI.speech_dialog.is_done) then
                data.step_dialog = data.step_dialog + 1
                UI.speech_dialog:change_label(dialogs[data.step_dialog])
            else
                UI.speech_dialog:complete_triggered()
            end
        end
    end
end

StartAnimation.step_5_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    animation_data.brog.state = Brog.State.IDLE
    animation_data.brog.direction = -1
    game_state.player.state = PlayerState.SLEEP
    local player_pos = game_state.player.pos
    local end_x = player_pos.x + 64 - 4
    local end_y = player_pos.y - 4 - 32
    local initial_pos = V2(240, 40)
    local end_pos = V2(end_x, end_y)

    animation_data.brog.anchor.x = end_pos.x
    animation_data.brog.anchor.y = end_pos.y

    local tx = easeInOut(self.scene_normal_time, 2)
    local ty = easeIn(self.scene_normal_time, 2)
    animation_data.brog.pos.x = lume.lerp(initial_pos.x, end_pos.x, tx)
    animation_data.brog.pos.y = lume.lerp(initial_pos.y, end_pos.y, ty)

    game_state.player:animate()
    animation_data.brog:animate()
end

StartAnimation.step_6_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    Audio.play_sound("spell", 0.8, 0.8, 0.5)
    game_state.player.state = PlayerState.IDLE
    animation_data.brog.state = Brog.State.CASTING
    animation_data.brog.direction = 1
    animation_data.brog.pos.x = game_state.player.pos.x - 4
    animation_data.brog.pos.y = game_state.player.pos.y - 80 + 16 + TILE_SIZE + 4
    -- local initial_pos = V2(240, 40)
    -- local end_pos = V2(60, 80)

    -- local tx = easeInOut(self.scene_normal_time, 1)
    -- local ty = easeOut(self.scene_normal_time, 0.4)
    -- brog.pos.x = lume.lerp(initial_pos.x, end_pos.x, tx)
    -- brog.pos.y = lume.lerp(initial_pos.y, end_pos.y, ty)

    game_state.player:animate()
    animation_data.brog:animate()
end

StartAnimation.step_7_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    local brog_x = game_state.player.pos.x + 64 - 4
    local brog_y = game_state.player.pos.y - 4 - 32
    animation_data.brog.pos = V2(brog_x, brog_y)
    animation_data.brog.direction = -1

    animation_data.brog.state = Brog.State.TURNING
    game_state.player:animate()
    animation_data.brog:animate()

    if(animation_data.brog:current_animation().has_looped) then
        self:next_step()
    end
end

StartAnimation.step_8_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    game_state.player.state = PlayerState.IDLE
    animation_data.brog.state = Brog.State.IDLE

    local brog_x = game_state.player.pos.x + 64 - 4
    local brog_y = game_state.player.pos.y - 4 - 32
    local initial_pos = V2(brog_x, brog_y)
    local end_pos = V2(380, 40)
    animation_data.brog.direction = 1

    local tx = easeInOut(self.scene_normal_time, 1)
    local ty = easeIn(self.scene_normal_time, 0.5)
    animation_data.brog.pos.x = lume.lerp(initial_pos.x, end_pos.x, tx)
    animation_data.brog.pos.y = lume.lerp(initial_pos.y, end_pos.y, ty)

    game_state.player:animate()
    animation_data.brog:animate()
end

StartAnimation.initial_talk_with_nara_data = function()
    return {
        talk_with_nara_step = nil 
    }
end

StartAnimation.talk_with_nara_handle = function(self, dt, next_dialog_triggered, data, animation_data)
    game_state.player.state = PlayerState.SLEEP
    animation_data.brog.state = Brog.State.IDLE

    local dialogs = {
        "Hey",
        "Heeeeeeeeeeeey",
        "...",
    }
    if(not data.talk_with_nara_step) then
        data.talk_with_nara_step = 1
        UI.add_speech_dialog(dialogs[1], animation_data.brog)
    end
    animation_data.brog.state = Brog.State.IDLE
    animation_data.brog.direction = -1
    local anchor_y = 40
    local offset = 3
    local speed = 2
    animation_data.brog.pos.y = game_state.player.pos.y - 80 + 16 + 20 + 8
    game_state.player:animate()
    animation_data.brog:animate()

    -- TODO: BUG: drawn more frames than update
    -- next_triggered is 3 draw frames in a row before
    -- input update frame (1/60)
    if(next_dialog_triggered) then
        if(data.talk_with_nara_step == #dialogs and UI.speech_dialog.is_done) then
            UI.clear_speech_dialog()
            self:next_step()
        else
            if(UI.speech_dialog.is_done) then
                data.talk_with_nara_step = data.talk_with_nara_step + 1
                UI.speech_dialog:change_label(dialogs[data.talk_with_nara_step])
            else
                UI.speech_dialog:complete_triggered()
            end
        end
    end
end
