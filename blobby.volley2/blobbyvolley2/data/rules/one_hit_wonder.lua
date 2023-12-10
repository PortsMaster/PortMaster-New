__AUTHOR__ = "chameleon"
__TITLE__  = "Crazy Volley - One Hit Wonder"
function OnBallHitsPlayer(player)
	if touches(player) > 1 then
		mistake(player, opponent(player), 1)
	end
end
