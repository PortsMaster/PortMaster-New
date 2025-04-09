-- Flags und runners
wait = 0
naechsterBallSchmettern = true -- evtl Variablennamen wechseln
angriffsstaerke = 50 -- versetzung zum Ball je grösser desto tiefer fliegt der Service 0-64(  64 ist ca CONST_BALLRADIUS + CONST_BLOBBY_BAUCH_RADIUS) 
angriffsstaerkeNeuBerechnen =false -- neuberechnung von angriffsstaerke => Variable Angriffe

-- Konstanten

CONST_FELD_LAENGE = 800
CONST_BALL_RADIUS = 31.5
CONST_GROUND_PLANE = 100

CONST_MITTE = CONST_FELD_LAENGE/2
CONST_RECHTER_RAND = CONST_FELD_LAENGE - CONST_BALL_RADIUS


CONST_BLOBBY_HOEHE = 89
CONST_BLOBBY_KOPF_RADIUS = 25
CONST_BLOBBY_BAUCH_RADIUS = 33
CONST_BLOBBY_KOPF_BERUEHRUNG = CONST_GROUND_PLANE + CONST_BLOBBY_HOEHE + CONST_BALL_RADIUS

CONST_NETZ_RADIUS = 7
CONST_NETZ_HOEHE = 157

-- Linke Berührungsebene des Balls falls er ans Netz kommt
CONST_NETZ_LINKS = CONST_MITTE - CONST_NETZ_RADIUS - CONST_BALL_RADIUS 



function OnOpponentServe()
	moveto(120)
	generatenaechsterBallSchmettern() -- der gegner soll den smash ja nicht vorhersagen können
end

function OnServe(ballready)
	moveto(ballx())
	wait = wait + 1 
	naechsterBallSchmettern = true
	if ballready then
		if wait > 90 then
			jump()
			wait = 0
		end
	end
end	

function OnGame()
	naechsterBallSchmetternFlagTesten() -- schaut ob der bot angreifen soll oder nicht
	target = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_BLOBBY_KOPF_BERUEHRUNG)	
	
	if target > 440 then
		moveto(120)
	else	
		if naechsterBallSchmettern then
			sprungattacke(angriffsstaerke)
			return
		end

		-- nun kümmern wir uns um die Bälle die ans netz prallen
		if ((target > CONST_NETZ_LINKS) and (ballx() < CONST_NETZ_LINKS)) then
			netzappraller(target)
			return
		end

		moveto(target)
	end
end


function netzappraller(p_target)
		moveto(CONST_NETZ_LINKS - (p_target - CONST_NETZ_LINKS) + math.abs(bspeedx()*bspeedx()*1.4))
end



function sprungattacke(p_angriffsstaerke)
		moveto(ballx()-p_angriffsstaerke) -- Bei der Sprungatacke wird die Stärke des gewünschten schlages angegeben
		if bally() < 580 then
			jump()
		end
end

function naechsterBallSchmetternFlagTesten()
	if (touches() == 3) then -- falls der Bot einen Anschlag Findet der Direckt punktet so wird der Wer nicht neu berechnet da er dann nciht auf 3 Berührungen kommt
		naechsterBallSchmettern = false
		angriffsstaerkeNeuBerechnen = true -- da würde es sicher auch einen Inteligenteren Test geben.
		return
	end
	
	if (angriffsstaerkeNeuBerechnen == true) then
		generatenaechsterBallSchmettern()
	end
	

	if (ballx() > CONST_MITTE) then -- wenn der ball auf der Anderen Seite ist soll der bot nicht naechsterBallSchmettern sein
		naechsterBallSchmettern = false 
		return
	end
	
	if (touches() == 2) then -- nach der 2. Berührung angreifen
		if (bally() > 500) then -- erst wenn der Ball hoeher als 500 fliegt sonst gibt es keinen schönen Schmetterball.
			naechsterBallSchmettern = true
		end
		return
	end

	if ((ballx() < (400-CONST_BALL_RADIUS)) and (bally() < 200) and (math.abs(bspeedx()) < 40)) then -- der ball könnte noch drüber fliegen ** noch optimieren
		naechsterBallSchmettern = true
		return
	end
end

function generatenaechsterBallSchmettern()
	angriffsstaerkeNeuBerechnen = false;
	angriffsstaerke = math.random(20,55) -- variiert mit der Angriffsstärke also auch mit den Anschlägen
end

function estimImpact(bx,by,vbx,vby,destY) -- erlaubt ein besseres Estimate mit ein paar umbeding nötigen Angaben
	bgrav = 0.28	

    time1 =(-vby-math.sqrt((vby^2)-(-2*bgrav*(by-destY))))/(-bgrav)
    resultX = (vbx * time1) + bx

	if(resultX < CONST_BALL_RADIUS) then -- korrigieren der Appraller an der Hinteren Ebene
		resultX = math.abs(CONST_BALL_RADIUS - resultX) + CONST_BALL_RADIUS
	end
	
	if(resultX > CONST_RECHTER_RAND) then -- Korrigieren der Appraller an der Rechten Ebene
		resultX = CONST_FELD_LAENGE - (resultX - CONST_FELD_LAENGE)
	end

    return resultX
end

function cleanMoveTo(position) -- eine nette Spielerei ;)
	if (posx() ~= position) then
		moveto(position)
	end	
end
