
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.uvod = 0
        room.do_prace = 0
        room.znovu = 0
        room.dilna = 0
        room.zvedni = 0

        return function()
            if isReady(small) and isReady(big) then
                if not level_isShowing() and small.X == 25 and small.Y == 23 and big.X == 27 and big.Y == 21 then
                    if not big:isLeft() then
                        level_planShow(function(count)
                            return level_action_move('L')
                        end)
                    end
                    file_include("script/"..codename.."/demo_help.lua")
                end
                if not level_isShowing() and no_dialog() then
                    if room.uvod == 0 then
                        switch(pokus){
                            [1] = function()
                                addm(6, "kuf-m-je")
                                addv(4, "kuf-v-noco")
                                addv(9, "kuf-v-hod")
                            end,
                            [2] = function()
                                addv(9, "kuf-v-hod")
                            end,
                            default = function()
                                switch(random(3)){
                                    [0] = function()
                                    end,
                                    [1] = function()
                                        addv(9, "kuf-v-hod")
                                    end,
                                    [2] = function()
                                        addm(6, "kuf-m-je")
                                    end,
                                }
                            end,
                        }
                        room.uvod = 1
                    elseif room.do_prace == 0 and kufr.hotovo == 1 then
                        switch(pokus){
                            [1] = function()
                                addv(10, "kuf-v-doprace")
                            end,
                            [2] = function()
                                addv(10, "kuf-v-dotoho")
                            end,
                            default = function()
                                switch(random(2)){
                                    [0] = function()
                                        addv(10, "kuf-v-doprace")
                                    end,
                                    [1] = function()
                                        addv(10, "kuf-v-dotoho")
                                    end,
                                }
                            end,
                        }
                        addm(5, "kuf-m-ven")
                        addv(0, "kuf-v-ukol")
                        room.do_prace = 1
                    elseif room.znovu == 0 and room.do_prace == 1 and room.dilna == 0 and random(100) < 5 then
                        switch(pokus){
                            [1] = function()
                                addv(20, "kuf-v-jeste")
                                addm(2, "kuf-m-disk")
                                addv(6, "kuf-v-restart")
                                addm(3, "kuf-m-pravda")
                            end,
                        }
                        room.znovu = 1
                    elseif room.dilna == 0 and room.znovu == 1 and (small.Y >= 22 or big.Y >= 22) then
                        addm(30, "kuf-m-dodilny")
                        addv(5, "kuf-v-napad")
                        room.dilna = 1
                    elseif room.zvedni == 0 and ocel.Y == 18 and small.Y >= 22 and small.Y <= 24 and small.X >= 29 and small.X <= 30 then
                        room.zvedni = 1
                        addm(0, "kuf-m-nezvednu")
                    elseif room.zvedni <= 1 and ocel.Y == 16 and random(100) < 7 then
                        room.zvedni = 2
                        addm(0, "kuf-m-kousek")
                    end
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_kufr()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        kufr.faze = 0
        kufr.hotovo = 0

        return function()
            local anim_table = {
                [0] = function()
                    if kufr.dir == dir_down then
                        kufr.faze = kufr.faze + 1
                    end
                end,
                [1] = function()
                    kufr.afaze = 0
                    if kufr.dir == dir_no then
                        kufr.faze = kufr.faze + 1
                    end
                end,
                [2] = function()
                    kufr.afaze = kufr.faze - 2
                    kufr.faze = kufr.faze + 1
                end,
                [7] = function()
                    kufr.delay = 3
                    kufr.faze = kufr.faze + 1
                end,
                [8] = function()
                    if kufr.delay > 0 then
                        kufr.delay = kufr.delay - 1
                    else
                        level_newDemo("script/"..codename.."/demo_briefcase.lua")
                        kufr.faze = kufr.faze + 1
                    end
                end,
                [9] = function()
                    kufr.delay = 4
                    kufr.faze = kufr.faze + 1
                end,
                [10] = function()
                    if kufr.delay > 0 then
                        kufr.delay = kufr.delay - 1
                    else
                        kufr.afaze = 13 - kufr.faze
                        kufr.faze = kufr.faze + 1
                    end
                end,
                [14] = function()
                    kufr.delay = 37
                    kufr.faze = kufr.faze + 1
                end,
                [15] = function()
                    if kufr.delay > 0 then
                        kufr.delay = kufr.delay - 1
                    else
                        kufr.faze = kufr.faze + 1
                    end
                end,
                [16] = function()
                    kufr.afaze = kufr.faze - 11
                    kufr.faze = kufr.faze + 1
                end,
                [22] = function()
                    kufr.afaze = 0
                    kufr.faze = kufr.faze + 1
                    kufr.hotovo = 1
                end,
            }
            anim_table[3] = anim_table[2]
            anim_table[4] = anim_table[2]
            anim_table[5] = anim_table[2]
            anim_table[6] = anim_table[2]

            anim_table[11] = anim_table[10]
            anim_table[12] = anim_table[10]
            anim_table[13] = anim_table[10]

            anim_table[17] = anim_table[16]
            anim_table[18] = anim_table[16]
            anim_table[19] = anim_table[16]
            anim_table[20] = anim_table[16]
            anim_table[21] = anim_table[16]
            switch(kufr.faze)(anim_table)

            kufr:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_ocel()
        return function()
            if ocel.dir ~= dir_no then
                room.dilna = 1
                room.do_prace = 1
                room.znovu = 1
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
    subinit = prog_init_kufr()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_ocel()
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

