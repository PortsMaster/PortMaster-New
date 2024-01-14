ldtk:level('credit')

local credit = objects.credit()

global.game.level.funcs['back'] = {
    function ()
        objects.splash('level/last', 0.7, 0.25, 0.15)
    end,
}

global.game.level.funcs['next'] = {
    function ()
        credit:next()
    end,
}

global.game.level.funcs['previous'] = {
    function ()
        credit:previous()
    end,
}