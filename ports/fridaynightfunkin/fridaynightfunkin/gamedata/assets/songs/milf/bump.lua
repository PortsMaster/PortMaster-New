function beat()
	if curBeat >= 168 and curBeat < 200 and state.camZooming and game.camera.zoom < 1.35 then
		game.camera.zoom = game.camera.zoom + 0.015
		state.camHUD.zoom = state.camHUD.zoom + 0.03
	end
end
