
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky07.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(2)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.cas = random(100) + 10
        room.zakaz = 0

        return function()
            pom2 = 99
            if no_dialog() and isReady(small) and isReady(big) then
                if room.cas > 0 then
                    room.cas = room.cas - 1
                else
                    room.cas = random(1000) + 600
                    pom1 = roompole[1]
                    if math.mod(pom1, 4) == 2 then
                        if room.zakaz == 1 then
                            pom1 = pom1 + 1
                        end
                    end
                    pom2 = math.mod(pom1, 4)
                    pom1 = pom1 + 1
                    pom1 = math.mod(pom1, 4)
                    roompole[1] = pom1
                end
            end
            switch(pom2){
                [0] = function()
                    addm(7, "kni-m-svicny")
                    if pokus < 3 or random(3) > 0 then
                        addv(7, "kni-v-ber")
                    end
                end,
                [1] = function()
                    addv(7, "kni-v-prolezt")
                    addm(7, "kni-m-tloustka")
                    addv(7, "kni-v-padavko")
                    addm(7, "kni-m-hromado")
                    adddel(7)
                    planBusy(big, true)
                    addv(1, "kni-v-vypni")
                    planBusy(big, false)
                end,
                [2] = function()
                    addm(7, "kni-m-hrncirstvi")
                    addv(7, "kni-v-amforstvi")
                    addm(7, "kni-m-amfornictvi")
                end,
                [3] = function()
                    addm(7, "kni-m-mise")
                    addv(7, "kni-v-proc")
                    addm(7, "kni-m-cetky")
                    adddel(14)
                    planBusy(small, true)
                    addm(1, "kni-m-kramy")
                    planBusy(small, false)
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_universal()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        universal.co = 0
        universal.kdo = 0
        local treasures = {}
        for i = 0, 2 do
            treasures[i] = getModelsTable()[universal.index + i]
        end

        return function()
            if universal.co == 0 then
                switch(random(10)){
                    [1] = function()
                        universal.co = 1
                    end,
                    [2] = function()
                        universal.co = 8
                    end,
                }
                if universal.co ~= 0 then
                    universal.kdo = random(3)
                end
            elseif isRange(universal.co, 1, 3) then
                treasures[universal.kdo].afaze = universal.co
                universal.co = universal.co + 1
            elseif isRange(universal.co, 4, 6) then
                treasures[universal.kdo].afaze = 7 - universal.co
                universal.co = universal.co + 1
            elseif isRange(universal.co, 8, 9) then
                treasures[universal.kdo].afaze = universal.co - 4
                universal.co = universal.co + 1
            elseif isRange(universal.co, 10, 11) then
                treasures[universal.kdo].afaze = 15 - universal.co
                universal.co = universal.co + 1
            else
                treasures[universal.kdo].afaze = 0
                universal.co = 0
            end
            treasures[universal.kdo]:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        return function()
            if big.Y < 18 then
                room.zakaz = 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pc2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pc2.stav = 0

        return function()
            if pc2.stav > 0 then
                pc2.stav = pc2.stav - 1
            else
                pc2.stav = random(300) + 50
            end
            if isRange(pc2.stav, 2, 3) then
                pc2.afaze = pc2.afaze - 1
            elseif isRange(pc2.stav, 6, 7) then
                pc2.afaze = pc2.afaze + 1
            elseif pc2.stav == 8 then
                if random(2) == 1 then
                    pc2.afaze = 0
                else
                    pc2.afaze = 3
                end
            end
            pc2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_switcher()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
    end

    -- -------------------------------------------------------------
    local function prog_init_pf2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pf2.afaze = random(2)
        pf2:updateAnim()
    end

    -- -------------------------------------------------------------
    local function prog_init_db1()
        return function()
            if db1.dir == dir_no then
                db1.afaze = 0
            else
                db1.afaze = 1
            end
            db1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pf1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pf1.afaze = random(2)
        pf1:updateAnim()
    end

    -- -------------------------------------------------------------
    local function prog_init_db2()
        return function()
            if db2.dir == dir_no then
                db2.afaze = 0
            else
                db2.afaze = 1
            end
            db2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_pc1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        pc1.stav = 0

        return function()
            if pc1.stav > 0 then
                pc1.stav = pc1.stav - 1
            else
                pc1.stav = random(300) + 50
            end
            if isRange(pc1.stav, 2, 3) then
                pc1.afaze = pc1.afaze - 1
            elseif isRange(pc1.stav, 6, 7) then
                pc1.afaze = pc1.afaze + 1
            elseif pc1.stav == 8 then
                if random(2) == 1 then
                    pc1.afaze = 0
                else
                    pc1.afaze = 3
                end
            end
            pc1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krystal()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        local crystals = {}
        for pom1 = 0, 9 do
            item = getModelsTable()[krystal.index + pom1]
            crystals[pom1] = item
            pom2 = random(7) * 4
            item.afaze = pom2
            item.glob1 = 0
            item.glob2 = pom2
        end

        return function()
            for key, item in pairs(crystals) do
                if item.glob1 == 0 then
                    if random(25) == 1 then
                        item.glob1 = item.glob1 + 1
                    end
                elseif isRange(item.glob1, 1, 5) then
                    item.glob1 = item.glob1 + 1
                elseif item.glob1 == 6 then
                    item.glob1 = 0
                end
                if isRange(item.glob1, 0, 3) then
                    pom2 = item.glob1
                elseif isRange(item.glob1, 4, 6) then
                    pom2 = 7 - item.glob1
                end
                item.afaze = item.glob2 + pom2
                item:updateAnim()
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
    subinit = prog_init_universal()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_big()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pc2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_switcher()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pf2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_db1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pf1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_db2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_pc1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krystal()
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

