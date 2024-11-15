
-- -----------------------------------------------------------------
-- View update
-- -----------------------------------------------------------------
local function animateFish(model)
    if model:isAlive() then
        local action = model:getAction()

        if "move_up" == action then
            model:runAnim("vertical_up")
        elseif "move_down" == action then
            model:runAnim("vertical_down")
        elseif "move_left" == action or "move_right" == action then
            model:runAnim("swam")
        elseif "turn" == action then
            model:runAnim("turn")
        elseif "activate" == action then
            model:setAnim("turn", 0)
        elseif "busy" == action then
            model:setAnim("turn", 0)
        else
            --NOTE: for talking see animateHead() bellow
            model:runAnim("rest")
        end
    else
        model:runAnim("skeleton")
    end
end

-- -----------------------------------------------------------------
local function animateHead(model)
    model_useSpecialAnim(model.index, "", 0)
    if model:isAlive() then
        local state = model:getState()
        if "talking" == state or model_isTalking(TALK_INDEX_BOTH) then
            if not model.talk_phase then
                model.talk_phase = random(3)
            elseif math.mod(game_getCycles(), 2) == 0 then
                model.talk_phase = math.mod(
                    model.talk_phase + randint(1, 2), 3)
            end
        else
            model.talk_phase = false
        end

        local action = model:getAction()
        if "busy" == action then
            if model.talk_phase then
                model:setAnim("talk", model.talk_phase)
            else
                model:setAnim("turn", 0)
            end
        else
            if "talking" == state or model_isTalking(TALK_INDEX_BOTH) then
                model:useSpecialAnim("head_talking", model.talk_phase)
            elseif "pushing" == state then
                model:useSpecialAnim("head_pushing", 0)
            elseif random(100) < 6 then
                model:useSpecialAnim("head_blink", 0)
            end
        end
    end
end

-- -----------------------------------------------------------------
function animateUnits()
    for index, unit in pairs(getUnitTable()) do
        animateFish(unit)
        animateHead(unit)
    end
end

