-- Open Golf launcher: Play and the controls image; the game has no settings to edit here

local config = {
    title = "Open Golf",
    subtitle = "3D minigolf",
    help = "Hold A to grab the ball, pull back with the left stick, release A to putt.",
    items = {},
}

function config.load(path)
    return {}
end

function config.save(path, values)
    return true
end

return config
