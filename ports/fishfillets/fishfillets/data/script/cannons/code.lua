
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky06.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        if random(100) < 50 then
            room.uvod = 0
        else
            room.uvod = 1
        end
        room.tuseni = 0
        room.jo = 0
        room.pocitadlo = random(500) + 500

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                switch(room.uvod){
                    [0] = function()
                        addv(20 + random(30), "del-v-dve")
                        addm(random(5), "del-m-voda")
                        room.uvod = 2
                    end,
                    [1] = function()
                        addm(20 + random(30), "del-m-ci")
                        addv(random(5), "del-v-splet")
                        room.uvod = 2
                    end,
                }
                if room.pocitadlo < 1 and room.tuseni == 0 then
                    addv(random(5), "del-v-mec")
                    addm(random(5), "del-m-tus")
                    room.tuseni = 1
                end
                room.pocitadlo = room.pocitadlo - 1
            elseif isReady(small) and big:isOut() and room.jo == 0 and (small.X < 2 or small.X > 25) then
                small:setBusy(true)
                switch(random(2)){
                    [0] = function()
                        addm(0, "del-m-jedn0")
                    end,
                    [1] = function()
                        addm(0, "del-m-jedn1")
                    end,
                }
                addm(random(5), "del-m-jedn2")
                room.jo = 1
                planBusy(small, false)
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_delo1()
        return function()
            switch(math.mod(game_getCycles() + 1, 4)){
                [0] = function()
                    delo1.afaze = 2
                end,
                [2] = function()
                    delo1.afaze = 2
                end,
                [1] = function()
                    delo1.afaze = 0
                end,
                [3] = function()
                    delo1.afaze = 1
                end,
            }
            delo1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_delo3()
        return function()
            switch(math.mod(game_getCycles(), 4)){
                [0] = function()
                    delo3.afaze = 2
                end,
                [2] = function()
                    delo3.afaze = 2
                end,
                [1] = function()
                    delo3.afaze = 0
                end,
                [3] = function()
                    delo3.afaze = 1
                end,
            }
            delo3:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_delo2()
        return function()
            switch(math.mod(game_getCycles() + 3, 4)){
                [0] = function()
                    delo2.afaze = 2
                end,
                [2] = function()
                    delo2.afaze = 2
                end,
                [1] = function()
                    delo2.afaze = 0
                end,
                [3] = function()
                    delo2.afaze = 1
                end,
            }
            delo2:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_delo4()
        return function()
            switch(math.mod(game_getCycles() + 1, 4)){
                [0] = function()
                    delo4.afaze = 2
                end,
                [2] = function()
                    delo4.afaze = 2
                end,
                [1] = function()
                    delo4.afaze = 0
                end,
                [3] = function()
                    delo4.afaze = 1
                end,
            }
            delo4:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_delo1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_delo3()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_delo2()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_delo4()
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

