g=0.28
pg=0.88
v0=14.5
v_p=4.5
pj=0.44
r1=31.5




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
			for test=t1,t2,0.2 do
				if ( (yb(y,vy,test)-objy)^2+(x+vx*test-objx)^2 < (r1+r2)^2)
					then
						t=test
						break
				end
			end
	end

	if (t<=0) and (t3<t4)
		then
			for test=t3,t4,0.2 do
				if ( (yb(y,vy,test)-objy)^2+(x+vx*test-objx)^2 < (r1+r2)^2)
					then
						t=test
						break
				end
			end
	end

	if (t<=0) or (t>150) then t=-1 end

	return t

end



function est(x,y,vx,vy,height,typ)

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
--		if (x1>360) then x1=2*360-x1 end
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
			x2,y2,vx2,vy2,t2,nn=est(x1,y1,vx1,vy1,targety,2)
			break
		end
end

return x2,y2
end






function nothing()
--[[		if (math.abs(xe-xo)>0.1) then
			xo=xe
			for test=30,0,-3 do
				t1=test
				y1=yp(t1)
				t2=math.floor(tb(y,vy,y1+31.5+25+19,2))
				y2=yb(y,vy,t2)

				x2,y2,vx2,vy2,t2,_=est(x,y,vx,vy,y2+0.1)
				t2=t2
				if (vx2>2) then
					n=0
					elseif (vx2>0.5) then
					n=5
					else
					n=13
				end
				xi,yi=impact(x2,y2,vx2,vy2,pos(x2-n*4.5),y1,220,1,0)

				if (math.abs(posx()-(x2-n*4.5))/4.5<t2-1) and (x2>80) and (t2-1>t1) and (xi>400) then
					break
				end
			end
		end

		move(x2-n*4.5)
		if (t2<=t1) then 
			jump()
		end
		--]]

end






function OnOpponentServe()
xdo=0
xe=0
s=1
touch=0
xodo=0
change=1
stop=0
t1,t2,y1,y2,x,y,vx,vy=0,0,0,0,0,0,0,0
calc=0
if (math.abs(pos(posx())-posx())>1) then move(400) else
move(200)
end
xo=0
c=0
end

function OnServe(ballready)
xe=0
s=1
xodo=0
xdo=0
change=1
touch=0
stop=0
t1,t2,y1,y2,x,y,vx,vy=0,0,0,0,0,0,0,0
xo=0
c=0
if (math.abs(pos(posx())-posx())>1) then move(400) else
	if (math.abs(posx()-180)<2) then jump() else move(180) end
	end
end

function OnGame()

if (change==0) and (touches()<touch) then
	p=math.random()
	change=1
end
p0=0
p1=1
h=31.5+19+25
x,y,vx,vy=ballx(),bally(),bspeedx(),bspeedy()
xeo=xe
neto=net
xe,_,_,_,te,net=est(x,y,vx,vy,220)

if (math.abs(xe-xeo)<0.1) then
xdo=xe
end

if (neto==net) then netdo=net
end
--1 Player
--2 Ball

if (s==1) then
	if (netdo==1) then
			t1=tp(340)
			if (t1>=te) then jump() end
			if (math.abs(posx()-360)/4.5<te+8) then
				left()
			else
				right()
			end
		elseif (xdo<400-31.5) then
			if (math.abs(xdo-xodo)>0.2) then
				xodo=xdo
				imp=0
				x1=0
				for t=27,0,-3 do
					t1f=t
					y1f=yp(t1f)
					t2f=math.floor(tb(y,vy,y1f+h,2))
					if (t2f>0) then
-- 						debug(0)
-- 						debug(t2f)
						y2f=yb(y,vy,t2f)
-- 						debug(y2f)
						vy2f=vy-g*t2f
						x2f,y2f,vx2f,vy2f,t2f,_=est(x,y,vx,vy,y2f-vy2f/10,2)
-- 						debug(t2f)
-- 						debug(y2f)
-- 						debug(vy)
						t1f=math.floor(tp(y2f-h))
						y1f=yp(t1f)
						impt=0
						if (t1f<=t2f-2) then
							for x1f=pos(x2f)-25*4.5,pos(x2f)+4.5,4.5 do
								impf,_=impact(x2f,y2f,vx2f,vy2f,pos(x1f),y1f,220,1,0)
								if (impf>440) and (math.abs(posx()-x1f)/4.5<t2f) then
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
							if (impt>400) then
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
							if (imp>400) then break end
						end
					end
				end
				t2=t2+1
			end
			t2=t2-1
			if (s==1) then
			move(x1)
			if (t2<=t1+0.1) then jump() end
			end
		else
			move(200)
	end
end

if (bally()<140) then s=0 end

-- debug(0)
-- debug(x2)
-- debug(ballx())
-- debug(y2)
-- debug(bally())
-- debug(vx2)
-- debug(bspeedx())
-- debug(vy2)
-- debug(bspeedy())
-- debug(xe)
-- debug(imp)
-- debug(t2)
-- debug(0)
end


