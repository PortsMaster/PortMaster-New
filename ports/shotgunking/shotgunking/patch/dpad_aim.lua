-- DPAD-AIM: hold L2 + dpad L/R to rotate aim like clock hands. Lets
-- dpad-only handhelds (no analog sticks) aim the shotgun. Dpad U/D do
-- nothing while L2 is held. Wild-shot semantics are suppressed for the
-- rest of an L2-hold once dpad has been used during it.

defbtn("dpax+", 0, "c:dpad:right")
defbtn("dpax-", 0, "c:dpad:left")

-- Override btn so btn("unsafe") reads as false for the rest of the
-- current L2-hold once dpad-aim has been used. Reaches all callers
-- because Lua resolves global `btn` via _ENV at call time.
local _orig_btn = btn
function btn(name)
	if name == "unsafe" and _dpad_aim_used_during_hold then
		return false
	end
	return _orig_btn(name)
end

local ROT_RATE = 3.14159265 / 640  -- rad/tick; full sweep ~5s observed

function dpad_aim_tick(xL, yL)
	if btnp("unsafe") then _dpad_aim_used_during_hold = false end
	if not _orig_btn("unsafe") then return xL, yL end
	local r = btnv("dpax+") - btnv("dpax-")
	if r == 0 then return xL, yL end
	if not aimPos then aimPos = {x=0, y=-1} end
	local a = r * ROT_RATE
	local cs, sn = cos(a), sin(a)
	local nx = aimPos.x*cs - aimPos.y*sn
	local ny = aimPos.x*sn + aimPos.y*cs
	aimPos.x, aimPos.y = nx, ny
	smoothAim.x, smoothAim.y = nx, ny
	ctrl_mode = "aim"
	_dpad_aim_used_during_hold = true
	return 0, 0
end
