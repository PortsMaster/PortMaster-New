
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky10.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.posl = 2
        pom1 = 0
        local rand1 = random(pokus + 1)
        if isIn(rand1, {0, 2, 4, 10, 20, 30, 50}) then
            addv(random(30), "tru-v-nasly")
            addm(7, "tru-m-co")
            if random(2) == 1 then
                addv(10 + random(6), "tru-v-poklad")
            else
                addv(10 + random(6), "tru-v-gral")
            end
            if random(5) == 1 then
                addm(7, "tru-m-zrada")
            end
            pom1 = 1
        elseif isIn(rand1, {1, 3, 5, 11, 43}) then
            addv(random(30), "tru-v-vkupe")
            if random(3) > 0 then
                addm(8, "tru-m-zrada")
            end
            pom1 = 1
        end
        if pom1 == 1 then
            addm(10 + random(10), "tru-m-oznamit")
            if pokus < 3 or random(6) > 0 then
                addv(5 + random(5), "tru-v-stacit")
                addm(7 + random(6), "tru-m-zpochybnit")
            end
            addv(8 + random(9), "tru-v-nejspis")
            if random(2) == 1 then
                addm(9, "tru-m-nejistota")
            end
        end

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                pom1 = room.posl
                while pom1 == room.posl do
                    pom1 = random(4)
                end
                room.posl = pom1
                switch(pom1){
                    [0] = function()
                        addm(500 + random(1000), "tru-m-truhla"..random(2))
                        addv(10 + random(14), "tru-v-truhla"..random(2))
                    end,
                    [1] = function()
                        addm(500 + random(1000), "tru-m-vzit"..random(3))
                        addv(10, "tru-v-vzit"..random(3))
                    end,
                    [2] = function()
                        addv(500 + random(1000), "tru-v-zrak")
                    end,
                    [3] = function()
                        addm(500 + random(1000), "tru-m-trpyt")
                    end,
                }
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_drahokamy()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        local gems = {}
        for pom1 = 1, 10 do
            gem = getModelsTable()[pom1]
            gems[pom1] = gem
            gem.glob = -random(100)
        end

        return function()
            for key, gem in pairs(gems) do
                gem.glob = gem.glob + 1
                if isIn(gem.glob, {1, 2, 3}) then
                    gem.afaze = gem.afaze + 1
                elseif isIn(gem.glob, {4, 5, 6}) then
                    gem.afaze = gem.afaze - 1
                elseif gem.glob == 7 then
                    gem.glob = -random(100) - 10
                end
                gem:updateAnim()
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_prsten()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        prsten.afaze = 3
        prsten:updateAnim()

        return function()
            switch(prsten.afaze){
                [0] = function()
                    if random(5) < 2 then
                        prsten.afaze = 3
                    else
                        prsten.afaze = 1
                    end
                end,
                [1] = function()
                    if random(4) < 2 then
                        prsten.afaze = 0
                    else
                        prsten.afaze = 2
                    end
                end,
                [2] = function()
                    if random(3) < 2 then
                        prsten.afaze = 1
                    end
                end,
                [4] = function()
                    if random(5) < 2 then
                        prsten.afaze = 3
                    else
                        prsten.afaze = 5
                    end
                end,
                [5] = function()
                    if random(4) < 2 then
                        prsten.afaze = 4
                    end
                end,
                [3] = function()
                    switch(random(20)){
                        [1] = function()
                            prsten.afaze = 0
                        end,
                        [2] = function()
                            prsten.afaze = 4
                        end,
                    }
                end,
            }
            prsten:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_koruna1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        koruna1.blesk = 0

        return function()
            switch(koruna1.blesk){
                [0] = function()
                    switch(random(20)){
                        [1] = function()
                            koruna1.blesk = 1
                            koruna1.afaze = 1
                        end,
                        [2] = function()
                            koruna1.blesk = 1
                            koruna1.afaze = 4
                        end,
                    }
                end,
                [1] = function()
                    switch(koruna1.afaze){
                        [1] = function()
                            koruna1.afaze = 2
                        end,
                        [2] = function()
                            koruna1.afaze = 3
                        end,
                        [3] = function()
                            koruna1.blesk = 2
                        end,
                        [4] = function()
                            koruna1.afaze = 5
                        end,
                        [5] = function()
                            koruna1.blesk = 2
                        end,
                    }
                end,
                [2] = function()
                    switch(koruna1.afaze){
                        [1] = function()
                            koruna1.afaze = 0
                        end,
                        [0] = function()
                            koruna1.blesk = 0
                        end,
                        [2] = function()
                            koruna1.afaze = 1
                        end,
                        [3] = function()
                            koruna1.afaze = 2
                        end,
                        [4] = function()
                            koruna1.afaze = 0
                        end,
                        [5] = function()
                            koruna1.afaze = 4
                        end,
                    }
                end,
            }
            koruna1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_koruna2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        koruna2.blesk = 0

        return function()
            switch(koruna2.blesk){
                [0] = function()
                    switch(random(20)){
                        [1] = function()
                            koruna2.blesk = 1
                            koruna2.afaze = 1
                        end,
                        [2] = function()
                            koruna2.blesk = 1
                            koruna2.afaze = 4
                        end,
                    }
                end,
                [1] = function()
                    switch(koruna2.afaze){
                        [1] = function()
                            koruna2.afaze = 2
                        end,
                        [2] = function()
                            koruna2.afaze = 3
                        end,
                        [3] = function()
                            koruna2.blesk = 2
                        end,
                        [4] = function()
                            koruna2.afaze = 5
                        end,
                        [5] = function()
                            koruna2.blesk = 2
                        end,
                    }
                end,
                [2] = function()
                    switch(koruna2.afaze){
                        [1] = function()
                            koruna2.afaze = 0
                        end,
                        [0] = function()
                            koruna2.blesk = 0
                        end,
                        [2] = function()
                            koruna2.afaze = 1
                        end,
                        [3] = function()
                            koruna2.afaze = 2
                        end,
                        [4] = function()
                            koruna2.afaze = 0
                        end,
                        [5] = function()
                            koruna2.afaze = 4
                        end,
                    }
                end,
            }
            koruna2:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_drahokamy()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_prsten()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_koruna1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_koruna2()
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

