--ANIM: Numy Fractal Demo
--by Richard 'DawnBringer' Fhager


--Gamma corrected plotting active

dofile("../libs/dawnbringer_lib.lua") --> ShiftHUE()
dofile("../libs/db_text.lua")

function main(Cplots,Rndseed,PlotStr) -- Encapsulate to localize some varaibles for speed

 Rndseed = Rndseed or 1
 PlotStr = PlotStr or 0.5

 if Rndseed > -1 then
  math.randomseed(Rndseed)
  else
   Rndseed = math.random(0,99999)
   math.randomseed(Rndseed)
 end

 local Cycles
 local c,r,g,b,f,i,x,y,v,w,h, exp,xx,yy,x1,y1, EXP,XX,YY,X1,Y1, Xavg,Yavg, X,Y,S, i1,i2,i3, V1,V2,V3,V4, I1,I2,I3
 local ro,go,bo,rd,gd,bd, Sr,Sg,Sb
 local NOM_SIZ, nom_x, nom_y, XM,YM, S1,S2,S3,S4,S5
 local r32a, r24a, r16a, r08a, r04a, g32a, g24a, g16a, g08a, g04a,  b32a, b24a, b16a, b08a, b04a
 local LM, SIZE, GRAD, DIST_SCL, DIST_FLG, DIST_MAG, DIST_FRQ_rnd, AMT  
 local rnd,sin,cos,abs,floor
 local chart
 local plotAdd, format, sign, drawAll

 Cycles = 127   -- Color changes are coded for 127 cycles
 Cplots = Cplots or 5000  -- The plot positions doesn't change beacuse of cycle/plot distribution

 clearpicture(matchcolor(0,0,0))
 finalizepicture() -- Text uses original background for transparancy so clearing must be finalized

 w, h = getpicturesize()

 rnd,sin,cos,abs,floor = math.random, math.sin, math.cos, math.abs, math.floor

function format(v,p)
 return floor(v * 10^p) / 10^p
end
 
 --
 function sign(v)
   if v > 0 then return 1; end
   if v < 0 then return -1; end
   return 0 
 end
 --

function plotAdd(mtx,w,h,x,y,r,g,b,amt)
   local rgb,r1,g1,b1,c2,org,yh,xw,rn,gn,bn,rgby
   
   x = floor(x * nom_x)  -- note: nom is constant declard globally 
   y = floor(y * nom_y) 

   if y>8 and y<h and x>=0 and x<w then 

     yh,xw = y/h, x/w

     if GRAD == 0 then
      r1,g1,b1 = 0,0,0
     end

     if GRAD == 1 then
      r1 = xw * 75
      --g1 = (1-abs(2*(0.5-yh))) * 175
      g1 = (1-abs(1-2*yh)) * 175
      b1 = (1-xw) * 150
     end

     if GRAD == 2 then
      r1 = yh * 150      + (1-xw) * 150
      g1 = yh * 150      + xw * 100
      b1 = (1-yh) * 300  + xw * 100
     end

     rgby = mtx[y+1]
     rgb = rgby[x+1] 

     --if xw <= 0.5 then
     --[[
     rn = rgb[1]+(r+r1)*amt
     gn = rgb[2]+(g+g1)*amt
     bn = rgb[3]+(b+b1)*amt
     mtx[y+1][x+1] = {rn, gn, bn}
     putpicturepixel(x, y, matchcolor(rn, gn, bn)) 
     --]]
     --end

     -- GAMMA is ACTIVE
     --if xw > 0.5 then
     ----[[
     -- Gamma correction makes things smoother, the darks more visible and the brightest parts less "overexposed"
     -- However it also takes away a bit of the "pop", so these adjusted values strikes a good balance
     -- And yes, minute changes have great effect.
     --amt = amt*2.5
     amt = amt * 2.39 -- 0.5009,2.39, 0.501/2.38
     rn = (rgb[1]*rgb[1]+((r+r1)*amt)^2)^0.5009
     gn = (rgb[2]*rgb[2]+((g+g1)*amt)^2)^0.5009
     bn = (rgb[3]*rgb[3]+((b+b1)*amt)^2)^0.5009
     --mtx[y+1][x+1] = {rn, gn, bn}
     rgby[x+1] = {rn, gn, bn}
     putpicturepixel(x, y, matchcolor(rn, gn, bn))
     --]]
     --end   

   end

