__AUTHOR__ = "chameleon"
__TITLE__  = "Crazy Volley - Firewall"
function OnBallHitsPlayer(player)
	if touches(player) > 3 then
		mistake(player, opponent(player), 10)
	end
end
function OnBallHitsWall(player)
	score(opponent(player), 1)
end
function OnBallHitsGround(player)
	mistake(player, opponent(player), 10)
end

SCORE_TO_WIN = 10 * SCORE_TO_WIN
