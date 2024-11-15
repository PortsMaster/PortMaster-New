
local npldiku=27;
local dxklec=5;
local dyklec=6;

local pldnic=0;
local pldjdu=1;
local pldjsem=2;
local pldodch=3;
local pldzust=4;
local pldzed=5;

-- -----------------------------------------------------------------
function initPldici(leader)
    leader.pldik = {}
    for i = 0, npldiku - 1 do
        leader.pldik[i] = {}
        leader.pldik[i].xs = 0
        leader.pldik[i].ys = 0
        leader.pldik[i].cinnost = 0
        leader.pldik[i].faze = 0
        leader.pldik[i].smer = 0
        leader.pldik[i].delit = 0
        leader.pldik[i].otec = 0
    end
    leader.klec = {}
    for i = 0, dxklec + 1 do
        leader.klec[i] = {}
    end


    for i = 0, npldiku - 1 do
        getModelsTable()[leader.index + i].afaze = 36
        getModelsTable()[leader.index + i]:updateAnim()
    end
    for x = 0, dxklec + 1 do
        for y = 0, dyklec + 1 do
            if x == 0 or x > dxklec or y == 0 or y > dyklec or x == 3 and y >= 4 then
                leader.klec[x][y] = pldzed
            else
                leader.klec[x][y] = pldnic
            end
        end
    end
    getModelsTable()[leader.index + 12].afaze = 0
    getModelsTable()[leader.index + 12]:updateAnim()
    leader.pocet = 1
    leader.pldik[0].xs = 3
    leader.pldik[0].ys = 1
    leader.pldik[0].cinnost = 0
    leader.pldik[0].faze = 0
    leader.pldik[0].delit = random(200) + 200
end

-- -----------------------------------------------------------------
function fazeplda(leader, x, y, anim)
    local p
    p = (x - 1) * dyklec + y
    if p > 15 then
        p = p - 3
    end
    if p > npldiku or p <= 0 then
        print("SCRIPT_WARNING out of array; p="..p.."; x="..x.."; y="..y.."; anim="..anim)
    else
        p = leader.index + p - 1
        getModelsTable()[p].afaze = anim
        getModelsTable()[p]:updateAnim()
    end
