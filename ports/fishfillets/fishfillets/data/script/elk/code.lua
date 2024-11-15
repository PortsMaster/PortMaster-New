
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky09.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.olosech = 0
        room.poslhlaska = 0
        room.dalsihlaska = random(300) + 50
        room.pochlasek = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(pokus){
                        [1] = function()
                            pom1 = 2
                        end,
                        [2] = function()
                            pom1 = 1
                        end,
                        default = function()
                            pom1 = random(3)
                        end,
                    }
                    adddel(10 + random(20))
                    if pom1 >= 1 then
                        addm(0, "deu-m-valka")
                        addv(10, "deu-v-nepratelstvi")
                    end
                    if pom1 >= 2 then
                        addm(random(20) + 5, "deu-m-bojovat")
                        addv(3, "deu-v-losa")
                    end
                elseif room.olosech == 0 and dist(small, loos) <= 2 and random(100) < 3 then
                    room.olosech = 1
                    switch(pokus){
                        [1] = function()
                            pom1 = 1
                        end,
                        [2] = function()
                            pom1 = 2
                        end,
                        default = function()
                            pom1 = random(3)
                        end,
                    }
                    switch(pom1){
                        [1] = function()
                            addv(10, "deu-v-radsi")
                            planDialogSet(random(10) + 5, "deu-l-pozalsta", 101, loos, "cinnost")
                            planDialogSet(0, "deu-p-schnell", 111, papouch, "cinnost")
                        end,
                        [2] = function()
                            addm(10, "deu-m-zvlastni")
                            addv(8, "deu-v-slysel")
                            planDialogSet(10, "deu-l-los", 101, loos, "cinnost")
                            planSet(loos, "cinnost", 30)
                        end,
                    }
                end
            end
            if no_dialog() then
                if room.dalsihlaska > 0 then
                    room.dalsihlaska = room.dalsihlaska - 1
                end
                if room.dalsihlaska == 0 then
                    room.pochlasek = room.pochlasek + 1
                    room.dalsihlaska = random(300) + room.pochlasek * 30
                    pom1 = random(2)
                    if pom1 == room.poslhlaska then
                        pom1 = 2
                    end
                    room.poslhlaska = pom1
                    switch(pom1){
                        [0] = function()
                            if random(2) == 0 then
                                planDialogSet(20, "deu-p-trinken"..random(2), 111, papouch, "cinnost")
                            else
                                planDialogSet(20, "deu-p-los", 111, papouch, "cinnost")
                                planDialogSet(random(20) + 5, "deu-l-los"..random(2), 101, loos, "cinnost")
                            end
                        end,
                        [1] = function()
                            switch(random(6)){
                                [0] = function()
                                    planDialogSet(20, "deu-p-schnell", 111, papouch, "cinnost")
                                end,
                                [1] = function()
                                    planDialogSet(20, "deu-p-jawohl", 111, papouch, "cinnost")
                                end,
                                [2] = function()
                                    planDialogSet(20, "deu-p-stimmt", 111, papouch, "cinnost")
                                end,
                                [3] = function()
                                    planDialogSet(20, "deu-p-streng", 111, papouch, "cinnost")
                                end,
                                [4] = function()
                                    planDialogSet(20, "deu-p-ordnung", 111, papouch, "cinnost")
                                end,
                                [5] = function()
                                    planDialogSet(20, "deu-p-skoll", 111, papouch, "cinnost")
                                end,
                            }
                        end,
                        [2] = function()
                            switch(random(6)){
                                [0] = function()
                                    planDialogSet(20, "deu-l-ja", 101, loos, "cinnost")
                                end,
                                [1] = function()
                                    planDialogSet(20, "deu-l-neznaju", 101, loos, "cinnost")
                                end,
                                [2] = function()
                                    planDialogSet(20, "deu-l-nesmotrel", 101, loos, "cinnost")
                                end,
                                [3] = function()
                                    planDialogSet(20, "deu-l-zivjot", 101, loos, "cinnost")
                                    planSet(loos, "cinnost", 30)
                                end,
                                [4] = function()
                                    planDialogSet(20, "deu-l-necital", 101, loos, "cinnost")
                                end,
                                [5] = function()
                                    planDialogSet(20, "deu-l-tovarisci", 101, loos, "cinnost")
                                    planSet(loos, "cinnost", 30)
                                end,
                            }
                        end,
                    }
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_papouch()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        papouch.cinnost = 0

        return function()
            switch(papouch.cinnost){
                [111] = function()
                    papouch.afaze = random(2)
                end,
            }

            papouch:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snecik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snecik.kouka = 0

        return function()
            if snecik.dir ~= dir_no then
                snecik.kouka = random(100) + 10
            elseif snecik.kouka > 0 then
                snecik.kouka = snecik.kouka - 1
            end
            if snecik.kouka > 0 then
                if snecik.afaze < 2 then
                    snecik.afaze = snecik.afaze + 1
                end
            elseif snecik.afaze > 0 then
                snecik.afaze = snecik.afaze - 1
            end

            snecik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_loos()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        loos.cinnost = 0

        return function()
            pomb1 = math.mod(game_getCycles(), 3) == 0
            switch(loos.cinnost){
                [0] = function()
                    loos.afaze = 3
                    if random(1000) < 3 then
                        loos.cinnost = 1
                    end
                end,
                [1] = function()
                    if pomb1 then
                        if random(100) < 5 then
                            loos.afaze = 3
                        else
                            loos.afaze = 0
                        end
                    end
                    if random(1000) < 2 then
                        loos.cinnost = 0
                    end
                end,
                [10] = function()
                    setanim(loos, "a3d3a4a5a6a7d2a6a5a4a3")
                    loos.cinnost = 11
                end,
                [11] = function()
                    goanim(loos)
                    if anim == "" then
                        if random(100) < 30 then
                            loos.cinnost = 10
                        else
                            loos.cinnost = 0
                        end
                    end
                end,
                [20] = function()
                    setanim(loos, "a3d5a4d1a5d1a6d1a7d12a6d1a5d1a4d1a3")
                    loos.cinnost = 21
                end,
                [21] = function()
                    goanim(loos)
                    if anim == "" then
                        loos.cinnost = 0
                    end
                end,
                [30] = function()
                    loos.cinnost = random(2) * 10 + 10
                end,
                [101] = function()
                    if pomb1 then
                        pom1 = random(2)
                        if pom1 == loos.afaze then
                            pom1 = 2
                        end
                        if pom1 == 0 and random(100) < 8 then
                            loos.afaze = 3
                        else
                            loos.afaze = pom1
                        end
                    end
                end,
            }

            loos:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_papouch()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snecik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_loos()
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

