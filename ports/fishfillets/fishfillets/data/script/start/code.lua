
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
        local boring = 0

        room.uzreklnavod = 0
        room.qcount = 0
        if pokus == 1 then
            room.qnavod1 = 110
            room.qnavod2 = 500
        else
            room.qnavod1 = 400
            room.qnavod2 = 2000
        end
        room.kecyoceli = random(100) + 80
        room.malanepohne = 0
        room.malanemuze = 0
        room.tlustoch = 0
        room.restrt = 0

        return function()
            if small:getAction() == "rest" and big:getAction() == "rest" then
                boring = boring + 1
            else
                boring = 0
            end

            room.qcount = room.qcount + 1
            if room.qcount == 3 then
                addm(15 + random(5), "1st-m-cotobylo")
                addv(6, "1st-v-netusim")
                addv(random(10) + 10, "1st-v-ven")
                addm(3, "1st-m-pockej")
            end
            if no_dialog() and trubka.cinnost == 0 and isReady(small) and isReady(big) then
                if room.qnavod1 > 0 and boring >= room.qnavod1 then
                    room.qnavod1 = -1
                    addm(5, "1st-m-proc")
                    planBusy(small, true, 3)
                    addm(5, "1st-m-hej")
                elseif game_getCycles() >= room.qnavod2 and room.qnavod2 ~= -1 then
                    room.qnavod1 = -1
                    planBusy(small, true, 3)
                    addm(5, "1st-m-hej")
                end
                if room.qnavod1 == -1 then
                    room.qnavod1 = 600
                    room.qnavod2 = -1
                    planBusy(big, true, 4)
                    addv(5, "1st-v-navod1")
                    planBusy(small, false, 3)
                    planBusy(big, false, 1)
                    planBusy(small, true, 100)
                    planBusy(big, true, 2)
                    addm(3, "1st-m-navod4")
                    addv(0, "1st-v-navod5")
                    addm(2, "1st-m-navod6")
                    planBusy(big, false, 3)
                    planBusy(small, false, 2)
                    addv(20, "1st-v-navod7")
                    addm(20, "1st-m-navod8")
                    if room.uzreklnavod == 0 then
                        room.uzreklnavod = 1
                        addv(35, "1st-v-davej")
                        addm(0, "1st-m-nechtoho")
                        addv(5, "1st-v-takdobre")
                    end
                end
                if room.kecyoceli == 0 then
                    room.kecyoceli = random(600) + 300
                    trubka.cinnost = 1
                else
                    room.kecyoceli = room.kecyoceli - 1
                end
                if room.malanemuze == 0 and trubka.pohnul == 0 and small.X == 13 then
                    room.malanemuze = 1
                    addm(random(5) + 2, "1st-m-neprojedu")
                end
                if room.malanepohne == 0 and trubka.pohnul == 0 and small.X == 12 and small.Y >= 10 then
                    room.malanepohne = 1
                    addm(0, "1st-m-nepohnu")
                end
                if room.malanepohne > 0 then
                    room.malanepohne = room.malanepohne + 1
                    if trubka.dir == dir_left then
                        if room.malanepohne < 50 then
                            addv(0, "1st-v-takukaz")
                        end
                        room.malanepohne = -1
                    end
                end
                if room.malanepohne ~= -2 and trubka.dir == dir_left then
                    addm(4, "1st-m-hmmm")
                    room.malanepohne = -2
                end
                if zidlev.X >= 20 and big.X >= 21 and big.Y == 15 then
                    switch(room.tlustoch){
                        [0] = function()
                            addv(10, "1st-v-nemuzu")
                            if random(100) < 50 then
                                addv(4, "1st-v-pribral")
                            end
                            room.tlustoch = room.tlustoch + 1
                        end,
                        [2] = function()
                            addv(10, "1st-v-posunout")
                            room.tlustoch = room.tlustoch + 1
                        end,
                    }
                end
                if big.X < 20 and room.tlustoch == 1 then
                    room.tlustoch = room.tlustoch + 1
                end
                if room.restrt == 0 and trubka.X <= 9 and small.X <= trubka.X - 3 then
                    planBusy(small, false)
                    addm(10, "1st-m-pokud")
                    planBusy(big, true, 3)
                    addv(3, "1st-v-znovu")
                    if random(100) < 50 then
                        addm(0, "1st-m-backspace")
                        addv(0, "1st-v-jedno")
                    end
                    planBusy(small, false, 3)
                    addv(5, "1st-v-najit")
                    planBusy(big, false)
                    room.restrt = 1
                end
            end
            if no_dialog() and room.restrt == 0 and small:isOut() and isReady(big) and big.X <= 23 and zidlev.X >= 20 then
                addv(30, "1st-v-chyba")
                planBusy(big, true)
                addv(10, "1st-v-nedostanu")
                planBusy(big, false)
                planBusy(big, true, 50)
                addv(3, "1st-v-stiskni")
                if random(100) < 50 then
                    addm(0, "1st-m-backspace")
                    addv(0, "1st-v-jedno")
                end
                --[[ TODO: control panel
                addv(5, "1st-v-najit")
                ]]
                planBusy(big, false)
                room.restrt = 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_trubka()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        trubka.cinnost = 0
        trubka.pohnul = 0

        return function()
            if trubka.dir == dir_left or trubka.dir == dir_right then
                trubka.pohnul = 1
            end
            local anim_table = {
                [1] = function()
                    trubka.cinnost = trubka.cinnost + 1
                    trubka.afaze = trubka.afaze + 1
                    trubka.delay = 7
                end,
                [5] = function()
                    if trubka.delay > 0 then
                        trubka.delay = trubka.delay - 1
                    else
                        trubka.cinnost = trubka.cinnost + 1
                    end
                end,
                [6] = function()
                    trubka.afaze = 5
                    trubka.cinnost = trubka.cinnost + 1
                    trubka.delay = 8
                end,
                [7] = function()
                    if trubka.delay > 0 then
                        if random(100) < 10 then
                            trubka.afaze = 4
                        else
                            trubka.afaze = 5
                        end
                        trubka.delay = trubka.delay - 1
                    else
                        trubka.cinnost = trubka.cinnost + 1
                    end
                end,
                [8] = function()
                    trubka:planDialog(0, "1st-x-ocel")
                    trubka.cinnost = trubka.cinnost + 1
                end,
                [9] = function()
                    if trubka:isTalking() then
                        if trubka.afaze == 4 then
                            trubka.afaze = 5
                        end
                        if math.mod(game_getCycles(), 3) == 1 then
                            if random(2) == 0 then
                                trubka.afaze = trubka.afaze + 1
                            else
                                trubka.afaze = trubka.afaze - 1
                            end
                            if trubka.afaze == 4 then
                                trubka.afaze = 8
                            elseif trubka.afaze == 9 then
                                trubka.afaze = 5
                            end
                        end
                        if trubka.afaze == 5 and random(100) < 40 then
                            trubka.afaze = 4
                        end
                    else
                        trubka.cinnost = trubka.cinnost + 1
                    end
                end,
                [10] = function()
                    trubka.afaze = 5
                    trubka.cinnost = trubka.cinnost + 1
                end,
                [11] = function()
                    trubka.afaze = trubka.afaze - 1
                    trubka.cinnost = trubka.cinnost + 1
                end,
                [16] = function()
                    trubka.cinnost = 0
                end,
            }

            anim_table[2] = anim_table[1]
            anim_table[3] = anim_table[1]
            anim_table[4] = anim_table[1]
            anim_table[12] = anim_table[11]
            anim_table[13] = anim_table[11]
            anim_table[14] = anim_table[11]
            anim_table[15] = anim_table[11]
            switch(trubka.cinnost)(anim_table)
            trubka:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_trubka()
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

