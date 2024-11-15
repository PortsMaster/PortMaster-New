
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

        room.vzperac = 0
        room.blbecek = 0
        room.neprojedu = 0
        room.orybe = 0
        room.kecy = 0
        room.potvurka = 0
        room.onetopyrovi = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if look_at(small, netopyr) and small.Y > 17 and small.Y < 22 and room.vzperac == 0 and (netopyr.afaze == 2 or netopyr.afaze == 3) and random(100) < 4 then
                    addm(random(20), "jes-m-netopyr")
                    addv(random(5), "jes-v-tojo")
                    room.vzperac = 1
                elseif look_at(small, blbec) and dist(small, blbec) < 3 and room.blbecek == 0 and random(100) < 2 then
                    addm(random(5), "jes-m-tvor")
                    room.blbecek = 1
                elseif big.X == 3 and big.Y == 15 and tycka.X == 10 and tycka.Y == 15 and room.neprojedu == 0 and random(100) < 3 then
                    addv(0, "jes-v-uzke")
                    room.neprojedu = 1
                elseif look_at(small, rybka) and tycka.X == 10 and tycka.Y == 17 and random(100) < 30 and room.orybe == 0 then
                    room.orybe = 1
                    addm(random(5), "jes-m-ryba")
                    addv(random(5), "jes-v-kamen")
                elseif random(1000) < 3 and room.kecy == 0 then
                    switch(random(3)){
                        [0] = function()
                            addv(random(5), "jes-v-gral")
                        end,
                        [1] = function()
                            addv(random(5), "jes-v-gral")
                            addm(random(5), "jes-m-deprese")
                        end,
                        [2] = function()
                            addv(random(5), "jes-v-gral")
                            addm(random(5), "jes-m-deprese")
                            addv(random(5), "jes-v-nevim")
                        end,
                    }
                    room.kecy = 1
                elseif room.kecy == 1 and big.Y > 19 and random(100) < 30 then
                    addm(random(5), "jes-m-takvidis")
                    room.kecy = 2
                elseif room.potvurka == 0 and random(100) < 5 and look_at(small, das) and dist(small, das) < 4 then
                    switch(random(3)){
                        [0] = function()
                            addm(1, "jes-m-potvora0")
                        end,
                        [1] = function()
                            addm(1, "jes-m-potvora1")
                        end,
                        [2] = function()
                            addm(1, "jes-m-potvora2")
                        end,
                    }
                    switch(random(3)){
                        [0] = function()
                            addv(random(5), "jes-v-potvora0")
                        end,
                        [1] = function()
                            addv(random(5), "jes-v-potvora1")
                        end,
                        [2] = function()
                            addv(random(5), "jes-v-potvora2")
                        end,
                    }
                    room.potvurka = 1
                elseif room.onetopyrovi == 0 and look_at(small, netopyr) and dist(small, netopyr) < 4 and random(1000) < 2 then
                    room.onetopyrovi = 1
                    addm(1, "jes-m-netopyr0")
                    switch(random(3)){
                        [0] = function()
                            addv(random(5), "jes-v-netopyr0")
                        end,
                        [1] = function()
                            addv(random(5), "jes-v-netopyr1")
                        end,
                        [2] = function()
                            addv(random(5), "jes-v-netopyr2")
                        end,
                    }
                    switch(random(3)){
                        [0] = function()
                            addm(random(5), "jes-m-netopyr1")
                        end,
                        [1] = function()
                            addm(random(5), "jes-m-netopyr2")
                        end,
                        [2] = function()
                            addm(random(5), "jes-m-netopyr3")
                        end,
                    }
                elseif room.potvurka == 1 and das.X == 17 and das.Y == 7 and random(1000) < 4 then
                    switch(random(2)){
                        [0] = function()
                            addv(random(5), "jes-v-nechut0")
                        end,
                        [1] = function()
                            addv(random(5), "jes-v-nechut1")
                        end,
                    }
                    room.potvurka = 2
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_netopyr()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        netopyr.kridla = -(1 * (random(200) + 20))
        netopyr.oci = 0
        netopyr.vzpira = 0

        return function()
            if netopyr.oci == 0 and random(100) < 30 then
                netopyr.oci = 1
            elseif random(100) < 60 then
                netopyr.oci = 0
            end
            if tycka.X == 10 and tycka.Y == 15 and vaza.X == 18 and vaza.Y == 16 and netopyr.X == 18 and netopyr.Y == 19 then
                if netopyr.kridla < 0 then
                    netopyr.kridla = netopyr.kridla + 1
                elseif netopyr.kridla == 0 and netopyr.vzpira < 7 and tycka.X == 10 and tycka.Y == 15 and vaza.X == 18 and vaza.Y == 16 and netopyr.X == 18 and netopyr.Y == 19 then
                    netopyr.afaze = netopyr.oci + 2
                    netopyr.vzpira = netopyr.vzpira + 1
                elseif netopyr.vzpira >= 7 and netopyr.kridla == 0 then
                    netopyr.vzpira = 0
                    netopyr.kridla = -(1 * (random(300) + 5))
                    netopyr.afaze = netopyr.oci
                end
            else
                netopyr.afaze = netopyr.oci
            end
            netopyr:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_tycka()
        return function()
            if netopyr.afaze == 2 or netopyr.afaze == 3 then
                tycka.afaze = 1
            else
                tycka.afaze = 0
            end
            tycka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_das()
        return function()
            switch(das.afaze){
                [1] = function()
                    if random(100) < 10 then
                        das.afaze = 6
                    else
                        das.afaze = das.afaze + 1
                    end
                end,
                [5] = function()
                    das.afaze = 0
                end,
                [8] = function()
                    das.afaze = 5
                end,
                default = function()
                    das.afaze = das.afaze + 1
                end,
            }
            das:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_blbec()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        blbec.faze = 0
        blbec.udivenej = 0

        return function()
            if math.mod(game_getCycles(), 2) == 0 then
                switch(blbec.faze){
                    [0] = function()
                        blbec.faze = blbec.faze + 1
                    end,
                    [1] = function()
                        blbec.faze = blbec.faze + 1
                    end,
                    [2] = function()
                        blbec.faze = 0
                    end,
                }
            end
            if blbec.dir ~= dir_no then
                blbec.udivenej = random(100) + 30
            end
            if blbec.udivenej > 0 then
                blbec.udivenej = blbec.udivenej - 1
                if random(100) < 20 then
                    blbec.afaze = 3 * blbec.faze + 1
                else
                    blbec.afaze = 3 * blbec.faze + 2
                end
            else
                blbec.afaze = 3 * blbec.faze
            end
            blbec:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_rybka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rybka.faze = -random(200) - 100

        return function()
            switch(rybka.faze){
                [1] = function()
                    rybka.afaze = 2
                    if random(100) < 25 then
                        rybka.faze = rybka.faze + 1
                    end
                end,
                [2] = function()
                    rybka.afaze = 1
                    rybka.faze = rybka.faze + 1
                end,
                [3] = function()
                    rybka.afaze = 3
                    if random(100) < 25 then
                        rybka.faze = rybka.faze + 1
                    end
                end,
                [4] = function()
                    rybka.afaze = 1
                    if random(100) < 15 then
                        rybka.faze = 1
                    else
                        rybka.faze = -random(200) - 100
                    end
                end,
                default = function()
                    if rybka.faze >= -10 and rybka.faze <= 0 then
                        rybka.afaze = 1
                        rybka.faze = rybka.faze + 1
                    else
                        rybka.afaze = 0
                        rybka.faze = rybka.faze + 1
                    end
                end
            }
            rybka:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vaza()
        return function()
            if netopyr.afaze == 2 or netopyr.afaze == 3 then
                vaza.afaze = 1
            else
                vaza.afaze = 0
            end
            vaza:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_netopyr()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_tycka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_das()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_blbec()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rybka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_vaza()
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

