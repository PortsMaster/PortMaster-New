
local function viewY(model)
    local shift_x, shift_y = model_getViewShift(model.index)
    return model.Y + shift_y
end
local function incViewShift(model, shift_x, shift_y)
    local oldShiftX, oldShiftY = model_getViewShift(model.index)
    model_setViewShift(model.index,
        oldShiftX + shift_x,
        oldShiftY + shift_y)
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky07.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        if random(100) < 70 or pokus == 1 then
            room.uvod = 0
        end
        room.hodinky = 0
        room.cervik = 0
        room.desticky = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod == 0 then
                    if random(100) < 33 then
                        addm(10 + random(20), "pyr-m-kam")
                    elseif random(100) < 50 then
                        addv(30 + random(30), "pyr-v-vsim")
                    else
                        addm(10 + random(20), "pyr-m-kam")
                        addv(random(40), "pyr-v-vsim")
                    end
                    room.uvod = 1
                elseif room.hodinky == 0 and look_at(small, stela) and (small.Y > 14 and small.Y < 21) and (stela.afaze == 2 or stela.afaze == 4 or stela.afaze == 5) then
                    addm(0, "pyr-m-nudi")
                    addv(2 + random(3), "pyr-v-sark")
                    if random(100) < 50 then
                        addm(random(5), "pyr-m-comy")
                    end
                    if random(100) < 50 then
                        addm(random(5), "pyr-m-zkus")
                    end
                    if random(100) < 50 then
                        addm(random(5), "pyr-m-nic")
                    end
                    room.hodinky = 1
                elseif look_at(small, cerv) and room.cervik == 0 and (small.Y < viewY(cerv) + 2 and small.Y > viewY(cerv) - 2) and random(100) < 4 then
                    addm(0, "pyr-m-plaz")
                    if random(100) < 50 then
                        addv(random(5), "pyr-v-druha")
                        room.cervik = 1
                    end
                elseif faraon.afaze == 2 and big.dir ~= dir_no and faraon.dir ~= dir_no and level_isNewRound() and random(100) < 20 then
                    addv(0, "pyr-v-sfing")
                    adddel(10)
                elseif room.desticky == 0 and random(100) < 3 and (look_at(small, deska1) and small.Y == deska1.Y and dist(small, deska1) < 2 and deska1.dir == dir_no or look_at(small, deska2) and small.Y == deska2.Y and dist(small, deska2) < 2 and deska2.dir == dir_no or look_at(small, deska3) and small.Y == deska3.Y and dist(small, deska3) < 2 and deska3.dir == dir_no) then
                    addm(0, "pyr-m-dest")
                    addv(random(15), "pyr-v-sbohem")
                    room.desticky = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_faraon()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        faraon.delay = random(200) + 100

        return function()
            if faraon.dir ~= dir_no then
                faraon.delay = random(20) + 15
                faraon.afaze = 2
            end
            if faraon.delay > 0 then
                faraon.delay = faraon.delay - 1
            else
                switch(faraon.afaze){
                    [0] = function()
                        faraon.delay = random(20) + 20
                        faraon.afaze = 1
                    end,
                    default = function()
                        if isIn(faraon.afaze, {1, 2}) then
                            faraon.delay = random(200) + 100
                            faraon.afaze = 0
                        end
                    end,
                }
            end
            faraon:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_stela()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        stela.konstanta = 10
        stela.faze = 0
        stela.delay = 0

        return function()
            if stela.dir ~= dir_no then
                stela.afaze = 0
                stela.delay = 0
                stela.faze = 0
            end
            if stela.delay > 0 then
                stela.delay = stela.delay - 1
            else
                local faze_table = {
                    [0] = function()
                        stela.delay = stela.konstanta * (random(30) + 50)
                    end,
                    [1] = function()
                        stela.afaze = 1
                        stela.delay = 0
                    end,
                    [2] = function()
                        stela.delay = random(30) + 20
                        stela.afaze = 2
                    end,
                    [3] = function()
                        stela.afaze = 1
                        stela.delay = 0
                    end,
                    [4] = function()
                        stela.afaze = 0
                        stela.delay = stela.konstanta * (random(20) + 30)
                    end,
                    [8] = function()
                        stela.afaze = 0
                        stela.delay = stela.konstanta * (random(10) + 20)
                    end,
                    [12] = function()
                        stela.afaze = 0
                        stela.delay = stela.konstanta * (random(5) + 5)
                    end,
                    [13] = function()
                        stela.afaze = 3
                        stela.delay = stela.konstanta * (random(20) + 30)
                    end,
                    [14] = function()
                        stela.afaze = 4
                        stela.delay = random(30) + 20
                    end,
                    [15] = function()
                        stela.afaze = 3
                        stela.delay = stela.konstanta * (random(10) + 20)
                    end,
                    [17] = function()
                        stela.afaze = 3
                        stela.delay = stela.konstanta * (random(5) + 5)
                    end,
                    default = function()
                        stela.afaze = 5
                        stela.delay = 30000
                    end,
                }

                faze_table[5] = faze_table[1]
                faze_table[9] = faze_table[1]

                faze_table[6] = faze_table[2]
                faze_table[10] = faze_table[2]

                faze_table[7] = faze_table[3]
                faze_table[11] = faze_table[3]

                faze_table[16] = faze_table[14]

                switch(stela.faze)(faze_table)
                stela.faze = stela.faze + 1
            end
            stela:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_cerv()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        cerv.stav = -5
        cerv.mez = random(15)

        return function()
            if cerv.stav < 32 then
                cerv.stav = cerv.stav + 1
            end
            if cerv.stav == 30 then
                if viewY(cerv) > cerv.mez then
                    cerv.stav = 0
                else
                    cerv.mez = cerv.mez + 2 + random(21 - cerv.mez - 2)
                end
            end

            local stav_table = {
                [0] = function()
                    cerv.afaze = 0
                end,
                [5] = function()
                    cerv.afaze = 1
                end,
                [7] = function()
                    cerv.afaze = 2
                end,
                [1] = function()
                    cerv.afaze = 3
                end,
                [13] = function()
                    cerv.afaze = 4
                end,
                [20] = function()
                    cerv.afaze = 5
                end,
                [22] = function()
                    cerv.afaze = 6
                end,
                [26] = function()
                    cerv.afaze = 7
                end,
                [28] = function()
                    cerv.afaze = 0
                    incViewShift(cerv, -1, -1)
                end,
                [32] = function()
                    if viewY(cerv) < cerv.mez then
                        incViewShift(cerv, 1, 1)
                    else
                        cerv.stav = 0
                        cerv.mez = random(cerv.mez - 2)
                    end
                end,
            }

            stav_table[1] = stav_table[0]
            stav_table[2] = stav_table[0]
            stav_table[3] = stav_table[0]
            stav_table[4] = stav_table[0]

            stav_table[6] = stav_table[5]

            stav_table[8] = stav_table[7]
            stav_table[9] = stav_table[7]
            stav_table[10] = stav_table[7]

            stav_table[12] = stav_table[11]

            stav_table[14] = stav_table[13]
            stav_table[15] = stav_table[13]
            stav_table[16] = stav_table[13]
            stav_table[17] = stav_table[13]
            stav_table[18] = stav_table[13]
            stav_table[19] = stav_table[13]

            stav_table[21] = stav_table[20]

            stav_table[23] = stav_table[22]
            stav_table[24] = stav_table[22]
            stav_table[25] = stav_table[22]

            stav_table[27] = stav_table[26]

            switch(cerv.stav)(stav_table)
            cerv:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_faraon()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_stela()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_cerv()
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

