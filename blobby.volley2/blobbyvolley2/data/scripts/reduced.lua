-- Reduced but very effective bot.
-- Borrows from axji.lua, com_10.lua and com_11.lua as distributed with
-- Blobby Volley.
-- Copyright (C) 2010 Soeren D. Schulze
-- The terms of the GPLv2 or later apply.
-- See the Blobby Volley distribution for the license text.

-- 15.01.14 - ngc92: Use blobby volley api provided constants when possible
-- 22.09.15 - ngc92: Adapted to new API, clean up

modeLock = false
timeto = 0
target = 0
naivetarget = 0
estimbspeedx = 0
servrand = nil

function OnServe(ballready)
   if servrand == nil then
      servrand = math.random()
   end
   
   if moveto(ballx() + servrand * 5) and ballready then
      jump()
      servrand = nil
   end
end	

function OnOpponentServe()
   moveto(100)
end

function OnGame()
   -- try high play
   if(estimImpactHigh()) then
		if naivetarget < CONST_FIELD_MIDDLE and target < CONST_FIELD_MIDDLE
			and (modeLock == true or timeto > math.abs(posx()-highPlayPos())/4.5 + 26)
			and touches() < 3
		then
			modeLock = timeto < 30
			if modeLock == false then
				servrand = nil
			end
			highPlay()
			return
		end
   end

	-- otherwise, low play
	modeLock = false
	servrand = nil
	
	local balldir = estimbspeedx > 0 and 1 or -1
	
	if(estimImpactLow()) then
		if (timeto > (balldir*(target-posx()) - 10)/CONST_BLOBBY_SPEED
			or naivetarget >= CONST_FIELD_MIDDLE) 
		then
			lowPlay()
		-- HEELLPPP...
		elseif naivetarget < CONST_FIELD_MIDDLE then
--			print("PANIC!", ballx(), bally())
			-- This often saves your ass if you're standing inside a
			-- corner and the ball bounces from the wall or the net.
			lowPlay()
			jump()
		end
	end
end

function highPlayPos()
   if estimbspeedx < 0 then
      -- safety againt fast balls
      return target - 50 - estimbspeedx*5
   else
      return target - 50
   end
end

function highPlay()
   if (target > CONST_FIELD_MIDDLE) then
      moveto(100)
   else
      moveto(highPlayPos())
      -- 33 time units for jumping to max height
      -- Regarding naive target here.
      -- If the ball really bounces back, it would be a bad idea to jump...
      if servrand == nil then
		servrand = math.random()
      end
      if naivetarget < CONST_FIELD_MIDDLE and timeto < 28 + servrand then
		jump()
      end
   end
end


function lowPlay()
   if (target > CONST_FIELD_MIDDLE) then
      moveto(100)
   else
      moveto(target)
   end
end

function estimImpactHigh()
	return estimImpact(CONST_BLOBBY_MAX_JUMP - 25)
end

function estimImpactLow()
	return estimImpact(CONST_BALL_BLOBBY_HEAD)
end

function estimImpact(destY) -- erlaubt ein besseres Estimate mit ein paar unbeding nötigen Angaben
   local x, v, t = estimate_x_at_y(destY)
   if (t == math.huge) then
      target = nil
      return false
   end
   
   naivetarget = (bspeedx() * t) + ballx()
   target, estimbspeedx, timeto = x, v, t
   return true
end
