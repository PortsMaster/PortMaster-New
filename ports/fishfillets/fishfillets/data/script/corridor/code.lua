
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky02.ogg")
    local pokus = getRestartCount()
    local luminous = {
        small, big,
        leftpes, rightpes, vypinac,
        dvere1, dvere2, dvere3, dvere4,
        poklop1, poklop2
    }
    addHeadAnim(small, "images/fishes/small", "head_dark", "dark_00")
    addHeadAnim(small, "images/fishes/small", "head_dark", "dark_01")
    addHeadAnim(big, "images/fishes/big", "head_dark", "dark_00")
    addHeadAnim(big, "images/fishes/big", "head_dark", "dark_01")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.oci = 0
        room.bliknul = 0
        room.last = random(2)
        room.rpesmala = 0
        room.rpesvelka = 0
        room.nerusit = 0
        room.pesmluvi = 0
        room.dark = false
        local darked = false

        return function()
            if room.dark then
                for key, model in pairs({small, big}) do
                    if model:isAlive() then
                        local action = model:getAction()
                        if action == "turn" or action == "activate" or random(100) < 6 then
                            model_useSpecialAnim(model.index, "head_dark", 1)
                        else
                            model_useSpecialAnim(model.index, "head_dark", 0)
                        end
                    end
                end

                if not darked then
                    game_changeBg("images/"..codename.."/dark.png")
                    for key, model in pairs(getModelsTable()) do
                        if not isIn(model, luminous) then
                            model:setEffect("invisible")
                        end
                    end
                    darked = true
                end
            elseif darked then
                game_changeBg("images/"..codename.."/chodba-p2.png")
                for key, model in pairs(getModelsTable()) do
                    model:setEffect("none")
                end
                darked = false
            end

            if no_dialog() and isReady(small) and isReady(big) then
                if room.dark and room.tma > 0 then
                    room.tma = room.tma - 1
                end
                if not room.dark then
                    room.tma = random(100) + 50
                end
                if room.bliknul == 1 then
                    room.bliknul = room.bliknul + 1
                    addm(random(10) + 10, "ch-m-rozsvit"..random(3))
                    addv(random(15) + 2, "ch-v-pockej"..random(3))
                elseif room.bliknul == 3 then
                    room.bliknul = room.bliknul + 1
                    addm(random(10), "ch-m-blik"..random(2))
                    room.oci = room.bliknul + 2
                elseif room.oci < room.bliknul and room.oci > 0 then
                    if random(100) < 40 then
                        room.oci = 0
                        addm(3, "ch-m-blik0")
                    else
                        room.oci = room.bliknul
                    end
                elseif room.tma == 0 then
                    room.tma = random(300) + 100
                    if random(100) < 80 then
                        room.last = 1 - room.last
                    end
                    switch(room.last){
                        [0] = function()
                            addv(0, "ch-v-halo"..random(3))
                            addm(random(20), "ch-m-tady"..random(3))
                        end,
                        [1] = function()
                            addm(0, "ch-m-bojim"..random(3))
                            addv(random(20), "ch-v-neboj"..random(3))
                        end,
                    }
                elseif room.rpesvelka == 0 and big.Y >= 20 and random(100) < 2 then
                    room.rpesvelka = 1
                    room.nerusit = 1
                    pom1 = random(4)
                    addv(10, "ch-v-robopes")
                    addm(random(5), "ch-m-ten")
                    addv(random(10), "ch-v-zapada")
                    addm(5 + random(10), "ch-m-odpoved"..pom1)
                    if random(100) < 70 then
                        addv(random(20) + 10, "ch-v-smysl")
                        if random(100) < 80 then
                            addm(random(10) + 5, "ch-m-vubec")
                        end
                    end
                    room.cpsa = random(2)
                    planDialogSet(random(20), "ch-r-nevsimej"..random(3), 10, room, "pesmluvi")
                    planDialogSet(random(20), "ch-r-hracka", 10, room, "pesmluvi")
                    planDialogSet(10 + random(20), "ch-r-ikdyz"..random(4), 10, room, "pesmluvi")
                    planDialogSet(10 + random(20), "ch-r-anavic"..pom1, 10, room, "pesmluvi")
                    planSet(room, "nerusit", 0)
                elseif room.rpesmala == 0 and small.Y >= 28 and (small.X <= 11 or small.X >= 20) and random(100) < 3 then
                    if room.rpesvelka == 1 and random(3) < 2 then
                        addv(2, "ch-v-pozor")
                    else
                        addm(2, "ch-m-doufam")
                    end
                    room.rpesmala = 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_rightpes()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        rightpes.faze = 0

        return function()
            if rightpes.faze == 2 then
                rightpes.faze = 0
            else
                rightpes.faze = rightpes.faze + 1
            end
            if room.dark then
                rightpes.afaze = rightpes.faze + 3
            else
                rightpes.afaze = rightpes.faze
                if room.pesmluvi ~= 0 and room.cpsa == 1 and random(2) == 0 then
                    rightpes.afaze = rightpes.afaze + 6
                end
            end
            rightpes:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_leftpes()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        leftpes.faze = 0

        return function()
            if leftpes.faze == 2 then
                leftpes.faze = 0
            else
                leftpes.faze = leftpes.faze + 1
            end
            if room.dark then
                leftpes.afaze = leftpes.faze + 3
            else
                leftpes.afaze = leftpes.faze
                if room.pesmluvi ~= 0 and room.cpsa == 0 and random(2) == 0 then
                    leftpes.afaze = leftpes.afaze + 6
                end
            end
            leftpes:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vypinac()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        vypinac.stav = 0
        local afterLoad = true

        return function()
            if afterLoad then
                afterLoad = false
                return
            end

            switch(vypinac.stav){
                [0] = function()
                    if (vypinac.dir == dir_left or vypinac.dir == dir_right) and level_isNewRound() then
                        vypinac.stav = vypinac.stav + 1
                        vypinac.afaze = 1
                        vypinac:talk("ch-x-click1")
                    end
                end,
                [1] = function()
                    vypinac.stav = vypinac.stav + 1
                    vypinac.afaze = 2
                    room.dark = true
                    room.bliknul = room.bliknul + 1
                    if room.nerusit == 0 then
                        game_killPlan()
                    end
                end,
                [2] = function()
                    if (vypinac.dir == dir_left or vypinac.dir == dir_right) and level_isNewRound() then
                        vypinac.stav = 0
                        vypinac.afaze = 0
                        room.dark = false
                        vypinac:talk("ch-x-click2")
                        room.bliknul = room.bliknul + 1
                        if room.nerusit == 0 then
                            game_killPlan()
                        end
                    end
                end,
            }
            vypinac:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dvere1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dvere1.faze = 0
        dvere1.pocit = 2

        return function()
            if dvere1.pocit > 0 then
                dvere1.pocit = dvere1.pocit - 1
            else
                dvere1.pocit = 5
                dvere1.faze = 1 - dvere1.faze
            end
            if room.dark then
                dvere1.afaze = dvere1.faze + 2
            else
                dvere1.afaze = dvere1.faze
            end
            dvere1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dvere2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dvere2.faze = 0
        dvere2.pocit = 1

        return function()
            if dvere2.pocit > 0 then
                dvere2.pocit = dvere2.pocit - 1
            else
                dvere2.pocit = 1
                dvere2.faze = 1 - dvere2.faze
            end
            if room.dark then
                dvere2.afaze = dvere2.faze + 2
            else
                dvere2.afaze = dvere2.faze
            end
            dvere2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dvere3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dvere3.faze = 0
        dvere3.pocit = 2

        return function()
            if dvere3.pocit > 0 then
                dvere3.pocit = dvere3.pocit - 1
            else
                dvere3.pocit = 4
                dvere3.faze = 1 - dvere3.faze
            end
            if room.dark then
                dvere3.afaze = dvere3.faze + 2
            else
                dvere3.afaze = dvere3.faze
            end
            dvere3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_dvere4()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        dvere4.faze = 0
        dvere4.pocit = 1

        return function()
            if dvere4.pocit > 0 then
                dvere4.pocit = dvere4.pocit - 1
            else
                dvere4.pocit = 2
                dvere4.faze = 1 - dvere4.faze
            end
            if room.dark then
                dvere4.afaze = dvere4.faze + 2
            else
                dvere4.afaze = dvere4.faze
            end
            dvere4:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_poklop2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        poklop2.faze = 1
        poklop2.pocit = 1

        return function()
            if poklop2.pocit > 0 then
                poklop2.pocit = poklop2.pocit - 1
            else
                poklop2.pocit = 3
                poklop2.faze = 1 - poklop2.faze
            end
            if room.dark then
                poklop2.afaze = poklop2.faze + 2
            else
                poklop2.afaze = poklop2.faze
            end
            poklop2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_poklop1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        poklop1.faze = 0
        poklop1.pocit = 1

        return function()
            if poklop1.pocit > 0 then
                poklop1.pocit = poklop1.pocit - 1
            else
                poklop1.pocit = 3
                poklop1.faze = 1 - poklop1.faze
            end
            if room.dark then
                poklop1.afaze = poklop1.faze + 2
            else
                poklop1.afaze = poklop1.faze
            end
            poklop1:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_rightpes()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_leftpes()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_vypinac()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dvere1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dvere2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dvere3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_dvere4()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_poklop2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_poklop1()
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

