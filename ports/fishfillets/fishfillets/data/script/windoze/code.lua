
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky13.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(2)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.resit = 0
        room.umrela = 0
        room.navrhy = random(500) + 200
        room.poslnavrh = 4
        room.odire = 0
        room.onotepadu = 0
        room.ooknech = 0
        room.obonusu = 0
        room.obordelu = 0
        room.ooceli = 0
        room.hlasky = random(100) + 20
        room.nhlasek = 0
        local backup_stdBlackJokes = stdBlackJoke
        local autoRestart = 0

        return function()
            if room.resit == 1 then
                if staramala:isOut() and staravelka:isOut() then
                    room.resit = 2
                    big:setBusy(false)
                    small:setBusy(false)
                    --NOTE: turn on standard black jokes
                    stdBlackJoke = backup_stdBlackJokes
                else
                    game_setFastFalling(true)
                    big:setBusy(true)
                    small:setBusy(true)
                end
            else
                game_setFastFalling(false)
                staramala:setBusy(true)
                staravelka:setBusy(true)
            end
            if autoRestart == 0 and (
                (not staramala:isAlive() and (not staravelka:isAlive() or staravelka:isOut())) or
                (not staravelka:isAlive() and (not staramala:isAlive() or staramala:isOut())) or
                (not small:isAlive() and not big:isAlive())) then
                autoRestart = 1
                level_planShow(function(count)
                    if count == 60 then
                        return level_action_restart()
                    else
                        return false
                    end
                end)
            end

            if room.resit == 0 then
                if big:getTouchDir() ~= dir_no and bonuslevel:getTouchDir() ~= dir_no then
                    room.resit = 1
                    roompole[1] = 1
                    room.obonusu = 0
                    big:setBusy(true)
                    small:setBusy(true)
                    staramala:setBusy(false)
                    staravelka:setBusy(false)
                    game_checkActive()
                    if pokus == 1 then
                        addv(0, "win-v-pockej")
                        addm(2, "win-m-zavrene")
                    end
                    if pokus < 3 or random(100) < 40 then
                        addv(5, "win-v-osvobodit")
                        addm(10, "win-m-ven")
                        addv(0, "win-v-citim")
                        addm(random(10) + 5, "win-m-vzit")
                    end
                    addv(5, "win-v-nehrajem")
                    --NOTE: turn off standard black jokes
                    stdBlackJoke = function() end
                end
            end
            if room.resit == 1 then
                if room.umrela == 0 and isReady(staramala) and not staravelka:isAlive() then
                    room.umrela = 1
                    addm(5, "win-m-jejda")
                elseif room.umrela == 0 and isReady(staravelka) and not staramala:isAlive() then
                    room.umrela = 1
                    addv(5, "win-v-real")
                end
            end
            if room.resit ~= 1 and no_dialog() and isReady(small) and isReady(big) then
                if room.navrhy > 0 then
                    room.navrhy = room.navrhy - 1
                end
                if room.hlasky > 0 then
                    room.hlasky = room.hlasky - 1
                end
                if room.navrhy == 0 then
                    room.navrhy = random(1500) + 200
                    pom1 = random(4)
                    if room.poslnavrh == pom1 then
                        pom1 = 4
                    end
                    addm(30, "win-m-costim"..pom1)
                    adddel(30)
                elseif room.ooceli == 0 and dist(small, bonuslevel) <= 1 then
                    room.ooceli = 1
                    addm(5, "win-m-vga")
                elseif room.hlasky == 0 then
                    pom1 = random(5)
                    room.nhlasek = room.nhlasek + 1
                    room.hlasky = random(300) + 300
                    if roompole[0] == 0 and room.nhlasek == 2 then
                        pom1 = 0
                    end
                    switch(pom1){
                        [0] = function()
                            if room.obonusu == 0 then
                                room.obonusu = 1
                                addm(10, "win-m-okno")
                                addv(8, "win-v-hra")
                                addm(random(10) + 10, "win-m-chodila")
                                addv(2, "win-v-nic0")
                                addm(2, "win-m-nic1")
                                addv(2, "win-v-nic2")
                                addm(5, "win-m-nic3")
                                addv(random(10) + 10, "win-v-hav")
                                if roompole[1] == 0 then
                                    addm(random(30) + 10, "win-m-zahrat")
                                end
                            end
                        end,
                        [1] = function()
                            if room.onotepadu == 0 then
                                room.onotepadu = 1
                                addm(10, "win-m-blok")
                                adddel(random(15) + 5)
                                planSet(notepad, "napsano", 1)
                                adddel(random(15) + 5)
                                planSet(notepad, "napsano", 2)
                                adddel(random(15) + 5)
                                planSet(notepad, "napsano", 3)
                                adddel(random(15) + 5)
                                planSet(notepad, "napsano", 4)
                                addv(10, "win-v-premyslej")
                            end
                        end,
                        [2] = function()
                            if room.odire == 0 then
                                room.odire = 1
                                addm(30, "win-m-dira")
                                addv(3, "win-v-tamhle")
                            end
                        end,
                        [3] = function()
                            if room.ooknech == 0 then
                                room.ooknech = 1
                                addv(20, "win-v-pocitala")
                                addm(5, "win-m-nemusim")
                            end
                        end,
                        [4] = function()
                            if room.obordelu == 0 then
                                room.obordelu = 1
                                addv(30, "win-v-plocha")
                            end
                        end,
                    }
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_bonuslevel()
        return function()
            if room.resit == 1 then
                bonuslevel.afaze = 1
            else
                bonuslevel.afaze = 0
            end
            bonuslevel:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_notepad()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        notepad.napsano = 0

        return function()
            notepad.afaze = notepad.napsano * 2 + math.floor(math.mod(game_getCycles(), 10) / 5)
            notepad:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_staravelka()
    end

    -- -------------------------------------------------------------
    local function prog_init_staramala()
    end

    -- -------------------------------------------------------------
    local function prog_init_spuntik()
        spuntik:setEffect("invisible")
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_bonuslevel()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_notepad()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_staravelka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_staramala()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_spuntik()
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

