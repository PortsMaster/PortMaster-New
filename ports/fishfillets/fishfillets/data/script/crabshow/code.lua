
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

        room.uvod = 10 + random(10)
        room.poslvykrik = -1
        room.pocetvykriku = 0
        room.venku = 1
        room.obaloncich = random(20) + 40
        room.omeste = random(2)
        room.okrabech = 0
        room.osose = random(4000) + 3000
        if pokus > 1 and random(100) < 50 then
            room.opocitech = random(1500) + 1000
        else
            room.opocitech = -1
        end

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.uvod > 0 then
                    if cihla.X == cihla.XStart and cihla.Y == cihla.YStart then
                        room.uvod = room.uvod - 1
                    else
                        room.uvod = -1
                        room.venku = 0
                    end
                end
                if room.osose > 0 then
                    room.osose = room.osose - 1
                end
                if room.opocitech > 0 then
                    room.opocitech = room.opocitech - 1
                end
                if room.obaloncich > 0 then
                    if balon1.dir ~= dir_no or balon2.dir ~= dir_no or balon3.dir ~= dir_no or lbalon.dir ~= dir_no or rbalon.dir ~= dir_no then
                        room.obaloncich = room.obaloncich - 1
                    end
                end
                if room.uvod == 0 then
                    room.uvod = 100 + random(200)
                    room.pocetvykriku = room.pocetvykriku + 1
                    pom1 = random(2)
                    if pom1 == room.poslvykrik then
                        pom1 = 2
                    end
                    if isIn(room.pocetvykriku, {5, 11, 16}) then
                        pom1 = 3
                    end
                    room.poslvykrik = pom1
                    switch(pom1){
                        [3] = function()
                            addv(3, "sec-v-zavreny")
                            addm(10, "sec-m-kamen")
                        end,
                        default = function()
                            if 0 <= pom1 and pom1 <= 2 then
                                addv(3, "sec-v-ven"..pom1)
                            end
                        end,
                    }
                elseif room.venku == 0 then
                    room.venku = 1
                    addm(random(10) + 10, "sec-m-ven"..random(2))
                elseif room.obaloncich == 0 then
                    room.obaloncich = -1
                    addm(5, "sec-m-balonky")
                elseif room.omeste == 0 and random(3000) == 0 then
                    room.omeste = 1
                    addv(10, "sec-v-mesto")
                elseif room.okrabech == 0 and random(2000) == 0 then
                    room.okrabech = 1
                    addm(20, "sec-m-krab")
                    addv(10, "sec-v-ktery")
                    addm(5, "sec-m-dole"..random(2))
                    addv(5 + random(20), "sec-v-normalni"..random(2))
                elseif room.osose == 0 then
                    room.osose = -1
                    addv(40, "sec-v-socha")
                    addm(random(10) + 4, "sec-m-situace")
                    adddel(random(15) + 5)
                    planSet(drzka, "cinnost", 1)
                elseif room.opocitech == 0 then
                    room.opocitech = -1
                    addv(20, "sec-v-pocit")
                    addm(5, "sec-m-pocity")
                    addv(0, "sec-v-pockej")
                    addv(random(30) + 40, "sec-v-oci")
                    addm(4, "sec-m-program")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_drzka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        drzka.cinnost = 0
        drzka.afaze = 0

        return function()
            switch(drzka.cinnost){
                [1] = function()
                    setanim(drzka, "a5d2a10d11a11d4a10d4a11d4a10d4a11d4a10d?20-40a9")
                    drzka.cinnost = drzka.cinnost + 1
                end,
                [2] = function()
                    goanim(drzka)
                end,
            }
            drzka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_lbalon()
        return function()
            if lbalon.dir == dir_left then
                if lbalon.afaze == 0 then
                    lbalon.afaze = 3
                else
                    lbalon.afaze = lbalon.afaze - 1
                end
            elseif lbalon.dir == dir_right then
                if lbalon.afaze == 3 then
                    lbalon.afaze = 0
                else
                    lbalon.afaze = lbalon.afaze + 1
                end
            elseif lbalon.X == krab.X and lbalon.Y - 3 == krab.Y then
                if lbalon.afaze == 3 then
                    lbalon.afaze = 0
                else
                    lbalon.afaze = lbalon.afaze + 1
                end
                krab.beh = 1
            end
            lbalon:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_rbalon()
        return function()
            if rbalon.dir == dir_left then
                if rbalon.afaze == 0 then
                    rbalon.afaze = 3
                else
                    rbalon.afaze = rbalon.afaze - 1
                end
            elseif rbalon.dir == dir_right then
                if rbalon.afaze == 3 then
                    rbalon.afaze = 0
                else
                    rbalon.afaze = rbalon.afaze + 1
                end
            elseif rbalon.X - 5 == krab.X and rbalon.Y - 3 == krab.Y then
                if rbalon.afaze == 0 then
                    rbalon.afaze = 3
                else
                    rbalon.afaze = rbalon.afaze - 1
                end
                krab.beh = 1
            end
            rbalon:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_balon1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        balon1.pauza = random(200)

        return function()
            if balon1.dir == dir_left then
                if balon1.afaze == 0 then
                    balon1.afaze = 3
                else
                    balon1.afaze = balon1.afaze - 1
                end
            elseif balon1.dir == dir_right then
                if balon1.afaze == 3 then
                    balon1.afaze = 0
                else
                    balon1.afaze = balon1.afaze + 1
                end
            elseif balon1.pauza == 0 then
                balon1.pauza = random(320) - 60
            end
            if balon1.pauza < 0 then
                if balon1.afaze == 3 then
                    balon1.afaze = 0
                else
                    balon1.afaze = balon1.afaze + 1
                end
                balon1.pauza = balon1.pauza + 1
            else
                balon1.pauza = balon1.pauza - 1
            end
            balon1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_balon2()
        return function()
            if balon2.dir == dir_left then
                if balon2.afaze == 0 then
                    balon2.afaze = 3
                else
                    balon2.afaze = balon2.afaze - 1
                end
            elseif balon2.dir == dir_right then
                if balon2.afaze == 3 then
                    balon2.afaze = 0
                else
                    balon2.afaze = balon2.afaze + 1
                end
            end
            balon2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_balon3()
        return function()
            if balon3.dir == dir_left then
                if balon3.afaze == 0 then
                    balon3.afaze = 3
                else
                    balon3.afaze = balon3.afaze - 1
                end
            elseif balon3.dir == dir_right then
                if balon3.afaze == 3 then
                    balon3.afaze = 0
                else
                    balon3.afaze = balon3.afaze + 1
                end
            end
            balon3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava1()
        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava2()
        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava3()
        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab.beh = 0
        krab.oci = 1
        krab.voci = 1
        krab.mrac = 1
        krab.nohy = 1
        krab.afaze = 10

        return function()
            if krab.beh == 1 then
                if krab.nohy == 2 then
                    krab.nohy = 0
                else
                    krab.nohy = krab.nohy + 1
                end
                krab.beh = 0
            else
                krab.nohy = 1
            end
            if random(20) == 1 then
                krab.mrac = 1 - krab.mrac
            end
            if xdist(small, krab) == 0 and ydist(small, krab) <= 0 then
                if small.X < krab.X then
                    krab.oci = 0
                elseif small.X > krab.X + 3 then
                    krab.oci = 2
                else
                    krab.oci = 1
                end
            elseif xdist(big, krab) == 0 and ydist(big, krab) <= 0 then
                if big.X < krab.X - 1 then
                    krab.oci = 0
                elseif big.X > krab.X + 3 then
                    krab.oci = 2
                else
                    krab.oci = 1
                end
            elseif odd(game_getCycles()) then
                local rand11 = random(11)
                switch(rand11){
                    [6] = function()
                        if krab.voci == 0 then
                            krab.voci = 3
                        else
                            krab.voci = krab.voci - 1
                        end
                    end,
                    [9] = function()
                        krab.voci = random(4)
                    end,
                    default = function()
                        if 0 <= rand11 and rand11 <= 5 then
                            if krab.voci == 3 then
                                krab.voci = 0
                            else
                                krab.voci = krab.voci + 1
                            end
                        end
                    end,
                }
                if krab.voci == 3 then
                    krab.oci = 1
                else
                    krab.oci = krab.voci
                end
            end
            krab.afaze = krab.oci + krab.mrac * 3 + krab.nohy * 6
            krab:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_shrimp()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        shrimp.afaze = 4

        return function()
            if odd(game_getCycles()) then
                switch(krab.oci){
                    [0] = function()
                        shrimp.afaze = 2
                    end,
                    [2] = function()
                        shrimp.afaze = 0
                    end,
                    [1] = function()
                        switch(krab.voci){
                            [1] = function()
                                local rand10 = random(10)
                                switch(rand10){
                                    [0] = function()
                                        shrimp.afaze = 3
                                    end,
                                    default = function()
                                        if 1 <= rand10 and rand10 <= 6 then
                                            shrimp.afaze = 4
                                        else
                                            shrimp.afaze = 1
                                        end
                                    end,
                                }
                            end,
                            [3] = function()
                                local rand10 = random(10)
                                if 0 <= rand10 and rand10 <= 3 then
                                        shrimp.afaze = 3
                                elseif 4 <= rand10 and rand10 <= 9 then
                                    shrimp.afaze = 4
                                else
                                    shrimp.afaze = 1
                                end
                            end,
                            default = function()
                                switch(math.mod(game_getCycles(), 8)){
                                    [0] = function()
                                        shrimp.afaze = 1
                                    end,
                                    [1] = function()
                                        shrimp.afaze = 1
                                    end,
                                    [4] = function()
                                        shrimp.afaze = 3
                                    end,
                                    [5] = function()
                                        shrimp.afaze = 3
                                    end,
                                    default = function()
                                        shrimp.afaze = 4
                                    end,
                                }
                            end,
                        }
                    end,
                }
            end
            shrimp:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krabik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krabik.spi = 0
        krabik.afaze = 0

        return function()
            if odd(game_getCycles()) then
                if krabik.spi > 0 then
                    krabik.afaze = 1
                    krabik.spi = krabik.spi - 1
                else
                    switch(shrimp.afaze){
                        [0] = function()
                            krabik.afaze = 5
                        end,
                        [1] = function()
                            krabik.afaze = 2
                        end,
                        [2] = function()
                            krabik.afaze = 4
                        end,
                        [3] = function()
                            krabik.afaze = 3
                        end,
                        [4] = function()
                            krabik.afaze = 0
                        end,
                    }
                    if random(100) == 14 then
                        krabik.spi = random(30)
                    end
                end
            end
            krabik:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_drzka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_lbalon()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rbalon()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_balon1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_balon2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_balon3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_shrimp()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krabik()
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

