
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky01.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.odedkovi = 0
        room.ritual = 0
        room.ohlavem = 0
        room.ohlavev = 0
        room.blizko = 0
        room.jikry = 0
        room.curat = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.blizko > 0 then
                    room.blizko = room.blizko - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    addm(randint(5, 20), "zd2-m-dalsi")
                    switch(random(2)){
                        [0] = function()
                            addv(random(5), "zd2-v-odlis0")
                        end,
                        [1] = function()
                            addv(random(5), "zd2-v-odlis1")
                        end,
                    }
                elseif room.odedkovi == 0 and small.X > 20 and small.Y < 30 and look_at(big, dedek) then
                    room.odedkovi = 1
                    addv(randint(5, 10), "zd2-v-vlevo")
                    switch(random(2)){
                        [0] = function()
                            addm(randint(1, 5), "zd2-m-nevid0")
                        end,
                        [1] = function()
                            addm(randint(1, 5), "zd2-m-nevid1")
                        end,
                    }
                elseif room.ritual == 0 and random(100) < 5 and room.odedkovi == 1 and dedek.pohlse == 0 then
                    addv(1, "zd2-v-symbol")
                    addm(randint(1, 5), "zd2-m-douf")
                    room.ritual = 1
                elseif room.ohlavem == 0 and dist(small, hlava) < 3 and look_at(small, hlava) and random(100) < 5 then
                    room.ohlavem = 1
                    addm(1, "zd2-m-lebka")
                elseif room.ohlavev == 0 and dist(big, hlava) < 3 and look_at(big, hlava) and random(100) < 5 then
                    room.ohlavev = 1
                    addv(1, "zd2-v-haml")
                elseif room.blizko == 0 and (dist(small, dedek) < 5 and look_at(small, dedek) or dist(small, dedek) < 5 and look_at(small, dedek)) then
                    room.blizko = random(400) + 100
                    switch(random(3)){
                        [0] = function()
                            planDialogSet(random(3), "zd2-x-hus0", 101, dedek, "mluvi")
                        end,
                        [1] = function()
                            planDialogSet(random(3), "zd2-x-hus1", 102, dedek, "mluvi")
                        end,
                        [2] = function()
                            planDialogSet(random(3), "zd2-x-kricet", 102, dedek, "mluvi")
                        end,
                    }
                elseif dedek.dir ~= dir_no and random(100) < 2 then
                    switch(random(3)){
                        [0] = function()
                            planDialogSet(randint(2, 6), "zd2-x-krik0", 101, dedek, "mluvi")
                        end,
                        [1] = function()
                            planDialogSet(randint(2, 6), "zd2-x-krik1", 102, dedek, "mluvi")
                        end,
                        [2] = function()
                            if room.ritual == 1 then
                                planDialogSet(randint(2, 6), "zd2-x-ritual", 102, dedek, "mluvi")
                            end
                        end,
                    }
                elseif dist(small, dedek) < 3 and dist(big, dedek) < 3 and random(100) < 1 then
                    planDialogSet(randint(2, 6), "zd2-x-nechteme", 102, dedek, "mluvi")
                elseif (dist(small, dedek) <= 1 or dist(big, dedek) <= 1) and random(100) < 2 then
                    switch(random(3)){
                        [0] = function()
                            planDialogSet(randint(2, 6), "zd2-x-nechme", 102, dedek, "mluvi")
                        end,
                        [1] = function()
                            planDialogSet(randint(2, 6), "zd2-x-pokoj", 102, dedek, "mluvi")
                        end,
                        [2] = function()
                            planDialogSet(randint(2, 6), "zd2-x-fuj", 102, dedek, "mluvi")
                        end,
                    }
                elseif dist(small, dedek) < 3 and look_at(small, dedek) and room.jikry == 0 and random(100) < 1 then
                    room.jikry = 1
                    planDialogSet(random(3), "zd2-x-neklast", 102, dedek, "mluvi")
                elseif dist(big, dedek) < 3 and look_at(big, dedek) and room.curat == 0 and random(100) < 1 then
                    room.curat = 1
                    planDialogSet(random(3), "zd2-x-necurat", 102, dedek, "mluvi")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vytah()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        --NOTE: double rope
        game_addDecor("rope", vytah.index, stroj.index, 43, 0, 58, 27)
        game_addDecor("rope", vytah.index, stroj.index, 43 + 3, 0, 58 + 3, 27)
    end

    -- -------------------------------------------------------------
    local function prog_init_stroj()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        return function()
            if stroj.X == vytah.X - 1 then
                if stroj.dir == dir_no and vytah.dir == dir_down then
                    pom1 = 2
                elseif stroj.dir == dir_up and vytah.dir == dir_no then
                    pom1 = 1
                elseif stroj.dir == dir_no and vytah.dir == dir_up then
                    pom1 = -1
                elseif stroj.dir == dir_down and vytah.dir == dir_no then
                    pom1 = -2
                else
                    pom1 = 0
                end
                stroj.afaze = stroj.afaze + pom1
                if stroj.afaze > 5 then
                    stroj.afaze = stroj.afaze - 6
                elseif stroj.afaze < 0 then
                    stroj.afaze = stroj.afaze + 6
                end
            end
            stroj:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dedek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dedek.mluvi = 0
        dedek.pohlse = 0
        dedek.mavani = randint(1, 3)

        return function()
            if dedek.dir ~= dir_no then
                dedek.pohlse = 1
            end
            if dedek.mavani == 0 then
                if dedek.mluvi == 102 then
                    dedek.afaze = 1
                else
                    dedek.afaze = 0
                end
                dedek.mavani = randint(1, 3)
            else
                switch(dedek.mluvi){
                    [101] = function()
                        dedek.afaze = 1
                        dedek.mavani = dedek.mavani - 1
                    end,
                    [102] = function()
                        dedek.afaze = 2
                        dedek.mavani = dedek.mavani - 1
                    end,
                    default = function()
                        dedek.afaze = 0
                    end,
                }
            end
            dedek:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_vytah()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_stroj()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dedek()
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

