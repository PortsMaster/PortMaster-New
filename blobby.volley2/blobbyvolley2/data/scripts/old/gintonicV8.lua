--Gin Tonic v8 - No Comments, sorry :P

CT_ServeSelf = { 152, 163, 180, 195, 205, 240 }
CT_ServeOpp = { 140, 200, 240 }
CT_ServeIndex = 0
CT_Tolerance = 5
CT_Action = ""
CT_ShotDecision = 0
CT_NextGround = 9999
CT_LastTouches = 9999
CT_LastHeight = 0
CT_SkipNextBlock = 0

CT_WaitCounter = 0
CT_WaitName = ""
CT_WaitMoveTo = 0

function IsAt(position)
        return (math.abs(posx()-position) <= CT_Tolerance)
end

function Wait(name, time, moveto)
        if (CT_WaitName == name) then
                if (CT_WaitCounter == 0) then
                        return false
                end
        end
        CT_WaitCounter = time
        CT_WaitName = name
        CT_WaitMoveTo = moveto
        return true
end

function WaitQueue()
        if (CT_WaitCounter > 0) then
                CT_WaitCounter = CT_WaitCounter - 1
                if (CT_WaitMoveTo > 0) then
                            if (not IsAt(CT_WaitMoveTo)) then moveto(CT_WaitMoveTo) end
                end
                return true
        else
                return false
        end
end

function ResetWait()
        CT_WaitCounter = 0
        CT_WaitName = ""
end

function OnOpponentServe()
    if (CT_ServeIndex == 0) then
        CT_ServeIndex = math.random(1,3)
    end
    if (not IsAt(CT_ServeOpp[CT_ServeIndex])) then moveto(CT_ServeOpp[CT_ServeIndex]) end
end

function OnServe(ballready)
    if (WaitQueue()) then return end
    if (CT_ServeIndex == 0) then
        CT_ServeIndex = math.random(1,6)
    end
    if (ballready) then
        if (Wait("ServeDelay",math.random(28,90),CT_ServeSelf[CT_ServeIndex]+math.random(-150, 150))) then return end
        if (IsAt(CT_ServeSelf[CT_ServeIndex])) then
            jump()                                
        else                
            moveto(CT_ServeSelf[CT_ServeIndex])
        end
    else
        if (posx() < 150) then
            jump()
        end
        moveto(40)
    end
end

