function postBeat()
	if not state.startingSong and curBeat >= 16 and curBeat < 48 and curBeat % 16 == 15 then
		state.dad:playAnim('cheer', true)
		state.boyfriend:playAnim('hey', true)
		local time = PlayState.conductor.time
		state.dad.lastHit, state.boyfriend.lastHit = time, time
	end
end
