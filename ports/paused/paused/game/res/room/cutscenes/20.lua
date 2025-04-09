if global.showLinks then
    ldtk:level('patreon')

    global.game.level.funcs['patreon'] = {
        function ()
            love.system.openURL('https://www.patreon.com/HamdyElzanqali')
        end,
    }
else
    room.goTo('level/20')
end
