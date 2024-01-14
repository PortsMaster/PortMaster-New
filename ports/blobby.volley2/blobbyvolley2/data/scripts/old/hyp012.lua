g=0.28
pg=0.88
v0=14.5
v_p=4.5
pj=0.44
r1=31.5

h=31.5+19+25


estt=0
nettime=0
touch=0
est=0
p=math.random()/2+0.5
esto1=10
esto2=10
esto3=10
esto4=10

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
return 144.5+(14.5+pj/2+pg/10)*t-1/2*(pg-pj)*t^2
end

function tp(y)
	return (14.5+pj/2+pg/10)/(pg-pj)-math.sqrt(((14.5+pj/2+pg/10)/(pg-pj))^2-(y-144.5)/(1/2*(pg-pj)))
end

function tp2(y1p,v1p)
	if (y1p>146) then
	return (v1p/0.88-1/2+math.sqrt((v1p/0.88-1/2)^2-(144.5-y1p)/0.44))
	else
	return 0
	end
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

function lob()

	if (math.abs(est-esto2)>0.2) then
		esto2=est
		imp=0
		x1=0
		t=30
		while (t>=0) do
			if (t==0) then j=0 else j=1 end
			t1f=t
			y1f=yp(t1f)
			t2g=math.floor(tb(y,vy,y1f+h,2))
			y2f=yb(y,vy,t2g)
			vy2f=vy-g*t2g
			x2f,y2f,vx2f,vy2f,t2f,_=estimate(x,y,vx,vy,y2f-vy2f/30,2)
			t1f=math.floor(tp(y2f-h))
			y1f=yp(t1f)
			if (t1f+math.abs(tp2(posy(),vp))<t2f) and (t2g>1) and (t2f>1) and ((math.abs(posx()-(x2f+4.5))/4.5<t2f) or (math.abs(posx()-(x2f-15*4.5))/4.5<t2f)) then
				impf=0
				for x1f=pos(x2f)-2*4.5,pos(x2f)-12*4.5,-4.5 do
					impo=impf
					impf,_,_,_,_,_=impact(x2f,y2f,vx2f,vy2f,x1f,y1f,220,j,0)
					if (impf>730) and (math.abs(posx()-x1f)/4.5<t2f) and (x1f<360) and (x1f>0) then
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
					if (impf<impo) then break end
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
				if (imp>740) then break end
			end
			if (t>12) then t=t-6 else t=t-4 end
		end
		t2=t2+1
	end
	t2=t2-1
	if (x1>0) then
		move(x1)
		if (t2<=t1+0.1) and (y1>146) then
			 jump() end
		else
-- 			move(est)
p=math.random()
esto2=0
	end

end


function attack()

	if (math.abs(est-esto1)>0.2) then
		h2=900
		esto1=est
		imp=0
		x1=0
		t=30
		while (t>=0) do
			if (t==0) then j=0 else j=1 end
			t1f=t
			y1f=yp(t1f)
			t2g=math.floor(tb(y,vy,y1f+h,2))
			y2f=yb(y,vy,t2g)
			vy2f=vy-g*t2g
			x2f,y2f,vx2f,vy2f,t2f,_=estimate(x,y,vx,vy,y2f-vy2f/30,2)
			t1f=math.floor(tp(y2f-h))
			y1f=yp(t1f)
			if (t1f+math.abs(tp2(posy(),vp))<t2f) and (t2g>1) and (t2f>1) and ((math.abs(posx()-(pos(x2f)+4.5))/4.5<t2f) or (math.abs(posx()-(pos(x2f)-15*4.5))/4.5<t2f)) then
				for x1f=pos(x2f)-17*4.5,pos(x2f)+4.5,4.5 do
					impf,_,xaf,yaf,vxaf,vyaf=impact(x2f,y2f,vx2f,vy2f,x1f,y1f,220,j,0)
					if (impf>400) and (math.abs(posx()-x1f)/4.5+1<t2f) and (x1f>0) and (x1f<360) then
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
				if (h2t<h2) and (h2t>316+31.5+10) then
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
				if (h2>316+31.5+10) and (h2<316+31.5+60) then break end
			end
		if (t>12) then t=t-6
		else t=t-4 end
		end
		t2=t2+1
	end
	t2=t2-1

	if (x1>0) then
		move(x1)
		if (t2<=t1+0.1) and (y1>146) then
			 jump()
		end
	else
-- 		move(est-5)
		--p=0.9
p=math.random()
esto1=0
	end
end


function netp()

	if (math.abs(est-esto3)>0.2) then
		esto3=est
		imp=500
		x1=0
		for t=33,0,-3 do
			if (t==0) then j=0 else j=1 end
			t1f=t
			y1f=yp(t1f)
			t2g=math.floor(tb(y,vy,y1f+h,2))
			y2f=yb(y,vy,t2g)
			vy2f=vy-g*t2g
			x2f,y2f,vx2f,vy2f,t2f,nn=estimate(x,y,vx,vy,y2f-vy2f/30,2)
			t1f=math.floor(tp(y2f-h))
			y1f=yp(t1f)
			if (t1f+math.abs(tp2(posy(),vp))<t2f) and (t2g>1) and (t2f>1) and ((math.abs(posx()-(x2f+4.5))/4.5<t2f) or (math.abs(posx()-(x2f-15*4.5))/4.5<t2f)) and (nn==0) then
				for x1f=pos(x2f)-4.5,pos(x2f)-8*4.5,-4.5 do
					impf,_,_,_,_,_=impact(x2f,y2f,vx2f,vy2f,x1f,y1f,220,j,0)
					if (impf>380) and (math.abs(posx()-x1f)/4.5<t2f) and (x1f<360) and (x1f>0) then
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
				if (impt<imp) and (impt<430) then
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
				if (imp<390) then break end
			end
		end
		t2=t2+1
	end
	t2=t2-1
	if (x1>0) and (est<368.5) then
		move(x1)
		if (t2<=t1+0.1) and (y1>146) then
			 jump() end
		else
