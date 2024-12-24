function beat()
	if not state.startingSong and curBeat % 8 == 7 then
		state.gf:playAnim('cheer', true)
		state.gf.lastHit = PlayState.conductor.time
		if curBeat ~= 79 then
			state.boyfriend:playAnim('hey', true)
			state.boyfriend.lastHit = PlayState.conductor.time
		end
	end
end
