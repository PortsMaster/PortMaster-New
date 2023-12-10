g=0.28
pg=0.88
v0=14.5
v_p=4.5
pj=0.44
r1=31.5
p0=0
p1=0.5
p2=1
h=31.5+19+25


estt=0
nettime=0
touch=0
est=0
p=0.4
esto=10


function yb(y,vy,t)

	return y+(vy-g/10)*t-1/2*g*t^2

end

function move(x)

	if (posx()<x) and (math.abs(posx()-x)>2.26) then right()
	elseif (posx()>x) and (math.abs(posx()-x)>2.26) then left()
	end

end

function tb(y,vy,height,typ)
local sgn=0
	if (typ==1)
		then
			sgn=-1
		else
			sgn=1
	end
	if vy^2/g^2-vy/(5*g)+1/100+2*(y-height)/g<0
		then return -1
	else
		return -1/10+vy/g+sgn*math.sqrt( vy^2/g^2-vy/(5*g)+1/100+2*(y-height)/g )
	end
end

function time(t)

	return 1/5*math.ceil(5*t)

end

function pos(x)

	local x1,x2
	x1=4.5*math.ceil((1/4.5)*x)
	x2=4.5*math.floor((1/4.5)*x)
	if (x1<0) or (x2<0) then return 0
	else
	if (math.abs(x1-x)<math.abs(x2-x))
		then
			return x1
		else
			return x2
	end
end
end

function yp(t)
-- Eingabe: Position und Geschwindigkeit des Players, Zeitpunkt an dem man die y-Koordinate des Players wissen möchte
-- Ausgabe: Höhe des Players nach der Zeit t
return 144.5+(14.5+pj/2+pg/10)*t-1/2*(pg-pj)*t^2
end

function tp(y)
	return (14.5+pj/2+pg/10)/(pg-pj)-math.sqrt(((14.5+pj/2+pg/10)/(pg-pj))^2-(y-144.5)/(1/2*(pg-pj)))
end

function time(t)
return 1/5*math.ceil(5*t)
end


-- </Abschnitt 2>

function collide(x,y,vx,vy,objx,objy,r2)

	local t1=time(math.max(tb(y,vy,objy-(r1+r2),1)-0.2,0))
	local t2=time(tb(y,vy,objy+(r1+r2),1)+0.2)
	local t3=time(math.max(tb(y,vy,objy+(r1+r2),2)-0.2,0))
	local t4=time(tb(y,vy,objy-(r1+r2),2)+0.2)
	local t=-1
	if (t1<t2)
		then
			for testimate=t1,t2,0.2 do
				if ( (yb(y,vy,testimate)-objy)^2+(x+vx*testimate-objx)^2 < (r1+r2)^2)
					then
						t=testimate
						break
				end
			end
	end

	if (t<=0) and (t3<t4)
		then
			for testimate=t3,t4,0.2 do
				if ( (yb(y,vy,testimate)-objy)^2+(x+vx*testimate-objx)^2 < (r1+r2)^2)
					then
						t=testimate
						break
				end
			end
	end

	if (t<=0) or (t>150) then t=-1 end

	return t

end



function estimate(x,y,vx,vy,height,typ)

	local collision=1
	local tw,tn,ts=0,0,0
	local tr,xr,yr,vxr,vyr,n=0,0,0,0,0,0

	while(collision==1) do
		ts=collide(x,y,vx,vy,400,316,7)
		if (vx>0)
			then
				tw=time((768.5-x)/vx)
				tn=time((361.5-x)/vx)
			else
				tw=time((31.5-x)/vx)
				tn=time((438.5-x)/vx)
		end
		local th=time(tb(y,vy,height,typ))
		local t=10000

		if ((ts>0) and (ts<t)) then t=ts end
		if (((tn>0) and (tn<t)) and (yb(y,vy,tn)<316)) then t=tn end
		if ((tw>0) and (tw<t)) then t=tw end

		if (th>t)
			then
				if (t==ts)
					then
						tr=tr+t
						x=x+vx*t
						y=yb(y,vy,t)
						vy=vy-g*t
						xr=x
						yr=y
						vxr=0
						vyr=0
						n=1
						collision=0
					elseif ((t==tn) or (t==tw))
					then
						tr=tr+t
						x=x+vx*t
						y=yb(y,vy,t)
						vx=-vx
						vy=vy-g*t
						collision=1
				end
			else
				tr=tr+th
				vxr=vx
				vyr=vy-g*th
				xr=x+vx*th
				yr=yb(y,vy,th)
				collision=0
		end
	end
	if (tr<0)
		then
			return -1,-1,-1,-1,-1,-1
		else
			return xr,yr,vxr,vyr,tr,n
	end
