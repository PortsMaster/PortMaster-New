
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky15.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.kec1 = random(5)
        repeat
            room.kec2 = random(5)
        until room.kec2 ~= room.kec1
        repeat
            room.kec3 = random(5)
        until room.kec3 ~= room.kec1 and room.kec3 ~= room.kec2
        repeat
            room.kec4 = random(5)
        until room.kec4 ~= room.kec1 and room.kec4 ~= room.kec2 and room.kec4 ~= room.kec3
        room.kecdel1 = random(300) + 300
        room.kecdel2 = random(1000) + 1000
        room.kecdel3 = random(3000) + 3000
        room.kecdel4 = random(10000) + 10000
        room.uvod = 0
        room.ohaku = 0
        room.ooku = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                for pom1 = 1, 1 do
                    if room.kecdel1 > 0 then
                        room.kecdel1 = room.kecdel1 - 1
                    end
                    if room.kecdel2 > 0 then
                        room.kecdel2 = room.kecdel2 - 1
                    end
                    if room.kecdel3 > 0 then
                        room.kecdel3 = room.kecdel3 - 1
                    end
                    if room.kecdel4 > 0 then
                        room.kecdel4 = room.kecdel4 - 1
                    end
                end
                pom1 = -1
                if room.uvod == 0 then
                    room.uvod = 1
                    pom1 = random(4)
                    adddel(10 + random(30))
                    switch(pom1){
                        [0] = function()
                            addm(0, "vl-m-hara")
                        end,
                        [3] = function()
                            addv(0, "vl-v-kaj1")
                        end,
                        default = function()
                            addm(0, "vl-m-hara")
                            addv(5 + random(10), "vl-v-kaj"..pom1)
                        end,
                    }
                    pom1 = -1
                elseif room.ohaku == 0 and look_at(small, hakahak) and dist(small, hakahak) <= 2 and random(100) < 1 then
                    room.ohaku = 1
                    addm(20, "vl-m-hak")
                    addv(random(10) + 5, "vl-v-lodni")
                    planDialogSet(3, "vl-x-site", 301, hakahak, "cinnost")
                elseif room.kecdel1 == 0 then
                    room.kecdel1 = -1
                    pom1 = room.kec1
                elseif room.kecdel2 == 0 then
                    room.kecdel2 = -1
                    pom1 = room.kec2
                elseif room.kecdel3 == 0 then
                    room.kecdel3 = -1
                    pom1 = room.kec3
                elseif room.kecdel4 == 0 then
                    room.kecdel4 = -1
                    pom1 = room.kec4
                elseif room.ooku == 0 and dist(small, ocko) <= 3 and random(100) < 1 then
                    room.ooku = 1
                    addm(10, "vl-m-oko")
                    if random(100) < 25 then
                        addv(10, "vl-v-silha")
                    end
                elseif room.ooku == 0 and dist(big, ocko) <= 4 and random(100) < 1 then
                    room.ooku = 1
                    addv(10, "vl-v-silha")
                end
                if pom1 >= 0 then
                    if pom1 == 4 then
                        pom2 = 102
                    else
                        pom2 = 101
                    end
                    planDialogSet(30, "vl-leb-kecy"..pom1, pom2, lebkic, "cinnost")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_diamant3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        diamant3.faze = 0

        return function()
            switch(diamant3.faze){
                [0] = function()
                    if random(100) < 5 then
                        diamant3.faze = diamant3.faze + 1
                    end
                end,
                [7] = function()
                    diamant3.faze = 0
                end,
                default = function()
                    if isIn(diamant3.faze, {1, 2, 3}) then
                        diamant3.afaze = diamant3.afaze + 1
                        diamant3.faze = diamant3.faze + 1
                    elseif isIn(diamant3.faze, {4, 5, 6}) then
                        diamant3.afaze = diamant3.afaze - 1
                        diamant3.faze = diamant3.faze + 1
                    end
                end,
            }
            diamant3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ocko()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        ocko.cinnost = 0

        return function()
            if ocko.cinnost == 0 then
                if random(100) < 10 then
                    local rand8 = random(8)
                    switch(rand8){
                        [3] = function()
                            ocko.citac = random(3) + 2
                            ocko.cinnost = 2
                            ocko.faze = random(2) * 2
                        end,
                        [7] = function()
                            ocko.citac = random(10) + 2
                            ocko.cinnost = 5
                        end,
                        default = function()
                            if 0 <= rand8 and rand8 <= 2 then
                                ocko.citac = random(5) + 5
                                ocko.cinnost = 1
                                ocko.faze = random(2) * 2
                            elseif 4 <= rand8 and rand8 <= 6 then
                                ocko.citac = random(12) + 12
                                ocko.cinnost = 3 + random(2)
                            end
                        end
                    }
                end
            elseif ocko.cinnost == 1 or ocko.cinnost == 2 then
                switch(ocko.faze){
                    [0] = function()
                        if ocko.cinnost == 1 then
                            ocko.afaze = 1
                        else
                            ocko.afaze = 3
                        end
                        if random(100) < 20 then
                            ocko.faze = ocko.faze + 1
                        end
                    end,
                    [1] = function()
                        ocko.afaze = 0
                        ocko.faze = ocko.faze + 1
                    end,
                    [2] = function()
                        if ocko.cinnost == 1 then
                            ocko.afaze = 2
                        else
                            ocko.afaze = 4
                        end
                        if random(100) < 20 then
                            ocko.faze = ocko.faze + 1
                        end
                    end,
                    [3] = function()
                        ocko.afaze = 0
                        ocko.citac = ocko.citac - 1
                        if ocko.citac == 0 then
                            ocko.cinnost = 0
                        else
                            ocko.faze = 0
                        end
                    end,
                }
            elseif isIn(ocko.cinnost, {3, 4, 5}) then
                switch(ocko.cinnost){
                    [3] = function()
                        switch(ocko.afaze){
                            [0] = function()
                                ocko.afaze = random(4) + 1
                            end,
                            [1] = function()
                                ocko.afaze = 3
                            end,
                            [2] = function()
                                ocko.afaze = 4
                            end,
                            [3] = function()
                                ocko.afaze = 2
                            end,
                            [4] = function()
                                ocko.afaze = 1
                            end,
                        }
                    end,
                    [4] = function()
                        switch(ocko.afaze){
                            [0] = function()
                                ocko.afaze = random(4) + 1
                            end,
                            [1] = function()
                                ocko.afaze = 4
                            end,
                            [2] = function()
                                ocko.afaze = 3
                            end,
                            [3] = function()
                                ocko.afaze = 1
                            end,
                            [4] = function()
                                ocko.afaze = 2
                            end,
                        }
                    end,
                    [5] = function()
                        if random(100) < 40 then
                            ocko.afaze = random(5)
                        end
                    end,
                }
                ocko.citac = ocko.citac - 1
                if ocko.citac == 0 then
                    ocko.cinnost = 0
                    ocko.afaze = 0
                end
            end
            ocko:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_lebkic()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        lebkic.cinnost = 0

        return function()
            if odd(game_getCycles()) then
                switch(lebkic.cinnost){
                    [0] = function()
                        if random(100) < 3 then
                            lebkic.afaze = 1
                        else
                            lebkic.afaze = 0
                        end
                    end,
                    [101] = function()
                        lebkic.afaze = random(3)
                        if lebkic.afaze > 0 then
                            lebkic.afaze = lebkic.afaze + 1
                        end
                    end,
                    [102] = function()
                        lebkic.afaze = random(4)
                    end,
                }
            end
            lebkic:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_diamant1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        diamant1.faze = 0

        return function()
            switch(diamant1.faze){
                [0] = function()
                    if random(100) < 5 then
                        diamant1.faze = diamant1.faze + 1
                    end
                end,
                [7] = function()
                    diamant1.faze = 0
                end,
                default = function()
                    if isIn(diamant1.faze, {1, 2, 3}) then
                        diamant1.afaze = diamant1.afaze + 1
                        diamant1.faze = diamant1.faze + 1
                    elseif isIn(diamant1.faze, {4, 5, 6}) then
                        diamant1.afaze = diamant1.afaze - 1
                        diamant1.faze = diamant1.faze + 1
                    end
                end,
            }
            diamant1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hakahak()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hakahak.cinnost = 0

        return function()
            switch(hakahak.cinnost){
                [0] = function()
                    hakahak.afaze = 0
                end,
                [301] = function()
                    if hakahak.afaze == 0 or hakahak.afaze == 2 then
                        hakahak.afaze = 1
                    else
                        hakahak.afaze = random(2) * 2
                    end
                end,
            }
            hakahak:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_diamantv()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        diamantv.faze = 0

        return function()
            switch(diamantv.faze){
                [0] = function()
                    if random(100) < 10 then
                        if random(2) == 0 then
                            diamantv.faze = 1
                        else
                            diamantv.faze = 11
                        end
                    end
                end,
                [7] = function()
                    diamantv.faze = 0
                end,
                [12] = function()
                    diamantv.afaze = 5
                    diamantv.faze = diamantv.faze + 1
                end,
                [14] = function()
                    diamantv.afaze = 0
                    diamantv.faze = 0
                end,
                default = function()
                    if isIn(diamantv.faze, {1, 2, 3}) then
                        diamantv.afaze = diamantv.afaze + 1
                        diamantv.faze = diamantv.faze + 1
                    elseif isIn(diamantv.faze, {4, 5, 6}) then
                        diamantv.afaze = diamantv.afaze - 1
                        diamantv.faze = diamantv.faze + 1
                    elseif isIn(diamantv.faze, {11, 13}) then
                        diamantv.afaze = 4
                        diamantv.faze = diamantv.faze + 1
                    end
                end,
            }
            diamantv:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_diamant2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        diamant2.faze = 0

        return function()
            switch(diamant2.faze){
                [0] = function()
                    if random(100) < 5 then
                        diamant2.faze = diamant2.faze + 1
                    end
                end,
                [7] = function()
                    diamant2.faze = 0
                end,
                default = function()
                    if isIn(diamant2.faze, {1, 2, 3}) then
                        diamant2.afaze = diamant2.afaze + 1
                        diamant2.faze = diamant2.faze + 1
                    elseif isIn(diamant2.faze, {4, 5, 6}) then
                        diamant2.afaze = diamant2.afaze - 1
                        diamant2.faze = diamant2.faze + 1
                    end
                end,
            }
            diamant2:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_diamant3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ocko()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_lebkic()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_diamant1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hakahak()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_diamantv()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_diamant2()
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


