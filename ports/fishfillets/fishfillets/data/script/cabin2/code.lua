
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
        local boring = 0

        room.uvod = 0
        room.zivy = 0
        room.poklad = 0
        room.chobotnicka = 0
        room.chobotnicka1 = 0
        room.kostricky = randint(200, 1000)
        room.mysleni = randint(1000, 5000)
        room.posvitime = 0
        room.hrbet = randint(25, 100)
        room.operenej = 0

        return function()
            if small:getAction() == "rest" and big:getAction() == "rest" then
                boring = boring + 1
            else
                boring = 0
            end

            if isReady(small) and isReady(big) and no_dialog() then
                if room.zivy > 0 then
                    room.zivy = room.zivy + 1
                end
                if room.zivy > 50 then
                    room.zivy = 0
                end
                if room.kostricky > 0 then
                    room.kostricky = room.kostricky - 1
                end
                if room.mysleni > 0 then
                    room.mysleni = room.mysleni - 1
                end
                if room.hrbet > 0 and big.Y == poklop.Y + 1 and poklop.Y < poklop.YStart then
                    room.hrbet = room.hrbet - 1
                end
                if room.uvod == 0 then
                    if pokus == 1 or random(100) < 50 then
                        addv(randint(20, 30), "ka2-v-nekde")
                        if random(100) < 40 then
                            addm(random(5), "ka2-m-kdepak")
                        end
                    end
                    room.uvod = 1
                elseif (0 <= papzivy.afaze and papzivy.afaze <= 8) and room.operenej == 0 then
                    addv(0, "ka2-v-papousek")
                    room.operenej = 1
                    room.zivy = 1
                elseif look_at(small, papzivy) and room.zivy > 0 and room.zivy < 50 and room.operenej == 1 then
                    addm(0, "ka2-m-kostra")
                    room.zivy = 0
                    room.operenej = 0
                elseif dist(small, truhla) <= 3 and room.poklad == 0 and look_at(small, truhla) and random(100) < 10 then
                    room.poklad = 1
                    addm(random(5), "ka2-m-posledni")
                    local rand7 = random(7)
                    if rand7 == 0 or rand7 == 1 then
                        addv(random(5), "ka2-v-mapa0")
                    elseif rand7 == 2 or rand7 == 3 then
                        addv(random(5), "ka2-v-mapa1")
                    elseif rand7 == 4 or rand7 == 5 then
                        addv(random(5), "ka2-v-mapa2")
                    end
                elseif small.X >= chobot.X and small.X <= chobot.X + 4 and small.Y == chobot.Y - 1 and room.chobotnicka == 0 and random(100) < 2 then
                    room.chobotnicka = 1
                    addm(1, "ka2-m-chapadlo")
                    switch(random(3)){
                        [0] = function()
                            addv(random(5) + 10, "ka2-v-fik")
                        end,
                        [1] = function()
                            addv(random(5) + 10, "ka2-v-fik")
                            chobot:planDialog(5, "k1-chob-p")
                            addv(random(5), "ka2-v-napad")
                        end,
                    }
                elseif dist(small, chobot) <= 2 and look_at(small, chobot) and room.chobotnicka1 == 0 and room.chobotnicka == 1 and random(100) < 3 then
                    room.chobotnicka1 = -1
                    addm(1, "ka2-m-hej")
                    if random(3) <= 1 then
                        addm(randint(30, 50), "ka2-m-diky")
                    end
                elseif room.kostricky == 0 and small.X > 8 and big.X > 8 then
                    room.kostricky = -1
                    addv(random(5), "ka2-v-kostry")
                    if random(100) < 70 then
                        addm(random(5), "ka2-m-patrne")
                    end
                elseif room.mysleni == 0 and boring > 40 then
                    room.mysleni = -1
                    addv(random(10), "ka2-v-myslet")
                    addm(random(5), "ka2-m-tezko")
                elseif lampa.dir ~= dir_no and room.posvitime == 0 and random(100) < 40 then
                    addm(10, "ka2-m-svitit")
                    room.posvitime = 1
                elseif room.hrbet == 0 and big.Y == poklop.Y + 1 and poklop.Y < poklop.YStart then
                    room.hrbet = -1
                    addv(0, "ka2-v-hrbet")
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

        return function()
            if papouch.stav == 0 and random(250) == 0 and no_dialog() then
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
            elseif papouch.stav == 101 then
                papouch.afaze = random(2)
            end
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

        small.lebku = 0

        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_papzivy()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        papzivy.cinnost = 0
        papzivy.pocet = 0
        papzivy.afaze = 9

        return function()
            if papzivy.cinnost > 0 and papzivy.cinnost < 20 and small:getAction() == "turn" then
                if papzivy.cinnost < 5 then
                    papzivy.cinnost = 24 - papzivy.cinnost
                else
                    papzivy.cinnost = 20
                end
            end
            switch(papzivy.cinnost){
                [0] = function()
                    if random(1000) < 4 then
                        if xdist(small, papzivy) > 1 and not small:isLeft() or xdist(small, papzivy) < -1 and small:isLeft() then
                            papzivy.cinnost = 1
                        end
                    end
                end,
                [5] = function()
                    papzivy.delay = random(5) + 2
                    papzivy.cinnost = papzivy.cinnost + 1
                end,
                [6] = function()
                    if papzivy.delay > 0 then
                        papzivy.delay = papzivy.delay - 1
                    else
                        papzivy.cinnost = papzivy.cinnost + 1
                    end
                end,
                [7] = function()
                    papzivy.afaze = 0
                    papzivy.cinnost = papzivy.cinnost + 1
                    papzivy.delay = random(100) + 10
                end,
                [8] = function()
                    if papzivy.delay > 0 then
                        papzivy.delay = papzivy.delay - 1
                    else
                        papzivy.cinnost = papzivy.cinnost + 1
                        papzivy.delay = random(60) + 20
                    end
                end,
                [9] = function()
                    if odd(game_getCycles()) then
                        papzivy.afaze = random(4) + 1
                    end
                    if papzivy.delay > 0 then
                        papzivy.delay = papzivy.delay - 1
                    else
                        papzivy.cinnost = 7
                    end
                end,
                [24] = function()
                    papzivy.cinnost = 0
                end,
                default = function()
                    if 1 <= papzivy.cinnost and papzivy.cinnost <= 4 then
                        papzivy.afaze = 9 - papzivy.cinnost
                        papzivy.cinnost = papzivy.cinnost + 1
                    elseif 20 <= papzivy.cinnost and papzivy.cinnost <= 23 then
                        papzivy.afaze = papzivy.cinnost - 14
                        papzivy.cinnost = papzivy.cinnost + 1
                    end
                end,
            }
            papzivy:updateAnim()
        end
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
    subinit = prog_init_papzivy()
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

