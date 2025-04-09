ldtk:level('twitter')

local label
global.game.level.funcs['twitter'] = {
    function ()
        if global.showLinks then
            love.system.openURL('https://twitter.com/HamdyElzanqali')
        end
        if not label then
            label = objects.label({x = 36, y = 72, props = {text="@HamdyElzanqali"}})
        end
        
    end,
}