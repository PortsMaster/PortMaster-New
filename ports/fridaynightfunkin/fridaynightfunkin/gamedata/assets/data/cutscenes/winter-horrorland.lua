function create()
	state.camHUD.visible, state.camNotes.visible = false, false

	state.camFollow:set(400, -2050)
	game.camera:snapToTarget()

	util.playSfx(paths.getSound('gameplay/Lights_Turn_On'))
	game.camera.zoom = 1.5

	local blackScreen = Graphic(0, 0,
		math.floor(game.width * 2), math.floor(game.height * 2), Color.BLACK)
	blackScreen:setScrollFactor()
	state:add(blackScreen)

	Timer.tween(0.7, blackScreen, {alpha = 0}, 'linear', function()
		state:remove(blackScreen)
	end)

	Timer.after(1, function()
		state.camHUD.visible, state.camNotes.visible = true, true
		Timer.tween(1.2, game.camera, {zoom = state.stage.camZoom}, 'in-out-quad',
			function() state:startCountdown() end)
	end)
end
