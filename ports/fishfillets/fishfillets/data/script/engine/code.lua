
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky13.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(2)

    WAS_SMALL = 1
    WAS_BIG = 2

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        switch(pokus){
            [1] = function()
                room.uvod = 2
            end,
            [2] = function()
                room.uvod = 1
            end,
            default = function()
                room.uvod = 3 + random(2)
            end,
        }
        if roompole[1] == 0 then
            room.omotoru = random(50) + 30
        else
            room.omotoru = random(200) + 50 * pokus
        end
        room.oklici = 0
        room.vypnula = -1
        room.zapnula = -1
        room.jeli = 0
        local who = WAS_SMALL
        local radius = 0

        return function()
            if small.dir ~= dir_no then
                who = WAS_SMALL
            elseif big.dir ~= dir_no then
                who = WAS_BIG
            end
            if klicek.X + 2 == motorek.X and klicek.Y - 2 == motorek.Y then
                room.vypnula = 0
                if room.zapnula == 0 then
                    game_killPlan()
                    room.zapnula = who
                end
                roompole[1] = 1
                if not klicek:isTalking() then
                    klicek:talk("mot-x-motor", VOLUME_FULL, -1)
                end
                if math.mod(game_getCycles(), 3) == 0 then
                    if radius < 30 then
                        radius = radius + 2
                    end
                    roompole[0] = roompole[0] + 1
                    pom1 = roompole[0]
                    local left = radius * math.sin(pom1 / 20 * math.pi)
                    local top = radius * math.cos(pom1 / 20 * math.pi)
                    game_setScreenShift(left, top)
                end
            else
                room.zapnula = 0
                if room.vypnula == 0 then
                    room.vypnula = who
                    game_killPlan()
                end
                if klicek:isTalking() then
                    klicek:killSound()
                end
                radius = 0
                game_setScreenShift(0, 0)
            end
            if no_dialog() and isReady(small) and isReady(big) then
                if room.omotoru > 0 then
                    room.omotoru = room.omotoru - 1
                end
                if room.omotoru >= 0 and (small.vylezla == 1 or big.vylezla == 1) then
                    room.omotoru = -1
                end
                if room.uvod > 0 then
                    adddel(random(50) + 10)
                    switch(room.uvod){
                        [1] = function()
                            addm(0, "mot-m-info")
                            addv(random(10), "mot-v-konvencni")
                        end,
                        [2] = function()
                            addm(0, "mot-m-tak")
                            addv(random(10), "mot-v-zavery")
                        end,
                        [3] = function()
                            switch(random(2)){
                                [0] = function()
                                    addm(0, "mot-m-info")
                                end,
                                [1] = function()
                                    addm(0, "mot-m-tak")
                                end,
                            }
                            switch(random(2)){
                                [0] = function()
                                    addv(random(10), "mot-v-konvencni")
                                end,
                                [1] = function()
                                    addv(random(10), "mot-v-zavery")
                                end,
                            }
                        end,
                    }
                    room.uvod = 0
                elseif room.omotoru == 0 then
                    room.omotoru = -1
                    switch(roompole[1]){
                        [0] = function()
                            addm(30, "mot-m-akce"..random(3))
                            addv(random(10), "mot-v-funkce"..random(3))
                        end,
                        [1] = function()
                            addv(30, "mot-v-znovu"..random(2))
                        end,
                    }
                end
                if room.oklici == 0 and small.dir ~= dir_no and klicisko.dir ~= dir_no and random(100) < 7 then
                    room.oklici = 1
                    if random(100) < 35 then
                        addv(5, "mot-v-klic")
                        addm(7, "mot-m-ublizit")
                    end
                elseif room.zapnula > 0 then
                    if room.jeli == 0 then
                        pom1 = 1
                    else
                        pom1 = random(4)
                    end
                    room.jeli = 1
                    if pom1 == 1 or pom1 == 2 then
                        switch(room.zapnula){
                            [WAS_SMALL] = function()
                                addv(random(20) + 10, "mot-v-zvuky"..random(2))
                                if pom1 == 1 then
                                    addm(random(10) + 10, "mot-m-nemuzu"..random(2))
                                end
                            end,
                            [WAS_BIG] = function()
                                addm(random(20) + 10, "mot-m-zvuky"..random(2))
                                addv(random(10) + 10, "mot-v-nemuzu"..random(2))
                            end,
                        }
                    elseif pom1 == 3 then
                        addm(random(30) + 20, "mot-m-mayday")
                    end
                    room.zapnula = -1
                elseif room.vypnula > 0 then
                    if room.jeli == 1 or random(100) < 60 then
                        switch(room.vypnula){
                            [WAS_SMALL] = function()
                                addv(random(10) + 5, "mot-v-konecne"..random(2))
                            end,
                            [WAS_BIG] = function()
                                addm(random(10) + 5, "mot-m-konecne"..random(2))
                            end,
                        }
                    end
                    if room.jeli == 1 then
                        room.jeli = 2
                    end
                    room.vypnula = -1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_klicek()
        return function()
            if klicek:isTalking() then
                if klicek.afaze == 2 then
                    klicek.afaze = 0
                else
                    klicek.afaze = klicek.afaze + 1
                end
            elseif klicek.afaze == 1 then
                klicek.afaze = 2
            end
            klicek:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        small.vylezla = 0

        return function()
            if small.X == 35 then
                small.vylezla = 1
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_big()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        big.vylezla = 0

        return function()
            if big.X == 8 then
                big.vylezla = 1
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
    subinit = prog_init_klicek()
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

