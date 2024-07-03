--ANIM: Fractal Tree V1.0
--by Richard 'DawnBringer' Fhager

--
function main()

 local n,w,h,rad,floor,cos,sin,r,g,b
 local CX,CY,IANG,AINC,AINC_i,ILEN,LMULT,LINC,COLS,AACC,AACC_i,ANGLE,ASUM,ACSUM
 local moved, key, mouse_x, mouse_y, mouse_b, update
 local branch, draw, setTriRamp

 floor = math.floor
   cos = math.cos
   sin = math.sin

 rad = math.pi / 180

  w,h = getpicturesize()

 ----------------------
 -- Settings --
 ----------------------
  IANG = -90 * rad -- Inital Rotation of Tree

  ANGLE = 25 * rad  -- Branching angle
   AINC = 1 * rad   -- Angle change increment
 AINC_i = 0         -- (Integer multiplier)
   ASUM = 0         -- (Current Branching angle (calculated))

   AACC = 0.005     -- Angle addition by iteration
 AACC_i = 0         -- (Integer multiplier)
  ACSUM = 0         -- (Current Addition angle (calculated))


     ILEN = floor(h / 6)
    LMULT = 0.6          -- Length multipiler
 MAXLMULT = 0.8          -- Max multiplier, more means more iterations, CAUTION using values above 0.8, seriously 0.85 can flip out 
     LINC = 0.005        -- Length change increment

 ----------------------
 

 --
 -- Recursive branch creation
 --
 function branch(x0,y0,v0,l0, lmult, i)
  local x,y,v,l,xc,yc,m,ai, l1,l2

  m = i
  if l0 > 4 then

   l = l0 * lmult 
   ai = (i+1) * ACSUM -- Additional angle by interation

   --l1 = l0 * (lmult - math.random()*0.2+0.1) -- Changing length, must be done sep. for each branch
 
   v = v0 + ASUM         + ai   --+ math.random()*0.5-0.25             
   x = x0 + cos(v) * l
   y = y0 + sin(v) * l
   drawline(x0,y0,x,y,1+i)
   m = branch(x,y,v,l, lmult, i+1)

   v = v0 - ASUM         - ai  --+ math.random()*0.5-0.25 
   x = x0 + cos(v) * l
   y = y0 + sin(v) * l
   drawline(x0,y0,x,y,1+i)
   m = branch(x,y,v,l, lmult, i+1)
  end
  return m -- return max iteration for color usage estimate
 end
 --
 

-- (Function also added to DB-lib)
-- Create a curved ramp between three colors (that goes through the mid color)
--
function setTriRamp(rgb0,rgb1,rgb2, cols, start_index) -- {r,g,b}..,colors in ramp

  local n,r,g,b,r0,g0,b0,r1,g1,b1,f0,f1

  start_index = start_index or 0

  -- Extended Bezier (Make ramp go through midpoint)
  r = rgb1[1]*2 - (rgb0[1]+rgb2[1])*0.5 -- Same as 2*(c0 - c1 - c2)
  g = rgb1[2]*2 - (rgb0[2]+rgb2[2])*0.5
  b = rgb1[3]*2 - (rgb0[3]+rgb2[3])*0.5
  rgb1 = {r,g,b}

  -- Make a Ramp for branch colors (Extended 3-Point Bezier Curve)
  for n = 0, cols-1, 1 do
   f1 = (1 / (cols-1)) * n
   f0 = 1 - f1
   r0 = rgb0[1]*f0 + rgb1[1]*f1
   g0 = rgb0[2]*f0 + rgb1[2]*f1
   b0 = rgb0[3]*f0 + rgb1[3]*f1
   r1 = rgb1[1]*f0 + rgb2[1]*f1
   g1 = rgb1[2]*f0 + rgb2[2]*f1
   b1 = rgb1[3]*f0 + rgb2[3]*f1
   r = r0 * f0 + r1 * f1
   g = g0 * f0 + g1 * f1
   b = b0 * f0 + b1 * f1
   setcolor(start_index + n, r,g,b)
  end

end
--

 COLS = branch(0,0,IANG,ILEN, MAXLMULT, 0) -- Colors used depends on minimum branch length (thru LMULT) & screen height

 setTriRamp({48,16,0}, 
            {32+8,96+8,112}, 
            {176,228+4,128}, 
             COLS, 1)

 setcolor(0,248,255,216)


 CX = floor(w/2)
 CY = h - h/3

 --
 function draw()
   ASUM = ANGLE + AINC * AINC_i
   ACSUM = AACC * AACC_i * ASUM
   clearpicture(0) 
   drawline(w/2,h,CX,CY,1)
   branch(CX,CY,IANG,ILEN, LMULT, 0)
   statusmessage("A="..(floor(ASUM*180/math.pi)).."°, LM="..LMULT..", IA="..floor(AACC*AACC_i*100)*0.01)
   updatescreen()
 end
 --

 updatescreen() -- Weirdly we need this updatescreen() to get (inital) Statusmessage to work properly
 draw()


 key = 0
 repeat
  moved, key, mouse_x, mouse_y, mouse_b = waitinput(0)
  update = 0
  if (key == 273) and LMULT < MAXLMULT then LMULT = LMULT + LINC; update = 1; end -- up arrow
  if (key == 274) and LMULT > 0.1 then LMULT = LMULT - LINC; update = 1; end -- down arrow
  if (key == 276) then AINC_i = AINC_i - 1; update = 1; end -- left arrow
  if (key == 275) then AINC_i = AINC_i + 1; update = 1; end -- right arrow
  if (key == 269) then AACC_i = AACC_i - 1; update = 1; end -- Minus
  if (key == 270) then AACC_i = AACC_i + 1; update = 1; end -- Plus

  if update == 1 then
   draw()
  end

 until (key == 27)


end
--

messagebox("Fractal Tree v1.0", "Instructions:\n\nUse Arrow-keys to modify tree.\n\n +/- keys to change angle increment.\n\n ESC to exit.")
main()