-- 			move(est-4.5)
p=math.random()
esto3=0
	end

end





function playto(dest)
--310

	if (math.abs(est-esto4)>0.2) then
		x1,y1,t1,x2,y2,t2,vx2,vy2,x1f,y1f,t1f,x2f,y2f,t2f,vx2f,vy2f,x1t,y1t,t1t,x2t,y2t,t2t,vx2t,vy2t=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		t2g=0
--		debug(-10)
		esto4=est
		imp=500
		x1=0
		for t=33,0,-3 do
			if (t==0) then j=0 else j=1 end
			t1f=t
			y1f=yp(t1f)
			t2g=math.floor(tb(y,vy,y1f+h,2))
			y2f=yb(y,vy,t2g)
			vy2f=vy-g*t2g
			x2f,y2f,vx2f,vy2f,t2f,nn=estimate(x,y,vx,vy,y2f-vy2f/30,2)
			t1f=math.floor(tp(y2f-h))
			y1f=yp(t1f)
			if (t1f+math.abs(tp2(posy(),vp))<t2f) and (t2g>1) and (t2f>1) and ((math.abs(posx()-(x2f+4.5))/4.5<t2f) or (math.abs(posx()-(x2f-15*4.5))/4.5<t2f)) and (nn==0) then
				for x1f=pos(x2f)+4*4.5,pos(x2f)-13*4.5,-4.5 do
					impf,_,_,_,_,_=impact(x2f,y2f,vx2f,vy2f,x1f,y1f,220,j,0)
					if (impf>dest-30) and (impf<dest+30) and (math.abs(posx()-x1f)/4.5<t2f) and (x1f<360) and (x1f>0) then
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
				if (math.abs(impt-dest)<math.abs(imp-dest)) then
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
				if (math.abs(imp-dest)<20) then break end
			end
		end
		t2=t2+1
	end
	t2=t2-1
	if (x1>0) and (est<368.5) then
		move(x1)
		if (t2<=t1+0.1) and (y1>146) then
			 jump() end
		else
-- 			move(est)
p=math.random()
esto4=0
	end

end






function OnOpponentServe()
pp=math.random()
	y1p=144.5
	if (math.abs(pos(posx())-posx())>1) then
			move(400)
		else
			move(200)
	end
	valid=1
	nettime=0
	phase=0
	imp1=0
	imp2=0
	imp=0
	active=1
end

function OnServe(ballready)
pp=math.random()
	active=1
	nettime=0
	y1p=144.5
	phase=0
		est=700
	imp1=0
	imp2=0
	imp=0
	
	if (math.abs(pos(posx())-posx())>1) then
			move(400)
		else
			if (math.abs(posx()-198)<2) then
					jump()
				else
					move(198)
			end
	end
	valid=1
end



function OnGame()

	yp2=y1p
	y1p=oppy()
	vp=y1p-yp2
	
	if (math.abs(imp1-imp)>0.1) then
		imp2=imp1
		imp1=imp
	end
	
	esttold=estt
	netold=net
	toucho=touch
	touch=touches()
	if (touch<toucho) then p=math.random() 
pp=math.random()
end
	
	x,y,vx,vy=ballx(),bally(),bspeedx(),bspeedy()
	estt,_,_,_,tnet,net=estimate(x,y,vx,vy,220)
	
	if (math.abs(esttold-estt)<0.1) then -- Schutz gegen Fehler bei der estimate-Funktion während Netz/Wandkollisionen
			est=estt
	end
	if (active==1) then
			if (phase==2) and ((est>431.5) or (est<368.5)) then
				nettime=11
				phase=4
				elseif (phase==4) and (nettime>0) then
					nettime=nettime-1
				else
					if (est>431.5) then
							phase=3
						elseif (est<431.5) and (est>368.5) then
							phase=2
						else
							phase=1
					end
			end
		else
			phase=6
	end
	if (bally()<130) then active=0 end
	
	if (math.sqrt((ballx()-400)^2+(bally()-316)^2)<(31.5+7)) and (math.sqrt((bspeedx())^2+(bspeedy())^2)<2) then phase=5 end
	
	if (phase==3) then
			move(170)
		elseif (phase==1) then
	
			if (p<0.5) then
					if (touch==0) then
							playto(310)
						elseif (touch==1) then
							if (p<0.2) then
									netp()
								elseif (p>=0.2) and (p<0.35) then
									playto(pp*300+450)
								elseif (p>=0.35) and (p<0.5) then
									attack()
							end
						else
							attack()
					end
				else
					if (touch==0) then
							if (p>=0.5) and (p<0.75) then
									playto(pp*300+450)
								elseif (p>=0.75) and (p<=1.0) then
									attack()
							end
						else
							attack()
					end
			end
		elseif (phase==2) then
			if (tnet<=tp(393)+1) or (nettime>0) then jump() end
			if (math.abs(posx()-360)/4.5-10<=tnet) then
					left()
				else
					right()
			end
		elseif (phase==4) then
			right()
			jump()
		elseif (phase==5) then
			if (posx()>300) then
				jump()
			end
			right()
	end
	
	if ((x1==0) or (imp==0)) and (phase==1) then 
--		debug(-1)
		move(est)
	end
--debug(phase)
end
