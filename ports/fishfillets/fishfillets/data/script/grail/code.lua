
file_include('script/share/prog_border.lua')

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky04.ogg")
    local pokus = getRestartCount()

    --NOTE: a final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    for key, item in pairs(getModelsTable()) do
        if item:getH() == 2 and item:getW() == 2 then
            item:setGoal("goal_out")
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uztovedi = 0
        room.jestejeden = 0
        room.uztobude = 0
        room.tusili = 0
        if pokus > 7 then
            if odd(pokus) then
                room.uvod = -1
                room.pokr = 20 + random(20)
            else
                room.uvod = 20 + random(25)
                room.pokr = -1
            end
        else
            room.uvod = 15 + random(20)
            room.pokr = 20 + random(50)
        end

        return function()
            local remain = 0
            for key, item in pairs(getModelsTable()) do
                if item:getH() == 2 and item:getW() == 2 then
                    if item.X == aura.X and item.Y == aura.Y + 1 then
                        item:setAnim("default", 1)
                        if room.uztovedi < 3 and item ~= light then
                            room.uztovedi = 3
                        end
                    else
                        item:setAnim("default", 0)
                    end
                    if not item:isOut() then
                        remain = remain + 1
                    end
                end
            end
            pom2 = 0
            if no_dialog() and isReady(small) and isReady(big) then
                if room.uvod > 0 then
                    room.uvod = room.uvod - 1
                elseif room.uvod == 0 then
                    room.uvod = -1
                    pom2 = 1
                elseif room.pokr > 0 then
                    room.pokr = room.pokr - 1
                elseif room.pokr == 0 then
                    room.pokr = -1
                    pom2 = 3
                elseif stdBorderReport() then
                    if room.uztovedi > 2 then
                        addm(8, "gr-m-vsechny1")
                    else
                        addm(10, "gr-m-svaty1")
                        addv(6, "gr-v-vsechny1")
                        if pokus < 2 or random(100) < 70 then
                            addm(8, "gr-m-jensvaty")
                        end
                    end
                elseif room.tusili == 0 and room.uztovedi < 2 and random(1000) == 1 then
                    room.tusili = 1
                    pom2 = 2
                elseif room.uztovedi == 3 and random(30) == 1 then
                    room.uztovedi = 4
                    pom2 = 5
                elseif room.jestejeden == 0 and remain == 1 and random(30) == 1 then
                    room.jestejeden = 1
                    pom2 = 7
                elseif room.uztobude == 0 and isIn(remain, {1, 2, 3}) and random(150) == 1 then
                    room.uztobude = 1
                    pom2 = 6
                end
            end
            switch(pom2){
                [1] = function()
                    addm(10, "gr-m-gral")
                    addv(8, "gr-v-jiste")
                    pom1 = random(2)
                    addm(8, "gr-m-zare"..pom1)
                    addv(8, "gr-v-nic"..pom1)
                end,
                [2] = function()
                    addv(10, "gr-v-tuseni")
                    addm(10, "gr-m-tuseni")
                end,
                [3] = function()
                    addm(10, "gr-m-svaty0")
                    addv(8, "gr-v-vsechny0")
                end,
                [4] = function()
                end,
                [5] = function()
                    addm(8, "gr-m-vsechny0")
                end,
                [6] = function()
                    addv(10, "gr-v-skoro0")
                end,
                [7] = function()
                    addv(10, "gr-v-skoro1")
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_light()
        light:setAnim("default", 1)
        return function()
            if room.uztovedi == 0 then
                if light.X ~= aura.X or light.Y ~= aura.Y + 1 then
                    room.uztovedi = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_aura()
        return function()
            if aura.afaze >= 11 then
                aura.afaze = 0
            else
                aura.afaze = aura.afaze + 1
            end
            aura:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_light()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_aura()
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