end


function impact(x,y,vx,vy,xpos,ypos,targety,jump,move)
local x1,y1,vx1,vy1=0,0,0,0
local x2,y2,vx2,vy2,t2,nn=0,0,0,0,0,0
local xpos1=xpos
local ypos1=ypos
for t=0,20,0.2 do

		if (jump==1) then
			ypos1=yp(tp(ypos)+t)
		end
		x1=x+vx*t
		if (x1<31.5) then x1=2*31.5-x1 end
		if (x1>368.5) then x1=2*368.5-x1 end
		y1=yb(y,vy,t)

		if ((xpos1-x1)^2+(ypos1+19-y1)^2<(31.5+25)^2) then
			local dx=x1-xpos1
			local dy=y1-(ypos1+19)
			local l=math.sqrt(dx^2+dy^2)
			vx1=dx/l
			vy1=dy/l
			x1=x1+vx1*3
			y1=y1+vy1*3
			vy1=vy1*13.125
			vx1=vx1*13.125
			x2,y2,vx2,vy2,t2,nn=estimate(x1,y1,vx1,vy1,targety,2)
			break
		end
end

return x2,y2,x1,y1,vx1,vy1
end


function netp()

	if (math.abs(est-esto)>0.2) then
		esto=est
		imp=0
		x1=0
		for t=27,0,-3 do
			t1f=t
			y1f=yp(t1f)
			t2f=math.floor(tb(y,vy,y1f+h,2))
			if (t2f>0) then
				y2f=yb(y,vy,t2f)
				vy2f=vy-g*t2f
				x2f,y2f,vx2f,vy2f,t2f,_=estimate(x,y,vx,vy,y2f-vy2f/10,2)
				t1f=math.floor(tp(y2f-h))
				y1f=yp(t1f)
				impt=0
				if (t1f<=t2f-2) and (math.abs(posx()-x2f)/4.5<t2f) then
					for x1f=pos(x2f)+4.5,pos(x2f)-15*4.5,-4.5 do
						impf,_=impact(x2f,y2f,vx2f,vy2f,pos(x1f),y1f,220,1,0)
						if (impf>400) and (math.abs(posx()-x1f)/4.5<t2f) then
							impt=impf
							x1t=x1f
							y1t=y1f
							t1t=t1f
							x2t=x2f
							y2t=y2f
							t2t=t2f
							vx2t=vx2f
							vy2t=vy2f
							break
						end
					end
					if (impt>imp) and (impt<431.5) then
						imp=impt
						x1=x1t
						y1=y1t
						t1=t1t
						x2=x2t
						y2=y2t
						t2=t2t
						vx2=vx2t
						vy2=vy2t
					end
					if (imp>415) then break end
				end
			end
		end
		t2=t2+1
	end

	t2=t2-1
	move(x1)
	if (t2<=t1+0.1) and (y1>150) then jump() end

end



function lob()

	if (math.abs(est-esto)>0.2) then
		esto=est
		imp=0
		x1=0
		for t=27,0,-3 do
			t1f=t
			y1f=yp(t1f)
			t2f=math.floor(tb(y,vy,y1f+h,2))
			if (t2f>0) then
				y2f=yb(y,vy,t2f)
				vy2f=vy-g*t2f
				x2f,y2f,vx2f,vy2f,t2f,_=estimate(x,y,vx,vy,y2f-vy2f/10,2)
				t1f=math.floor(tp(y2f-h))
				y1f=yp(t1f)
				impt=0
				if (t1f<=t2f-2) then
					for x1f=pos(x2f)+4.5,pos(x2f)-15*4.5,-4.5 do
						impf,_=impact(x2f,y2f,vx2f,vy2f,pos(x1f),y1f,220,1,0)
						if (impf>700) and (math.abs(posx()-x1f)/4.5<t2f) then
							impt=impf
							x1t=x1f
							y1t=y1f
							t1t=t1f
							x2t=x2f
							y2t=y2f
							t2t=t2f
							vx2t=vx2f
							vy2t=vy2f
							break
						end
					end
					if (impt>imp) then
						imp=impt
						x1=x1t
						y1=y1t
						t1=t1t
						x2=x2t
						y2=y2t
						t2=t2t
						vx2=vx2t
						vy2=vy2t
					end
					if (imp>750) then break end
				end
			end
		end
		t2=t2+1
	end

	t2=t2-1
	move(x1)
	if (t2<=t1+0.1) then jump() end

end



