-- There is place to customize game before start

--NOTE: hack for win32, lang Czech = cs
--NOTE: first five characters from LC_CTYPE are stored in "lang" param
local lang = string.sub(getParam("lang") or "", 1, 5)
local winCodes = {
    Czech = "cs",
    Engli = "en",
    Frenc = "fr",
    Germa = "de",
    Itali = "it",
    Polis = "pl",
    Spani = "es",
    Dutch = "nl",
    Bulga = "bg",
    Swedi = "sv",
    Slove = "sl",
    Portu = "pt",
    Russi = "ru",
    Esper = "eo"
}

if winCodes[lang] then
    setParam("lang", winCodes[lang])
end

--NOTE: default speech is 'cs' (there are cs/*.ogg files)
if getParam("speech") == nil then
    setParam("speech", "cs")
end

--- Prints global score.
-- Usable from debug console.
function score()
    local solvedCounter = 0
    local userSteps = 0
    local bestSteps = 0
    local oldImpl = node_bestSolution
    function node_bestSolution(codename, steps, solver)
        local solution = "solved/"..codename..".lua"
        if file_exists(solution) then
            solvedCounter = solvedCounter + 1
            bestSteps = bestSteps + steps
            file_include(solution)
            userSteps = userSteps + string.len(saved_moves)
        end
    end

    file_include("script/worldfame.lua")
    node_bestSolution = oldImpl
    print("Solved:", solvedCounter)
    print("Steps:", userSteps .."/".. bestSteps,
        "(loss: ".. 100 * (userSteps - bestSteps) / bestSteps .."%)")
end

-- Prints the Hall of Fame table as HTML.
function hf()
    local OUTPUT_LANG = "en"
    local origImpls = {
        node_bestSolution = node_bestSolution,
        woldmap_addDesc = woldmap_addDesc,
    }
    local solutions = {}
    local descs = {}
    function node_bestSolution(codename, moves, author)
        solutions[codename] = {
            moves = moves,
            author = author,
        }
    end

    function worldmap_addDesc(codename, lang, levelname, branch)
        if lang ~= OUTPUT_LANG then
            return
        end
        if codename == "menu" or codename == "score"
                or codename == "ending" then
            return
        end

        local num_steps = nil
        local solution = "solved/"..codename..".lua"
        if file_exists(solution) then
            saved_moves = nil
            file_include(solution)
            if saved_moves then
                num_steps = string.len(saved_moves)
            end
        end

        table.insert(descs, {
            codename=codename,
            lang=lang,
            levelname=levelname,
            branch=branch,
            num_steps=num_steps,
        })
    end

    local function formatPrefix()
        local version = getParam("package") .. " " .. getParam("version")
        print(string.format([[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>Hall of Fame Statistics</title>
</head>
<body>
<h3>%s</h3>
<table border="1">
<tr>
    <th>Level</th>
    <th>Name</th>
    <th>Codename</th>
    <th>Best solution</th>
    <th>Solution author</th>
    <th>Your solution</th>
    <th>Difference</th>
</tr>]], version))
end

    local function formatSuffix()
        print([[
</table>
</body>
</html>]])
    end

    local function formatSpace()
        print('<tr><td colspan="7">&nbsp;</td></tr>')
    end

    local function formatTotal(total, player_total)
        print(string.format('<tr><td colspan="3">&nbsp;<b>Total</b></td><td align="right">%s</td><td>&nbsp;</td><td align="right">%s</td><td align="right">%s</td></tr>', total, player_total, player_total - total))
    end

    local function formatRow(index, levelname, codename, moves, author, player_steps)
        if index < 10 then
            index = '0'..index
        end
        local diff = "-"
        if moves and player_steps then
            diff = player_steps - moves
        end
        print(string.format('<tr><td align="right">%s&nbsp;</td><td>&nbsp;%s</td><td>&nbsp;%s</td><td align="right">%s&nbsp;</td><td>&nbsp;%s</td><td align="right">&nbsp;%s</td><td align="right">&nbsp;%s</td></tr>',
            index, levelname, codename, moves or "-", author or "-",
            player_steps or "-", diff or "-"))
    end


    file_include("script/worlddesc.lua")
    file_include("script/worldfame.lua")

    formatPrefix()
    local total = 0
    local player_total = 0
    local lastBranch = descs[1].branch
    for index, level in ipairs(descs) do
        local moves = nil
        local author = nil
        local solution = solutions[level.codename]
        if solution then
            moves = solution.moves
            author = solution.author
            total = total + moves
        end
        if level.num_steps then
            player_total = player_total + level.num_steps
        end

        if lastBranch ~= level.branch then
            formatSpace()
            lastBranch = level.branch
        end
        formatRow(index, level.levelname, level.codename, moves, author,
            level.num_steps)

        if index == 70 then
            -- subtotal
            formatSpace()
            formatTotal(total, player_total)
        end
    end

    formatSpace()
    formatTotal(total, player_total)

    formatSuffix()

    for k, v in pairs(origImpls) do
        _G[k] = v
    end

    sendMsg("App", "flush_stdout")
end
