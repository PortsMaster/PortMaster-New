function ldtk.onEntity(entity)
    if entity.props.o then
        objects[entity.props.o](entity)
    end
end

function ldtk.onLayer(layer)
    objects.layer(layer)
end

function ldtk.onLevelLoaded(level)
    global.game.level.funcs = {}
end

function ldtk.onLevelCreated(level)
    --nothing
end

ldtk:load('res/ldtk/game.ldtk')

global.deathCounter = 0
global.timer = 0

global.stopMusic()

--objects.splash('credit', 0.5)
room.goTo("intro")

