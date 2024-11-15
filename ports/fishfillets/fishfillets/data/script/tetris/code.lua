
local cubes = {}
for index = 0, 9 do
    cubes[index] = getModelsTable()[first_cube.index + index]
end

-- -----------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------
local function prog_init()
    initModels()
    sound_playMusic("music/rybky07.ogg")
    local pokus = getRestartCount()


    -- -------------------------------------------------------------
    local function prog_init_room()
        local pom1, pom2, pomb1, pomb2 = 0, 0, false, false

        room.zacatek = 0
        room.pocitadlo = 300 + random(400 + pokus * 500)
        room.konec = 0

        return function()
            if no_dialog() and isReady(small) and isReady(big) then
                if room.pocitadlo > 1 then
                    room.pocitadlo = room.pocitadlo - 1
                end
                if room.zacatek == 0 then
                    addm(9 + random(35), "tet-m-vypadala")
                    if pokus < 5 or random(100) < 50 then
                        addv(5, "tet-v-ucta")
                        addm(9, "tet-m-usudek")
                    end
                    room.zacatek = 1
                elseif room.pocitadlo == 0 then
                    room.pocitadlo = -1
                    addv(9, "tet-v-myslim")
                    if random(100) < 50 then
                        addm(9, "tet-m-ano")
                    end
                    addv(9, "tet-v-lepsi")
                    if random(100) < 50 then
                        addm(16, "tet-m-jaklepsi")
                        addv(6, "tet-v-hybat")
                    end
                    if random(100) < 70 then
                        addm(16, "tet-m-predmety")
                    end
                    addv(16, "tet-v-uprava")
                    addm(6, "tet-m-program")
                    if random(100) < 50 then
                        addm(60, "tet-m-pozor")
                    end
                elseif room.konec == 0 and trubka.X == 29 and trubka.dir == dir_no then
                    room.konec = 1
                    pom2 = 100
                    for key, cube in pairs(cubes) do
                        if cube.Y < pom2 then
                            pom2 = cube.Y
                        end
                    end
                    if pom2 < 17 then
                        addv(9, "tet-v-kostky")
                        if random(100) > 10 * (pokus - 3) or random(100) < 50 then
                            addm(15 + random(7), "tet-m-lepe")
                        end
                    end
                end
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

