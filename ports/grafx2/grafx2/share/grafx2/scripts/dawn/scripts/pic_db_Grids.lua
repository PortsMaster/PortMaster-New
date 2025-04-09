--PICTURE: Grids V1.1
--by Richard Fhager 
--Email: dawnbringer@hem.utfors.se


OK, Sx,Sy,sq,di,is,hx,line,fill,bg = inputbox("Grids", 
                            "X-Side (1 = y-lines only)",  16, 1, 512,0,
                            "Y-Side (1 = x-lines only)",  16, 1, 512,0,
                            "1. Box",            1, 0, 1,-1,
                            "2. Diagonal",       0, 0, 1,-1,
                            "3. Isometric",      0, 0, 1,-1,
                            "4. Hexagonal (only fill)",      0, 0, 1,-1,
                            "a) Lines",          1, 0, 1,-2,
                            "b) Filled",         0, 0, 1,-2, 
                            "Draw Background Color", 0, 0, 1, 0
                            --"Offset?",        0, 0, 1, 0
);

if OK == true then
	
 -- HEXAGON stuff: Approximation settings
 R = 7/8 * Sy/Sx
 H = R * Sy
 AY = 1/R/2
 q = {[true] = 1, [false] = 0}

 f = math.floor

fc = getforecolor()
bc = getbackcolor()


-- y/x lines only
ofy,ofx = 0,0
if Sx == 1 then Sx = 9999; ofx = 1; end
if Sy == 1 then Sy = 9999; ofy = 1; end	

if fill == 0 then	
 if sq == 1 then g = function(x,y,sx,sy) return 1-math.min(1, (x % sx) * (y % sy));end; end
 if di == 1 then g = function(x,y,sx,sy) return 1-math.min(1,((x+y+sx/2) % sx) * ((x-y+sy/2) % sy));end; end
 if is == 1 then g = function(x,y,sx,sy) return 1-math.min(1,(math.floor((x/2+y+sx/2) % sx) * math.floor((x/2-y+sy/2) % sy)));end; end
end
if fill == 1 then	
 if sq == 1 then g = function(x,y,sx,sy) return math.floor(x/sx+math.floor(y/sy))%2;end; end
 if di == 1 then g = function(x,y,sx,sy) return math.floor((x+y+sx/2)/sx+math.floor((x-y+sy/2)/sy))%2;end; end
 if is == 1 then g = function(x,y,sx,sy) return (math.floor((x/2+y+sx/2)/sx) + math.floor((x/2-y+sy/2)/sy) )%2 ;end; end
end

if hx == 1 then
 g = function(x,y,sx,sy) return 1+(f(y/H)+(f(((f((x-y*AY)/sy)*2+q[((x-y*AY)%sy>(sy-(y%H)/R))])+f(y/H)*4)/3)%2))%3; end
end

OX = 0
OY = 0
oy = 0
if oy == 1 then OY = Sy/2; end


w, h = getpicturesize()
for y = ofy, h - 1 + ofy, 1 do
  for x = ofx, w - 1 + ofx, 1 do

   v=0
   v = g(x+OX,y+OY,Sx,Sy)

    c = bc
    if v > 0 then c = fc+v-1; end
    if not(c==bc and bg==0) or (fill==0 and v==1) then putpicturepixel(x-ofx, y-ofy, c); end;

  end
end


end
