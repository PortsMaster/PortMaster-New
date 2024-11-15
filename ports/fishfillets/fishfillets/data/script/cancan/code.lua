
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.druh = 1

    end

    -- -------------------------------------------------------------
    local function prog_init_krab1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab1.ceka = 10
        krab1.krok = 0

        return function()
            krab1.muze = 0
            krab2.muze = 0
            krab3.muze = 0
            krab4.muze = 0
            if krab2.Y == krab1.Y and dist(krab1, krab2) == 1 then
                krab1.muze = 1
                krab2.muze = 1
            end
            if krab3.Y == krab1.Y and dist(krab1, krab3) == 1 then
                krab1.muze = 1
                krab3.muze = 1
            end
            if krab4.Y == krab1.Y and dist(krab1, krab4) == 1 then
                krab1.muze = 1
                krab4.muze = 1
            end
            if krab3.Y == krab2.Y and dist(krab2, krab3) == 1 then
                krab2.muze = 1
                krab3.muze = 1
            end
            if krab4.Y == krab2.Y and dist(krab2, krab4) == 1 then
                krab2.muze = 1
                krab4.muze = 1
            end
            if krab4.Y == krab3.Y and dist(krab3, krab4) == 1 then
                krab3.muze = 1
                krab4.muze = 1
            end
            if math.mod(game_getCycles(), 2) == 0 then
                if krab1.krok == 7 then
                    krab1.krok = 0
                else
                    krab1.krok = krab1.krok + 1
                end
            end
            if krab1.ceka > 0 then
                krab1.ceka = krab1.ceka - 1
            end
            if krab1.dir ~= dir_no or not klavir:isTalking() then
                krab1.ceka = 20
            end
            if krab1.muze == 1 and krab1.ceka == 0 and klavir:isTalking() then
                if room.druh == 0 then
                    if isIn(krab1.krok, {1, 3, 5, 7}) then
                        krab1.afaze = 7
                    elseif isIn(krab1.krok, {2, 4, 6, 0})then
                        krab1.afaze = 9
                    end
                else
                    switch(krab1.krok){
                        [0] = function()
                            krab1.afaze = 6
                        end,
                        [2] = function()
                            krab1.afaze = 7
                        end,
                        [4] = function()
                            krab1.afaze = 8
                        end,
                        [6] = function()
                            krab1.afaze = 9
                        end,
                        default = function()
                            krab1.afaze = 0
                        end,
                    }
                end
            elseif krab1.afaze > 5 or math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                krab1.afaze = random(6)
            end
            krab1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab2.ceka = 20

        return function()
            if krab2.ceka > 0 then
                krab2.ceka = krab2.ceka - 1
            end
            if krab2.dir ~= dir_no or not klavir:isTalking() then
                krab2.ceka = 20
            end
            if krab2.muze == 1 and krab2.ceka == 0 and klavir:isTalking() then
                if room.druh == 0 then
                    if isIn(krab1.krok, {1, 3, 5, 7}) then
                        krab2.afaze = 7
                    elseif isIn(krab1.krok, {2, 4, 6, 0})then
                        krab2.afaze = 9
                    end
                else
                    switch(krab1.krok){
                        [0] = function()
                            krab2.afaze = 6
                        end,
                        [2] = function()
                            krab2.afaze = 7
                        end,
                        [4] = function()
                            krab2.afaze = 8
                        end,
                        [6] = function()
                            krab2.afaze = 9
                        end,
                        default = function()
                            krab2.afaze = 0
                        end,
                    }
                end
            elseif krab2.afaze > 5 or math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                krab2.afaze = random(6)
            end
            krab2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab3.ceka = 30

        return function()
            if krab3.ceka > 0 then
                krab3.ceka = krab3.ceka - 1
            end
            if krab3.dir ~= dir_no or not klavir:isTalking() then
                krab3.ceka = 20
            end
            if krab3.muze == 1 and krab3.ceka == 0 and klavir:isTalking() then
                if room.druh == 0 then
                    if isIn(krab1.krok, {1, 3, 5, 7}) then
                        krab3.afaze = 7
                    elseif isIn(krab1.krok, {2, 4, 6, 0})then
                        krab3.afaze = 9
                    end
                else
                    switch(krab1.krok){
                        [0] = function()
                            krab3.afaze = 6
                        end,
                        [2] = function()
                            krab3.afaze = 7
                        end,
                        [4] = function()
                            krab3.afaze = 8
                        end,
                        [6] = function()
                            krab3.afaze = 9
                        end,
                        default = function()
                            krab3.afaze = 0
                        end,
                    }
                end
            elseif krab3.afaze > 5 or math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                krab3.afaze = random(6)
            end
            krab3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab4()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab4.ceka = 40

        return function()
            if krab4.ceka > 0 then
                krab4.ceka = krab4.ceka - 1
            end
            if krab4.dir ~= dir_no or not klavir:isTalking() then
                krab4.ceka = 20
            end
            if krab4.muze == 1 and krab4.ceka == 0 and klavir:isTalking() then
                if room.druh == 0 then
                    if isIn(krab1.krok, {1, 3, 5, 7}) then
                        krab4.afaze = 7
                    elseif isIn(krab1.krok, {2, 4, 6, 0})then
                        krab4.afaze = 9
                    end
                else
                    switch(krab1.krok){
                        [0] = function()
                            krab4.afaze = 6
                        end,
                        [2] = function()
                            krab4.afaze = 7
                        end,
                        [4] = function()
                            krab4.afaze = 8
                        end,
                        [6] = function()
                            krab4.afaze = 9
                        end,
                        default = function()
                            krab4.afaze = 0
                        end,
                    }
                end
            elseif krab4.afaze > 5 or math.mod(game_getCycles(), 3) == 0 and random(100) < 40 then
                krab4.afaze = random(6)
            end
            krab4:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_klavir()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        klavir.ruce = 0
        klavir.otocka = -random(100) - 100
        klavir.vyruseni = 0

        return function()
            if klavir.dir ~= dir_no then
                klavir:killSound()
                klavir.vyruseni = 20 + random(25)
            end
            if klavir.vyruseni > 0 then
                if no_dialog() then
                    klavir.vyruseni = klavir.vyruseni - 1
                    if klavir.vyruseni == 0 then
                        klavir:talk("kan-klavir-music", VOLUME_LOW, -1)
                    end
                end
                if random(100) < 3 then
                    klavir.afaze = 8
                else
                    klavir.afaze = 6
                end
            else
                if not klavir:isTalking() then
                    klavir:talk("kan-klavir-music", VOLUME_LOW, -1)
                end
                if klavir.otocka > 0 and klavir.mrknuti > 0 then
                    if klavir.ruce == 0 then
                        klavir.ruce = 2
                    elseif klavir.ruce == 2 then
                        klavir.ruce = 0
                    else
                        klavir.ruce = random(2) * 2
                    end
                    klavir.afaze = 8 + math.floor(klavir.ruce / 2)
                    klavir.mrknuti = klavir.mrknuti - 1
                    klavir.otocka = klavir.otocka - 1
                else
                    klavir.ruce = math.mod(klavir.ruce + random(3) + 1, 4)
                    if klavir.otocka > 0 then
                        klavir.afaze = 4 + klavir.ruce
                        if random(100) < 7 then
                            klavir.mrknuti = 1 + random(4)
                        end
                        klavir.otocka = klavir.otocka - 1
                    else
                        klavir.afaze = klavir.ruce
                        klavir.otocka = klavir.otocka + 1
                        if klavir.otocka == 0 then
                            klavir.otocka = random(10) + 50
                            klavir.mrknuti = 0
                        end
                    end
                end
                if klavir.otocka == 0 then
                    klavir.otocka = -random(300) - 150
                end
            end
            klavir:updateAnim()
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
                if sepie.dir == dir_left or sepie.dir == dir_down then
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

    -- -------------------------------------------------------------
    local function prog_init_rejnok()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rejnok.pozice = 0
        rejnok.nespi = 0

        return function()
            if math.mod(game_getCycles(), 2) == 0 or rejnok.nespi > 20 then
                if rejnok.pozice == 5 then
                    rejnok.pozice = 0
                else
                    rejnok.pozice = rejnok.pozice + 1
                end
                if rejnok.dir ~= dir_no then
                    rejnok.nespi = random(60) + 20
                end
                if rejnok.nespi > 0 then
                    if random(100) < 13 then
                        rejnok.afaze = rejnok.pozice
                    else
                        rejnok.afaze = rejnok.pozice + 6
                    end
                    rejnok.nespi = rejnok.nespi - 1
                else
                    rejnok.afaze = rejnok.pozice
                end
            end
            rejnok:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sasanka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sasanka.noha = 0
        sasanka.kvet = 0

        return function()
            if isWater(sasanka.X, sasanka.Y - 1) then
                local cycle = math.mod(game_getCycles(), 8)
                if isIn(cycle, {0, 1, 2, 3}) then
                    sasanka.noha = 0
                else
                    sasanka.noha = 1
                end
                if isIn(cycle, {0, 3, 4, 7}) then
                    sasanka.kvet = 1
                else
                    sasanka.kvet = 0
                end
                sasanka.afaze = sasanka.noha * 4 + sasanka.kvet + 1
            else
                sasanka.afaze = 1
            end
            sasanka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.ptalnyni = 0

        return function()
            if big.ptalnyni == 1 and klavir:isTalking() then
                big.ptalnyni = 0
            elseif big.ptalnyni == 0 and not klavir:isTalking() and random(1000) < 15 then
                big.ptalnyni = 1
                addv(3, "kan-v-proc")
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
    subinit = prog_init_krab1()
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
    subinit = prog_init_klavir()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sepie()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rejnok()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sasanka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_big()
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

