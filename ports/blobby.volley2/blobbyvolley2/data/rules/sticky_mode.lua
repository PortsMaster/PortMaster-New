__AUTHOR__ = "chameleon"
__TITLE__  = "Crazy Volley - Sticky Mode"


function HandleInput(player, left, right, up)
	if isgamerunning() then
		return left, right, false
	else
		return left, right, up
	end
end
