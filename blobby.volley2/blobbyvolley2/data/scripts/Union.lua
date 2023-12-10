--UNION
--27.3.2007 - version 2
--Enormator
-- 11.01.12 - insert game-provided physic constants where possible - by ngc92
-- 11.04.15 - updated math helper functions

--Startwerte setzen
--set starting values
OOSinit=false
OSinit=false
OGinit=false
decision=0
funcs=4
oldtouches=0
oldbspeedx=0
serve=false

--Weltkonstanten definieren
--define world constants
blobbyheadheight = CONST_GROUND_HEIGHT + CONST_BLOBBY_HEIGHT + CONST_BALL_RADIUS
blobbymaxjump = 393.625
blobbygroundpos = CONST_GROUND_HEIGHT + CONST_BLOBBY_HEIGHT / 2 
netheight = CONST_NET_HEIGHT + CONST_NET_RADIUS -- height is just the rod. for total height, we have to add the net-sphere-radius too

--Hauptfunktionen
--main functions

function OnOpponentServe()
 --initialisiere Funktion
 --initialise function
 OSinit=false
 OGinit=false
 if (OOSinit==false) then --einmal pro Aufruf von OnOpponentServe
                          --one time per OnOpponentServe
  decision=decide(1) --Entscheidung faellen
                     --make a decision
  OOSinit=true
  serve=false
 end
 dofunc (1, decision, true) --Entscheidung ausfuehren
                            --follow the taken decision
end

function OnServe(ballready)
 --initialisiere Funktion
 --initialise function
 OOSinit=false
 OGinit=false
 if (OSinit==false) then --einmal pro Aufruf von OnServe
                         --one time per OnServe
  decision=decide(2) --Entscheidung faellen
                     --make a decision
  OSinit=true
  serve=true --Aufschlag auch waehrend OnGame weitermachen
             --continue serve while OnGame
 end
 dofunc (2, decision, true) --Entscheidung ausfuehren
                            --follow the taken decision
end

function OnGame()
 --initialisiere Funktion
 --initialise function
 OOSinit=false
 OSinit=false
 if (OGinit==false) and (serve==false) then --einmal pro Aufruf von OnGame und wenn der Aufschlag schon vorbei ist
                                            --one time per OnGame and when serve is already over
  decision=decide(3) --Entscheidung faellen
                     --make a decision
  OGinit=true
 end
 if (serve==true) then --Falls noch beim Aufschlag
                       --if still while serve
  dofunc (2, decision, true) --Der Funktion sagen, dass sie immernoch beim Aufschlag ist
                             --tell the function, it's still OnServe
 else
  dofunc (3, decision, true) --Der Funktion sagen, dass sie im Spiel ist
                             --tell the function that it's OnGame
 end
 if (ballx()>CONST_BALL_LEFT_NET+CONST_BALL_RADIUS) then --Falls Ball nicht mehr erreichbar
                                               --If Ball not gettable by Bot
  serve=false --Aufschlagende erzwingen
              --Make an end to the serve
 end
 if (touches()~=oldtouches) or (math.abs(oldbspeedx)~=math.abs(bspeedx())) then --Hat sich die Situation geändert
                                                                                --If the situation has changed
  OGinit=false --gleich Entscheidung neu fällen
               --redo decision
  oldtouches=touches()
  oldbspeedx=bspeedx()
 end
end

--Entscheidungsfunktionen
--decision functions

function decide (funcno)
 t1=1
 chosen=1
 chosenret=0
 --Alle Funktionen abfragen und die mit dem größten Return wählen
 --test all functions and take the one with the highest return value
 while (t1 <= funcs) do
  temp=dofunc(funcno,t1,false)
  if (temp > chosenret) then
   chosen=t1
   chosenret=temp
  end
  t1=t1+1
 end
 --print (chosenret) --Sagt, für wie gut sich die gewählte Funktion hält
                   --tells how good the chosen function says to fit
 return chosen
end

function dofunc (funcno, actionno, action) --Weist jeder Aktionsnummer den echten Funktionsnamen zu
                                           --converts actionnumbers to the real names of the functions
 if (actionno==1) then
  return std45deg (funcno, action)
 end
 if (actionno==2) then
  return takelow (funcno, action)
 end
 if (actionno==3) then
  return wait (funcno, action)
 end
 if (actionno==4) then
  return twohitserve1 (funcno, action)
 end
 return false
end

--Ausführbare Funktionen
--executable functions

