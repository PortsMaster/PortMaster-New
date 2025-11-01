require("./utils");
require("./math");
require("./animation")
require("./audio")
local Object = require("./classic")

local AUDIO_CUES_AMOUNT = 6
for i = 1, AUDIO_CUES_AMOUNT do
    Audio.create_sound("sounds/audio_cue-"..i..".ogg", "audio_cue_"..i, "static", 1, 1.0)
end

-- Cave cues
Audio.create_sound("sounds/cave_audio_cue_1.mp3", "cave_audio_cue_1", "static", 3, 1.0)
Audio.create_sound("sounds/cave_audio_cue_2.mp3", "cave_audio_cue_2", "static", 3, 1.0)
-- Jungle cues
Audio.create_sound("sounds/jungle_audio_cue_1.mp3", "jungle_audio_cue_1", "static", 2, 1.0)
Audio.create_sound("sounds/jungle_audio_cue_2.mp3", "jungle_audio_cue_2", "static", 2, 1.0)
-- Temple cues
Audio.create_sound("sounds/temple_audio_cue_1.mp3", "temple_audio_cue_1", "static", 2, 1.0)
Audio.create_sound("sounds/temple_audio_cue_2.mp3", "temple_audio_cue_2", "static", 2, 1.0)
Audio.create_sound("sounds/temple_audio_cue_3.mp3", "temple_audio_cue_3", "static", 2, 1.0)
Audio.create_sound("sounds/temple_audio_cue_4.mp3", "temple_audio_cue_4", "static", 2, 1.0)


Trigger = Object.extend(Object)
TriggerCounter = Object.extend(Object)

Trigger.Type = {
    ["HIDDEN"]          = 0,
    ["ANIMATION"]       = 1,
    ["JUMPS_SAVED_CUE"] = 2,
}

Trigger.AudioTriggerImage = love.graphics.newImage("audio_trigger.png")
Trigger.AUDIO_CUES_KEYS_BY_AREA = {
    cave = {
        "cave_audio_cue_1",
        "cave_audio_cue_2",
    },
    jungle = {
        "jungle_audio_cue_1",
        "jungle_audio_cue_2",
    },
    temple = {
        "temple_audio_cue_1",
        "temple_audio_cue_2",
        "temple_audio_cue_3",
        "temple_audio_cue_4",
    }
}

local TRIGGER_COUNTER_TOTAL_TIME = 30

function TriggerCounter.new(self, trigger_id)
    self.trigger_id = trigger_id
    self.time = 0
    self.done = false
    self.triggered = false
    self.count_percentage = 0
end

function TriggerCounter:update()
    if(self.triggered and (not done) ) then
        self.time = math.min(self.time + 1, TRIGGER_COUNTER_TOTAL_TIME)
        self.count_percentage = self.time / TRIGGER_COUNTER_TOTAL_TIME

        if(self.time == TRIGGER_COUNTER_TOTAL_TIME) then 
            self.done = true
        end
    end
end

function TriggerCounter:trigger()
    if(not self.triggered) then
        Audio.play_sound("secret")
    end
    self.triggered = true
end

function Trigger.new(self, id, pos, type, tile_map, width, height, expected_jumps)
    self.id = id
    self.pos = pos -- top_left
    self.type = type or Trigger.Type.HIDDEN
    self.tile_map = tile_map
    self.width = width
    self.height = height
    self.expected_jumps = expected_jumps 

    self.triggered = false
end

function Trigger:hitbox()
    return Rectangle(
        V2(self.pos.x, self.pos.y),
        V2(self.pos.x + self.width, self.pos.y + self.height)
    )
end

function Trigger:draw()
    -- Draw hitbox
    if false then
        love.graphics.setColor(1, 0, 0, 0.6)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle(
            "fill",
            self.pos.x, self.pos.y,
            self.width, self.height
        )
        love.graphics.setColor(1, 1, 1)
    end

    local debug_draw_audio_trigger = dev_mode
    debug_draw_audio_trigger = debug_draw_audio_trigger and game_state.show_audio_triggers
    debug_draw_audio_trigger = debug_draw_audio_trigger and self.type == Trigger.Type.JUMPS_SAVED_CUE

    if debug_draw_audio_trigger then
        if self:has_less_jumps_than_expected() then
            love.graphics.setColor(0.2, 0.8, 0.2, 0.6)
        else
            love.graphics.setColor(0.8, 0.2, 0.2, 0.6)
        end
        love.graphics.setLineWidth(1)
        love.graphics.rectangle(
            "fill",
            self.pos.x, self.pos.y,
            self.width, self.height
        )
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Trigger.AudioTriggerImage, self.pos.x, self.pos.y)
    end
end

function Trigger:has_less_jumps_than_expected()
    return game_state.player:jumps_since_door_spawn() <= self.expected_jumps
end

function Trigger:triggered_by_player()
    if(self.type == Trigger.Type.JUMPS_SAVED_CUE) then
        if(not self.triggered) then
            if(self:has_less_jumps_than_expected()) then
                local current_area = game_state.tile_map:area_key()
                local current_area_cue_keys = Trigger.AUDIO_CUES_KEYS_BY_AREA[current_area]

                if current_area_cue_keys == nil then
                    print("[ERROR]: There are no audio cues for this area:", current_area)
                else
                    local audio_cue_key = lume.randomchoice(current_area_cue_keys)
                    Audio.play_sound(audio_cue_key, 1, 1)
                end
            end
        end
    end

    self.triggered = true

    if(self.type == Trigger.Type.HIDDEN) then
        self.tile_map:reveal_hidden_area(self.id)
    end

    if(self.type == Trigger.Type.ANIMATION) then
        game_state:trigger_animation(self.id)
    end
end
