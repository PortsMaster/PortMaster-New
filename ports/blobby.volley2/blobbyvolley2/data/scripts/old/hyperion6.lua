-- Dies ist der BlobbyVolley2 Bot "Hyperion"
-- geschrieben und getestet wurde der Bot mit der SVN-Version
-- Die Version Blobby0.6 hatte verschiedene Bugs, unter anderem bei der oppx() und der estimate() Funktion
--
-- Hyperion ver. 0.6

-- <Abschnitt 1> - Einige Konstanten die die physikalische Welt in BlobbyVolley2 beschreiben

g=0.28
g_p=0.88
v0=14.5
v_p=4.5
jb_p=0.44
r1=31.5

-- </Abschnitt 1>


-- <Abschnitt 2> - kleine unkomplizierte Hilfsfunktionen die ich benötige

function max(a,b)
	if (a>b) then
		return a
	else
		return b
	end
end

function min(a,b)
	if (a<b) then
		return a
	else
		return b
	end
end

function y_b(y,vy,t)
-- Eingabe: Position und Geschwindigkeit des Balles, Zeitpunkt an dem man die y-Koordinate des Balles wissen möchte
-- Ausgabe: Höhe des Balles nach der Zeit t
	return y+(vy-g/10)*t-1/2*g*t^2
end

function peak(y,vy)
	return vy/g-1/10
end

function ymax_b(y,vy)
	return y_b(v,vy,peak(y,vy))
end

function move(x)
	if (posx()<x) and (math.abs(posx()-x)>2.6) then right()
	elseif (posx()>x) and (math.abs(posx()-x)>2.6) then left()
	end
end

function t1_y(y,vy,height)
-- Eingabe: Position und Geschwindigkeit des Balles, Höhe die der Ball erreichen soll
-- Ausgabe: Ausgabe der Zeit bis zur Höhe height
	if (vy^2/g^2-vy/(5*g)+1/100+2*(y-height)/g<0) then
		return -1
	else
		return -1/10+vy/g-math.sqrt( vy^2/g^2-vy/(5*g)+1/100+2*(y-height)/g )
	end
end

function t2_y(y,vy,height)
-- Eingabe: Position und Geschwindigkeit des Balles, Höhe die der Ball erreichen soll
-- Ausgabe: Ausgabe der Zeit bis zur Höhe height
	if (vy^2/g^2-vy/(5*g)+1/100+2*(y-height)/g<0) then
		return -1
	else
		return -1/10+vy/g+math.sqrt( vy^2/g^2-vy/(5*g)+1/100+2*(y-height)/g )
	end
end

function y_p(y,t)
-- Eingabe: Position und Geschwindigkeit des Players, Zeitpunkt an dem man die y-Koordinate des Players wissen möchte
-- Ausgabe: Höhe des Players nach der Zeit t
	return y+(v0+jb_p/2+g_p/10)*t-1/2*(g_p-jb_p)*t^2
end

tp_peak=(14.5+0.44/2+0.88/10)/(0.88-0.44)
yp_max=y_p(144.5,tp_peak)

function time(t)
	return 1/5*math.ceil(5*t)
end

function t2_yp(y,vy,height)
y=144.5
	return (v0+jb_p/2+g_p/10)/(g_p-jb_p)+math.sqrt((v0+jb_p/2+g_p/10)^2/(g_p-jb_p)^2+2*y/(g_p-jb_p))
end
-- </Abschnitt 2>


-- <Abschnitt 3> - Komplizierte Funktionen die die Game-Engine nachbilden und so Einschlagpunkte, etc. berechnen.

function collide(x,y,vx,vy,x2,y2,r2)
-- Berechnet, ob und nach welcher Zeit der Ball im Zustand (x,y,vx,vy) mit der Kugel an (x2,y2) mit Radius r2 kollidiert
local leftb=x2-r2-r1
local rightb=x2+r2+r1
local lowerb=y2-r2-r1
local upperb=y2+r2+r1

local txlb=time((leftb-x)/vx) -- Zeit zur linken Begrenzung
local txrb=time((rightb-x)/vx) -- Zeit zur rechten Begrenzung
local tyla=time(t1_y(y,vy,lowerb)) --untere Grenze steigend (ascending)
local tyld=time(t2_y(y,vy,lowerb)) --untere Grenze fallend (descending)
local tyua=time(t1_y(y,vy,upperb)) --obere Grenze steigend (ascending)
local tyud=time(t2_y(y,vy,upperb)) --obere Grenze fallend (descending)
local tp=time(vy/g-1/10) -- Zeit bis die Ballkurve auf dem Höhepunkt ist (kann in der Vergangenheit liegen)

local t1,t2,t_coll=0,0,-1

if (vx>0) then
		t1=max(max(txlb,tyla),0)
		t2=min(txrb,tyld)
	else
		t1=max(max(txrb,tyla),0)
		t2=min(txlb,tyld)
end

if (t1<t2) and (t1<300) and (math.abs(t1-t2)<100) then
	for t=t1,t2,0.2 do
		local xnew,ynew=x+vx*t,y_b(y,vy,t)
		if ((xnew-x2)^2+(ynew-y2)^2<(r1+r2)^2) then
			t_coll=t
			break
		end
	end
