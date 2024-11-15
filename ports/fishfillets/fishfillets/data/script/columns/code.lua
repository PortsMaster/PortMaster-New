
--NOTE: rows must be together in models.lua
local advices1 = {}
local advices1_end = rada1end.index - rada1beg.index
for i = 0, advices1_end do
    advices1[i] = getModelsTable()[rada1beg.index + i]
end

local advices2 = {}
local advices2_end = rada2end.index - rada2beg.index
for i = 0, advices2_end do
    advices2[i] = getModelsTable()[rada2beg.index + i]
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky05.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        switch(pokus){
            [1] = function()
                room.uvod = 12
            end,
            default = function()
                room.uvod = random(4) + random(2) * 10
            end,
        }
        room.kochani = random(2)
        room.pady = 0
        room.osose = random(1500) + 500

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.osose > 0 then
                    room.osose = room.osose - 1
                end
                if room.uvod > 0 then
                    if room.uvod >= 10 and random(100) < 40 then
                        addm(10 + random(40), "sl-m-velkolepe")
                        room.uvod = room.uvod - 10
                    end
                    if math.mod(room.uvod, 10) >= 1 then
                        addv(20, "sl-v-stopa")
                    end
                    if room.uvod > 10 then
                        addm(5 + random(30), "sl-m-velkolepe")
                        room.uvod = room.uvod - 10
                    end
                    if room.uvod >= 2 then
                        addv(5, "sl-v-vkapse")
                    end
                    if room.uvod >= 3 then
                        addm(random(20) + 5, "sl-m-trvat")
                    end
                    room.uvod = 0
                elseif room.osose == 0 and chlapik.cinnost == 0 then
                    addm(20, "sl-m-sedi")
                    addv(5, "sl-v-feidios")
                    addm(20 + random(50), "sl-m-tehdy")
                    room.osose = -1
                elseif room.kochani == 0 and room.pady <= 1 and big.dir ~= dir_no and random(100) < 2 then
                    room.kochani = 1
                    big:setBusy(true)
                    addv(0, "sl-v-nechme")
                    adddel(random(90) + 30)
                    planBusy(big, false)
                elseif room.pady <= 0 and small.X == 33 and small.Y == 27 and ocel.Y < 26 then
                    addv(0, "sl-v-opatrne")
                    room.pady = 1
                elseif room.pady <= 1 and sochoradi.cinnost >= 8 then
                    addv(0, "sl-v-skoda")
                    room.pady = 2
                elseif room.pady <= 2 and sochoradi.Y == 16 and samotna.X >= 14 and chlapik.cinnost == 0 then
                    room.pady = 3
                    addv(0, "sl-v-pust")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_samotna()
        return function()
            if random(100) < 2 then
                samotna.afaze = random(2) * 2
            end
            if samotna.dir ~= dir_no then
                samotna.afaze = 1
            end
            samotna:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_rada1beg()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rada1beg.cinnost = 0

        return function()
            switch(rada1beg.cinnost){
                [0] = function()
                    if random(1000) < 15 then
                        rada1beg.cinnost = random(5) + 2
                        switch(rada1beg.cinnost){
                            [4] = function()
                                repeat
                                    rada1beg.xicht1 = random(3)
                                until rada1beg.xicht1 ~= rada1beg.afaze
                                repeat
                                    rada1beg.xicht2 = random(3)
                                until rada1beg.xicht2 ~= rada1beg.afaze
                            end,
                            default = function()
                                if isIn(rada1beg.cinnost, {2, 3}) then
                                    repeat
                                        rada1beg.xicht1 = random(3)
                                    until rada1beg.xicht1 ~= rada1beg.afaze
                                end
                            end,
                        }
                        rada1beg.faze = 0
                    end
                end,
                [1] = function()
                    rada1beg.cinnost = random(3) + 2
                    rada1beg.xicht1 = random(3)
                    rada1beg.xicht2 = random(3)
                    rada1beg.faze = 0
                end,
                [2] = function()
                    if odd(game_getCycles()) then
                        advices1[rada1beg.faze].afaze = rada1beg.xicht1
                        rada1beg.faze = rada1beg.faze + 1
                        if rada1beg.faze > advices1_end then
                            rada1beg.cinnost = 0
                        end
                    end
                end,
                [3] = function()
                    if odd(game_getCycles()) then
                        advices1[advices1_end - rada1beg.faze].afaze = rada1beg.xicht1
                        rada1beg.faze = rada1beg.faze + 1
                        if advices1_end - rada1beg.faze < 0 then
                            rada1beg.cinnost = 0
                        end
                    end
                end,
                [4] = function()
                    if odd(game_getCycles()) then
                        advices1[rada1beg.faze].afaze = rada1beg.xicht1
                        advices1[advices1_end - rada1beg.faze].afaze = rada1beg.xicht2

                        rada1beg.faze = rada1beg.faze + 1
                        if rada1beg.faze > advices1_end then
                            rada1beg.cinnost = 0
                        end
                    end
                end,
                [5] = function()
                    if random(1000) < 15 then
                        rada1beg.cinnost = 1
                    elseif random(100) < 20 then
                        pom1 = random(advices1_end + 1)
                        advices1[pom1].afaze = random(3)
                    end
                end,
                [6] = function()
                    if random(1000) < 15 then
                        rada1beg.cinnost = 1
                    elseif random(100) < 50 then
                        pom1 = random(advices1_end + 1)
                        if random(100) < 20 then
                            advices1[pom1].afaze = random(3)
                        else
                            switch(random(2)){
                                [0] = function()
                                    if pom1 > 0 then
                                        advices1[pom1].afaze = advices1[pom1 - 1].afaze
                                    end
                                end,
                                [1] = function()
                                    if pom1 < advices1_end then
                                        advices1[pom1].afaze = advices1[pom1 + 1].afaze
                                    end
                                end,
                            }
                        end
                    end
                end,
                [7] = function()
                    rada1beg.cinnost = 4
                    rada1beg.xicht1 = 1
                    rada1beg.xicht2 = 1
                    rada1beg.faze = 0
                end,
            }
            for index, advice in pairs(advices1) do
                advice:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_rada2beg()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rada2beg.cinnost = 0

        return function()
            switch(rada2beg.cinnost){
                [0] = function()
                    if random(1000) < 15 then
                        rada2beg.cinnost = random(5) + 2
                        switch(rada2beg.cinnost){
                            [4] = function()
                                repeat
                                    rada2beg.xicht1 = random(3)
                                until rada2beg.xicht1 ~= rada2beg.afaze
                                repeat
                                    rada2beg.xicht2 = random(3)
                                until rada2beg.xicht2 ~= rada2beg.afaze
                            end,
                            default = function()
                                if isIn(rada2beg.cinnost, {2, 3}) then
                                    repeat
                                        rada2beg.xicht1 = random(3)
                                    until rada2beg.xicht1 ~= rada2beg.afaze
                                end
                            end,
                        }
                        rada2beg.faze = 0
                    end
                end,
                [1] = function()
                    rada2beg.cinnost = random(3) + 2
                    rada2beg.xicht1 = random(3)
                    rada2beg.xicht2 = random(3)
                    rada2beg.faze = 0
                end,
                [2] = function()
                    if odd(game_getCycles()) then
                        advices2[rada2beg.faze].afaze = rada2beg.xicht1
                        rada2beg.faze = rada2beg.faze + 1
                        if rada2beg.faze > advices2_end then
                            rada2beg.cinnost = 0
                        end
                    end
                end,
                [3] = function()
                    if odd(game_getCycles()) then
                        advices2[advices2_end - rada2beg.faze].afaze = rada2beg.xicht1
                        rada2beg.faze = rada2beg.faze + 1
                        if advices2_end - rada2beg.faze < 0 then
                            rada2beg.cinnost = 0
                        end
                    end
                end,
                [4] = function()
                    if odd(game_getCycles()) then
                        advices2[rada2beg.faze].afaze = rada2beg.xicht1
                        advices2[advices2_end - rada2beg.faze].afaze = rada2beg.xicht2
                        rada2beg.faze = rada2beg.faze + 1
                        if rada2beg.faze > advices2_end then
                            rada2beg.cinnost = 0
                        end
                    end
                end,
                [5] = function()
                    if random(1000) < 15 then
                        rada2beg.cinnost = 1
                    elseif random(100) < 20 then
                        pom1 = random(advices2_end + 1)
                        advices2[pom1].afaze = random(3)
                    end
                end,
                [6] = function()
                    if random(1000) < 15 then
                        rada2beg.cinnost = 1
                    elseif random(100) < 50 then
                        pom1 = random(advices2_end + 1)
                        if random(100) < 20 then
                            advices2[pom1].afaze = random(3)
                        else
                            switch(random(2)){
                                [0] = function()
                                    if pom1 > 0 then
                                        advices2[pom1].afaze = advices2[pom1 - 1].afaze
                                    end
                                end,
                                [1] = function()
                                    if pom1 < advices2_end then
                                        advices2[pom1].afaze = advices2[pom1 + 1].afaze
                                    end
                                end,
                            }
                        end
                    end
                end,
                [7] = function()
                    rada2beg.cinnost = 4
                    rada2beg.xicht1 = 1
                    rada2beg.xicht2 = 1
                    rada2beg.faze = 0
                end,
            }
            for index, advice in pairs(advices2) do
                advice:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sochoradi()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sochoradi.cinnost = 0

        return function()
            if isIn(sochoradi.cinnost, {4, 5, 7}) then
                sound_playSound("impact_light")
            end
            switch(sochoradi.cinnost){
                [0] = function()
                    if sochoradi.dir == dir_up then
                        sochoradi.cinnost = sochoradi.cinnost + 1
                    end
                end,
                [8] = function()
                    rada1beg.cinnost = 7
                    sochoradi.cinnost = sochoradi.cinnost + 1
                end,
                default = function()
                    if 1 <= sochoradi.cinnost and sochoradi.cinnost <= 7 then
                        sochoradi.afaze = sochoradi.cinnost
                        sochoradi.cinnost = sochoradi.cinnost + 1
                    end
                end,
            }
            sochoradi:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_chlapik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        chlapik.cinnost = 0

        return function()
            if isIn(chlapik.cinnost, {5, 9}) then
                sound_playSound("impact_light")
            end
            switch(chlapik.cinnost){
                [0] = function()
                    if chlapik.dir == dir_down then
                        chlapik.cinnost = chlapik.cinnost + 1
                    end
                end,
                [1] = function()
                    if chlapik.dir == dir_no then
                        chlapik.afaze = 1
                        chlapik.cinnost = chlapik.cinnost + 1
                        small:killSound()
                        game_killPlan()
                        if isReady(small) then
                            addm(2, "sl-m-jekot")
                            if isReady(big) then
                                addv(0, "sl-v-barbarka")
                            end
                            addm(20 + random(20), "sl-m-nelibila")
                        end
                    end
                end,
                [10] = function()
                    rada1beg.cinnost = 7
                    chlapik.cinnost = chlapik.cinnost + 1
                end,
                default = function()
                    if 2 <= chlapik.cinnost and chlapik.cinnost <= 9 then
                        chlapik.afaze = chlapik.cinnost
                        chlapik.cinnost = chlapik.cinnost + 1
                    end
                end,
            }
            chlapik:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_samotna()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rada1beg()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rada2beg()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sochoradi()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_chlapik()
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

