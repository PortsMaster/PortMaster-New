
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky03.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.sas = 0
        room.kuk = 0
        room.okoralech = 0
        room.obarvach = 0
        room.neprojedes = 0
        room.mohlabys = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(random(1)){
                        [0] = function()
                            addm(20 + random(30), "ncp-m-tesno0")
                        end,
                        [1] = function()
                            addm(20 + random(30), "ncp-m-tesno1")
                        end,
                    }
                    if random(100) < 30 then
                        addv(random(8), "ncp-v-dostala")
                    end
                elseif look_at(small, sasanka) and dist(small, sasanka) < 3 and room.sas == 0 and random(100) < 20 then
                    addv(random(5), "ncp-v-sasanka")
                    room.sas = 1
                elseif look_at(small, konik) and konik.afaze == 3 and dist(small, konik) < 4 and room.kuk == 0 then
                    addm(random(5), "ncp-m-nekoukej")
                    room.kuk = 1
                elseif (koral1.dir ~= dir_no or koral2.dir ~= dir_no or koral3.dir ~= dir_no or koral0.dir ~= dir_no) and room.okoralech == 0 and random(100) < 2 then
                    room.okoralech = 1
                    if big.dir ~= dir_no then
                        addv(0, "ncp-v-mekky")
                    else
                        switch(random(5)){
                            [4] = function()
                                addm(0, "ncp-m-komari")
                                addv(random(3), "ncp-v-ceho")
                                addm(random(3), "ncp-m-koraly")
                            end,
                            default = function()
                                addm(0, "ncp-m-tvrdy")
                            end,
                        }
                    end
                elseif big.X == 4 and big.Y == 29 and room.neprojedes == 0 and random(100) < 10 then
                    addv(random(3), "ncp-v-neprojedu")
                    room.neprojedes = 1
                elseif room.obarvach == 0 and random(10000) < 5 then
                    room.obarvach = 1
                    addm(random(10), "ncp-m-barvy")
                elseif valec.X == 3 and valec.Y == 34 and room.mohlabys == 0 then
                    room.mohlabys = 1
                    addv(random(3), "ncp-v-tak")
                    if random(100) < 80 then
                        addm(random(10), "ncp-m-muzes")
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sasanka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sasanka.cinnost = 0
        sasanka.noha = 0
        sasanka.kvet = 1
        sasanka.akcnost = 1

        return function()
            if sasanka.cinnost ~= 5 and (dist(small, sasanka) < 3 or dist(big, sasanka) < 3) then
                sasanka.cinnost = 5
                sasanka.counts = random(10) + 15
                sasanka.akcnost = 1
            end
            if sasanka.cinnost == 0 then
                sasanka.cinnost = random(4) + 1
                sasanka.fazec = 0
                sasanka.akcnost = 2 + random(2)
            end
            if math.mod(game_getCycles(), sasanka.akcnost) == 0 then
                cinnost_table = {
                    [1] = function()
                        sasanka.noha = math.floor(sasanka.fazec / 4)
                        if sasanka.cinnost == 1 then
                            sasanka.kvet = math.mod(sasanka.fazec, 2) + 1
                            sasanka.akcnost = 2
                            if sasanka.kvet == 2 then
                                sasanka:talk("ncp-x-tup", VOLUME_FULL)
                            end
                        else
                            sasanka.kvet = math.mod(sasanka.fazec, 2) * 2 + 1
                            sasanka.akcnost = 3
                        end
                        sasanka.fazec = sasanka.fazec + 1
                        if sasanka.fazec == 8 then
                            if random(100) < 30 then
                                sasanka.cinnost = 0
                            else
                                sasanka.fazec = 0
                            end
                        end
                    end,
                    [3] = function()
                        switch(sasanka.fazec){
                            [0] = function()
                                sasanka.counts = random(10) + 7
                                sasanka.fazec = sasanka.fazec + 1
                                sasanka.kvet = 1
                            end,
                            [1] = function()
                                sasanka.noha = 1 - sasanka.noha
                                sasanka.counts = sasanka.counts - 1
                                if sasanka.counts == 0 then
                                    sasanka.fazec = sasanka.fazec + 1
                                end
                            end,
                            [2] = function()
                                if sasanka.cinnost == 3 then
                                    sasanka.kvet = 0
                                    sasanka.counts = random(8) + 5
                                else
                                    sasanka.kvet = 3
                                    sasanka.counts = random(6) + 3
                                end
                                sasanka.fazec = sasanka.fazec + 1
                            end,
                            [3] = function()
                                sasanka.counts = sasanka.counts - 1
                                if sasanka.counts == 0 then
                                    if random(100) < 30 then
                                        sasanka.cinnost = 0
                                    else
                                        sasanka.fazec = 0
                                    end
                                end
                            end,
                        }
                    end,
                    [5] = function()
                        sasanka.akcnost = 2
                        sasanka.counts = sasanka.counts - 1
                        switch(sasanka.counts){
                            [0] = function()
                                sasanka.cinnost = 0
                            end,
                            [1] = function()
                                sasanka.kvet = 1
                                sasanka.noha = 1 - sasanka.noha
                            end,
                            default = function()
                                sasanka.kvet = 0
                            end,
                        }
                    end,
                }

                cinnost_table[2] = cinnost_table[1]
                cinnost_table[4] = cinnost_table[3]
                switch(sasanka.cinnost)(cinnost_table)
            end
            sasanka.afaze = sasanka.noha * 4 + sasanka.kvet
            sasanka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snek()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snek.stav = 0

        return function()
            switch(snek.stav){
                [0] = function()
                    if snek.dir ~= dir_no then
                        snek.stav = 1
                    end
                end,
                [1] = function()
                    snek.afaze = 3
                    snek.stav = snek.stav + 1
                end,
                [2] = function()
                    snek.afaze = 1
                    snek.stav = snek.stav + 1
                end,
                [3] = function()
                    snek.afaze = 2
                    if snek.dir == dir_no then
                        snek.stav = 4
                        snek.count = 20
                    end
                end,
                [4] = function()
                    snek.count = snek.count - 1
                    if snek.count == 0 then
                        snek.stav = 5
                        snek.count = 5
                    end
                    if snek.dir ~= dir_no then
                        snek.stav = 2
                    end
                end,
                [5] = function()
                    snek.afaze = 1
                    snek.count = snek.count - 1
                    if snek.count == 0 then
                        snek.afaze = 0
                        snek.stav = 0
                    end
                    if snek.dir ~= dir_no then
                        snek.stav = 1
                    end
                end,
            }
            snek:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local small_boring = 0
        local small_smile = 4
        local xicht = 0

        return function()
            if small:getAction() == "rest" then
                small_boring = small_boring + 1
            else
                small_boring = 0
            end
            if small_boring >= 15 and small_boring < 40 and look_at(small, konik) and ydist(small, konik) == 0 and xdist(small, konik) < 3 then
                if xicht ~= small_smile then
                    xicht = small_smile
                    konik.stav = 7
                end
            else
                xicht = 0
            end
            if xicht ~= 0 then
                small:useSpecialAnim("head_all", xicht)
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local big_boring = 0
        local xicht = 0
        return function()
            if big:getAction() == "rest" then
                big_boring = big_boring + 1
            else
                big_boring = 0
            end
            if big_boring >= 15 and big_boring < 40 and look_at(big, konik) and ydist(big, konik) == 0 and xdist(big, konik) < 3 then
                if xicht ~= 6 then
                    xicht = 6
                    konik.stav = 7
                end
            else
                xicht = 0
            end
            if xicht ~= 0 then
                big:useSpecialAnim("head_all", xicht)
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_konik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        konik.stav = 0
        konik.mrkani = 0

        return function()
            if konik.stav ~= 2 and konik.dir == dir_down then
                konik:talk("ncp-x-ihaha", VOLUME_FULL)
            end
            if konik.dir == dir_down or elko.dir == dir_down then
                konik.stav = 2
            elseif konik.stav == 2 then
                konik.stav = 0
            end
            switch(konik.stav){
                [0] = function()
                    pom1 = 15
                    if look_at(small, konik) and math.abs(xdist(small, konik)) <= 3 and math.abs(ydist(small, konik)) <= 1 then
                        pom1 = 0
                    end
                    if look_at(big, konik) and math.abs(xdist(big, konik)) <= 3 and math.abs(ydist(big, konik)) <= 1 then
                        pom1 = 0
                    end
                    if random(100) < pom1 then
                        konik.stav = 1
                        konik.mrkani = 0
                    end
                    konik.afaze = 0
                end,
                [2] = function()
                    konik.afaze = 3
                end,
                [6] = function()
                    konik.stav = 10
                    konik.mrkani = 10
                end,
                [7] = function()
                    konik.mrkani = 10
                    konik.stav = 8
                end,
                [8] = function()
                    konik.mrkani = konik.mrkani - 1
                    if konik.mrkani == 0 then
                        konik.stav = 3
                    end
                end,
                [10] = function()
                    if konik.mrkani > 0 then
                        konik.mrkani = konik.mrkani - 1
                    else
                        konik.stav = 11
                    end
                end,
                [11] = function()
                    konik.afaze = 3
                    konik.mrkani = random(10) + 10
                    konik.stav = konik.stav + 1
                end,
                [12] = function()
                    if konik.mrkani > 0 then
                        konik.mrkani = konik.mrkani - 1
                    else
                        konik.afaze = 0
                        konik.stav = 0
                    end
                end,
                default = function()
                    if isIn(konik.stav, {1, 3, 4, 5}) then
                        switch(konik.mrkani){
                            [0] = function()
                                konik.afaze = 2
                            end,
                            [1] = function()
                                konik.afaze = 1
                                konik:talk("ncp-x-tik", VOLUME_FULL)
                            end,
                            [2] = function()
                                konik.afaze = 2
                            end,
                            [3] = function()
                                konik.afaze = 0
                                konik.mrkani = -1
                                if konik.stav == 1 then
                                    konik.stav = 0
                                else
                                    konik.stav = konik.stav + 1
                                end
                            end,
                        }
                        konik.mrkani = konik.mrkani + 1
                    end
                end,
            }
            konik:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sasanka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snek()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_small()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_big()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_konik()
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

