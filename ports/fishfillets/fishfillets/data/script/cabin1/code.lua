
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

        room.podekovat = 0
        if random(100) < 50 then
            room.atmosf = random(200) + 100
            room.podiv = -1
        else
            room.podiv = 20
            room.atmosf = -1
        end
        room.chob = random(2) + 1
        room.truh = random(40) + 10
        room.mov = 0
        room.nekro = 0
        local screenShiftX, screenShiftY = 0, 0
        --NOTE: turn off standard black jokes
        stdBlackJoke = function() end

        return function()
            if not small:isAlive() or not big:isAlive() then
                if room.nekro == 0 then
                    planDialogSet(6, "k1-pap-karamba", 101, papouch, "stav")
                end
                room.nekro = 1
            else
                if chobot.dir ~= dir_no then
                    room.podekovat = 1
                end
                if room.atmosf >= 0 then
                    if room.atmosf == 0 then
                        if no_dialog() then
                            addv(50, "k1-v-citis")
                            addm(1, "k1-m-kolebku")
                            addv(2, "k1-v-cit")
                        else
                            room.atmosf = room.atmosf + 20
                        end
                    end
                    room.atmosf = room.atmosf - 1
                end
                if room.podiv >= 0 then
                    if xdist(small, lebka) <= 2 and look_at(small, lebka) and lebka.dir == dir_no then
                        if room.podiv == 0 and small.cinnost == 0 then
                            if no_dialog() then
                                addm(20, "k1-m-podivin")
                                addv(2, "k1-v-proc")
                                addm(2, "k1-m-lebku")
                                addv(2, "k1-v-jejeho")
                                if random(2) == 0 then
                                    addm(5, "k1-m-mysli")
                                end
                            else
                                room.podiv = room.podiv + 10
                            end
                        end
                        room.podiv = room.podiv - 1
                    end
                end
                if room.podekovat == 0 and small.Y <= 7 and small.X == 17 then
                    room.podekovat = 1
                    if no_dialog() then
                        addm(5, "k1-m-diky")
                        addv(3, "k1-v-radose")
                    end
                end
                switch(room.chob){
                    [1] = function()
                        if small.X == chobot.X + 1 and small.Y == chobot.Y then
                            if no_dialog() then
                                addv(0, "k1-v-opatrne")
                                addm(3, "k1-m-tospisona")
                            end
                            room.chob = 0
                        end
                    end,
                    [2] = function()
                        if look_at(small, chobot) and dist(small, chobot) == 2 then
                            if no_dialog() then
                                addm(4, "k1-m-chobotnice")
                                addv(6, "k1-v-patrila")
                                planDialogSet(8, "k1-pap-drahousek", 101, papouch, "stav")
                            end
                            room.chob = 0
                        end
                    end,
                }
                if room.truh >= 0 then
                    if dist(small, truhla) < 2 then
                        if room.truh == 0 then
                            if no_dialog() then
                                room.truh = room.truh - 1
                                switch(random(2)){
                                    [0] = function()
                                        addm(0, "k1-m-copak")
                                        addv(3, "k1-v-kdovi")
                                        planDialogSet(6, "k1-pap-drahokamy", 101, papouch, "stav")
                                    end,
                                    [1] = function()
                                        addm(0, "k1-m-myslis")
                                        addv(random(10), "k1-v-bedna")
                                    end,
                                }
                            else
                                room.truh = room.truh - 10
                            end
                        else
                            room.truh = room.truh - 1
                        end
                    end
                end

                if room.mov == 0 and random(100) < 1 then
                    room.mov = 1
                end
                if room.mov == 1 and big:getTouchDir() ~= dir_no and room:getTouchDir() ~= dir_no then
                    local touchDir = room:getTouchDir()
                    local shiftX, shiftY = getDirShift(touchDir)
                    screenShiftX = screenShiftX + shiftX * 15
                    screenShiftY = screenShiftY + shiftY * 15
                    game_setScreenShift(screenShiftX, screenShiftY)
                    if no_dialog() then
                        room.mov = 2
                        addm(4, "k1-m-codelas")
                        addv(3, "k1-v-promin")
                    end
                end
                if room.mov == 1 or room.mov == 2 then
                    screenShiftX = screenShiftX - screenShiftX / 10
                    screenShiftY = screenShiftY - screenShiftY / 10
                    game_setScreenShift(screenShiftX, screenShiftY)
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_truhla()
        return function()
            if truhla.dir ~= dir_no and level_isNewRound() then
                truhla:talk("k1-x-vrz", VOLUME_FULL)
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_papouch()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        papouch.stav = 0
        papouch.strcil = 0
        papouch.smalse = 0
        papouch.nekoukej = 0
        papouch.tlustej = 0

        return function()
            switch(papouch.stav){
                [0] = function()
                    if no_dialog() then
                        if (papouch.dir == dir_left or papouch.dir == dir_right) and papouch.strcil == 0 and random(6) == 0 then
                            papouch.strcil = 1
                            planDialogSet(0, "k1-pap-nestrkej", 101, papouch, "stav")
                        elseif papouch.Y == 18 and papouch.smalse == 0 then
                            papouch.smalse = 1
                            planDialogSet(0, "k1-pap-prekazet", 101, papouch, "stav")
                        elseif poklop.Y == 7 and small.Y > 7 and small.Y < 17 and small.X > 7 and big.Y < 7 and papouch.smalse == 0 then
                            papouch.smalse = 1
                            planDialogSet(0, "k1-pap-prcice", 101, papouch, "stav")
                        elseif papouch.nekoukej == 0 and dist(small, papouch) <= 1 and random(100) < 5 then
                            papouch.nekoukej = 1
                            planDialogSet(0, "k1-pap-vodprejskni", 102, papouch, "stav")
                        elseif papouch.nekoukej == 0 and dist(big, papouch) <= 1 and random(100) < 5 then
                            papouch.nekoukej = 2
                            planDialogSet(0, "k1-pap-vodprejskni", 102, papouch, "stav")
                        elseif papouch.nekoukej == 1 and dist(small, papouch) > 2 and random(100) < 25 then
                            planDialogSet(0, "k1-pap-noproto", 101, papouch, "stav")
                        elseif papouch.nekoukej == 2 and dist(big, papouch) > 2 and random(100) < 25 then
                            planDialogSet(0, "k1-pap-noproto", 101, papouch, "stav")
                        elseif papouch.tlustej == 0 and trubka.X >= 13 and trubka.Y == 18 then
                            papouch.tlustej = 1
                            planDialogSet(0, "k1-pap-sestlustej", 101, papouch, "stav")
                            papouch.stav = 1
                        elseif random(250) == 0 then
                            switch(random(7)){
                                [0] = function()
                                    planDialogSet(0, "k1-pap-sucharek", 101, papouch, "stav")
                                end,
                                [1] = function()
                                    planDialogSet(0, "k1-pap-kruty", 101, papouch, "stav")
                                end,
                                [2] = function()
                                    planDialogSet(0, "k1-pap-3xkruty", 101, papouch, "stav")
                                end,
                                [3] = function()
                                    planDialogSet(0, "k1-pap-kruci", 101, papouch, "stav")
                                end,
                                [4] = function()
                                    planDialogSet(0, "k1-pap-sakris", 101, papouch, "stav")
                                end,
                                [5] = function()
                                    planDialogSet(0, "k1-pap-trhnisi", 101, papouch, "stav")
                                end,
                                [6] = function()
                                    planDialogSet(0, "k1-pap-problem", 101, papouch, "stav")
                                end,
                            }
                            papouch.stav = 1
                        end
                    end
                end,
                [101] = function()
                    if papouch.nekoukej > 0 then
                        papouch.nekoukej = 3
                    end
                    papouch.afaze = random(2)
                end,
                [102] = function()
                    papouch.afaze = random(2)
                end,
            }
            papouch:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_chobot()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        chobot.lastdir = dir_no
        chobot.oci = 0
        chobot.chapadla = 0
        chobot.akcnost = 2

        return function()
            if chobot.dir ~= dir_no then
                chobot.akcnost = 7
            elseif chobot.akcnost > 2 and math.mod(game_getCycles(), 5) == 0 then
                chobot.akcnost = chobot.akcnost - 1
            end
            if chobot.dir ~= chobot.lastdir then
                if not chobot:isTalking() then
                    if chobot.dir == dir_down then
                        chobot:talk("k1-chob-p", VOLUME_FULL)
                    elseif chobot.dir ~= dir_no then
                        switch(random(3)){
                            [0] = function()
                                chobot:talk("k1-chob-1", VOLUME_FULL)
                            end,
                            [1] = function()
                                chobot:talk("k1-chob-2", VOLUME_FULL)
                            end,
                            [2] = function()
                                chobot:talk("k1-chob-3", VOLUME_FULL)
                            end,
                        }
                    end
                end
                chobot.lastdir = chobot.dir
            end
            if chobot.dir == dir_no and math.mod(game_getCycles(), chobot.akcnost) == 0 then
                if random(2) == 0 then
                    if chobot.chapadla < 2 then
                        chobot.chapadla = chobot.chapadla + 1
                    else
                        chobot.chapadla = 0
                    end
                else
                    if chobot.chapadla > 0 then
                        chobot.chapadla = chobot.chapadla - 1
                    else
                        chobot.chapadla = 2
                    end
                end
            end
            pomb1 = xdist(small, chobot) == 0 and ydist(small, chobot) <= 0 or xdist(big, chobot) == 0 and ydist(big, chobot) <= 0
            pomb1 = pomb1 or chobot.dir ~= dir_no
            if pomb1 then
                chobot.oci = 1
            end
            switch(chobot.oci){
                [0] = function()
                    if random(100) < 10 then
                        chobot.oci = 2
                    end
                end,
                [2] = function()
                    if random(100) < 10 then
                        chobot.oci = 0
                    end
                end,
                [1] = function()
                    if not pomb1 and random(100) < 20 then
                        chobot.oci = 0
                    end
                end,
            }
            chobot.afaze = chobot.oci + 3 * chobot.chapadla
            chobot:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        small.leb = 0
        small.cinnost = 0
        small.delay = 0

        return function()
            if no_dialog() then
                switch(small.cinnost){
                    [0] = function()
                        if lebka.dir ~= dir_no and lebka.dir ~= dir_down and small.dir ~= dir_no and (small.leb == 0 or random(100) < 10) and level_isNewRound() then
                            small.leb = 1
                            small:talk("k1-m-fuj")
                        end
                    end,
                }
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.cinnost = 0

    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_truhla()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_papouch()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_chobot()
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

