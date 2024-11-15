
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky15.ogg")
    local pokus = getRestartCount()



    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.obudikovi = 0
        room.okramech = randint(1000, 3000)
        room.olodi = 0
        room.sbirka = randint(300, 1200)

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.okramech > 0 then
                    room.okramech = room.okramech - 1
                end
                if room.sbirka > 0 then
                    room.sbirka = room.sbirka - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    addm(randint(15, 30), "sm-m-prolezame")
                    switch(random(3)){
                        [0] = function()
                            addv(random(5), "sm-v-jine0")
                        end,
                        [1] = function()
                            addv(random(5), "sm-v-jine1")
                        end,
                        [2] = function()
                            addv(random(5), "sm-v-jine2")
                        end,
                    }
                elseif room.obudikovi == 0 and look_at(small,budik) and dist(small,budik) < 3 and random(100) < 1 then
                    room.obudikovi = 1
                    addv(0, "sm-v-budik")
                    if random(2) < 1 then
                        addm(random(5), "sm-m-normalni")
                    end
                elseif room.okramech == 0 then
                    room.okramech = randint(1000, 3000)
                    switch(random(4)){
                        [0] = function()
                            addm(random(10), "sm-m-kramy0")
                        end,
                        [1] = function()
                            addm(random(10), "sm-m-kramy1")
                        end,
                        [2] = function()
                            addv(random(10), "sm-v-kramy2")
                        end,
                        [3] = function()
                            addv(random(10), "sm-v-kramy3")
                        end,
                    }
                elseif room.olodi == 0 and lod.dir ~= dir_no then
                    room.olodi = 1
                    switch(random(2)){
                        [0] = function()
                            addv(random(7), "sm-v-lod")
                            addm(random(7), "sm-m-dedek")
                            addv(random(7), "sm-v-charon")
                            addm(random(7), "sm-m-codela")
                        end,
                        [1] = function()
                            addv(random(7), "sm-v-charon")
                            addm(random(7), "sm-m-codela")
                        end,
                    }
                    switch(random(2)){
                        [0] = function()
                            addv(random(7), "sm-v-duchodce0")
                        end,
                        [1] = function()
                            addv(random(7), "sm-v-duchodce1")
                        end,
                    }
                elseif room.sbirka == 0 then
                    room.sbirka = -1
                    addv(random(10), "sm-v-sbirka")
                    addm(random(7), "sm-m-namaloval")
                    if mic.beha == 1 then
                        addv(random(7), "sm-v-marnost")
                        addm(random(7), "sm-m-proc")
                        addv(random(7), "sm-v-podivej")
                        planDialogSet(random(7), "sm-x-meduza", 101, meduza, "keca")
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_meduza()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        meduza.afaze = 0
        meduza.keca = 0

        return function()
            if meduza.keca ~= 101 then
                if meduza.X == mic.X and meduza.Y == mic.Y - 3 then
                    mic.beha = 1
                    meduza.afaze = math.mod(meduza.afaze + 1, 3)
                    meduza:updateAnim()
                else
                    mic.beha = 0
                end
            else
                mic.beha = 0
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_mic()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        mic.beha = 1
        mic.afaze = 0

        return function()
            if mic.beha == 1 then
                mic.afaze = math.mod(mic.afaze + 1, 4)
                mic:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_meduza2()
        return function()
            if random(100) < 20 then
                meduza2.afaze = random(2)
                meduza2:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_meduza1()
        return function()
            if random(100) < 20 then
                meduza1.afaze = random(2)
                meduza1:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_stonozka()
        return function()
            if random(100) < 5 then
                stonozka.afaze = random(2)
                stonozka:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ostnatec()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        ostnatec.afaze = 0
        ostnatec.kukuc = randint(10, 30)

        return function()
            if ostnatec.kukuc > 0 and ostnatec.afaze ~= 0 then
                ostnatec.kukuc = ostnatec.kukuc - 1
            elseif ostnatec.kukuc == 0 then
                ostnatec.kukuc = randint(10, 30)
                ostnatec.afaze = 0
            elseif random(100) < 1 then
                ostnatec.afaze = random(2) + 1
            else
                ostnatec.afaze = 0
            end
            ostnatec:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_uhor()
        return function()
            if random(100) < 5 then
                uhor.afaze = random(2)
                uhor:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_budik()
        return function()
            switch(math.mod(game_getCycles(), 9)){
                [0] = function()
                    budik.afaze = 0
                end,
                [5] = function()
                    budik.afaze = 1
                end,
            }
            budik:updateAnim()

            if not budik:isTalking() then
                budik:planDialog(0, "sm-x-tiktak")
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
    subinit = prog_init_meduza()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_mic()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_meduza2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_meduza1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_stonozka()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ostnatec()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_uhor()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_budik()
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

