__AUTHOR__ = "chameleon"
__TITLE__  = "Crazy Volley - Tennis"

-- left/right ground hits
lgh = 0
rgh = 0

function OnMistake(player)
	lgh = 0
	rgh = 0
	score(opponent(player), true, 1)
end

function OnBallHitsPlayer(player)
	local opp = opponent(player)
	if player == LEFT_PLAYER then
		mh = lgh
		oh = rgh
	else
		mh = rgh
		oh = lgh
	end
	lgh = 0
	rgh = 0
	if touches(player) > 1 then
		mistake(player, opp, 1)
	end
	if oh > 0 and touches(opp) == 0 then
		mistake(opp, player, 1)
	end
end

function OnBallHitsGround(player)
	local opp = opponent(player)
	if player == LEFT_PLAYER then
		lgh = lgh + 1
		mh = lgh
		oh = rgh
		rgh = 0
	else
		rgh = rgh + 1
		mh = rgh
		oh = lgh
		lgh = 0
	end
	if mh > 1 or touches(player) > 0 then
		lgh = 0
		rgh = 0
		mistake(player, opp, 1)
	end
	if oh > 0 and touches(opp) == 0 then
		lgh = 0
		rgh = 0
		mistake(opp, player, 1)
	end
end
