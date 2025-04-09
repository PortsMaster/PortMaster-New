local bgMusic
local cutsceneTimer

function create()
	cutsceneTimer = Timer.new()

    state.dad.alpha = 0
    state.camHUD.visible, state.camNotes.visible = false, false

    -- Create the tankman sprite at a position relative to the dad's position
    tankman = Sprite(state.dad.x + 100, state.dad.y )

    -- Set the frames for the tankman sprite using the Sparrow atlas
    tankman:setFrames(paths.getSparrowAtlas('stages/tank/cutscenes/'
        .. paths.formatToSongPath(PlayState.SONG.song)))

    -- Add animations by prefix
    tankman:addAnimByPrefix('wellWell', 'TANK TALK 1 P1', 24, false)
    tankman:addAnimByPrefix('killYou', 'TANK TALK 1 P2', 24, false)

    -- Play the 'wellWell' animation
    tankman:play('wellWell', true)

    -- Optional: Set the scale for the tankman sprite
    tankman:setGraphicSize(350, 500)

    -- Insert tankman into the state after dad (if dad exists)
    table.insert(state.members, table.find(state.members, state.dad) + 1, tankman)

    -- Set the camera follow position relative to dad
    state.camFollow:set(state.dad.x + 280, state.dad.y - 0 )
end


function postCreate()
	bgMusic = Sound():load(paths.getMusic('gameplay/DISTORTO'), 0.5, true, true)
	bgMusic:play()
	game.camera.zoom = game.camera.zoom * 1.2

	cutsceneTimer:after(0.1, function()
		game.sound.play(paths.getSound('gameplay/wellWellWell'), ClientPrefs.data.vocalVolume / 100)
	end)

	cutsceneTimer:after(3, function()
		state.camFollow.x = state.camFollow.x + 650
		state.camFollow.y = state.camFollow.y + 100
	end)

	cutsceneTimer:after(4.5, function()
		state.boyfriend:playAnim('singUP', true)
		game.sound.play(paths.getSound('gameplay/bfBeep'), ClientPrefs.data.vocalVolume / 100)
	end)

	cutsceneTimer:after(5.2, function()
		state.boyfriend:playAnim('idle', true)
	end)

	cutsceneTimer:after(6, function()
		state.camFollow.x = state.camFollow.x - 650
		state.camFollow.y = state.camFollow.y - 100

		tankman:play('killYou', true)
		tankman.x = tankman.x - 36
		tankman.y = tankman.y - 10
		game.sound.play(paths.getSound('gameplay/killYou'), ClientPrefs.data.vocalVolume / 100)
	end)

	cutsceneTimer:after(12, function()
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
