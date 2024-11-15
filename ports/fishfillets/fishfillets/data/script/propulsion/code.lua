
file_include('script/share/prog_border.lua')

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky14.ogg")
    local pokus = getRestartCount()

    --NOTE: a final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    veve:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.oprojektu = random(10 * pokus) + 10 * pokus
        room.oforme = random(1500) + 300
        room.ohadce = random(3000) + 1000
        room.obadva = 0
        room.kteraprosba = 0

        return function()
            if stdBorderReport() then
                addv(random(10) + 5, "poh-v-ukol")
            end
            if no_dialog() and isReady(big) and isReady(small) then
                if room.oprojektu > 0 then
                    room.oprojektu = room.oprojektu - 1
                end
                if room.oforme > 0 then
                    room.oforme = room.oforme - 1
                end
                if room.ohadce > 0 then
                    room.ohadce = room.ohadce - 1
                end
                if room.uvod == 0 then
                    room.uvod = 1
                    adddel(10 + random(14))
                    switch(pokus){
                        [1] = function()
                            pom1 = 3
                        end,
                        [2] = function()
                            pom1 = random(2) + 1
                        end,
                        default = function()
                            if random(100) < 30 then
                                pom1 = random(2) + 1
                            end
                        end,
                    }
                    if odd(pom1) then
                        addv(5, "poh-v-takhle")
                    end
                    if pom1 >= 2 then
                        addm(5, "poh-m-tosnadne")
                    end
                    if pom1 > 0 and random(100) < 100 / pokus then
                        addv(10, "poh-v-biosila")
                        if pokus == 1 or random(100) < 20 then
                            addm(random(40) + 10, "poh-m-reaktor")
                            addv(7, "poh-v-automat")
                            addm(random(20) + 7, "poh-m-motor")
                            addv(7, "poh-v-tocit")
                        end
                    end
                elseif room.oprojektu == 0 then
                    room.oprojektu = -1
                    switch(pokus){
                        [1] = function()
                            pom1 = 6
                        end,
                        [2] = function()
                            pom1 = randint(4, 6)
                        end,
                        [3] = function()
                            pom1 = randint(2, 6)
                        end,
                        [4] = function()
                            pom1 = randint(1, 6)
                        end,
                        default = function()
                            pom1 = randint(0, 6)
                        end,
                    }
                    adddel(10)
                    if pom1 >= 5 then
                        addv(0, "poh-v-neuveri")
                    end
                    if pom1 >= 6 then
                        addm(5, "poh-m-projekt")
                    end
                    if pom1 >= 1 then
                        addv(10, "poh-v-zarizeni")
                    end
                    if pom1 >= 4 then
                        addm(4, "poh-m-sest")
                    end
                    if pom1 >= 2 then
                        addv(10, "poh-v-klec")
                    end
                    if pom1 >= 3 then
                        addm(6, "poh-m-dobre")
                    end
                elseif room.oforme == 0 then
                    addv(20, "poh-v-forma")
                    addm(3, "poh-m-princip")
                    addv(random(30) + 10, "poh-v-pomoct")
                    room.oforme = -1
                elseif (smutny.hybese == 1 or nasrany.hybese == 1) and small.dir ~= dir_no then
                    if room.kteraprosba == 0 then
                        room.kteraprosba = random(2) + 1
                    else
                        room.kteraprosba = 3 - room.kteraprosba
                    end
                    addm(0, "poh-m-dobryden"..(room.kteraprosba - 1))
                    if smutny.hybese == 1 then
                        smutny.hybese = 2
                    end
                    if nasrany.hybese == 1 then
                        nasrany.hybese = 2
                    end
                elseif room.ohadce == 0 then
                    room.ohadce = random(5000) + 2000
                    planSet(room, "obadva", 1)
                    adddel(random(100) + 50)
                    addm(0, "poh-m-pohadali")
                    if random(100) < 60 then
                        addv(10, "poh-v-setkani")
                        if random(100) < 60 then
                            addm(5, "poh-m-sestra")
                        end
                    end
                    adddel(random(100) + 50)
                    planSet(room, "obadva", 0)
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_veve()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        veve.cinnost = 0
        veve.vydrz = random(200) + 200

        return function()
            switch(veve.cinnost){
                [0] = function()
                    if 8 <= veve.afaze and veve.afaze <= 10 then
                        veve.afaze = veve.afaze + 1
                    else
                        veve.afaze = 8
                    end
                    if veve.vydrz > 0 then
                        veve.vydrz = veve.vydrz - 1
                    else
                        veve.cinnost = 1
                        veve.vydrz = 15 + random(20)
                    end
                end,
                [1] = function()
                    if odd(game_getCycles()) then
                        switch(veve.afaze){
                            [6] = function()
                                veve.afaze = 7
                            end,
                            default = function()
                                veve.afaze = 6
                            end,
                        }
                    end
                    if veve.vydrz > 0 then
                        veve.vydrz = veve.vydrz - 1
                    else
                        veve.cinnost = 2
                        veve.vydrz = 20 + random(25)
                    end
                end,
                [2] = function()
                    if math.mod(game_getCycles(), 4) == 0 then
                        switch(veve.afaze){
                            [6] = function()
                                veve.afaze = 7
                            end,
                            default = function()
                                veve.afaze = 6
                            end,
                        }
                    end
                    if veve.vydrz > 0 then
                        veve.vydrz = veve.vydrz - 1
                    else
                        veve.cinnost = 3
                        veve.vydrz = random(400) + 50
                        veve.kouka = 0
                        veve.makoukat = 0
                    end
                end,
                [3] = function()
                    if random(100) < 5 then
                        veve.makoukat = random(3)
                    end
                    if veve.kouka ~= veve.makoukat then
                        if veve.makoukat == 0 or veve.kouka == 0 then
                            veve.kouka = veve.makoukat
                        else
                            veve.kouka = 0
                        end
                    end
                    veve.afaze = 2 * veve.kouka
                    if random(100) < 5 then
                        veve.afaze = veve.afaze + 1
                    end
                    if veve.vydrz > 0 then
                        veve.vydrz = veve.vydrz - 1
                    else
                        veve.cinnost = 0
                        veve.vydrz = random(300) + 100
                    end
                end,
            }
            veve:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_bublik()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        bublik.bublat = -random(30) - 10

        return function()
            if bublik.bublat > 0 then
                pom1 = random(2) + 1
                if pom1 == bublik.afaze then
                    bublik.afaze = 3
                else
                    bublik.afaze = pom1
                end
            else
                bublik.afaze = 0
            end
            if bublik.bublat > 0 then
                bublik.bublat = bublik.bublat - 1
                if bublik.bublat == 0 then
                    bublik.bublat = -10 - random(30)
                end
            elseif bublik.bublat < 0 then
                bublik.bublat = bublik.bublat + 1
                if bublik.bublat == 0 then
                    bublik.bublat = 10 + random(30)
                end
            end
            bublik:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hadice()
        return function()
            if odd(game_getCycles()) and veve.cinnost == 0 and hadice.X + 2 == veve.X and hadice.Y == veve.Y + 1 and hadice.X == bublik.X + 1 and hadice.Y + 3 == bublik.Y then
                hadice.afaze = 1 - hadice.afaze
            end
            hadice:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_nasrany()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        nasrany.nohy = random(2) * 2
        nasrany.vyraz = random(4)
        nasrany.kamjde = nasrany.nohy
        nasrany.hybese = 0

        return function()
            switch(nasrany.hybese){
                [0] = function()
                    if nasrany.dir ~= dir_no then
                        nasrany.hybese = nasrany.hybese + 1
                    end
                end,
                [1] = function()
                    if nasrany.dir == dir_no then
                        nasrany.hybese = nasrany.hybese + 1
                    end
                end,
            }
            if room.obadva == 1 then
                nasrany.vyraz = 3
                if nasrany.nohy == 1 then
                    nasrany.nohy = nasrany.kamjde
                end
            else
                if nasrany.kamjde ~= nasrany.nohy then
                    if nasrany.kamjde == 1 or nasrany.nohy == 1 then
                        nasrany.nohy = nasrany.kamjde
                    else
                        nasrany.nohy = 1
                    end
                elseif math.mod(game_getCycles(), 3) == 0 and random(100) < 9 then
                    nasrany.vyraz = random(4)
                end
                if nasrany.vyraz ~= 4 and random(100) < 1 and not odd(nasrany.nohy) then
                    nasrany.kamjde = 2 - nasrany.nohy
                end
            end
            switch(nasrany.nohy){
                [0] = function()
                    nasrany.afaze = nasrany.vyraz
                end,
                [1] = function()
                    nasrany.afaze = 4 + nasrany.vyraz
                end,
                [2] = function()
                    nasrany.afaze = 7 + nasrany.vyraz
                end,
            }
            nasrany:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_smutny()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        smutny.strana = random(2)
        smutny.cinnost = 0
        smutny.vyraz = random(4) + 1
        smutny.hybese = 0

        return function()
            switch(smutny.hybese){
                [0] = function()
                    if smutny.dir ~= dir_no then
                        smutny.hybese = smutny.hybese + 1
                    end
                end,
                [1] = function()
                    if smutny.dir == dir_no then
                        smutny.hybese = smutny.hybese + 1
                    end
                end,
            }
            if room.obadva == 1 then
                smutny.vyraz = 4
            else
                switch(smutny.cinnost){
                    [0] = function()
                        if random(100) < 1 then
                            smutny.strana = 1 - smutny.strana
                        end
                        if random(1000) < 5 then
                            smutny.cinnost = 2
                        end
                    end,
                    [1] = function()
                        if random(100) < 5 then
                            smutny.cinnost = 0
                        end
                        if math.mod(game_getCycles(), 3) == 0 then
                            smutny.strana = 1 - smutny.strana
                        end
                    end,
                }
                if math.mod(game_getCycles(), 3) == 0 and random(100) < 6 then
                    smutny.vyraz = random(4) + 1
                end
            end
            if random(100) < 4 then
                smutny.afaze = smutny.strana * 5
            else
                smutny.afaze = smutny.strana * 5 + smutny.vyraz
            end
            smutny:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_plut1()
        return function()
            plut1.afaze = math.mod(plut1.afaze + 1, 3)
            plut1:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_veve()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_bublik()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hadice()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_nasrany()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_smutny()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_plut1()
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

