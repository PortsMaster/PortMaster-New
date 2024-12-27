local doof

function create()
	local dialogue = love.filesystem.read(paths.getPath('songs/roses/dialogue.txt')):split('\n')

	doof = DialogueBox(dialogue)
	doof:setScrollFactor()
	doof.cameras = {state.camNotes}
	doof.finishThing = function()
		state:startCountdown()
		close()
	end

	util.playSfx(paths.getSound('gameplay/ANGRY_TEXT_BOX'))
	game.camera:shake(0.001, 0.8)
	state.camHUD:shake(0.001, 0.8)

	Timer.after(1.5, function()
		util.playSfx(paths.getSound('gameplay/ANGRY'))
		game.camera:shake(0.001, 0.1)
		state.camHUD:shake(0.001, 0.1)
		state:add(doof)
	end)
end
