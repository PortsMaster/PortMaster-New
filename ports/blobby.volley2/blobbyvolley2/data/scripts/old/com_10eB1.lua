-- Com 1.0 human Beta 1
-- by Oreon, Axji & Enormator

-- Flags und runners
wait = 0
naechsterBallSchmettern = true -- evtl Variablennamen wechseln


-- Weltkonstanten

CONST_FELD_LAENGE = 800
CONST_BALL_RADIUS = 31.5
CONST_GROUND_PLANE = 100

CONST_BALL_GRAVITY = 0.28

CONST_MITTE = CONST_FELD_LAENGE/2
CONST_RECHTER_RAND = CONST_FELD_LAENGE - CONST_BALL_RADIUS

CONST_BLOBBY_HOEHE = 89
CONST_BLOBBY_KOPF_RADIUS = 25
CONST_BLOBBY_BAUCH_RADIUS = 33
CONST_BLOBBY_KOPF_BERUEHRUNG = CONST_GROUND_PLANE + CONST_BLOBBY_HOEHE + CONST_BALL_RADIUS
CONST_BLOBBY_MAXJUMP = 393.625

CONST_NETZ_RADIUS = 7
CONST_NETZ_HOEHE = 323

-- Berührungsebene des Balls falls er ans Netz kommt
CONST_NETZ_LINKS = CONST_MITTE - CONST_NETZ_RADIUS - CONST_BALL_RADIUS 
CONST_NETZ_RECHTS = CONST_MITTE + CONST_NETZ_RADIUS + CONST_BALL_RADIUS 

-- Charakter
CONST_ANGRIFFSGRUNDWERT_MIN = 30
CONST_ANGRIFFSGRUNDWERT_MAX = 55
MIN_ANGRIFFSSTAERKE = CONST_ANGRIFFSGRUNDWERT_MIN
MAX_ANGRIFFSSTAERKE = CONST_ANGRIFFSGRUNDWERT_MAX


-- ***ANFANG***

function OnOpponentServe()
	moveto(130)
end

function OnServe(ballready)
	naechsterBallSchmettern = true
	generatenaechsterBallSchmettern()
	moveto(ballx())
	if ballready and (ballx()-3 < posx()) and (posx() < ballx()+3) then
		jump()
	end
end	

function OnGame()
	naechsterBallSchmetternFlagTesten() -- schaut ob der bot angreifen soll oder nicht
	target = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_BLOBBY_KOPF_BERUEHRUNG,1) --X Ziel in Blobbyhoehe
	targets = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_BLOBBY_KOPF_BERUEHRUNG,2) --X Richtung (-1 oder 1) bei Einschlag
	targetNetz = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_NETZ_HOEHE,1) --X Ziel in Netzhoehe (Netzrollerberechnung)
	targetJump = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_BLOBBY_MAXJUMP,1) --X Ziel in Schmetterhoehe

	if (ballx() > CONST_NETZ_RECHTS) then --Wenn Ball auf rechter Spielfeldseite dann
		generatenaechsterBallSchmettern() --Angriffsstaerke neu berechnen
	end
	
	if (target > CONST_MITTE) and (ballx() > CONST_NETZ_RECHTS) then --Wenn der Ball mich nix angeht
		moveto(135) --Dann auf Standartposition warten
	else
		if (targetNetz > CONST_NETZ_LINKS - 10) then --Bei Netzroller einfach schmettern
			naechsterBallSchmettern = true
		end

		if naechsterBallSchmettern then
			if ((math.abs(bspeedx()) < 4) or (bspeedx() < 0)) then
				sprungattacke(angriffsstaerke)
			else
				if (targetJump < CONST_MITTE / 2) then
					sprungattacke(-30) --an Rueckwand spielen
				else
					sprungattacke(0) --weiterleiten
				end
			end
			return
		end

		moveto(target)
	end
end


function sprungattacke(p_angriffsstaerke)
	if (bally() < 550) and (math.abs(ballx() - posx()) > 200) then -- Falls nicht schmetterbar
		moveto (target - 25) --Dann Notloesung versuchen
		return
	end

	moveto(targetJump-p_angriffsstaerke) -- Bei der Sprungatacke wird die Stärke des gewünschten schlages angegeben

	if (bally() < 580) and (bspeedy() < 0) then
		jump()
	end
end

function naechsterBallSchmetternFlagTesten()
	if (touches() == 3) then -- falls der Bot einen Anschlag Findet der Direckt punktet so wird der Wer nicht neu berechnet da er dann nciht auf 3 Berührungen kommt
		naechsterBallSchmettern = false
		return
	end
	
	if (ballx() > CONST_MITTE) then -- wenn der ball auf der Anderen Seite ist soll der bot nicht naechsterBallSchmettern sein
		naechsterBallSchmettern = false 
		return
	end
	
	if (touches() == 1) and (math.abs(bspeedx()) < 2) then -- schon nach der 1ten Beruehrung angreifen wenn der Ball gut kommt
		naechsterBallSchmettern = true
		return
	end
	
	if (touches() == 2) then -- nach der 2. Berührung angreifen
		naechsterBallSchmettern = true
		return
	end
	naechsterBallSchmettern = false
end

function generatenaechsterBallSchmettern()
	angriffsstaerke = math.random(MIN_ANGRIFFSSTAERKE,MAX_ANGRIFFSSTAERKE)
end

function estimImpact(bx,by,vbx,vby,destY,Frage) -- erlaubt ein besseres Estimate mit ein paar unbeding nötigen Angaben
	bgrav = 0.28	

    time1 =(-vby-math.sqrt((vby^2)-(-2*bgrav*(by-destY))))/(-bgrav)
    resultX = (vbx * time1) + bx
	estimbspeedx=bspeedx()/math.abs(bspeedx())

	if(resultX > CONST_RECHTER_RAND) then -- Korrigieren der Appraller an der Rechten Ebene
		resultX = 2 * CONST_FELD_LAENGE - resultX
		estimbspeedx=-estimbspeedx
	end

	if(resultX < CONST_BALL_RADIUS) then -- korrigieren der Appraller an der linken Ebene
		resultX = math.abs(resultX - CONST_BALL_RADIUS) + CONST_BALL_RADIUS
		estimbspeedx=-estimbspeedx
		KollisionLinks = true
	else
		KollisionLinks = false
	end

	if (resultX > CONST_NETZ_RECHTS) and (estimbspeedx > 0) and ((KollisionLinks == true) or (ballx() < CONST_NETZ_LINKS)) then -- Abpraller am Netz unterhalb der Kugel erst wenn Netzroller ausgeschlossen sind
		resultX = 2 * CONST_NETZ_LINKS - resultX
		estimbspeedx=-estimbspeedx
	end

	if (Frage == 1) then
		return resultX
	end
	if (Frage == 2) then
		return estimbspeedx
	end
end