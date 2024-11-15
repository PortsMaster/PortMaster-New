
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky14.ogg")
    local pokus = getRestartCount()
    local roompole = createArray(1)


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.ooku = 0
        room.osedadle = 0

        return function()
            if isReady(small) and isReady(big) and no_dialog() then
                if room.uvod == 0 then
                    room.uvod = 1
                    if pokus > 1 then
                        adddel(10 * pokus)
                    end
                    if random(100) < 110 - 10 * pokus then
                        addm(20 + random(30), "let-m-divna")
                    end
                    if roompole[0] == 0 then
                        pom1 = random(3)
                    else
                        pom1 = random(2)
                        if roompole[0] == pom1 + 10 then
                            pom1 = 2
                        end
                    end
                    roompole[0] = pom1 + 10
                    addv(random(10) + 5, "let-v-vrak"..pom1)
                elseif room.ooku == 0 and ocicko.X >= 23 and random(100) < 1 then
                    addv(random(30), "let-v-oko")
                    addm(5, "let-m-oko")
                    room.ooku = 1
                elseif (sed1.dir ~= dir_no or sed2.dir ~= dir_no or sed3.dir ~= dir_no) and small.dir ~= dir_no and random(100) < 1 then
                    addm(0, "let-m-sedadlo")
                    if room.osedadle == 0 or random(100) < 30 then
                        addv(5 + random(15), "let-v-budrada")
                    end
                    room.osedadle = room.osedadle + 1
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ocicko()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        ocicko.cinnost = 0

        return function()
            local cinnost_table = {
                [0] = function()
                    if random(100) < 10 then
                        switch(random(8)){
                            [0] = function()
                                ocicko.citac = random(5) + 5
                                ocicko.cinnost = 1
                                ocicko.faze = random(2) * 2
                            end,
                            [1] = function()
                                ocicko.citac = random(5) + 5
                                ocicko.cinnost = 1
                                ocicko.faze = random(2) * 2
                            end,
                            [2] = function()
                                ocicko.citac = random(5) + 5
                                ocicko.cinnost = 1
                                ocicko.faze = random(2) * 2
                            end,
                            [3] = function()
                                ocicko.citac = random(3) + 2
                                ocicko.cinnost = 2
                                ocicko.faze = random(2) * 2
                            end,
                            [4] = function()
                                ocicko.citac = random(12) + 12
                                ocicko.cinnost = 3 + random(2)
                            end,
                            [5] = function()
                                ocicko.citac = random(12) + 12
                                ocicko.cinnost = 3 + random(2)
                            end,
                            [6] = function()
                                ocicko.citac = random(12) + 12
                                ocicko.cinnost = 3 + random(2)
                            end,
                            [7] = function()
                                ocicko.citac = random(10) + 2
                                ocicko.cinnost = 5
                            end,
                        }
                    end
                end,
                [1] = function()
                    switch(ocicko.faze){
                        [0] = function()
                            if ocicko.cinnost == 1 then
                                ocicko.afaze = 1
                            else
                                ocicko.afaze = 3
                            end
                            if random(100) < 20 then
                                ocicko.faze = ocicko.faze + 1
                            end
                        end,
                        [1] = function()
                            ocicko.afaze = 0
                            ocicko.faze = ocicko.faze + 1
                        end,
                        [2] = function()
                            if ocicko.cinnost == 1 then
                                ocicko.afaze = 2
                            else
                                ocicko.afaze = 4
                            end
                            if random(100) < 20 then
                                ocicko.faze = ocicko.faze + 1
                            end
                        end,
                        [3] = function()
                            ocicko.afaze = 0
                            ocicko.citac = ocicko.citac - 1
                            if ocicko.citac == 0 then
                                ocicko.cinnost = 0
                            else
                                ocicko.faze = 0
                            end
                        end,
                    }
                end,
                [3] = function()
                    switch(ocicko.cinnost){
                        [3] = function()
                            switch(ocicko.afaze){
                                [0] = function()
                                    ocicko.afaze = random(4) + 1
                                end,
                                [1] = function()
                                    ocicko.afaze = 3
                                end,
                                [2] = function()
                                    ocicko.afaze = 4
                                end,
                                [3] = function()
                                    ocicko.afaze = 2
                                end,
                                [4] = function()
                                    ocicko.afaze = 1
                                end,
                            }
                        end,
                        [4] = function()
                            switch(ocicko.afaze){
                                [0] = function()
                                    ocicko.afaze = random(4) + 1
                                end,
                                [1] = function()
                                    ocicko.afaze = 4
                                end,
                                [2] = function()
                                    ocicko.afaze = 3
                                end,
                                [3] = function()
                                    ocicko.afaze = 1
                                end,
                                [4] = function()
                                    ocicko.afaze = 2
                                end,
                            }
                        end,
                        [5] = function()
                            if random(100) < 40 then
                                ocicko.afaze = random(5)
                            end
                        end,
                    }
                    ocicko.citac = ocicko.citac - 1
                    if ocicko.citac == 0 then
                        ocicko.cinnost = 0
                        ocicko.afaze = 0
                    end
                end,
            }

            cinnost_table[2] = cinnost_table[1]
            cinnost_table[4] = cinnost_table[3]
            cinnost_table[5] = cinnost_table[3]

            switch(ocicko.cinnost)(cinnost_table)
            ocicko:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ocicko()
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

