-- Hyperion v0.3 by Hyperion
-- Ein paar Ideen stammen von anderen Bots, z.B. vom Combot
-- Playtesting hauptsächlich gegen Combot und Dumpjump
-- Bot hat noch einige Schwierigkeiten bei Netzbällen, der Aufschlag ist zu variabel und dadurch nicht gut genug
-- Die Spielweise ist nicht berechnet, sondern durch Playtesting entstanden
-- Wird sich vielleicht bei der nächsten Version ändern, ich habe allerdings noch keine echte Schwäche gefunden, deswegen bin ich ein bisschen unmotiviert.
-- Kann noch nicht blocken und macht ab und zu Fehlaufschläge.
-- Hat in meinen Tests gegen alle anderen Bots gewonnen (und gegen mich leider auch). Verliert zwar ab und zu durch Netzroller, aber ich habs nicht geschafft zwei Punkte hintereinander zu machen.

-- Der Code ist stellenweise ziemlich schlecht, ich weiß.

-- [Die Dimensionen der Blobbywelt]

field_width				=	800
field_middle			=	400
ball_radius				=	31.5
net_radius				=	7
net_height				=	323 -- Die Kugel am Netz mit eingeschlossen, das ist im Sourcecode falsch dokumentiert
blobby_groesse			=	89
blobby_head				=	25
blobby_bottom_radius	=	33
blobby_center			=	100+89/2
ground					=	100
plane					=	220.5

-- [Die Physik in der Blobbywelt]

-- Die Zeit wird in steps=t gemessen, ein step entspricht dabei einen Frame, die Geschwindigkeit ist also von der Framerate abhängig (die Spielgeschwindigkeit wird auch über die Framerate gesteuert!!!

ball_grav		=	0.28	-- Der Ball fällt also langsamer als der Blobby auf die Erde zurück

blobby_grav		=	0.44 --eigentlich 0.88 aber wenn man sprungtaste gedrückt hält dann so, da es ohne sinnlos ist, kümmern wir uns nicht um die andere
blobby_speed		=	4.5
blobby_jump_speed	=	14.5

-- [Hilfsfunktionen]

function timetoy(y) -- Funktion arbeitet korrekt, driftet nur t=0.001 pro step
a=ball_grav
v=bspeedy()
y0=bally()
t=(v/a-1/10+math.sqrt(v^2/a^2-v/(5*a)+1/100+2*(y0-y)/a))
return t
end

function timetox(x)
v=bspeedx()
x0=ballx()
t=(x-x0)/v
return t
end

function ypos(t)
y=bally()+(bspeedy()-(ball_grav/10))*t-(1/2)*ball_grav*t^2
return y
end


function estimatef(height)
x=ballx()+bspeedx()*timetoy(height)
return x
end

function estimate(y)
x=estimatef(y)
if (x>ball_radius) and (x<361.5) then impact=x end
if (x<ball_radius)
	then
		impact=(2*ball_radius)-x
	end
if (x>361.5)
	then
		if (ballx()<361.5)
			then
				if(ypos(timetox(361.5))<net_height+ball_radius)
					then
						impact=2*361.5-x
					end
			else
				impact=x
			end
	end

return impact
end

-- [Spielfunktionen]

function retten()

if (posx()<280)
	then
		x=estimate(333)
		if (math.abs((x-40)-posx())>3) then moveto(x-40) end
		if (timetoy(333)<10) then jump() end
	else
		x=estimate(333)
		if (math.abs((x-20)-posx())>3) then moveto(x-20) end
		if (timetoy(333)<10) then jump() end
	end
end

function ueberspielen()

if (posx()<280)
	then
		x=estimate(437)
		if (math.abs((x-30)-posx())>3) then moveto(x-30) end
		if (timetoy(437)<24) then jump() end
	else
		x=estimate(437)
		if (math.abs((x-15)-posx())>3) then moveto(x-15) end
		if (timetoy(437)<24) then jump() end
	end
end


function schmettern()
		x=estimate(437)
		t=timetoy(437)
		if (t>24) and (math.abs((x-90)-posx())>3) then moveto(x-90) end
		if (t<24) then jump() end
		if (t<5) then right() end
end

-- [Hauptprogramm]

function OnServe(ballready)

if (new==nil) then new=1 end
if (new==1) then
	j=math.random()
	p=math.random(30,55)
	new=2
	end

if (j>0.5)
	then
		if (math.abs(posx()-200)>3) then moveto(200) else jump() end
	else
		if (math.abs(posx()-(200-p))>3) then moveto(200-p) else jump() end
	end
end

function OnOpponentServe()
moveto(200)
end

function OnGame()
new=1
x=estimate(220.5)

if (x<420)
	then
		if (touches()==0)
			then
				moveto(x)
				newp=1
			end
		if (touches()==1)
			then
				if (newp==1)
					then
						p1=math.random()
						newp=2
					end
				if (oppx()>300)
					then
						if(p1>0.4)
							then
								ueberspielen()
							else
								schmettern()
							end
					else
						if(p1>0.6)
							then
								ueberspielen()
							else
								schmettern()
							end
					end
			end
		if (touches()==2)
			then
				retten()
			end
	else
		moveto(200)
end

end
