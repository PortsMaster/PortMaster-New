function create()
	Timer.after(0.5, function()
		state.camHUD.visible, state.camNotes.visible = false, false

		util.playSfx(paths.getSound('gameplay/Lights_Shut_off'))
		local blackScreen = Graphic(game.width * -0.5, game.height * -0.5,
			math.floor(game.width * 2), math.floor(game.height * 2), Color.BLACK)
		blackScreen:setScrollFactor()
		state:add(blackScreen)
	end)

	Timer.after(3, function() state:endSong(true) end)
end
