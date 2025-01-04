function create()
	local black = Graphic(-100, -100, game.width * 2, game.height * 2, Color.BLACK)
	black.alpha = 0
	black:setScrollFactor()
	state:add(black)

	Timer.after(0.5, function()
		state.camFollow:set(state.dad.x + 140, state.dad.y + 40)
		state.camZooming = false
		Timer.tween(1.5, game.camera, {zoom = 1.5}, 'in-out-quad')
		state.camHUD.visible, state.camNotes.visible = false, false
		for delay = 1, 7 do
			Timer.after(0.3 * delay, function() black.alpha = black.alpha + 0.15 end)
		end
	end)

	Timer.after(3, function() state:endSong(true) end)
end