end
-- -----------------------------------------------------------------
function progPldici(leader)
    local nx
    local musibyt, kliddole, volnovedle
    local sm
    local pldik = leader.pldik
    local klec = leader.klec

    for i = 0, npldiku - 1 do
        getModelsTable()[leader.index + i].afaze = 36
        getModelsTable()[leader.index + i]:updateAnim()
    end
    for i = 0, leader.pocet - 1 do
        selected = pldik[i]
        if selected.delit > 0 then
            selected.delit = selected.delit - 1
        else
            selected.delit = 10 + random(10)
        end
        musibyt = klec[selected.xs][selected.ys] == pldzust
        kliddole = klec[selected.xs][selected.ys + 1] == pldjsem or klec[selected.xs][selected.ys + 1] == pldzed
        sm = random(2)
        switch(sm){
            [1] = function()
                nx = selected.xs - 1
            end,
            [0] = function()
                nx = selected.xs + 1
            end,
        }
        switch(selected.cinnost){
            [0] = function()
                if klec[selected.xs][selected.ys + 1] == 0 then
                    selected.cinnost = 1
                    selected.faze = 0
                    klec[selected.xs][selected.ys] = pldodch
                    klec[selected.xs][selected.ys + 1] = pldjdu
                    fazeplda(leader, selected.xs, selected.ys, 20)
                    fazeplda(leader, selected.xs, selected.ys + 1, 19)
                elseif kliddole and selected.delit == 0 and klec[nx][selected.ys] == 0 then
                    selected.delit = random(300) + 100
                    selected.cinnost = 2
                    selected.faze = 0
                    selected.smer = sm
                    klec[selected.xs][selected.ys] = pldjsem
                    if klec[selected.xs][selected.ys + 1] == pldjsem then
                        klec[selected.xs][selected.ys + 1] = pldzust
                    end
                    pldik[leader.pocet].xs = nx
                    pldik[leader.pocet].ys = selected.ys
                    pldik[leader.pocet].cinnost = 3
                    pldik[leader.pocet].faze = 0
                    pldik[leader.pocet].smer = sm
                    pldik[leader.pocet].delit = random(300) + 100
                    pldik[leader.pocet].otec = i
                    klec[nx][selected.ys] = pldjdu
                    fazeplda(leader, selected.xs, selected.ys, 4 - sm)
                    fazeplda(leader, nx, selected.ys, 36)
                    leader.pocet = leader.pocet + 1
                elseif random(100) < 4 and kliddole and not musibyt then
                    if klec[nx][selected.ys] == 0 and (klec[nx][selected.ys + 1] == 2 or klec[nx][selected.ys + 1] == 5) then
                        selected.cinnost = 4
                        selected.faze = 0
                        selected.smer = sm
                        klec[selected.xs][selected.ys] = pldodch
                        klec[nx][selected.ys] = pldjdu
                        fazeplda(leader, selected.xs, selected.ys, 4 - sm)
                    elseif klec[nx][selected.ys] == 0 and klec[nx][selected.ys + 1] == 0 then
                        selected.cinnost = 5
                        selected.faze = 0
                        selected.smer = sm
                        klec[selected.xs][selected.ys] = pldodch
                        klec[nx][selected.ys] = pldjdu
                        fazeplda(leader, selected.xs, selected.ys, 10 + sm * 18)
                    elseif (klec[nx][selected.ys] == pldjsem or klec[nx][selected.ys] == pldzed) and klec[selected.xs][selected.ys - 1] == 0 and klec[nx][selected.ys - 1] == 0 then
                        selected.cinnost = 6
                        selected.faze = 0
                        selected.smer = sm
                        if klec[nx][selected.ys] == pldjsem then
                            klec[nx][selected.ys] = pldzust
                        end
                        klec[selected.xs][selected.ys] = pldodch
                        klec[selected.xs][selected.ys - 1] = pldjdu
                        fazeplda(leader, selected.xs, selected.ys, 18)
                    else
                        fazeplda(leader, selected.xs, selected.ys, selected.faze)
                    end
                else
                    if random(100) < 10 then
                        selected.faze = random(5)
                    end
                    if random(100) < 2 then
                        fazeplda(leader, selected.xs, selected.ys, 5)
                    else
                        fazeplda(leader, selected.xs, selected.ys, selected.faze)
                    end
                end
            end,
            [1] = function()
                if selected.faze == 0 then
                    klec[selected.xs][selected.ys] = 0
                    selected.ys = selected.ys + 1
                    klec[selected.xs][selected.ys] = pldodch
                    fazeplda(leader, selected.xs, selected.ys, 2)
                    selected.faze = selected.faze + 1
                else
                    switch(klec[selected.xs][selected.ys + 1]){
                        [0] = function()
                            klec[selected.xs][selected.ys] = pldodch
                            klec[selected.xs][selected.ys + 1] = pldjdu
                            fazeplda(leader, selected.xs, selected.ys, 20)
                            fazeplda(leader, selected.xs, selected.ys + 1, 19)
                            selected.faze = selected.faze - 1
                        end,
                        [1] = function()
                            klec[selected.xs][selected.ys] = pldodch
                            fazeplda(leader, selected.xs, selected.ys, 2)
                            selected.cinnost = 0
                            selected.faze = 2
                        end,
                        [3] = function()
                            klec[selected.xs][selected.ys] = pldodch
                            fazeplda(leader, selected.xs, selected.ys, 2)
                            selected.cinnost = 0
                            selected.faze = 2
                        end,
                        default = function()
                            selected.cinnost = 0
                            selected.faze = 0
                            klec[selected.xs][selected.ys] = pldjsem
                            fazeplda(leader, selected.xs, selected.ys, 18)
                        end,
                    }
                end
            end,
            [3] = function()
                selected.faze = selected.faze + 1
                switch(selected.faze){
                    [4] = function()
                        fazeplda(leader, selected.xs, selected.ys, 14 + selected.smer * 18)
                        klec[selected.xs][selected.ys] = pldjsem
                    end,
                    [16] = function()
                        selected.cinnost = 0
                        selected.faze = 0
                        fazeplda(leader, selected.xs, selected.ys, 0)
                        pldik[selected.otec].cinnost = 0
                        fazeplda(leader, pldik[selected.otec].xs, pldik[selected.otec].ys, 4 - selected.smer)
                        if klec[pldik[selected.otec].xs][pldik[selected.otec].ys + 1] == 4 then
                            klec[pldik[selected.otec].xs][pldik[selected.otec].ys + 1] = 2
                        end
                    end,
                    [21] = function()
                        fazeplda(leader, selected.xs, selected.ys, 17 + selected.smer * 18)
                        if random(100) < 20 then
                            selected.faze = 15
                        else
                            selected.faze = selected.faze - 1
                        end
                    end,
                    default = function()
                        if 1 <= selected.faze and selected.faze <= 3 then
                            fazeplda(leader, selected.xs, selected.ys, 12 + selected.smer * 18)
                        elseif 5 <= selected.faze and selected.faze <= 6 then
                            fazeplda(leader, selected.xs, selected.ys, 14 + selected.smer * 18)
                        elseif 7 <= selected.faze and selected.faze <= 9 then
                            fazeplda(leader, selected.xs, selected.ys, 15 + selected.smer * 18)
                        elseif 10 <= selected.faze and selected.faze <= 15 then
                            fazeplda(leader, selected.xs, selected.ys, 16 + selected.smer * 18)
                            if random(100) < 10 then
                                selected.faze = 20
                            end
                        end
                    end,
                }
            end,
            [2] = function()
                if random(100) < 4 then
                    fazeplda(leader, selected.xs, selected.ys, 13 + selected.smer * 18)
                else
                    fazeplda(leader, selected.xs, selected.ys, 11 + selected.smer * 18)
                end
            end,
            [4] = function()
                selected.faze = selected.faze + 1
                switch(selected.smer){
                    [0] = function()
                        nx = selected.xs + 1
                    end,
                    [1] = function()
                        nx = selected.xs - 1
                    end,
                }
                switch(selected.faze){
                    [1] = function()
                        fazeplda(leader, selected.xs, selected.ys, 6 + selected.smer * 18)
                        fazeplda(leader, nx, selected.ys, 7 + selected.smer * 18)
                    end,
                    [2] = function()
                        fazeplda(leader, selected.xs, selected.ys, 8 + selected.smer * 18)
                        fazeplda(leader, nx, selected.ys, 9 + selected.smer * 18)
                    end,
                    [3] = function()
                        klec[selected.xs][selected.ys] = 0
                        selected.xs = nx
                        klec[selected.xs][selected.ys] = pldjsem
                        fazeplda(leader, selected.xs, selected.ys, 0)
                        selected.cinnost = 0
                        selected.faze = 0
                    end,
                }
            end,
            [5] = function()
                selected.faze = selected.faze + 1
                switch(selected.smer){
                    [0] = function()
                        nx = selected.xs + 1
                    end,
                    [1] = function()
                        nx = selected.xs - 1
                    end,
                }
                switch(selected.faze){
                    [1] = function()
                        fazeplda(leader, selected.xs, selected.ys, 10 + selected.smer * 18)
                    end,
                    [2] = function()
                        fazeplda(leader, selected.xs, selected.ys, 10 + selected.smer * 18)
                    end,
                    [3] = function()
                        fazeplda(leader, selected.xs, selected.ys, 21 + selected.smer)
                        fazeplda(leader, nx, selected.ys, 22 - selected.smer)
                    end,
                    [4] = function()
                        klec[selected.xs][selected.ys] = 0
                        selected.xs = nx
                        klec[selected.xs][selected.ys] = pldodch
                        fazeplda(leader, selected.xs, selected.ys, 2)
                        selected.cinnost = 1
                        selected.faze = 1
                    end,
                }
            end,
            [6] = function()
                selected.faze = selected.faze + 1
                switch(selected.smer){
                    [0] = function()
                        nx = selected.xs + 1
                    end,
                    [1] = function()
                        nx = selected.xs - 1
                    end,
                }
                switch(selected.faze){
                    [1] = function()
                        fazeplda(leader, selected.xs, selected.ys - 1, 20)
                        fazeplda(leader, selected.xs, selected.ys, 19)
                    end,
                    [2] = function()
                        klec[selected.xs][selected.ys] = 0
                        selected.ys = selected.ys - 1
                        klec[selected.xs][selected.ys] = pldodch
                        if klec[nx][selected.ys] == 0 then
                            fazeplda(leader, selected.xs, selected.ys, 21 + selected.smer)
                            fazeplda(leader, nx, selected.ys, 22 + selected.smer)
                            klec[nx][selected.ys] = pldjdu
                        else
                            selected.cinnost = 1
                            selected.faze = 1
                            fazeplda(leader, selected.xs, selected.ys, 2)
                            if klec[nx][selected.ys + 1] == 4 then
                                klec[nx][selected.ys + 1] = 2
                            end
                        end
                    end,
                    [3] = function()
                        klec[selected.xs][selected.ys] = 0
                        selected.xs = nx
                        klec[selected.xs][selected.ys] = pldjsem
                        fazeplda(leader, selected.xs, selected.ys, 18)
                        selected.cinnost = 0
                        selected.faze = 0
                        if klec[selected.xs][selected.ys + 1] == 4 then
                            klec[selected.xs][selected.ys + 1] = 2
                        end
                    end,
                }
            end,
        }
    end
end


