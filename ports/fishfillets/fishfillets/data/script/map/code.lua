
file_include('script/share/prog_border.lua')

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky06.ogg")
    local pokus = getRestartCount()

    --NOTE: final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    mapous:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.poh = 0
        room.obec = 1000 + random(3000)
        room.utb = 0

        return function()
            pom2 = 0
            if no_dialog() and isReady(small) and isReady(big) then
                if stdBorderReport() then
                    addv(10, "map-v-ukol")
                elseif game_getCycles() == 10 + pokus then
                    pom2 = 1
                elseif room.poh == 0 and mapous.X ~= mapous.XStart then
                    pom2 = 6
                    room.poh = 1
                elseif room.utb == 0 and isIn(mapous.X, {1, 2, 28}) then
                    room.utb = 1
                    pom2 = 7
                elseif room.obec > 0 then
                    room.obec = room.obec - 1
                else
                    room.obec = 1000 + random(1000 + math.floor(game_getCycles() / 5))
                    pom2 = random(4) + 2
                end
            end
            switch(pom2){
                [1] = function()
                    if random(3) > 0 then
                        addv(7, "map-v-mapa")
                    else
                        addm(7, "map-m-mapa")
                    end
                    if pokus < 4 or random(100) < 60 then
                        addm(7, "map-m-ukol")
                        addv(7, "map-v-jasne")
                        addm(7, "map-m-neplacej")
                    end
                end,
                [2] = function()
                    addv(7, "map-v-cojetam")
                    addv(7, "map-v-poklady")
                    addm(7, "map-m-uvidime")
                end,
                [3] = function()
                    addm(7, "map-m-sneci")
                    planDialogSet(8, "map-x-hlemyzdi", 111, sneci, "mluvi")
                end,
                [4] = function()
                    addv(8, "map-v-oci")
                end,
                [5] = function()
                    addv(8, "map-v-restart")
                    addm(8, "map-m-pravidla")
                end,
                [6] = function()
                    addm(7, "map-m-pohnout")
                    addv(7, "map-v-dal")
                end,
                [7] = function()
                    addm(7, "map-m-uz")
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_mapous()
        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_voko1()
        local eyes = {voko1, voko2}

        return function()
            for key, eye in pairs(eyes) do
                if eye.anim == "" then
                    switch(random(7)){
                        [0] = function()
                            setanim(eye, "d?10-99a1d?2-3a2d?2-3a1d?2-3a2d?2-3a1d?2-3a2d?2-3a1d?2-3a2d?2-3a0")
                        end,
                        [1] = function()
                            setanim(eye, "d?10-99a3d?2-3a4d?2-3a3d?2-3a4d?2-3a3d?2-3a4d?2-3a3d?2-3a4d?2-3a0")
                        end,
                        [2] = function()
                            setanim(eye, "d?10-99a?1-4d?10-30a0")
                        end,
                        [3] = function()
                            setanim(eye, "d?10-99a?1-4d?10-30a0")
                        end,
                        [4] = function()
                            setanim(eye, "d?10-99a3a1a4a1a3a2a4a1a3a1a4a1a3a1a4a1a0")
                        end,
                        [5] = function()
                            setanim(eye, "d?10-99a3a1a4a1a3a2a4a1a3a1a4a1a3a1a4a1a0")
                        end,
                        [6] = function()
                            setanim(eye, "d?10-99a?0-4d?2-8a?0-4d?2-8a?0-4d?2-8a?0-4d?2-8a0")
                        end,
                    }
                end
                goanim(eye)
                eye:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kr1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        setanim(kr1, "d?1-50a0a1a2a3d1a3a2a1a0R")

        return function()
            goanim(kr1)
            kr1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kr2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        setanim(kr2, "d?1-50a0a1a2a3d1a3a2a1a0R")

        return function()
            goanim(kr2)
            kr2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_sneci()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        sneci.mluvi = 0
        local snails = {}
        for i = 0, 8 do
            snails[i] = getModelsTable()[sneci.index + i]
        end

        return function()
            for key, snail in pairs(snails) do
                if sneci.mluvi ~= 0 or snail.dir ~= dir_no then
                    snail.afaze = 2
                else
                    switch(snail.afaze){
                        [0] = function()
                            if random(100) == 1 then
                                snail.afaze = 1
                            end
                        end,
                        [1] = function()
                            switch(random(6)){
                                [1] = function()
                                    snail.afaze = 3
                                end,
                                [2] = function()
                                    snail.afaze = 2
                                end,
                            }
                        end,
                        [2] = function()
                            if random(10) == 1 then
                                snail.afaze = 1
                            end
                        end,
                        [3] = function()
                            if random(4) == 1 then
                                snail.afaze = 0
                            end
                        end,
                    }
                end
                snail:updateAnim()
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
    subinit = prog_init_mapous()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_voko1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kr1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_kr2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_sneci()
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