end

-- Not in use?
function drawAll(mtx)
 local w,h,x,y,rgb
 h = #mtx
 w = #mtx[1]
 for y = 9, h-1, 1 do 
  for x = 0, w-1, 1 do
   rgb = mtx[y+1][x+1]
   putpicturepixel(x, y, matchcolor2(rgb[1],rgb[2],rgb[3],0.5))
  end
  if y%8==0 then
   updatescreen();if (waitbreak(0)==1) then return end
  end
 end 
end
--

chart = {}

-- Scale/Viewport/Zoom
-- Fractal will scale to image size/portions (also defines the size/space of the fractal that is seen)
NOM_SIZ = 1000 
nom_x = w / NOM_SIZ
nom_y = h / NOM_SIZ

-- Center point
XM = math.floor(w / nom_x / 2)
YM = math.floor(h / nom_y / 2)


-- DISTORTIONS
DIST_FLG = true
DIST_SCL = 0.5   -- Reduce size/scale due to magnitude scaling things up (roughly scale = 1 / (mag+1))
DIST_MAG = 1.0   -- Magnitude, Increase in size 
DIST_FRQ = 0.025 -- Maximum Frequencey (average is 25%) 0.01..0.1, 0.05 is nominal here
DIST_RND = 20    -- Parameter RND, frequency, nominal = 6 (in cases similar to increasing freq)
--

-- Layers Sizes
S1,S2,S3,S4,S5 = 4,8,16,24,32
S1,S2,S3,S4,S5 = 2,4,6,8,10
S1,S2,S3,S4,S5 = 2,3,5,8,12
S1,S2,S3,S4,S5 = 9.0, 9.1, 9.21, 9.33, 9.45 -- Radial Blur 
S1,S2,S3,S4,S5 = 2,4,7,12,18 -- Nice geometry
S1,S2,S3,S4,S5 = 1,3,10,10.1,10.3 -- Blur
S1,S2,S3,S4,S5 = 1,2,8,12,17 -- Echo


for i = 0, 99, 1 do

 for y = 1, h, 1 do 
  chart[y] = {}
  for x = 1, w, 1 do
   chart[y][x] = {1,1,1}
 end
 end 

v = 0.5 + rnd(0,10) -- Nominal = 5
I1,I2,I3 = 0,0,0
while I1*I2*I3 == 0 do
 I1 = format(-v + rnd()*v*2, 4)    -- -v + rnd()*v
 I2 = format(-v + rnd()*v*2, 4)
 I3 = format(-v + rnd()*v*2, 4)
end

------------
-- 2nd
v = 0.5 + rnd(0,10) -- Nominal = 5
i1,i2,i3 = 0,0,0
while i1*i2*i3 == 0 do
 i1 = format(-v + rnd()*v*2, 4)    -- -v + rnd()*v
 i2 = format(-v + rnd()*v*2, 4)
 i3 = format(-v + rnd()*v*2, 4)
end
exp = format(0.25 + rnd()*0.6, 5) -- nominal = 0.5
x1,y1 = 0,0
--
-------------

EXP = format(0.25 + rnd()*0.6, 5) -- nominal = 0.5
--EXP = 0.95


AMT = 0.025 * PlotStr*2 -- plot add strength (Plot Strength modifier is 0.5 as default, thus x2)

GRAD = rnd(0,2)
--GRAD = 0
if GRAD == 0 then AMT = AMT*1.4; end


--I1,I2,I3,EXP = -3,-2,-5,0.5
--I1,I2,I3,EXP = -2.376, -5.432, -0.106, 0.4112

X1,Y1 = 0,0
--I1 = I1+1.0
--I2 = I2+1.0

