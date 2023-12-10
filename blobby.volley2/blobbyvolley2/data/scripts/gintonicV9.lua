--Gin Tonic v9 - Still no comments, sorry :P

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
			moveto(CT_WaitMoveTo)
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
    moveto(CT_ServeOpp[CT_ServeIndex])
end

function OnServe(ballready)
    if (WaitQueue()) then return end
    if (CT_ServeIndex == 0) then
        CT_ServeIndex = math.random(1,6)
    end
    if (ballready) then
        if (Wait("ServeDelay", math.random(28,90), CT_ServeSelf[CT_ServeIndex]+math.random(-150, 150))) then return end
        if (moveto(CT_ServeSelf[CT_ServeIndex])) then
            jump()                                
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
        local timeJump = timeToHitHeight(CONST_BLOBBY_MAX_JUMP, 20)
		local timeGround = timeToHitHeight(CONST_BALL_BLOBBY_HEAD, 40)
        local timeBlock = timeToOppSmash(CONST_BLOBBY_MAX_JUMP)
        local estimhx = estimx(timeJump)
        local estimGround = estimx(timeGround)
        local estimBlock = estimx(timeBlock)
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
                if ((posy() < 150) or (touches() ~= CT_LastTouches)) then
                        CT_Action = ""
                else
                        if (estimhx == 9999) then estimhx = ballx()+bspeedx() end
                        jump()
                        if (posy() > 300) then
                                if (math.abs(bally()-posy()) < 18) then
                                        moveto(ballx()+bspeedx())
                                elseif (estimhx < 200) then
                                        moveto(estimhx-50)
                                elseif (oppx() > 600 and oppy() < 150) then
                                        if (CT_ShotDecision == 0) then CT_ShotDecision = math.random(4,6) end
                                        moveto(estimhx-10*CT_ShotDecision)
                                elseif (oppx() < 600 and oppy() > 180) then
                                        moveto(estimhx-40)
                                else
                                        moveto(estimhx-60)
                                end
                        else
                                moveto(estimhx-70)
                        end
                        return
                end
        elseif (CT_Action == "JumpPlayRev") then
                if ((posy() < 150) or (touches() ~= CT_LastTouches)) then
                        CT_Action = ""
                else
                        if (estimhx == 9999) then estimhx = ballx()+bspeedx() end
                        jump()
                        if (CT_ShotDecision == 0 and touches() == 2) then CT_ShotDecision = math.random(5,6) end
                        if (CT_ShotDecision == 0) then CT_ShotDecision = math.random(3,6) end
                        if (bspeedx() > 5 and touches() < 2 and CT_ShotDecision < 6) then CT_ShotDecision = math.random(6,8) end
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
                if (bspeedx() <= 7 and estimhx >= 65 and estimhx <= 420 and posx()-estimhx <= 90 and (bspeedx() >= -7 or not wallcoll)) then
                        if (estimGround > 400 or bally() > 250) then
                                CT_Action = "JumpPlayFwd"
                                CT_ShotDecision = 0
                                jump()
                        end
                end
                if ((wallcoll or bspeedx() >= -7) and estimhx <= 250 and posx()-estimhx >= -90) then
                        if (estimGround > 400 or bally() > 250) then
                                if (CT_Action == "JumpPlayFwd" and (touches() >= 2 or math.random(100) > 15)) then return end
                                CT_Action = "JumpPlayRev"
                                CT_ShotDecision = 0
                                jump()
                        end
                end
        end
end


function timeToHitHeight(height, depth)
	local time = ball_time_to_y(height)
	if time > depth then return -1 end
	return time
end

function timeToOppSmash(height)
	if (bally() < height) then return -1 end
	local time = ball_time_to_y(height)
	if time > 17 then return -1 end
	return math.ceil(time)
end

function willHitWall(time)
    local pos, velx = estimx(time)
    return velx ~= bspeedx()
end