function std45deg (funcno, action) --spielt Ball aus der Luft bei maxjump im 45° Winkel an
                                   --plays ball in the air at height maxjump with 45° angle
                                   --funcno(s)=2,3
 local maxjump  = blobbymaxjump
 local distance = 32.25
 local targetx=estimatex (maxjump) - distance
 if (funcno==1) then
  return -1
 end
 if (action==false) then
  if (funcno==2) and (action==false) then
   return math.random(10, 100)
  end
  if (funcno==3) and (action==false) then
   if target ~= math.huge and (bspeedx() <= 3) and (math.max(balltimetox(targetx), ball_time_to_y(maxjump)) >= math.max(blobtimetoy(maxjump), blob_time_to_x(targetx))) then
    if (estimhitnet()==true) and (blob_time_to_x(CONST_BALL_LEFT_NET)<=ball_time_to_y(netheight)) then
     return 190
    end
	if (bspeedx()==0) then
     return 85
    else
     return math.min((10^(-math.abs(bspeedx()))+1),1)*85
    end
	else
    return 0
   end
  end
 end
 if (action==true) then
  if (funcno==2) then
   if (posy()==144.5) then
    moveto (targetx)
   end
   if (math.abs(posx()-targetx)<4.5) and (ballx()==200) and (bally()==299.5) then
    jump()
   end
  end
  if (funcno==3) then
   moveto (targetx)
   if ((bally()<580) and (bspeedy()<0)) then
    jump()
   end
  end
  if (jumpcase) then
   jump()
  end
 end
end

function takelow (funcno, action) --Ballannahme ohne Sprung zum Stellen (bspeedx()=0) selten exakt
                                  --take ball without jump to create a ball with bspeedx()=0 (sellen exactly)
                                  --funcno(s)=3
 if (funcno==1) or (funcno==2) then
  return -1
 end
 if (action==false) then
  if (touches()<=1) then
   return 1
  else
   return -1
  end
 end
 if (action==true) then
  local target =estimatex( blobbyheadheight )
  if target ~= math.huge then
	moveto ( target )
  else
	moveto( 200 )
  end
 end
end

function wait (funcno, action) --Auf guter Position auf eine gegnerische Aktion warten
                               --wait for an opponent's move at a good position
                               --funcno(s)=1,3
 if (funcno==2) then
  return -1
 end
 if (funcno==1) and (action==false) then
  return 200
 end
 if (funcno==3) and (action==false) then
  local estimpos = estimatex( blobbyheadheight )
  if ( estimpos > 424.5 and estimpos ~= math.huge) then
   return 200
  else
   return -1
  end
 end
 if (action==true) then
  moveto (180)
 end  
end

function twohitserve1 (funcno, action) --Aufschlag: Stellen (bspeedx()=0), rueber
                                       --serve: up (bspeedx()=0), play
                                       --funcno(s)=2
 if (funcno==1) or (funcno==3) then
  return -1
 end
 if (action==false) then
  return math.random(10,100)
 else
  if (touches()==0) then
   moveto (200)
   if (math.abs(posx()-200)<5) then
    jump()
   end
  end
  if (touches()==1) then
   moveto (estimatex(blobbymaxjump)-45)
   if (bally()<580) and (bspeedy()<0) then
    jump()
   end
  end
  if (touches()==3) then
   serve=false
  end
 end
end

--mathematische Hilfsfunktionen
--mathematical helpers

function estimatex(destY) --gibt möglichst genaue Angabe der X-Koordinate zurück, bei der sich der Ball befindet, wenn er sich bei der angegebenen Y Koordinate befindet
                          --returns exact ballx when bally will be given destY
 if (bspeedy()==0) and (bspeedx()==0) then
  return ballx()
 end
 local time1 = ball_time_to_y(destY, balldata())
 -- return #inf if time is #inf, i.e. destY will never be reached
 if time1 == math.huge then
	return time1
 end
 local resultX, hit, estimbspeedx = estimx(time1)
 
 if (resultX > CONST_BALL_LEFT_NET) and (estimatey(CONST_BALL_LEFT_NET) <= netheight) and (estimbspeedx > 0) then
  resultX = mirror(resultX, CONST_BALL_LEFT_NET)
 end
 if (resultX < CONST_BALL_RIGHT_NET) and (estimatey(CONST_BALL_RIGHT_NET) <= netheight) and (estimbspeedx < 0) then
  resultX = mirror(resultX, CONST_BALL_RIGHT_NET)
 end
 return resultX
end

function blobtimetoy (y) --Zeit, die ein Blob braucht, um eine Y Position zu erreichen
                         --time needed by a blob to reach a given y coordinate
 if (y>383) then
  y=383
 end
 grav = CONST_BLOBBY_GRAVITY / 2    -- half, because we use jump buffer
 time1 = CONST_BLOBBY_JUMP/grav + math.sqrt(2*grav*(y-blobbygroundpos) + CONST_BLOBBY_JUMP*CONST_BLOBBY_JUMP) / grav
 time2 = CONST_BLOBBY_JUMP/grav - math.sqrt(2*grav*(y-blobbygroundpos) + CONST_BLOBBY_JUMP*CONST_BLOBBY_JUMP) / grav
 timemin=math.min(time1,time2)
 return timemin
end

function estimhitnet() --Wird der Ball das Netz treffen (bool)
                       --Will the ball hit the net (bool)
 safety=5
 return (361.5-safety < estimatex(323)) and (estimatex(323) < 438.5+safety)
end

function estimatey (x) --Y Position des Balls, wenn er sich an der angegebenen X Koordinate befindet
                       --y position of the ball, when it is at the given x coordinate
 return estimy(ball_time_to_x(x))
end
