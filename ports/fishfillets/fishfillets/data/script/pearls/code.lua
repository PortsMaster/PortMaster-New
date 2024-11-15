
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky04.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.fofr = randint(300, 1500)
        room.jestejednu = randint(500, 5000)
        room.flakat = 0
        room.otyci = randint(500, 3000)
        room.kleopatra = randint(300, 1000)
        room.opoteru = randint(600, 1200)

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.jestejednu > 0 then
                    room.jestejednu = room.jestejednu - 1
                end
                if room.jestejednu < -1 and room.jestejednu > -60 then
                    room.jestejednu = room.jestejednu + 1
                end
                if room.jestejednu < -60 and room.jestejednu > -120 then
                    room.jestejednu = room.jestejednu + 1
                end
                if room.otyci > 0 then
                    room.otyci = room.otyci - 1
                end
                if room.kleopatra > 0 then
                    room.kleopatra = room.kleopatra - 1
                end
                if room.opoteru > 0 then
                    room.opoteru = room.opoteru - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    addm(random(200) + 10, "jed-m-libi")
                    switch(random(2)){
                        [0] = function()
                            addm(random(5), "jed-m-perly0")
                        end,
                        [1] = function()
                            addm(random(5), "jed-m-perly1")
                        end,
                    }
                    switch(random(7)){
                        [0] = function()
                            addv(random(5), "jed-v-poslani0")
                        end,
                        [1] = function()
                            addv(random(5), "jed-v-poslani0")
                        end,
                        [2] = function()
                            addv(random(5), "jed-v-poslani1")
                        end,
                        [3] = function()
                            addv(random(5), "jed-v-poslani1")
                        end,
                        [4] = function()
                            addv(random(5), "jed-v-poslani2")
                        end,
                        [5] = function()
                            addv(random(5), "jed-v-poslani2")
                        end,
                    }
                elseif room.fofr <= small.fofr and room.flakat == 0 then
                    room.flakat = 1
                    addm(1, "jed-m-flakas")
                    switch(random(2)){
                        [0] = function()
                            addv(random(5), "jed-v-uzivat0")
                        end,
                        [1] = function()
                            addv(random(5), "jed-v-uzivat1")
                        end,
                    }
                elseif room.jestejednu == 0 and dist(small, zeva) < 3 and look_at(small, zeva) and random(100) < 5 then
                    room.jestejednu = -1 * (random(40) + 20)
                    addm(1, "jed-m-perlorodka0")
                    planDialogSet(randint(1, 20), "jed-x-nedam", 101, zeva, "cinnost")
                elseif dist(small, zeva) < 3 and look_at(small, zeva) and room.jestejednu == -1 then
                    room.jestejednu = -1 * (random(40) + 80)
                    addm(1, "jed-m-perlorodka1")
                    planDialogSet(randint(1, 20), "jed-x-nedam", 101, zeva, "cinnost")
                elseif dist(small, zeva) < 3 and look_at(small, zeva) and room.jestejednu == -60 then
                    room.jestejednu = random(10000) + 10000
                    addm(1, "jed-m-perlorodka2")
                    planDialogSet(randint(1, 20), "jed-x-nedam", 102, zeva, "cinnost")
                elseif room.otyci == 0 and room.flakat == 1 then
                    addm(random(5), "jed-m-trubka")
                    room.otyci = -1
                elseif room.kleopatra == 0 then
                    addv(random(10), "jed-v-ocet")
                    addm(random(4), "jed-m-moc")
                    addv(random(5), "jed-v-vzdelat")
                    room.kleopatra = -1
                elseif room.opoteru == 0 then
                    addv(random(10), "jed-v-poter")
                    if random(100) < 60 then
                        addm(random(5), "jed-m-kulicka")
                    end
                    room.opoteru = -1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        small.fofr = 0

        return function()
            if small.dir ~= dir_no and level_isNewRound() then
                small.fofr = small.fofr + 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_zeva()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        zeva.cinnost = 0
        zeva.pocet = 0

        return function()
            if zeva.cinnost == 0 and random(1000) < 10 then
                zeva.faze = 1
                if random(100) < 25 and zeva.pocet > 3 then
                    zeva.cinnost = 2
                else
                    zeva.cinnost = 1
                end
                zeva.pocet = zeva.pocet + 1
            end
            switch(zeva.cinnost){
                [1] = function()
                    switch(zeva.faze){
                        [1] = function()
                            zeva.afaze = 1
                            zeva.faze = zeva.faze + 1
                        end,
                        [2] = function()
                            zeva.afaze = 2
                            zeva.delay = random(10)
                            zeva.faze = zeva.faze + 1
                        end,
                        [3] = function()
                            if zeva.delay > 0 then
                                zeva.delay = zeva.delay - 1
                            else
                                zeva.afaze = 1
                                zeva.faze = zeva.faze + 1
                            end
                        end,
                        [4] = function()
                            zeva.cinnost = 0
                            zeva.afaze = 0
                        end,
                    }
                end,
                [2] = function()
                    switch(zeva.faze){
                        [1] = function()
                            zeva.afaze = 3
                            zeva.faze = zeva.faze + 1
                        end,
                        [2] = function()
                            zeva.afaze = 4
                            zeva.delay = 20 + random(100)
                            zeva.faze = zeva.faze + 1
                        end,
                        [3] = function()
                            if zeva.delay > 0 then
                                if random(100) < 3 then
                                    zeva.faze = 10
                                else
                                    zeva.delay = zeva.delay - 1
                                end
                            else
                                zeva.afaze = 1
                                zeva.faze = zeva.faze + 1
                            end
                        end,
                        [4] = function()
                            zeva.cinnost = 0
                            zeva.afaze = 0
                        end,
                        [16] = function()
                            zeva.afaze = 4
                            zeva.faze = 3
                        end,
                        default = function()
                            if zeva.faze == 10 or zeva.faze == 15 then
                                zeva.afaze = 5
                                zeva.faze = zeva.faze + 1
                            elseif zeva.faze == 11 or zeva.faze == 14 then
                                zeva.afaze = 6
                                zeva.faze = zeva.faze + 1
                            elseif zeva.faze == 12 or zeva.faze == 13 then
                                zeva.afaze = 7
                                zeva.faze = zeva.faze + 1
                            end
                        end
                    }
                end,
                [101] = function()
                    zeva.faze = 1
                    zeva.cinnost = 1
                end,
                [102] = function()
                    zeva.faze = 1
                    zeva.cinnost = 2
                end,
            }
            zeva:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_perla1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.globpole = {}
        for pom1 = 0, 11 do
            room.globpole[pom1] = -random(50) - 10
        end

        return function()
            for pom1 = 0, 11 do
                room.globpole[pom1] = room.globpole[pom1] + 1
                if isIn(room.globpole[pom1], {0, 5}) then
                    pom2 = 1
                elseif isIn(room.globpole[pom1], {1, 4}) then
                    pom2 = 2
                elseif isIn(room.globpole[pom1], {2, 3}) then
                    pom2 = 3
                elseif room.globpole[pom1] == 6 then
                    pom2 = 0
                    room.globpole[pom1] = -random(50) - 10
                else
                    pom2 = 0
                end
                getModelsTable()[perla1.index + pom1].afaze = pom2
                getModelsTable()[perla1.index + pom1]:updateAnim()
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
    subinit = prog_init_small()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_zeva()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_perla1()
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

