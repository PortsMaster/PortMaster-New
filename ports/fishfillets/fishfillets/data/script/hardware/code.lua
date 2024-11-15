
-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky03.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        if pokus == 1 then
            room.uvod = 0
        elseif random(100) < 80 then
            room.uvod = 0
        else
            room.uvod = 1
        end
        room.hlaska = random(1000) + 500
        room.oldwamp = WAmp
        room.oldwper = WPer
        room.mluveni = 0
        room.nudise = 0
        room.nepas = 0

        return function()
            if room.mluveni ~= 0 then
                wamp = random(4) + 4
                wper = random(4) + 1
            else
                wamp = room.oldwamp
                wper = room.oldwper
            end
            if isReady(small) and isReady(big) and no_dialog() then
                if room.hlaska > 0 then
                    room.hlaska = room.hlaska - 1
                end
                if room.uvod > 2 then
                    room.uvod = room.uvod - 1
                end
                if room.uvod == 0 then
                    if random(100) < 30 then
                        room.uvod = random(100) + 20
                    else
                        room.uvod = 1
                    end
                    if random(100) < 30 then
                        addv(random(20) + 5, "pz-v-zaskladanej")
                    else
                        adddel(random(20))
                    end
                    if random(100) < 40 then
                        addm(random(8) + 3, "pz-m-co")
                        addv(random(4), "pz-v-klice"..(random(2) + 1))
                    else
                        addv(random(8) + 3, "pz-v-co"..(random(2) + 1))
                        addm(random(4), "pz-m-spoje"..(random(3) + 1))
                    end
                elseif room.uvod == 2 then
                    room.uvod = 1
                    addm(8, "pz-m-vylez")
                    addv(10, "pz-v-dat")
                elseif room.hlaska == 0 then
                    room.hlaska = -1
                    addm(20, "pz-m-pocitace")
                    planDialogSet(random(20) + 30, "pz-x-pocitac", 5, room, "mluveni")
                elseif room.nudise == 0 and small.pohyby >= small.trpelivost and big.Y <= 8 then
                    addv(20, "pz-v-hej")
                    addm(0, "pz-m-nech")
                    room.nudise = 1
                elseif room.nepas == 0 and (k1.Y > 5 and k1.Y < 20 and k1.dir == dir_no or k2.Y > 5 and k2.Y < 20 and k2.dir == dir_no or k3.Y > 5 and k3.Y < 20 and k3.dir == dir_no) then
                    room.nepas = 1
                    addm(10, "pz-m-nepasuje")
                end
            end
        end
    end

    -- -------------------------------------------------------------
    local function prog_init_small()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        small.pohyby = 0
        small.trpelivost = 300 + random(700)

        return function()
            if level_isNewRound() and small.dir ~= dir_no then
                small.pohyby = small.pohyby + 1
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
    subinit = prog_init_small()
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

