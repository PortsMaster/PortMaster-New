-- Com 1.0 human Beta 1
-- by Oreon, Axji & Enormator

-- Flags und runners
wait = 0
naechsterBallSchmettern = true -- evtl Variablennamen wechseln
quatschFlag = 0
mood = math.random(1,3)+3 --Startlaune zwischen 4 und 6


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
CONST_MIN_MOOD = 0
CONST_MAX_MOOD = 10

CONST_ANGRIFFSGRUNDWERT_MIN = 35
CONST_ANGRIFFSGRUNDWERT_MAX = 60
MIN_ANGRIFFSSTAERKE = CONST_ANGRIFFSGRUNDWERT_MIN-mood
MAX_ANGRIFFSSTAERKE = CONST_ANGRIFFSGRUNDWERT_MAX-mood

CONST_GEDULD = 0.01  --weniger ist mehr Geduld

-- ***ANFANG***

function OnOpponentServe()
	BallLinks=false
	if (LauneBerechnet == false) then
		mood=mood-1 --schlechter gelaunt
		LauneBerechnen () --anwenden auf Angriffswert
		LauneBerechnet = true
	end
	moveto(130)
end

function OnServe(ballready)
	BallLinks=true
	if (LauneBerechnet == false) then
		mood=mood+1 --besser gelaunt
		LauneBerechnen () --anwenden auf Angriffswert
		LauneBerechnet = true
	end
	naechsterBallSchmettern = true
	generatenaechsterBallSchmettern()

	if (quatschFlag == 0) then
		quatschFlag = math.random(5,10)
	end
	if (mood > quatschFlag) then --je besser gelaunt, desto wahrscheinlicher Quatsch
		quatschFlag = enormerQuatsch()
	else
		moveto(ballx())
		if ballready and (ballx()-3 < posx()) and (posx() < ballx()+3) then
			jump()
		end
	end
end	

function OnGame()
	debug (mood)
	if (BallLinks == (ballx() > CONST_MITTE)) then --Bei jedem Ballwechsel
		mood = mood - CONST_GEDULD --um CONST_GEDULD schlechter gelaunt sein
		LauneBerechnen ()
		BallLinks = (ballx() < CONST_MITTE)
	end
	LauneBerechnet=false --Flag setzen für Berechnung beim Aufschlag
	quatschFlag=0 --Flag setzen für Berechnung beim Aufschlag
	los=false --Flag setzen für Berechnung beim Aufschlag
	naechsterBallSchmetternFlagTesten() -- schaut ob der bot angreifen soll oder nicht
	target = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_BLOBBY_KOPF_BERUEHRUNG) --X Ziel in Blobbyhoehe
	targetNetz = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_NETZ_HOEHE) --X Ziel in Netzhoehe (Netzrollerberechnung)
	targetJump = estimImpact(ballx(),bally(),bspeedx(),bspeedy(),CONST_BLOBBY_MAXJUMP) --X Ziel in Schmetterhoehe

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
			sprungattacke(angriffsstaerke)
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
	if ((bally() < 600) and (bspeedy() < 0)) or (math.abs(bspeedx()) > 2) or (math.abs(targetJump-posx()) > 40) then -- erst im letzten Moment bewegen -> unvorhersehbar
		moveto(targetJump-p_angriffsstaerke) -- Bei der Sprungatacke wird die Stärke des gewünschten schlages angegeben
	end
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
	
	if (touches() == 1) and (math.abs(bspeedx()) < 2) and (mood < CONST_MAX_MOOD) then -- schon nach der 1ten Beruehrung angreifen wenn der Ball gut kommt und er nicht zu gut gelaunt ist
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
	angriffsstaerke = math.random(MIN_ANGRIFFSSTAERKE,MAX_ANGRIFFSSTAERKE) -- variiert mit der Laune
end

function estimImpact(bx,by,vbx,vby,destY) -- erlaubt ein besseres Estimate mit ein paar umbeding nötigen Angaben
	bgrav = 0.28	

    time1 =(-vby-math.sqrt((vby^2)-(-2*bgrav*(by-destY))))/(-bgrav)
    resultX = (vbx * time1) + bx
	estimbspeedx=bspeedx()

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
    return resultX
end

function enormerQuatsch()
 if los then
  left()
  jump()
 else
  right()
 end
 if (posx() > 350) then
  los=true
 end
 if (posx() < 60) then
  los=false
  return CONST_MAX_MOOD + 1 -- MaxLaune+1 kann nie erreicht werden -> stop
 end
 return quatschFlag -- Wenn nicht fertig, dann nix aendern
end

function LauneBerechnen ()
 if (mood < CONST_MIN_MOOD) then
  mood = 0
 end
 if (mood > CONST_MAX_MOOD) then
  mood = 10
 end
 MIN_ANGRIFFSSTAERKE=CONST_ANGRIFFSGRUNDWERT_MIN-mood
 MAX_ANGRIFFSSTAERKE=CONST_ANGRIFFSGRUNDWERT_MAX-mood
end