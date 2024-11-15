
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()
    local roompole = createArray(3)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room:setEffect("zx")
        room.pocitadlo = 0
        room.uvod = 0
        room.nekdy = 100 + random(5000)
        room.pixely = 0
        room.hra = 0
        room.lore = 0
        room.premyslis = 0
        room.load = 0
        room.opakovani = 0
        room.tlaci = 0
        room.skladat = 0
        room.miner = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.nekdy > 0 then
                    room.nekdy = room.nekdy - 1
                end
                room.pocitadlo = room.pocitadlo + 1
                if room.uvod == 0 then
                    room.uvod = 1
                    switch(pokus){
                        [1] = function()
                            pom1 = 1
                        end,
                        [2] = function()
                            pom1 = 2
                        end,
                        default = function()
                            pom1 = random(2) + 1
                        end,
                    }
                    if pom1 == 1 then
                        addm(random(42) + 9, "zx-m-pametnici")
                        if pokus < 5 + random(5) or random(100) < 50 then
                            addv(15, "zx-v-osmibit")
                        end
                    else
                        addv(random(42) + 9, "zx-v-roboti")
                        addm(9, "zx-m-highway")
                    end
                elseif room.pixely == 0 and room.nekdy == 0 then
                    room.pixely = 1
                    addm(9, "zx-m-pixel")
                    if random(100) < 40 and room.hra == 0 then
                        room.hra = 1
                        addv(5, "zx-v-hry")
                    end
                elseif room.hra == 0 and big.dir ~= dir_no and jet.dir ~= dir_no then
                    room.hra = 1
                    addv(20 + random(50), "zx-v-hry")
                elseif room.premyslis == 0 and big.nehybe_se > 90 and room.pocitadlo > 500 + random(200) then
                    room.premyslis = 1
                    addm(0, "zx-m-premyslis")
                    if room.hra == 0 and random(100) < 25 then
                        addv(4, "zx-v-hry")
                        room.hra = 1
                    else
                        pom1 = random(6)
                        if pom1 < 5 then
                            addv(12, "zx-v-pamet")
                        end
                        if pom1 > 1 then
                            addv(5 + random(4), "zx-v-otazka")
                        end
                        if random(5) > 0 then
                            addm(10 + random(4), "zx-m-necodosebe")
                        end
                    end
                elseif room.lore == 0 and dist(knightik, small) < 5 and isIn(small.Y, {2, 3, 4}) and not small:isLeft() and random(100) < 20 then
                    room.lore = 1
                    addm(9 * random(2), "zx-m-knight")
                elseif room.load < 4 and room.pocitadlo > 400 + 200 * room.load + random(200) then
                    room.load = room.load + 1
                    if room.load == 1 then
                        addv(0, "zx-v-nahravani")
                    elseif random(2) == 0 then
                        addv(0, "zx-v-nahravani")
                    end
                elseif room.tlaci == 0 and small.dir ~= dir_no and small:getState() == "pushing" and small.tlacit_jeste == 0 then
                    room.tlaci = 1
                    addm(5, "zx-m-ocel")
                elseif room.skladat == 0 and roompole[2] < 2 and (jet1.dir ~= dir_no or jet2.dir ~= dir_no or jet3.dir ~= dir_no) and small.dir ~= dir_no and random(8) == 0 then
                    if pokus > 2 and random(100) < 60 then
                        room.skladat = 1
                    else
                        room.skladat = 1
                        roompole[2] = roompole[2] + 1
                        addm(9, "zx-m-jetpack")
                    end
                elseif room.miner == 0 and big.dir == dir_no and dist(manic, big) < 6 and random(100) < 8 then
                    if pokus > 3 and random(100) < 10 + 50 * roompole[1] then
                        room.miner = 1
                    else
                        roompole[1] = 1
                        room.miner = 1
                        addv(5, "zx-v-manicminer")
                    end
                end
            else
                room.pocitadlo = 0
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_knightik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        knightik.stav = 0
        knightik.poc = random(200) + 100

        return function()
            stav_table = {
                [0] = function()
                    if knightik.poc > 0 then
                        knightik.poc = knightik.poc - 1
                    else
                        knightik.stav = knightik.stav + 1
                        knightik.poc = 42
                    end
                end,
                [1] = function()
                    if knightik.poc == 0 then
                        if knightik.stav == 3 then
                            knightik.stav = 0
                        else
                            knightik.stav = 2
                        end
                        knightik.afaze = knightik.stav * 3
                        knightik.poc = 300 - knightik.stav * 50
                    else
                        knightik.poc = knightik.poc - 1
                        if math.mod(knightik.poc, 3) == 2 then
                            knightik.afaze = random(4) + 2
                        end
                    end
                end,
                [5] = function()
                    knightik.stav = knightik.stav + 1
                end,
                [9] = function()
                    knightik.stav = 0
                    knightik.afaze = 0
                end,
            }

            stav_table[2] = stav_table[0]

            stav_table[1] = stav_table[3]

            stav_table[6] = stav_table[5]
            stav_table[7] = stav_table[5]
            stav_table[8] = stav_table[5]
            switch(knightik.stav)(stav_table)
            if knightik.stav == 0 and random(100) == 14 then
                knightik.stav = 5
                knightik.afaze = 1
            end
            knightik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_trubys()
        return function()
            if trubys.afaze == 3 then
                trubys.afaze = 0
            else
                trubys.afaze = trubys.afaze + 1
            end
            trubys:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.nehybe_se = 0

        return function()
            if big.dir ~= dir_no then
                big.nehybe_se = 0
            else
                big.nehybe_se = big.nehybe_se + 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        small.tlacit_jeste = 20 + random(80)

        return function()
            if small.dir ~= dir_no and small.tlacit_jeste > 0 and small:getState() == "pushing" then
                small.tlacit_jeste = small.tlacit_jeste - 1
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
    subinit = prog_init_knightik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_trubys()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_big()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_small()
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

