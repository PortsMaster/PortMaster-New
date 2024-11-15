
local function isOneOf(models, x, y)
    for key, model in pairs(models) do
        if modelEquals(model, x, y) then
            return true
        end
    end
    return false
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()
    local windflowers = {}
    table.insert(windflowers, sas1)
    table.insert(windflowers, sas2)
    table.insert(windflowers, sas3)
    table.insert(windflowers, sas4)
    table.insert(windflowers, sas5)
    table.insert(windflowers, sas6)

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.quvod = random(20) + 20
        room.qhlaska = random(100) + 100
        room.pouzito = {}
        room.vydrz = random(2) + 2
        room.komentovaly = 0
        room.kreseni = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() and (balalajka.cinnost == 0 or balalajka.cinnost > 70) then
                if room.quvod > 0 then
                    room.quvod = room.quvod - 1
                end
                if balalajka.hrala > 0 then
                    room.quvod = -1
                end
                if room.qhlaska > 0 then
                    room.qhlaska = room.qhlaska - 1
                end
                if room.komentovaly < balalajka.hrala then
                    --TODO: getRestartCount cannot be changed
                    if pokus < 1000 then
                        pokus = pokus + 1000
                    end
                    room.komentovaly = balalajka.hrala
                    if room.komentovaly <= room.vydrz then
                        switch(random(4)){
                            [2] = function()
                                addv(0, "kor-v-odvaz")
                            end,
                            [3] = function()
                                addm(6, "kor-m-vsimlsis")
                                addv(2, "kor-v-avidelas")
                                addm(4, "kor-m-tovis")
                            end,
                            default = function()
                                if random(2) == 1 then
                                    addv(6, "kor-v-juchacka")
                                else
                                    addv(6, "kor-v-vali")
                                end
                                switch(random(3)){
                                    [0] = function()
                                        addm(3, "kor-m-hraje")
                                    end,
                                    [1] = function()
                                        addm(3, "kor-m-nachob")
                                    end,
                                }
                            end,
                        }
                    else
                        pom1 = random(6)
                        for pom2 = 1, 2 do
                            if pom2 == 1 and isIn(pom1, {0, 1, 4}) and random(3) == 0 or pom2 == 2 and pom1 == 5 then
                                switch(random(2)){
                                    [0] = function()
                                        addm(5, "kor-m-jinou")
                                    end,
                                    [1] = function()
                                        addm(5, "kor-m-neprehani")
                                    end,
                                }
                            elseif pom2 == 1 and pom1 <= 1 then
                                addm(5, "kor-m-lezekrkem")
                            end
                            if pom2 == 1 and isIn(pom1, {2, 3, 5}) or pom2 == 2 and pom1 == 4 then
                                switch(random(2)){
                                    [0] = function()
                                        addv(5, "kor-v-lezekrkem")
                                    end,
                                    [1] = function()
                                        addv(5, "kor-v-kostice")
                                    end,
                                }
                            end
                        end
                    end
                elseif room.kreseni == 0 and big.X >= 30 and big.Y == 5 and elko.X == 30 then
                    room.kreseni = room.kreseni + 1
                    addv(5, "kor-v-odsud")
                    addm(8, "kor-m-budesmuset")
                elseif room.kreseni == 1 and isWater(10, 6) and isWater(23, 6) then
                    room.kreseni = room.kreseni + 1
                elseif room.kreseni == 2 and (isOneOf(windflowers, 10, 6) or isOneOf(windflowers, 23, 6)) then
                    room.kreseni = room.kreseni + 1
                    addm(10, "kor-m-neniono")
                    addm(20, "kor-m-tudiru")
                elseif room.qhlaska == 0 then
                    room.qhlaska = random(600) + 200
                    pom1 = random(6)
                    if not room.pouzito[pom1] then
                        switch(pom1){
                            [0] = function()
                                addm(10, "kor-m-dusi")
                            end,
                            [1] = function()
                                addm(10, "kor-m-pocit")
                            end,
                            [2] = function()
                                addm(10, "kor-m-bizarni")
                            end,
                            [3] = function()
                                addv(10, "kor-v-bermudy")
                            end,
                            [4] = function()
                                addv(10, "kor-v-inteligentni")
                            end,
                            [5] = function()
                                addv(10, "kor-v-jedovate")
                            end,
                        }
                    end
                    room.pouzito[pom1] = true
                elseif room.quvod == 0 then
                    --TODO: getRestartCount cannot be changed
                    if 1 <= pokus and pokus <= 1000 then
                        room.quvod = random(2) + 1
                    elseif 1001 <= pokus and pokus <= 2000 then
                        room.quvod = 3
                        pokus = pokus + 1000
                    else
                        room.quvod = random(4)
                    end
                    if room.quvod == 0 or room.quvod == 1 then
                        addv(10, "kor-v-podivej")
                        addm(2, "kor-m-vzdyt")
                        addv(6, "kor-v-treba")
                    elseif room.quvod == 2 or room.quvod == 3 then
                        addm(10, "kor-m-podivej")
                        addv(5, "kor-v-spitu")
                        if random(100) < 40 then
                            addm(2, "kor-m-avlada")
                        end
                        addv(10, "kor-v-nicje")
                        if room.quvod == 3 then
                            addm(5, "kor-m-pokud")
                        end
                    end
                    room.quvod = -1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab1.krabfaze = 1
        krab1.cekat = 0

        return function()
            if room:isTalking() then
                switch(math.mod(game_getCycles(), 4)){
                    [0] = function()
                        krab1.krabfaze = 7
                    end,
                    [1] = function()
                        krab1.krabfaze = 7
                    end,
                    default = function()
                        krab1.krabfaze = 9
                    end,
                }
            elseif krab1.krabfaze <= 2 then
                krab1.krabfaze = 1
            else
                krab1.krabfaze = 2
            end
            if krab1.krabfaze == 2 then
                krab1.cekat = random(70) + 30
            end
            if krab1.krabfaze <= 2 then
                if krab1.cekat == 0 then
                    krab1.afaze = 1
                else
                    krab1.afaze = 0
                    krab1.cekat = krab1.cekat - 1
                end
            elseif not isWater(krab1.X, krab1.Y + 1) and not isWater(krab1.X + 1, krab1.Y + 1) then
                krab1.afaze = krab1.krabfaze
            elseif random(100) < 50 then
                krab1.afaze = random(4) + 2
            end
            krab1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_balalajka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        balalajka.cinnost = 0
        balalajka.hrala = 0
        balalajka.tcatcat = random(15) + 10

        return function()
            if balalajka.dir ~= dir_no and balalajka.cinnost == 0 then
                balalajka.cinnost = balalajka.cinnost + 1
            end
            switch(balalajka.cinnost){
                [0] = function()
                    local cycle = math.mod(game_getCycles(), 18)
                    switch(cycle){
                        [0] = function()
                            if balalajka.tcatcat == 0 then
                                balalajka:talk("kor-chob-tca", VOLUME_FULL)
                                balalajka.tcatcat = random(15) + 10
                            else
                                balalajka:talk("kor-chob-psi", VOLUME_FULL)
                                balalajka.tcatcat = balalajka.tcatcat - 1
                            end
                        end,
                        [11] = function()
                            balalajka:talk("kor-chob-chro", VOLUME_FULL)
                        end,
                        default = function()
                            if 1 <= cycle and cycle <= 10 then
                                balalajka.afaze = 0
                            else
                                balalajka.afaze = 1
                            end
                        end,
                    }
                end,
                [1] = function()
                    balalajka.hrala = balalajka.hrala + 1
                    game_killPlan()
                    balalajka.afaze = 2
                    balalajka:killSound()
                end,
                [6] = function()
                    balalajka.afaze = 3
                end,
                [10] = function()
                    balalajka.afaze = 4
                end,
                [13] = function()
                    balalajka.afaze = 3
                end,
                [15] = function()
                    balalajka.afaze = 4
                end,
                [17] = function()
                    balalajka.afaze = 5
                end,
                [19] = function()
                    room:talk("kor-room-music", VOLUME_LOW)
                end,
                [83] = function()
                    balalajka.afaze = 5
                end,
                [90] = function()
                    balalajka.cinnost = 0
                end,
                default = function()
                    if isIn(balalajka.cinnost, {21, 23, 25, 27}) then
                        balalajka.afaze = 6
                    elseif isIn(balalajka.cinnost, {22, 24, 26, 28}) then
                        if random(100) < 10 then
                            balalajka.afaze = 7
                        else
                            balalajka.afaze = 8
                        end
                    elseif isIn(balalajka.cinnost, {29, 31, 33, 35}) then
                        balalajka.afaze = 9
                    elseif isIn(balalajka.cinnost, {30, 32, 34, 36}) then
                        balalajka.afaze = 10
                    end
                end,
            }
            if balalajka.cinnost > 20 and balalajka.cinnost < 80 and not room:isTalking() then
                balalajka.cinnost = 80
            elseif balalajka.cinnost == 36 then
                balalajka.cinnost = 21
            elseif balalajka.cinnost > 0 then
                balalajka.cinnost = balalajka.cinnost + 1
            end
            balalajka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sas1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sas1.sasfaze = -1
        sas1.kvet = random(2) * 2 + 1
        sas1.noha = random(2)

        return function()
            if room:isTalking() then
                local cycle = math.mod(game_getCycles(), 8)
                if isIn(cycle, {0, 1, 2, 3}) then
                    pom1 = 0
                else
                    pom1 = 1
                end
                if isIn(cycle, {0, 3, 4, 7}) then
                    pom2 = 2
                else
                    pom2 = 1
                end
                sas1.sasfaze = pom1 * 4 + pom2
            else
                sas1.sasfaze = -1
            end
            if isWater(sas1.X + 1, sas1.Y - 1) or modelEquals(room, sas1.X + 1, sas1.Y - 1) then
                if sas1.sasfaze >= 0 then
                    sas1.afaze = sas1.sasfaze
                else
                    if math.mod(game_getCycles(), 3) == 0 and random(100) < 50 then
                        sas1.kvet = random(2) * 2 + 1
                    end
                    if math.mod(game_getCycles(), 4) == 0 and random(100) < 30 then
                        sas1.noha = random(2)
                    end
                    sas1.afaze = sas1.noha * 4 + sas1.kvet
                end
            else
                sas1.afaze = 0
            end
            sas1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sas2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sas2.kvet = random(2) * 2 + 1
        sas2.noha = random(2)

        return function()
            if isWater(sas2.X + 1, sas2.Y - 1) or modelEquals(room, sas2.X + 1, sas2.Y - 1) then
                if sas1.sasfaze >= 0 then
                    sas2.afaze = sas1.sasfaze
                else
                    if math.mod(game_getCycles(), 3) == 0 and random(100) < 50 then
                        sas2.kvet = random(2) * 2 + 1
                    end
                    if math.mod(game_getCycles(), 4) == 0 and random(100) < 30 then
                        sas2.noha = random(2)
                    end
                    sas2.afaze = sas2.noha * 4 + sas2.kvet
                end
            else
                sas2.afaze = 0
            end
            sas2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sas3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sas3.kvet = random(2) * 2 + 1
        sas3.noha = random(2)

        return function()
            if isWater(sas3.X + 1, sas3.Y - 1) or modelEquals(room, sas3.X + 1, sas3.Y - 1) then
                if sas1.sasfaze >= 0 then
                    sas3.afaze = sas1.sasfaze
                else
                    if math.mod(game_getCycles(), 3) == 0 and random(100) < 50 then
                        sas3.kvet = random(2) * 2 + 1
                    end
                    if math.mod(game_getCycles(), 4) == 0 and random(100) < 30 then
                        sas3.noha = random(2)
                    end
                    sas3.afaze = sas3.noha * 4 + sas3.kvet
                end
            else
                sas3.afaze = 0
            end
            sas3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sas4()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sas4.kvet = random(2) * 2 + 1
        sas4.noha = random(2)

        return function()
            if isWater(sas4.X + 1, sas4.Y - 1) or modelEquals(room, sas4.X + 1, sas4.Y - 1) then
                if sas1.sasfaze >= 0 then
                    sas4.afaze = sas1.sasfaze
                else
                    if math.mod(game_getCycles(), 3) == 0 and random(100) < 50 then
                        sas4.kvet = random(2) * 2 + 1
                    end
                    if math.mod(game_getCycles(), 4) == 0 and random(100) < 30 then
                        sas4.noha = random(2)
                    end
                    sas4.afaze = sas4.noha * 4 + sas4.kvet
                end
            else
                sas4.afaze = 0
            end
            sas4:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sas5()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sas5.kvet = random(2) * 2 + 1
        sas5.noha = random(2)

        return function()
            if isWater(sas5.X + 1, sas5.Y - 1) or modelEquals(room, sas5.X + 1, sas5.Y - 1) then
                if sas1.sasfaze >= 0 then
                    sas5.afaze = sas1.sasfaze
                else
                    if math.mod(game_getCycles(), 3) == 0 and random(100) < 50 then
                        sas5.kvet = random(2) * 2 + 1
                    end
                    if math.mod(game_getCycles(), 4) == 0 and random(100) < 30 then
                        sas5.noha = random(2)
                    end
                    sas5.afaze = sas5.noha * 4 + sas5.kvet
                end
            else
                sas5.afaze = 0
            end
            sas5:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sas6()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sas6.kvet = random(2) * 2 + 1
        sas6.noha = random(2)

        return function()
            if isWater(sas6.X + 1, sas6.Y - 1) or modelEquals(room, sas6.X + 1, sas6.Y - 1) then
                if sas1.sasfaze >= 0 then
                    sas6.afaze = sas1.sasfaze
                else
                    if math.mod(game_getCycles(), 3) == 0 and random(100) < 50 then
                        sas6.kvet = random(2) * 2 + 1
                    end
                    if math.mod(game_getCycles(), 4) == 0 and random(100) < 30 then
                        sas6.noha = random(2)
                    end
                    sas6.afaze = sas6.noha * 4 + sas6.kvet
                end
            else
                sas6.afaze = 0
            end
            sas6:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab2.cekat = 0

        return function()
            if krab1.krabfaze == 2 then
                krab2.cekat = random(70) + 30
            end
            if krab1.krabfaze <= 2 then
                if krab2.cekat == 0 then
                    krab2.afaze = 1
                else
                    krab2.afaze = 0
                    krab2.cekat = krab2.cekat - 1
                end
            elseif not isWater(krab2.X, krab2.Y + 1) and not isWater(krab2.X + 1, krab2.Y + 1) then
                krab2.afaze = krab1.krabfaze
            elseif random(100) < 50 then
                krab2.afaze = random(4) + 2
            end
            krab2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab3.cekat = 0

        return function()
            if krab1.krabfaze == 2 then
                krab3.cekat = random(70) + 30
            end
            if krab1.krabfaze <= 2 then
                if krab3.cekat == 0 then
                    krab3.afaze = 1
                else
                    krab3.afaze = 0
                    krab3.cekat = krab3.cekat - 1
                end
            elseif not isWater(krab3.X, krab3.Y + 1) and not isWater(krab3.X + 1, krab3.Y + 1) then
                krab3.afaze = krab1.krabfaze
            elseif random(100) < 50 then
                krab3.afaze = random(4) + 2
            end
            krab3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab4()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab4.cekat = 0

        return function()
            if krab1.krabfaze == 2 then
                krab4.cekat = random(70) + 30
            end
            if krab1.krabfaze <= 2 then
                if krab4.cekat == 0 then
                    krab4.afaze = 1
                else
                    krab4.afaze = 0
                    krab4.cekat = krab4.cekat - 1
                end
            elseif not isWater(krab4.X, krab4.Y + 1) and not isWater(krab4.X + 1, krab4.Y + 1) then
                krab4.afaze = krab1.krabfaze
            elseif random(100) < 50 then
                krab4.afaze = random(4) + 2
            end
            krab4:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab5()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab5.cekat = 0

        return function()
            if krab1.krabfaze == 2 then
                krab5.cekat = random(70) + 30
            end
            if krab1.krabfaze <= 2 then
                if krab5.cekat == 0 then
                    krab5.afaze = 1
                else
                    krab5.afaze = 0
                    krab5.cekat = krab5.cekat - 1
                end
            elseif not isWater(krab5.X, krab5.Y + 1) and not isWater(krab5.X + 1, krab5.Y + 1) then
                krab5.afaze = krab1.krabfaze
            elseif random(100) < 50 then
                krab5.afaze = random(4) + 2
            end
            krab5:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab6()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab6.cekat = 0

        return function()
            if krab1.krabfaze == 2 then
                krab6.cekat = random(70) + 30
            end
            if krab1.krabfaze <= 2 then
                if krab6.cekat == 0 then
                    krab6.afaze = 1
                else
                    krab6.afaze = 0
                    krab6.cekat = krab6.cekat - 1
                end
            elseif not isWater(krab6.X, krab6.Y + 1) and not isWater(krab6.X + 1, krab6.Y + 1) then
                krab6.afaze = krab1.krabfaze
            elseif random(100) < 50 then
                krab6.afaze = random(4) + 2
            end
            krab6:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sepie()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sepie.mrk = 0
        sepie.nohy = 0

        return function()
            pomb1 = sepie.dir == dir_down
            pomb2 = isWater(sepie.X, sepie.Y + 1) and isWater(sepie.X + 1, sepie.Y + 1) and not isWater(sepie.X + 2, sepie.Y + 3)
            if sepie.mrk > 0 then
                sepie.mrk = sepie.mrk - 1
            elseif random(100) < 15 then
                sepie.mrk = random(3) + 2
            end
            if pomb1 or not pomb2 then
                if odd(game_getCycles()) then
                    sepie.nohy = math.mod(sepie.nohy + 2 + random(2) * 2, 3)
                end
                sepie.afaze = sepie.nohy
                if pomb1 then
                    sepie.afaze = sepie.nohy + 3
                elseif sepie.mrk > 0 then
                    sepie.afaze = sepie.nohy + 6
                else
                    sepie.afaze = sepie.nohy
                end
            else
                if sepie.dir == dir_left or sepie.dir == dir_right then
                    sepie.nohy = math.mod(sepie.nohy + 1, 2)
                else
                    sepie.nohy = 0
                end
                if sepie.mrk > 0 then
                    sepie.afaze = 2 * sepie.nohy + 10
                else
                    sepie.afaze = 2 * sepie.nohy + 9
                end
            end
            sepie:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_balalajka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sas1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sas2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sas3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sas4()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sas5()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sas6()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab4()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab5()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab6()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sepie()
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

