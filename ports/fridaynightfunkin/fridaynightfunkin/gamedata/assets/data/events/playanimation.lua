function event(params)
	local data, target = params.v
	switch(data.target, {
		[{"boyfriend", "bf", "player"}] = function() target = state.boyfriend end,
		[{"dad", "opponent", "enemy"}] = function() target = state.dad end,
		[{"girlfriend", "gf"}] = function() target = state.gf end
	})
	target:playAnim(data.anim, data.force)
	target.lastHit = PlayState.conductor.time
end
