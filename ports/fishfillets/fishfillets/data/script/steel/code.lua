
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.houk = -1
        room.citac = random(40) + 40
        local bgfaze

        return function()
            pom1 = 0
            if room.citac > 0 then
                room.citac = room.citac - 1
            end
            if room.houk == -1 then
                if valec.dir == dir_left then
                    room.houk = room.houk + 1
                elseif room.citac == 0 and isReady(small) then
                    addm(0, "steel-m-"..random(2))
                    room.citac = -1
                else
                end
            else
                switch(math.mod(room.houk, 10)){
                    [2] = function()
                        room:talk("steel-x-redalert", VOLUME_FULL)
                        bgfaze = 1
                        pom1 = 1
                    end,
                    [4] = function()
                        room:talk("steel-x-redalert", VOLUME_FULL)
                    end,
                    [9] = function()
                        bgfaze = 2
                        pom1 = 1
                    end,
                }
                room.houk = room.houk + 1
            end
            if pom1 == 1 then
                for key, model in pairs(getModelsTable()) do
                    if model ~= small and model ~= big then
                        model.afaze = bgfaze
                        model:updateAnim()
                    end
                end
                game_changeBg("images/"..codename.."/steel-pozadi"..bgfaze..".png")
            end
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    return update_table
end
local update_table = prog_init()


-- -----------------------------------------------------------------
-- Update
-- -----------------------------------------------------------------
function prog_update()
    for key, subupdate in pairs(update_table) do
        subupdate()
    end
end

