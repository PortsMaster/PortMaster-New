local bgMusic
local cutsceneTimer

function create()
    -- Initialize the cutscene timer
    cutsceneTimer = Timer.new()

    -- Make the dad character invisible
    state.dad.alpha = 0

    -- Hide the HUD and notes
    state.camHUD.visible, state.camNotes.visible = false, false

    -- Create the tankman sprite relative to the dad's position
    tankman = Sprite(state.dad.x + 100, state.dad.y)

    -- Set the animation frames for the tankman sprite
    tankman:setFrames(paths.getSparrowAtlas('stages/tank/cutscenes/'
        .. paths.formatToSongPath(PlayState.SONG.song)))

    -- Add animations by prefix
    tankman:addAnimByPrefix('tightBars', 'TANK TALK 2', 24, false)

    -- Play the 'tightBars' animation
    tankman:play('tightBars', true)

    -- Set the graphic size for tankman (optional but ensures consistency)
    tankman:setGraphicSize(350, 500)

    -- Insert the tankman sprite into the state after dad
    table.insert(state.members, table.find(state.members, state.dad) + 1, tankman)

    -- Adjust the camera follow position relative to the dad's position
    state.camFollow:set(state.dad.x + 380, state.dad.y + 0)
end



function postCreate()
	bgMusic = game.sound.load(paths.getMusic('gameplay/DISTORTO'), 0.5, true, true)
	bgMusic:play()
	game.camera.zoom = game.camera.zoom * 1.2

	game.sound.play(paths.getSound('gameplay/tankSong2'), ClientPrefs.data.vocalVolume / 100)
	Timer.tween(4, game.camera, {zoom = state.stage.camZoom * 1.2}, 'in-out-quad')

	cutsceneTimer:after(4, function()
		Timer.tween(0.5, game.camera, {zoom = state.stage.camZoom * 1.2 * 1.2}, 'in-out-quad')
		state.gf:playAnim('sad', true)
	end)

	cutsceneTimer:after(4.5, function()
		Timer.tween(1, game.camera, {zoom = state.stage.camZoom * 1.2}, 'in-out-quad')
	end)

	cutsceneTimer:after(11.5, function()
		tankman:destroy()
		state.dad.alpha = 1
		state.camHUD.visible, state.camNotes.visible = true, true

		local times = PlayState.conductor.crotchet / 1000 * 4.5
		Timer.tween(times, game.camera, {zoom = state.stage.camZoom}, 'in-out-quad')
		state:startCountdown()
	end)
end

function songStart()
	bgMusic:stop()
	close()
end

function update(dt) cutsceneTimer:update(dt) end
