
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
    spunt:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.vratit = 0
        room.nechat = randint(1000, 2500)
        room.zatraceny = randint(2000, 4000)

        return function()
            if stdBorderReport() then
                addv(random(10) + 5, "sp-v-ven")
            end
            if isReady(small) and isReady(big) and no_dialog() then
                if room.nechat > 0 then
                    room.nechat = room.nechat - 1
                end
                if room.zatraceny > 0 then
                    room.zatraceny = room.zatraceny - 1
                end
                if room.uvod == 0 then
                    if pokus == 1 or random(100) < 70 then
                        switch(random(4)){
                            [0] = function()
                                addv(randint(20, 30), "sp-v-no0")
                            end,
                            [1] = function()
                                addm(randint(20, 30), "sp-m-no1")
                            end,
                            [2] = function()
                                addv(randint(20, 30), "sp-v-kdoby")
                            end,
                            [3] = function()
                                addm(randint(20, 30), "sp-m-neopatrnost")
                            end,
                        }
                        addv(random(10), "sp-v-zahynuli")
                        addm(random(8), "sp-m-vytazeny")
                        addv(random(8), "sp-v-trapne")
                    end
                    room.uvod = 1
                elseif room.vratit == 0 and random(100) < 1 then
                    room.vratit = 1
                    addm(random(5), "sp-m-costim")
                    switch(random(2)){
                        [0] = function()
                            addv(random(5), "sp-v-vratit0")
                            addm(random(5), "sp-m-vratit0")
                        end,
                        [1] = function()
                            addv(random(5), "sp-v-vratit1")
                            addm(random(5), "sp-m-vratit1")
                        end,
                    }
                    switch(random(4)){
                        [0] = function()
                            addm(random(5), "sp-m-kalet")
                            addv(random(5), "sp-v-pocit")
                            addm(random(5), "sp-m-potize")
                            addv(random(5), "sp-v-vzit")
                        end,
                        [1] = function()
                            addm(random(5), "sp-m-potize")
                            addv(random(5), "sp-v-vzit")
                        end,
                        [2] = function()
                            addm(random(5), "sp-m-kalet")
                            addv(random(5), "sp-v-vzit")
                        end,
                        [3] = function()
                            addm(random(5), "sp-m-potize")
                            addv(random(5), "sp-v-pocit")
                        end,
                    }
                    switch(random(2)){
                        [0] = function()
                            addm(random(5), "sp-m-taky")
                            addv(random(5), "sp-v-dotoho")
                        end,
                    }
                elseif room.nechat == 0 then
                    room.nechat = randint(500, 2000)
                    switch(random(2)){
                        [0] = function()
                            addm(random(5), "sp-m-nechat")
                            addv(random(5), "sp-v-centrala")
                        end,
                        [1] = function()
                            addv(random(5), "sp-v-jedno")
                            addm(random(5), "sp-m-vydrz")
                        end,
                    }
                elseif room.zatraceny == 0 then
                    room.zatraceny = randint(1000, 4000)
                    addm(random(5), "sp-m-spunt")
                    addv(random(7), "sp-v-co")
                    switch(random(5)){
                        [0] = function()
                            addm(random(7), "sp-m-vymluva0")
                        end,
                        [1] = function()
                            addm(random(7), "sp-m-vymluva1")
                        end,
                        [2] = function()
                            addm(random(7), "sp-m-vymluva2")
                        end,
                        [3] = function()
                            addm(random(7), "sp-m-vymluva3")
                        end,
                        [4] = function()
                            addm(random(7), "sp-m-vymluva4")
                        end,
                    }
                    if random(2) < 1 then
                        addv(random(7), "sp-v-nesmysl")
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_spunt()
        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab1.oci = 0
        krab1.spi = randint(2, 70)

        return function()
            if krab1.afaze == 1 and krab1.spi > 0 then
                krab1.spi = krab1.spi - 1
                krab1.afaze = 1
            elseif krab1.spi == 0 then
                krab1.spi = randint(2, 70)
                krab1.afaze = krab1.oci
            elseif random(100) < 5 then
                krab1.oci = random(5)
                if krab1.oci > 0 then
                    krab1.oci = krab1.oci + 1
                end
            elseif random(100) > 97 then
                krab1.afaze = 1
            else
                krab1.afaze = krab1.oci
            end
            krab1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava3()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hlava3.huba = 0
        hlava3.ksicht = randint(10, 100)

        return function()
            if hlava3.huba ~= 0 and hlava3.ksicht > 0 then
                hlava3.ksicht = hlava3.ksicht - 1
                hlava3.afaze = hlava3.huba
            elseif hlava3.ksicht == 0 then
                hlava3.ksicht = randint(10, 100)
                hlava3.huba = 0
            elseif random(1000) < 3 then
                hlava3.huba = random(2) + 1
            else
                hlava3.afaze = 0
            end
            hlava3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snecik1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snecik1.kouka = 0

        return function()
            if snecik1.dir ~= dir_no then
                snecik1.kouka = random(100) + 10
            elseif snecik1.kouka > 0 then
                snecik1.kouka = snecik1.kouka - 1
            end
            if snecik1.kouka > 0 then
                if snecik1.afaze < 2 then
                    snecik1.afaze = snecik1.afaze + 1
                end
            elseif snecik1.afaze > 0 then
                snecik1.afaze = snecik1.afaze - 1
            end
            snecik1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_krab2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        krab2.oci = 0
        krab2.spi = randint(2, 70)

        return function()
            if krab2.afaze == 1 and krab2.spi > 0 then
                krab2.spi = krab2.spi - 1
                krab2.afaze = 1
            elseif krab2.spi == 0 then
                krab2.spi = randint(2, 70)
                krab2.afaze = krab2.oci
            elseif random(100) < 5 then
                krab2.oci = random(5)
                if krab2.oci > 0 then
                    krab2.oci = krab2.oci + 1
                end
            elseif random(100) > 97 then
                krab2.afaze = 1
            else
                krab2.afaze = krab2.oci
            end
            krab2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_snecik2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        snecik2.kouka = 0

        return function()
            if snecik2.dir ~= dir_no then
                snecik2.kouka = random(100) + 10
            elseif snecik2.kouka > 0 then
                snecik2.kouka = snecik2.kouka - 1
            end
            if snecik2.kouka > 0 then
                if snecik2.afaze < 2 then
                    snecik2.afaze = snecik2.afaze + 1
                end
            elseif snecik2.afaze > 0 then
                snecik2.afaze = snecik2.afaze - 1
            end
            snecik2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hlava2.huba = 0
        hlava2.ksicht = randint(10, 100)

        return function()
            if hlava2.huba ~= 0 and hlava2.ksicht > 0 then
                hlava2.ksicht = hlava2.ksicht - 1
                hlava2.afaze = hlava2.huba
            elseif hlava2.ksicht == 0 then
                hlava2.ksicht = randint(10, 100)
                hlava2.huba = 0
            elseif random(1000) < 3 then
                hlava2.huba = random(2) + 1
            else
                hlava2.afaze = 0
            end
            hlava2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_hlava1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        hlava1.huba = 0
        hlava1.ksicht = randint(10, 100)

        return function()
            if hlava1.huba ~= 0 and hlava1.ksicht > 0 then
                hlava1.ksicht = hlava1.ksicht - 1
                hlava1.afaze = hlava1.huba
            elseif hlava1.ksicht == 0 then
                hlava1.ksicht = randint(10, 100)
                hlava1.huba = 0
            elseif random(1000) < 3 then
                hlava1.huba = random(2) + 1
            else
                hlava1.afaze = 0
            end
            hlava1:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_spunt()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snecik1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_krab2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_snecik2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_hlava1()
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