end

return t_coll
end

function estimate_t(x,y,vx,vy,height)
-- schätzt den Ort des Balles bei der Höhe height fallend und die Zeit bis dahin

local collision=1
local t_wall,t_net,t_netsphere=0,0,0
local t_ret,x_ret,y_ret,vx_ret,vy_ret=0,0,0,0,0
local t_height=0
while(collision==1) do
	t_netsphere=collide(x,y,vx,vy,400,316,7)
	if (vx>0)
		then
		t_wall=time((768.5-x)/vx)
		t_net=time((361.5-x)/vx)
		else
		t_wall=time((31.5-x)/vx)
		t_net=time((438.5-x)/vx)
	end
	local t=10000
	if ((t_netsphere>0) and (t_netsphere<t)) then t=t_netsphere end
	if (((t_net>0) and (t_net<t)) and (y_b(y,vy,t_net)<316)) then t=t_net end
	if ((t_wall>0) and (t_wall<t)) then t=t_wall end
	t_height=time(t2_y(y,vy,height))
	if (t_height>t) then
		if (t==t_netsphere) then
			t_ret=t_ret+t
			vx_ret=0
			vy_ret=0
			x_ret=400
			y_ret=316
			collision=0
		end
		if (t==t_net) or (t==t_wall) then
			t_ret=t_ret+t
			x=x+vx*t
			y=y_b(y,vy,t)
			vx=-vx
			vy=vy-g*t
			collision=1
		end
	else
		t_ret=t_ret+t_height
		vx_ret=vx
		vy_ret=vy-g*t_height
		x_ret=x+vx*t_height
		y_ret=y_b(y,vy,t_height)
		collision=0
	end


end -- while Ende
return x_ret,y_ret,vx_ret,vy_ret,t_ret
end




function impact(x,y,vx,vy,xpos,ypos)
-- schätzt den Einschlagsort des Balles wenn er mit dem Blobby an Position xpos kollidiert ist und dann losfliegt.
-- Funktioniert mit minimalem Fehler

r1=31.5
r2=25
--local x,y,vx,vy,t1=estimate_t(x,y,vx,vy,(ypos+19+25)+31.5) Die Wete haben schon nahe genug zu sein
local t=time(collide(x,y,vx,vy,xpos,ypos+19,25))
if(t>0) then
	x=x+vx*t
	y=y_b(y,vy,t)
	dx=x-xpos
	dy=y-(ypos+19)
	l=math.sqrt(dx^2+dy^2)
	vx=dx/l
	vy=dy/l
	x=x+vx*3
	y=y+vy*3
	vy=vy*13.125
	vx=vx*13.125
--	x=x+vx/5
--	y=y+vy/5
	x,y,vx,vy,t=estimate_t(x,y,vx,vy,220.5)
	return x,y,vx,vy,t
else
	return -1,-1,-1,-1,-1
end

end -- Funktionsende

function xtoplayto(target,height)

local x,y,vx,vy,t=estimate_t(ballx(),bally(),bspeedx(),bspeedy(),height+(25+19)+31.5+5)
local xpos=estimate_t(ballx(),bally(),bspeedx(),bspeedy(),height+(25+19)+31.5)
local sgn=0
if (x<target) then sgn=-1 else sgn=1 end
local imp=0
local oldimpact=-1000

for pos=xpos,xpos+sgn*30,sgn*2.5 do
	imp=impact(x,y,vx,vy,pos,height)
	if (math.abs(imp-target)<math.abs(oldimpact-target)) then
		oldimpact=imp
	else
		xpos=pos-sgn*2.5
		break
	end
end

return xpos
end


-- </Abschnitt 3>

-- <Abschnitt 4> - High-Level Funktionen die bestimmen wo man s

function stellen(tox,height)
--t2_yp
--t2_y
if (tox<390) then

elseif (390<tox) and (tox<410) then

elseif (tox>410) then

end

move(xplayto(tox,posy()))
end


function schmettern()

end

function ueberspielen()

end



-- </Abschnitt 4>

-- <Abschnitt 5> - Die Hauptfunktionen des Spiels
function OnOpponentServe()
end

function OnServe(ballready)
if (math.abs(math.floor(posx()/4.5)-posx()/4.5)<0.4)
	then
		if(math.abs(180-posx())<2) then jump() else moveto(180) end
	else
		moveto(400)
	end
	old=5
end

function OnGame()




x1=ballx()
y1=bally()
vx1=bspeedx()
vy1=bspeedy()
x2=oppx()
y2=163.5
r2=25

xe=estimate_t(x1,y1,vx1,vy1,220.5)
--debug(xe)
-- debug(x2)
xr,yr,vxr,vyr,tr=impact(x1,y1,vx1,vy1,x2,144.5)


-- debug(xr)
-- debug(0)


if (xe<400) then
		
		if (touches()==0) then
		test=xtoplayto(320,144.5)
		move(test)
		else
		test=xtoplayto(400,144.5)
		move(test-3.1)
		end


elseif (xe==400) then
	move(180)
else
	move(180)
end
old=touches()
end