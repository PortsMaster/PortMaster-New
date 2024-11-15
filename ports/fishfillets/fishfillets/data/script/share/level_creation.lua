
-- -----------------------------------------------------------------
LOOK_LEFT = 0
LOOK_RIGHT = 1

VOLUME_LOW = 50
VOLUME_LOWER = 75
VOLUME_FULL = 100

TALK_INDEX_BOTH = -1

-- -----------------------------------------------------------------
-- Room creation
-- -----------------------------------------------------------------
function createRoom(width, height, picture)
    level_createRoom(width, height, picture)
    sound_addSound("impact_light", "sound/share/sp-impact_light_00.ogg")
    sound_addSound("impact_light", "sound/share/sp-impact_light_01.ogg")
    sound_addSound("impact_heavy", "sound/share/sp-impact_heavy_00.ogg")
    sound_addSound("impact_heavy", "sound/share/sp-impact_heavy_01.ogg")

    sound_addSound("dead_small", "sound/share/sp-dead_small.ogg")
    sound_addSound("dead_big", "sound/share/sp-dead_big.ogg")
end

function setRoomWaves(double_amp, periode, inv_speed)
    game_setRoomWaves(double_amp/2, periode, 1/inv_speed)
end

local models_table = {}
function addModel(name, x, y, shape)
    local model_index = game_addModel(name, x, y, shape)
    local model = createObject(model_index)
    models_table[model_index] = model
    return model
end
function getModelsTable()
    return models_table
end

local unit_table = {}
function getUnitTable()
    return unit_table
end

-- -----------------------------------------------------------------
-- Model creation
-- -----------------------------------------------------------------
function createObject(model_index)
    local object = {}
    object.index = model_index
    object.talk_phase = false

    object.addAnim = function(self, anim_name, filename, lookDir)
        model_addAnim(self.index, anim_name, filename, lookDir)
    end
    object.runAnim = function(self, anim_name, phase)
        model_runAnim(self.index, anim_name, phase)
    end
    object.setAnim = function(self, anim_name, phase)
        model_setAnim(self.index, anim_name, phase)
    end
    object.useSpecialAnim = function(self, anim_name, phase)
        local action = self:getAction()
        if action ~= "busy" and action ~= "turn" and action ~= "activate" and self:isAlive() then
            model_useSpecialAnim(self.index, anim_name, phase)
        end
    end
    object.setEffect = function(self, effect_name)
        model_setEffect(self.index, effect_name)
    end

    object.getLoc = function(self)
        return model_getLoc(self.index)
    end
    object.getAction = function(self)
        return model_getAction(self.index)
    end
    object.getState = function(self)
        return model_getState(self.index)
    end
    object.getTouchDir = function(self)
        return model_getTouchDir(self.index)
    end
    object.isAlive = function(self)
        return model_isAlive(self.index)
    end
    object.isOut = function(self)
        return model_isOut(self.index)
    end
    object.isLeft = function(self)
        return model_isLeft(self.index)
    end
    object.isAtBorder = function(self)
        return model_isAtBorder(self.index)
    end
    object.getW = function(self)
        return model_getW(self.index)
    end
    object.getH = function(self)
        return model_getH(self.index)
    end
    object.isTalking = function(self)
        return model_isTalking(self.index)
    end
    object.talk = function(self, dialog, volume, loops)
        model_talk(self.index, dialog, volume, loops)
    end
    object.killSound = function(self)
        model_killSound(self.index)
    end
    object.planDialog = function(self, delay, dialog, action)
        planDialog(self.index, delay, dialog, action)
    end
    object.setGoal = function(self, goalname)
        model_setGoal(self.index, goalname)
    end
    object.change_turnSide = function(self)
        model_change_turnSide(self.index)
    end
    object.setBusy = function(self, busy)
        model_setBusy(self.index, busy)
    end

    return object
end

-- -----------------------------------------------------------------
-- Loading resources
-- -----------------------------------------------------------------
local function imgList(picture_00)
    -- return table of available sprites _00, _01, _02, ...
    --TODO: support others than .png
    local list = {picture_00}
    local index = 1
    local ext = ".png"
    local base, ok = string.gsub(picture_00, "_00"..ext.."$", "_")
    while ok == 1 do
        local next_file = base..index..ext
        if index < 10 then
            next_file = base.."0"..index..ext
        end

        if file_exists(next_file) then
            table.insert(list, next_file)
        else
            ok = 0
        end
        index = index + 1
    end
    return list
end

function addItemAnim(model, picture_00)
    -- store all "picture_*.png" sprites to object anim
    local anim_name = "default"

    for index, filename in ipairs(imgList(picture_00)) do
        model:addAnim(anim_name, filename)
    end

    model:setAnim(anim_name, 0)
end

function addHeadAnim(model, directory, anim, phase)
    local left_path = directory.."/heads/left/head_"..phase..".png"
    if file_exists(left_path) then
        model:addAnim(anim, left_path)
        model:addAnim(anim, directory.."/heads/right/head_"..phase..".png",
                LOOK_RIGHT)
    else
        print("SCRIPT_WARNING head anim is not available", anim, directory, phase)
    end
end
local function addBodyAnim(model, directory, anim, phase)
    local picture_00 = directory.."/left/body_"..phase..".png"
    for index, filename in ipairs(imgList(picture_00)) do
        model:addAnim(anim, filename)
        model:addAnim(anim,
                string.gsub(filename, "/left/body_", "/right/body_"),
                LOOK_RIGHT)
    end
end
local function addBodyAnimBackward(model, directory, anim, phase)
    local picture_00 = directory.."/left/body_"..phase..".png"
    local list = imgList(picture_00)
    for index = table.getn(list), 1, -1 do
        local filename = list[index]
        model:addAnim(anim, filename)
        model:addAnim(anim,
                string.gsub(filename, "/left/body_", "/right/body_"),
                LOOK_RIGHT)
    end
end

function addFishAnim(model, look_dir, directory)
    -- NOTE: remark fish in unit_table
    unit_table[model.index] = model
    if model:isLeft() and look_dir == LOOK_RIGHT then
        model:change_turnSide()
    end
    model:setGoal("goal_escape")

    addBodyAnim(model, directory, "skeleton", "skeleton_00")
    addBodyAnim(model, directory, "rest", "rest_00")

    addBodyAnim(model, directory, "vertical_up", "vertical_00")
    addBodyAnimBackward(model, directory, "vertical_down", "vertical_00")

    addBodyAnim(model, directory, "swam", "swam_00")
    addBodyAnim(model, directory, "turn", "turn_00")
    addBodyAnim(model, directory, "talk", "talk_00")

    -- heads
    addHeadAnim(model, directory, "head_talking", "talking_00")
    addHeadAnim(model, directory, "head_talking", "talking_01")
    addHeadAnim(model, directory, "head_talking", "talking_02")

    addHeadAnim(model, directory, "head_pushing", "pushing")
    addHeadAnim(model, directory, "head_blink", "blink")

    addHeadAnim(model, directory, "head_all", "talking_00")
    addHeadAnim(model, directory, "head_all", "pushing")
    addHeadAnim(model, directory, "head_all", "blink")
    addHeadAnim(model, directory, "head_all", "shock")
    addHeadAnim(model, directory, "head_all", "smile")
    addHeadAnim(model, directory, "head_all", "talking_01")
    addHeadAnim(model, directory, "head_all", "talking_02")
    addHeadAnim(model, directory, "head_all", "scowl_00")
    addHeadAnim(model, directory, "head_all", "scowl_01")

    model:runAnim("rest")
end

