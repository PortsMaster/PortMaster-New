
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky10.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 1
        room.tahy = random(500) + 500
        room.opldovi = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.uvod == 1 then
                    room.uvod = 0
                    switch(pokus){
                        [1] = function()
                            pom1 = random(2) + 1
                        end,
                        [2] = function()
                            pom1 = random(2) + 1
                        end,
                        default = function()
                            pom1 = random(3)
                        end,
                    }
                    adddel(10 + random(20))
                    switch(pom1){
                        [1] = function()
                            if random(2) == 0 then
                                addm(0, "puc-m-koukej")
                            else
                                addv(0, "puc-v-podivej")
                            end
                        end,
                        [2] = function()
                            addv(0, "puc-v-videl")
                            addm(10, "puc-m-oblicej")
                        end,
                    }
                elseif room.opldovi == 0 and dist(small, pld) < 4 and look_at(small, pld) and random(100) < 1 then
                    room.opldovi = 1
                    switch(random(3)){
                        [0] = function()
                            addm(10, "puc-m-pld0")
                        end,
                        [1] = function()
                            addm(10, "puc-m-pld1")
                        end,
                        [2] = function()
                            addm(10, "puc-m-hele")
                        end,
                    }
                    addm(random(30) + 5, "puc-m-slizka")
                    planSet(pld, "smutny", 60 + random(60))
                    pld:planDialog(3, "puc-x-pldik")
                elseif room.tahy == 1 and big.dir ~= dir_no then
                    addv(10, "puc-v-fuska"..random(2))
                    room.tahy = random(500) + 500
                elseif prvni.hotovo == 1 then
                    addv(5, "puc-v-fuska2")
                    addm(random(10) + 3, "puc-m-stalo")
                    addm(random(20) + 5, "puc-m-obraz")
                    adddel(5)
                    planSet(prvni, "faze", 1)
                    addv(20, "puc-v-nesmysl")
                    prvni.hotovo = 2
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_prvni()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        prvni.hotovo = 0
        prvni.faze = 0
        local Items = {}
        Items[00] = prvni
        Items[01] = puzz02
        Items[02] = puzz03
        Items[03] = puzz04
        Items[04] = puzz05
        Items[05] = puzz06
        Items[06] = puzz07
        Items[07] = puzz08
        Items[08] = puzz09
        Items[09] = puzz10
        Items[10] = puzz11
        Items[11] = puzz12
        Items[12] = puzz13
        Items[13] = puzz14
        Items[14] = puzz15
        Items[15] = puzz16
        Items[16] = puzz17
        Items[17] = puzz18
        Items[18] = puzz19
        Items[19] = puzz20

        return function()
            pomb1 = true
            for pom1 = 0, 3 do
                for pom2 = 0, 4 do
                    local x_real, x_ideal, y_real, y_ideal
                    -- Ideal X position is (xposition in puzzle) * (width of one piece)
                    x_ideal = prvni.X + pom1 * 4
                    -- Index is pom1 + pom2 * (number of pieces in one row)
                    x_real  = (Items[pom1 + pom2 * 4]).X
                    y_ideal = prvni.Y - pom2 * 4
                    y_real  = (Items[pom1 + pom2 * 4]).Y
                    pomb1 = pomb1 and (x_ideal == x_real) and (y_ideal == y_real)
                end
            end
            if prvni.hotovo == 0 and pomb1 then
                prvni.hotovo = 1
            end
            for pom1 = 0, 19 do
                local puzz_item = Items[pom1]
                puzz_item.afaze = prvni.faze
                puzz_item:updateAnim()
            end

            if prvni.faze > 0 and prvni.faze < 4 then
                prvni.faze = prvni.faze + 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pld()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pld.vlnit = 0
        pld.del = 0
        pld.ocko = 0
        pld.smer = 0
        pld.faze = 0
        pld.smutny = 0

        return function()
            switch(pld.dir){
                [dir_no] = function()
                    if pld.vlnit == -1 then
                        pld.vlnit = 8
                    end
                end,
                [dir_down] = function()
                    pld.vlnit = -1
                end,
                default = function()
                    pld.vlnit = 8
                end,
            }
            if pld.vlnit > 0 then
                pld.smutny = 0
            end
            if pld.vlnit > 0 then
                if pld.del == 0 then
                    if (pld.vlnit >= 6) and (pld.vlnit <= 8) then
                        pld.del = 1
                    elseif (pld.vlnit >= 3) and (pld.vlnit <= 5) then
                        pld.del = 2
                    else
                        pld.del = 3
                    end

                    if random(2) == 0 then
                        pld.afaze = math.mod(pld.afaze + 1, 4)
                    else
                        pld.afaze = math.mod(pld.afaze + 3, 4)
                    end
                    pld.vlnit = pld.vlnit - 1
                    if pld.vlnit == 0 then
                        pld.del = 0
                    end
                    if pld.vlnit == 0 then
                        pld.afaze = 0
                    elseif pld.vlnit == 1 then
                        pld.afaze = 3
                    end
                else
                    pld.del = pld.del - 1
                end
            elseif pld.smutny > 0 then
                if pld.ocko == 0 then
                    if random(100) < 10 then
                        pld.ocko = 3
                    end
                end
                if pld.ocko > 0 then
                    pld.ocko = pld.ocko - 1
                end
                if pld.ocko > 0 then
                    pld.afaze = 15
                else
                    pld.afaze = 14
                end
                pld.smutny = pld.smutny - 1
            else
                if random(100) < 10 then
                    pld.smer = 1 - pld.smer
                end
                if (pld.faze == 0) then
                    pld.afaze = 0
                    if random(100) < 10 then
                        pld.faze = 1
                    end
                elseif (pld.faze == 1) or (pld.faze == 4) then
                    pld.faze = pld.faze + 1
                    pld.afaze = 4
                elseif (pld.faze == 2) or (pld.faze == 3) then
                    pld.faze = pld.faze + 1
                    pld.afaze = 5
                elseif (pld.faze == 5) then
                    pld.afaze = 0
                    pld.faze = 0
                end

                switch(pld.afaze){
                    [0] = function()
                        if pld.smer == 1 then
                            pld.afaze = 6
                        end
                    end,
                    [4] = function()
                        if pld.smer == 1 then
                            pld.afaze = 7
                        end
                    end,
                }
                if pld.ocko == 0 then
                    if random(100) < 10 then
                        pld.ocko = 3
                    end
                end
                if pld.ocko > 0 then
                    pld.ocko = pld.ocko - 1
                end
                if pld.ocko > 0 then
                    if pld.afaze == 0 then
                        pld.afaze = 9
                    else
                        pld.afaze = pld.afaze + 6
                    end
                end
            end
            pld:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        return function()
            if room.tahy > 1 and small.dir ~= dir_no and level_isNewRound() then
                room.tahy = room.tahy - 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        return function()
            if room.tahy > 1 and big.dir ~= dir_no and level_isNewRound() then
                room.tahy = room.tahy - 1
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
    subinit = prog_init_prvni()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pld()
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

