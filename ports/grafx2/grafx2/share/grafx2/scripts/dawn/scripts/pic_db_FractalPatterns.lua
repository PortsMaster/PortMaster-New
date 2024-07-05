--PICTURE: Fractal Patterns V1.5 
--by Richard Fhager 
--Email: dawnbringer@hem.utfors.se

dofile("../libs/dawnbringer_lib.lua")
--> db.pattern(fx,fy,patternarray,offsetcolor,iterations)

OK,f_tri,f_car,f_chk,f_grf,iter = inputbox("Fractal Patterns",
                       
                           "1. Sierpinsky Triangles",  1,  0,1,-1,
                           "2. Sierpinsky Carpet",     0,  0,1,-1,
                           "3. Checkers 4x4 (dec)",    0,  0,1,-1,
                           "4. Logo",                  0,  0,1,-1,
                           "Iterations",               8,  1,100,0   
);

--
if OK == true then

if f_tri == 1 then
 frac = {{1,1},{1,0}};              --iter = 15  -- Triangles
end
if f_car == 1 then
 frac = {{1,1,1},{1,0,1},{1,1,1}};  --iter = 6   -- Carpet
end

if f_chk == 1 then
 frac = {}
 frac[1]  = {0.2, 1.0, 1.0, 0.2}
 frac[2]  = {1.0, 0.2, 0.2, 1.0}
 frac[3]  = {1.0, 0.2, 0.2, 1.0}
 frac[4] =  {0.2, 1.0, 1.0, 0.2}
end

if f_grf == 1 then
 frac = {}
 v = 0.5
 frac[1] = {v,v,v,v,0, v,v,v,v,0, v,v,v,v,0, v,v,v,v,0, v,0,0,v,0}
 frac[2] = {v,0,0,0,0, v,0,0,v,0, v,0,0,v,0, v,0,0,0,0, v,0,0,v,0}
 frac[3] = {v,0,v,v,0, v,v,v,0,0, v,v,v,v,0, v,v,v,0,0, 0,v,v,0,0}
 frac[4] = {v,0,0,v,0, v,0,0,v,0, v,0,0,v,0, v,0,0,0,0, v,0,0,v,0}
 frac[5] = {v,v,v,v,0, v,0,0,v,0, v,0,0,v,0, v,0,0,0,0, v,0,0,v,0}
 frac[6] = {0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0}
end

w, h = getpicturesize()

rf,gf,bf = getcolor(getforecolor())
rb,gb,bb = getcolor(getbackcolor())

for y = 0, h - 1, 1 do
  for x = 0, w - 1, 1 do

    ox = x / w;
    oy = y / h;

    f = db.patternDec(ox,oy,frac,0,iter);
    fm = 1 - f

    c = matchcolor(rb*fm+rf*f,gb*fm+gf*f,bb*fm+bf*f)

    putpicturepixel(x, y, c);

  end
  updatescreen(); if (waitbreak(0)==1) then return; end
end

end;
--