function OnGame()
        ResetWait()
        CT_ServeIndex = 0

        local timeJump = timeToHitHeight(380, 390, 20)
        local timeGround = timeToHitHeight(200, 222, 40)
        local timeBlock = timeToOppSmash(390)
        local estimhx = r_estimx(timeJump)
        local estimGround = r_estimx(timeGround)
        local estimBlock = r_estimx(timeBlock)
        local block = 0
        local wallcoll = willHitWall(timeJump)
        if (timeBlock ~= -1) then timeBlock = timeBlock+(estimBlock-400)/13 end
	if (timeBlock == -1) then timeBlock = 9999 end
        if (timeJump == -1) then estimhx = 9999 end
        if (timeGround == -1) then estimGround = 210 end
	if (CT_SkipNextBlock == 0) then CT_SkipNextBlock = math.random(1,10) end

	if (posy() < CT_LastHeight and posy() > 150 and posy() < 330) then CT_Action = "" end
	CT_LastHeight = posy()

        if (CT_Action == "NetBlock") then
                if ((posy() < 150) or (timeBlock <= 8 and oppy() < 150) or (ballx() <= posx()) or (touches() <= 0 and bspeedx() > 9)) then
                        CT_Action = ""
                else
                        jump()
                        moveto(400)
                        return
                end
        elseif (CT_Action == "JumpPlayFwd") then
                if (posy() < 150) then
                        CT_Action = ""
                else
                        if (estimhx == 9999) then estimhx = ballx()+bspeedx() end
                        jump()
                        if (posy() > 300) then
                                if (math.abs(bally()-posy()) < 18) then
                                        moveto(ballx()+bspeedx())
                                elseif (estimhx < 200) then
                                        if (CT_ShotDecision == 0) then CT_ShotDecision = math.random(3,5) end
                                        moveto(estimhx-10*CT_ShotDecision)
                                elseif (oppx() > 600 and oppy() < 150) then
                                        if (CT_ShotDecision == 0) then CT_ShotDecision = math.random(4,6) end
                                        moveto(estimhx-10*CT_ShotDecision)
                                elseif (oppx() < 600 and oppy() > 180) then
                                        moveto(estimhx-40)
                                else
                                        moveto(estimhx-60)
                                end
                        else
                                moveto(estimhx-50)
                        end
                        return
                end
        elseif (CT_Action == "JumpPlayRev") then
                if (posy() < 150 or touches() ~= CT_LastTouches) then
                        CT_Action = ""
                else
                        if (estimhx == 9999) then estimhx = ballx()+bspeedx() end
                        jump()
                        if (CT_ShotDecision == 0 and touches() == 2) then CT_ShotDecision = math.random(5,7) end
			if (CT_ShotDecision == 0) then CT_ShotDecision = math.random(3,8) end
                        if (math.abs(bally()-posy()) < 18) then
                                moveto(ballx()+bspeedx())
			else
                        	moveto(estimhx+5*CT_ShotDecision)
			end
                        return
                end
        end

	if (touches() ~= CT_LastTouches) then
		CT_LastTouches = touches()
		CT_NextGround = math.random(-20,20)
		CT_SkipNextBlock = 0
	end

	if (CT_Action == "") then
                if ((ballx() < 400 or bspeedx() < -2 or bspeedx() > 10) and estimGround < 400) then
			if (touches() >= 2) then
	                        moveto(estimGround+(posx()-500)/22)
			elseif (math.abs(bspeedx()) > 8) then
				moveto(estimGround)
			else
				moveto(estimGround+CT_NextGround)
			end
                elseif (estimhx < 650 and math.abs(bspeedx()) < 6) then
                        moveto(215)
                elseif (estimhx > 650) then 
                        moveto(250)
		else
			moveto(180)
                end
        end

	if (posy() > 150) then return end
	if (touches() > 2) then return end
        
        if (timeBlock >= 23 and timeBlock <= 25 and CT_SkipNextBlock ~= 1) then
                if (posx() > 210 and estimBlock > 395 and estimBlock < 650 and not wallcoll) then
                        jump()
                        moveto(400)
                        CT_Action = "NetBlock"
                        return
                end
        end
        if (timeJump >= 17 and timeJump <= 19) then
                if (bspeedx() <= 7 and estimhx >= 65 and estimhx <= 420 and posx()-estimhx <= 120 and (bspeedx() >= -7 or not wallcoll)) then
                        if (estimGround > 400 or bally() > 250) then
                                CT_Action = "JumpPlayFwd"
                                CT_ShotDecision = 0
                                jump()
                        end
                end
                if ((wallcoll or bspeedx() >= -7) and estimhx <= 250 and posx()-estimhx <= 180 and posx()-estimhx >= -120) then
                        if (estimGround > 400 or bally() > 250) then
				if (CT_Action == "JumpPlayFwd" and (touches() >= 2 or math.random(100) > 15)) then return end
                                CT_Action = "JumpPlayRev"
                                CT_ShotDecision = 0
                                jump()
                        end
                end
        end
end


function timeToHitHeight(minheight, maxheight, depth)
        local i = 0
        for i=1, depth do
                if (estimy(i) >= minheight and estimy(i) <= maxheight) then
                        return i
                end
        end
        return -1
end

function timeToOppSmash(height)
        if (bally() < height) then return -1 end
        local i = 0
        for i=1, 17 do
                if (estimy(i) < height) then
                        return i
                end
        end
        return -1
end

function r_estimx(time)
        local estim = estimx(time)
        if estim < 31.5 then estim = 63-estim end
        if estim > 768.5 then estim = 1537-estim end
        if (bally() < 330) then
                if (ballx() < 400 and estim > 400) then estim = 723-estim end
                if (ballx() > 400 and estim < 400) then estim = 877-estim end
        end
        return estim        
end

function willHitWall(time)
        if (estimx(time) < 31.5) then return true end
	if (estimx(time) > 768.5) then return true end
        return false
end