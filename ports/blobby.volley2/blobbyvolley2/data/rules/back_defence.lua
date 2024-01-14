__AUTHOR__ = "chameleon"
__TITLE__  = "Crazy Volley - Back Defence"
function HandleInput(player, left, right, up)
	if isgamerunning() and touches(player) == 0 and posx(player) > CONST_FIELD_WIDTH / 4 and posx(player) < CONST_FIELD_WIDTH * 3 / 4 then
		if launched(player) then
			if player == LEFT_PLAYER then
				right = false
			else
				left = false
			end
		else
			up = false
		end
	end
	return left, right, up
end
