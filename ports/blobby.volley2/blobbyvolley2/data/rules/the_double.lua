__AUTHOR__ = "chameleon"
__TITLE__  = "Crazy Volley - The Double"
function OnBallHitsPlayer(player)
	local opp = opponent(player)
	if touches(player) > 2 then
		mistake(player, opp, 1)
	end
	if touches(opp) == 1 then
		mistake(opp, player, 1)
	end
end

function OnBallHitsGround(player)
	local opp = opponent(player)
	if touches(opp) == 1 then
		mistake(opp, player, 1)
	else
		mistake(player, opp, 1)
	end
end
