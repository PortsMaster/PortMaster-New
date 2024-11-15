
file_include('script/share/prog_border.lua')

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky15.ogg")
    local pokus = getRestartCount()

    --NOTE: a final level
    small:setGoal("goal_alive")
    big:setGoal("goal_alive")
    disketa:setGoal("goal_out")

    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false
        local roompole = 0

        if pokus > 7 and odd(pokus) then
            room.uvod = 1
        else
            room.uvod = 0
        end
        room.zv = 0
        room.kr = 0
        room.obecna = 500 + random(2000)
        room.nepo = 0

        return function()
            pom2 = 0
            if no_dialog() and isReady(small) and isReady(big) then
                if room.uvod == 0 and random(50) == 1 then
                    room.uvod = 1
                    pom2 = 1
                elseif room.zv == 0 and dist(small, disketa) < 3 and random(30) == 1 then
                    room.zv = 1
                    roompole = roompole + 1
                    if odd(roompole) or roompole == 2 then
                        pom2 = 2
                    end
                elseif room.kr == 0 and dist(big, ocelkriz) < 2 and random(60) == 1 then
                    room.kr = 1
                    pom2 = 3
                elseif room.nepo == 0 and (dist(small, svab) < 2 or dist(big, svab) < 2) and random(20) == 1 then
                    room.nepo = 1
                    pom2 = 7
                elseif room.nepo == 2 then
                    room.nepo = 3
                    pom2 = 8
                elseif math.mod(svab.pohyby, 121) == 120 then
                    svab.pohyby = svab.pohyby + 1
                    pom2 = 9
                elseif stdBorderReport() then
                    addm(13, "disk-m-ukol")
                elseif room.obecna > 0 then
                    room.obecna = room.obecna - 1
                else
                    room.obecna = 1500 + random(game_getCycles())
                    pom2 = random(3) + 4
                end
            end
            switch(pom2){
                [1] = function()
                    addv(10, "disk-v-tady")
                    addm(8, "disk-m-tady")
                    addm(6, "disk-m-vejit")
                    addv(8, "disk-v-metrova")
                    addm(6, "disk-m-velka")
                    if random(pokus + 1) < 2 then
                        addm(20, "disk-m-ukol")
                    end
                end,
                [2] = function()
                    addm(10, "disk-m-zvednem")
                    addv(7, "disk-v-tezko")
                    if random(4) > 0 then
                        addv(8, "disk-v-nejde")
                    end
                end,
                [3] = function()
                    addv(10, "disk-v-kriz")
                    addm(7, "disk-m-depres")
                end,
                [4] = function()
                    addm(10, "disk-m-nahrat")
                    addv(7, "disk-v-mas")
                    addm(10, "disk-m-sakra")
                    addv(7, "disk-v-vratime")
                    addv(10, "disk-v-naano")
                end,
                [5] = function()
                    addm(10, "disk-m-zmatlo")
                    addv(7, "disk-v-neverim")
                end,
                [6] = function()
                    addm(10, "disk-m-tvorecci")
                    addv(8, "disk-v-viry")
                    addm(9, "disk-m-potvory")
                    addv(8, "disk-v-pozor")
                end,
                [7] = function()
                    planDialogSet(10, "disk-x-nepohnes", 120, svab, "stav")
                end,
                [8] = function()
                    if random(4) > 0 then
                        planDialogSet(3, "disk-x-jejda"..random(2), 120, svab, "stav")
                    end
                    if random(4) > 0 then
                        planDialogSet(6, "disk-x-mazany", 120, svab, "stav")
                    end
                end,
                [9] = function()
                    planDialogSet(3, "disk-x-uzne", 120, svab, "stav")
                    if random(3) > 0 then
                        addv(7, "disk-v-ulamu")
                    end
                end,
            }
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_disketa()
        return function()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vir1()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        vir1.stav = 1
        vir1.oci = 0
        vir1.huba = 0

        return function()
            switch(vir1.stav){
                [0] = function()
                    if no_dialog() and random(600) == 1 then
                        pom1 = random(3)
                        pom2 = random(3)
                        planSet(vir1, "stav", 110)
                        vir1:planDialog(2, "disk-x-vir"..pom1)
                        if pom1 ~= pom2 then
                            vir1:planDialog(4, "disk-x-vir"..pom2)
                        end
                        adddel(2)
                        planSet(vir1, "stav", 0)
                    elseif random(4) == 1 then
                        vir1.oci = random(3)
                    end
                end,
                [1] = function()
                    if vir1.dir ~= dir_no and game_getCycles() > 10 then
                        vir1.stav = 0
                    else
                        if random(4) == 1 then
                            vir1.oci = random(3)
                        end
                        if vir1.huba == 0 then
                            vir1.huba = 2
                        elseif random(3) == 1 then
                            vir1.huba = 3 - vir1.huba
                        end
                    end
                end,
            }
            if vir1.stav < 2 then
                vir1.huba = 0
            end
            vir1.afaze = vir1.huba * 3 + vir1.oci
            vir1:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_svab()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        svab.stav = 1
        svab.pam = 0
        svab.pohyby = 0

        return function()
            switch(svab.stav){
                [0] = function()
                    if random(100) == 1 then
                        svab.stav = 1
                        svab.afaze = 3
                    elseif svab.afaze == 3 then
                        if random(2) == 1 then
                            svab.afaze = 3
                        else
                            svab.afaze = 2
                        end
                    elseif random(7) == 1 then
                        svab.afaze = 3
                    else
                        svab.afaze = 2
                    end
                end,
                [1] = function()
                    if random(1000) == 1 then
                        svab.stav = 0
                    else
                        svab.afaze = 0
                    end
                end,
                default = function()
                    if svab.afaze == 2 then
                        if random(3) == 1 then
                            svab.afaze = 1
                        else
                            svab.afaze = 2
                        end
                    elseif random(3) == 1 then
                        svab.afaze = 2
                    else
                        svab.afaze = 1
                    end
                end,
            }
            if game_getCycles() > 20 then
                if svab.dir ~= dir_no then
                    if room.nepo < 2 then
                        room.nepo = 2
                    end
                    svab.pohyby = svab.pohyby + 1
                end
                if svab.dir == dir_down then
                    svab.pam = 1
                elseif svab.pam == 1 then
                    svab.pam = 0
                    if no_dialog() then
                        planDialogSet(0, "disk-x-au"..random(3), 120, svab, "stav")
                    end
                end
            end
            svab:updateAnim()
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_vir2()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        vir2.stav = 1
        vir2.oci = 0
        vir2.huba = 0

        return function()
            switch(vir2.stav){
                [0] = function()
                    if no_dialog() and random(600) == 1 then
                        pom1 = random(3)
                        pom2 = random(3)
                        planSet(vir2, "stav", 110)
                        vir2:planDialog(2, "disk-x-vir"..pom1)
                        if pom1 ~= pom2 then
                            vir2:planDialog(4, "disk-x-vir"..pom2)
                        end
                        adddel(2)
                        planSet(vir2, "stav", 0)
                    elseif random(4) == 1 then
                        vir2.oci = random(3)
                    end
                end,
                [1] = function()
                    if vir2.dir ~= dir_no and game_getCycles() > 10 then
                        vir2.stav = 0
                    else
                        if random(4) == 1 then
                            vir2.oci = random(3)
                        end
                        if vir2.huba == 0 then
                            vir2.huba = 2
                        elseif random(3) == 1 then
                            vir2.huba = 3 - vir2.huba
                        end
                    end
                end,
            }
            if vir2.stav < 2 then
                vir2.huba = 0
            end
            vir2.afaze = vir2.huba * 3 + vir2.oci
            vir2:updateAnim()
        end
    end

    -- --------------------
    local update_table = {}
    local subinit
    subinit = prog_init_room()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_disketa()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_vir1()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_svab()
    if subinit then
        table.insert(update_table, subinit)
    end
    subinit = prog_init_vir2()
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

