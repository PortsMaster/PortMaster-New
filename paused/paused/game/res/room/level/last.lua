ldtk:level('last')

local label
if global.showLinks then
    objects.label({x = 54, y = 26, props = {text="Patreon"}})
    global.game.level.funcs['support'] = {
        function ()
            love.system.openURL('https://www.patreon.com/HamdyElzanqali')
        end
    }
else
    objects.label({x = 53, y = 26, props = {text="Twitter"}})
    global.game.level.funcs['support'] = {
        function ()
            if not label then 
                label = objects.label({x = 53, y = 19, props = {text="@HamdyElzanqali"}})
            end
        end
        }
end

global.game.level.funcs['play'] = {
    function ()
        objects.splash('loader', 0.2)
    end,
}

global.game.level.funcs['credit'] = {
    function ()
        objects.splash('credit', 0.7, 0.25, 0.15)
    end,
}