function attack()
h2=900
	if (math.abs(est-esto)>0.2) then
		esto=est
		imp=0
		x1=0
		for t=27,0,-3 do
			t1f=t
			y1f=yp(t1f)
			t2f=math.floor(tb(y,vy,y1f+h,2))
			if (t2f>0) then
				y2f=yb(y,vy,t2f)
				vy2f=vy-g*t2f
				x2f,y2f,vx2f,vy2f,t2f,_=estimate(x,y,vx,vy,y2f-vy2f/10,2)
				t1f=math.floor(tp(y2f-h))
				y1f=yp(t1f)
				impt=0
				if (t1f<=t2f-2) then
					for x1f=pos(x2f)-25*4.5,pos(x2f)+4.5,4.5 do
						impf,_,xaf,yaf,vxaf,vyaf=impact(x2f,y2f,vx2f,vy2f,pos(x1f),y1f,220,1,0)
						if (impf>400) and (math.abs(posx()-x1f)/4.5<t2f) then
							impt=impf
							x1t=x1f
							y1t=y1f
							t1t=t1f
							x2t=x2f
							y2t=y2f
							t2t=t2f
							vx2t=vx2f
							vy2t=vy2f
							xat=xaf
							yat=yaf
							vxat=vxaf
							vyat=vyaf
							break
						end
					end
					h2t=yb(yat,vyat,(400-xat)/vxat)

					if (h2t<h2) and (h2t>316+7+31.5) then
						imp=impt
						x1=x1t
						y1=y1t
						t1=t1t
						x2=x2t
						y2=y2t
						t2=t2t
						vx2=vx2t
						vy2=vy2t
						xa=xat
						ya=yat
						vxa=vxat
						vya=vyat
					end
					h2=yb(ya,vya,(400-xa)/vxa)
					if (h2<316+7+31.5+20) and (h2>316+7+20) then break end
				end
			end
		end
		t2=t2+1
		t2t=t2t+1
	end

if (imp>400) then
		t2=t2-1
		move(x1)
		if (t2<=t1+0.1) then jump() end
	else
		t2t=t2t-1
		move(x1t)
		if (t2t<=t1t+0.1) then jump() end
end

end






function OnOpponentServe()

if (math.abs(pos(posx())-posx())>1) then move(400) else
move(200)
end
valid=1
end

function OnServe(ballready)
	est=700

	if (math.abs(pos(posx())-posx())>1) then
			move(400)
		else
			if (math.abs(posx()-180)<2) then
					jump()
				else
					move(180)
			end
	end
valid=1
end



function OnGame()

esttold=estt
netold=net


x,y,vx,vy=ballx(),bally(),bspeedx(),bspeedy()
estt,_,_,_,tnet,net=estimate(x,y,vx,vy,220)

if (math.abs(esttold-estt)<0.1) then -- Schutz gegen Fehler bei der estimate-Funktion während Netz/Wandkollisionen
		est=estt
end

-- phase1 -> Eigener Angriff
-- phase2 -> Gegner hat den Ball
-- phase3 -> Netzball blocken
-- phase4 -> Ball ist nicht mehr gültig

if (bally()<144) then valid=0 end

if (net==1) then -- klare Netzkollision
		if (yb(y,vy,(380-x)/vx)>370) then
				phase=3
			else
				phase=4
		end
	else
		if (netold==1) then -- Ball hat gerade das Netz getroffen
				nettime=8 -- Rest des Kollisionsskriptes abarbeiten
				phase=3
			elseif (netold==0) and (nettime>0) then
				nettime=nettime-1 -- Zeit runterzählen für den Rest des Kollisionsskriptes
				phase=3
			else -- Keine direkte Netzkollision und deren Nachwirkungen
				if (est>431.5) and (est<460) and (oppx()<700) then -- Ball kommt nahe ans Netz und der Gegner kann blocken
						phase=3
					elseif (est<400-31.5) then -- eigener Angriff
						phase=1
					else -- gegnerischer Angriff
						phase=2
				end
		end
end

if (valid==0) then phase=5 end -- Überschreibt alle vorherigen Berechnungen

toucho=touch
touch=touches()

if (touch<toucho) then p=math.random() end -- Neuberechnung des Angriffstyps wenn ein Angriff abgeschlossen ist



--1 Player
--2 Ball

if (phase==3) then
		t1=tp(393)
		if (t1>=tnet) then jump() end
		if (math.abs(posx()-360)/4.5<tnet+5) and posy()<200 then
				left()
			else
				right()
		end
	elseif(phase==2) then
		move(170)
	elseif(phase==1) then
 		if (0<=p) and (p<0.25) then
 				lob()
 			elseif (0.25<=p) and (p<0.85) then
 				attack()
			elseif (0.85<=p) and (p<=1) then
				netp()
			end

	elseif(phase==4) then
	move(250)
	else
		move(180)
end
-- debug(0)
-- debug(est)
-- debug(imp)
-- debug(p)
end