-- Layer model
LM = rnd(0,2)
if LM == 0 then 
 S1,S2,S3,S4,S5 = 2,4,6,10,16 -- Fibonacci
end
if LM == 1 then
 S1,S2,S3,S4,S5 = 1,2,8,12,17 -- Echo
end
if LM == 2then
 S1,S2,S3,S4,S5 = 1,3,10,10.1,10.3 -- Blur
end
--


-- Distortion values
V1 = rnd()*DIST_RND - (DIST_RND/2)
V2 = rnd()*DIST_RND - (DIST_RND/2)
V3 = rnd()*DIST_RND - (DIST_RND/2)
V4 = rnd()*DIST_RND - (DIST_RND/2)
DIST_FRQ_rnd = DIST_FRQ * rnd() * rnd()
--

  -- Base color and change over passes
  ro,go,bo = rnd(32,255),rnd(32,255),rnd(32,255)
  rd = (255-ro)/255 * rnd() * 2
  gd = (255-go)/255 * rnd() * 2
  bd = (255-bo)/255 * rnd() * 2


  -- Spectrum add-on color to the layers
  C = 350
  r = rnd(0,C)
  g = rnd(0,C)
  b = rnd(0,C)
  --r,g,b = 1350,0,0
  tot = r+g+b
  norm = C/tot -- Normalize so sum of chnnel colors = C
  r,g,b = r*norm,g*norm,b*norm

  deg = (30 + rnd(0,15)) * (rnd(0,1)*2-1)

  r04a,g04a,b04a = r,g,b
  r08a,g08a,b08a = db.shiftHUE(r,g,b, deg)
  r16a,g16a,b16a = db.shiftHUE(r,g,b, deg*2)
  r24a,g24a,b24a = db.shiftHUE(r,g,b, deg*3)
  r32a,g32a,b32a = db.shiftHUE(r,g,b, deg*4)
  --

  clearpicture(matchcolor(0,0,0))
  --finalizepicture() -- Text uses original background for transparancy so clearing must be finalized

  --text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag)

  txt = "I1: "..I1..", I2: "..I2..", I3: "..I3..", EXP: "..EXP..", SEED: "..Rndseed..", Image: "..i
  text.write(f, txt, 2,2, 2,3, 1000, {255,255,255}, 0, "_", 1.0, false)

   for c = 0, Cycles, 1 do

    r = ro + rd * c*2
    g = go + gd * c*2
    b = bo + bd * c*2

    for f = 1, Cplots, 1 do

      XX = Y1 - (abs(I2*X1-I3))^EXP * sign(X1)
      YY = I1 - X1
      X1 = XX
      Y1 = YY

      xx = y1 - (abs(i2*x1-i3))^exp * sign(x1)
      yy = i1 - x1
      x1 = xx
      y1 = yy
   
      Xavg = (X1+x1)*0.5
      Yavg = (Y1+y1)*0.5
 
      -- Use smallest values of the fractals, pretty cool results
      -- Rarely work with feeding average into both fractals
      --Xavg = X1; if math.abs(x1) < math.abs(X1) then Xavg = x1; end
      --Yavg = Y1; if math.abs(y1) < math.abs(Y1) then Yavg = y1; end

      X1,x1,Y1,y1 = -Xavg,-Xavg,-Yavg,-Yavg -- Feed average back into both fractals (fuses them into one new fractal)
      --X1,x1,Y1,y1 = X1,Xavg,Y1,Yavg -- Feed average back ONLY into the 2nd fractal (can produce a skew)
      --X1,x1,Y1,y1 = X1,Xavg,Yavg,Y1 
      --X1,x1,Y1,y1 = x1,X1,y1,Y1 -- Swapping values seem to create similar fractal but one rotated about 90 degrees (if NOT plotting the average)

      if DIST_FLG then
       --SIZE=1+DIST_MAG+(math.sin((X1*V1+Y1*V2)*DIST_FRQ_rnd)*math.cos((Y1*V3+X1*V4)*DIST_FRQ_rnd)*DIST_MAG)
       SIZE=1+DIST_MAG+(sin((Xavg*V1+Yavg*V2)*DIST_FRQ_rnd)*cos((Yavg*V3+Xavg*V4)*DIST_FRQ_rnd)*DIST_MAG)
       X = Xavg * SIZE * DIST_SCL
       Y = Yavg * SIZE * DIST_SCL
       S = (SIZE-1-DIST_MAG)*256 -- Altitude map distortions (brighter/darker on extruding)
        else          
         S,X,Y = 0,Xavg,Yavg
      end 
      
      Sr,Sg,Sb = S+r, S+g, S+b
      plotAdd(chart,w,h, X*S5+XM, Y*S5+YM,Sr+r32a,Sg+g32a,Sb+b32a,AMT)
      plotAdd(chart,w,h, X*S4+XM, Y*S4+YM,Sr+r24a,Sg+g24a,Sb+b24a,AMT)
      plotAdd(chart,w,h, X*S3+XM, Y*S3+YM,Sr+r16a,Sg+g16a,Sb+b16a,AMT)
      plotAdd(chart,w,h, X*S2+XM, Y*S2+YM,Sr+r08a,Sg+g08a,Sb+b08a,AMT)
      plotAdd(chart,w,h, X*S1+XM, Y*S1+YM,Sr+r04a,Sg+g04a,Sb+b04a,AMT)

  --plotAdd(chart,w,h, X1*S3+XM, Y1*S3+YM,S+r+r16a+300,S+g+g16a,S+b+b16a-300,AMT)
  --plotAdd(chart,w,h, x1*S3+XM, y1*S3+YM,S+r+r16a-300,S+g+g16a+100,S+b+b16a+300,AMT)

      --S2 = 8; S3 = 8 -- Symmetry
      --plotAdd(chart,w,h, XM - X*S2, YM + Y*S3,r+r08a,g+g08a,b+b08a,AMT)
      --plotAdd(chart,w,h, XM - X*S2, YM - Y*S3,r+r08a,g+g08a,b+b08a,AMT)
      --plotAdd(chart,w,h, XM + X*S2, YM - Y*S3,r+r08a,g+g08a,b+b08a,AMT)
      --plotAdd(chart,w,h, XM + X*S2, YM + Y*S3,r+r08a,g+g08a,b+b08a,AMT)     
      
     
 
   end -- f plots
  --text.write(font_f,txt,xpos,ypos,hspace,vspace,maxwidth,col,transparency,linebreak_char,aa_str,clear_flag,backup_flag)
   text.write(f, "Cycle: "..c, 2,9, 2,3, 1000, {255,255,255}, 0, "_", 1.0, true, true)
   updatescreen();if (waitbreak(0)==1) then return end
  end -- c cycles
  --drawAll(chart); updatescreen();if (waitbreak(2)==1) then return end
  db.drawRectangle(2,9,58,5,0) -- Erase Cycle counter (so it doesn't become the background for next scene)
  finalizepicture() -- save each image into the undo buffer
 end

end
-- main


 w,h = getpicturesize()

 OK,w,h,setsize,setpal,Rndseed,Cplots,PlotStr,dummy,dummy = inputbox("Numy Fractal Demo (WIP)",
                  
   "Screen  Width ("..w..")",  1024, 100,2048,0,  
   "Screen Height ("..h..")",   814, 100,2048,0,
   "Set Image Size",        1,  0,1,0,                        
   "Set Pal: Aurora [256]", 1,  0,1,0,
   "Random Seed (-1 = rnd)", -1, -1,99999,0,
   "Points/Cycle: 1k-50k",   5000, 1000,50000,0,
   "Plot Strength: 0..1 ",   0.5, 0,1,2,
   "", 0,  0,0,4, 
   "ESC Exits. Use Undo to view Pics.", 0,  0,0,4   
                                                                         
 );

--
if OK then

 if setsize == 1 then
  setpicturesize(w,h)
 end

 if setpal == 1 then
  dofile("../palettes/pfunc_pal_Aurora11.lua")(true)
 end

 main(Cplots,Rndseed,PlotStr)

end
--

