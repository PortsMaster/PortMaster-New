--SCENE: Rendered Scenery Collage
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

-- Math-scene render with full Floyd-Steinberg dither

OK,makepal,usepal,ditherprc,xdith,ydith,briweight = inputbox("Rendered Scenery Collage",                  
                           "1. Use Scenery Palette",     0,  0,1,-1,
                           "2. Use Current Palette",     1,  0,1,-1,  
                           --"3. Make Sample palette",     0,  0,1,-1,                        
                           "FS Dither Power %",        90,  0,200,0,
                           "X Bri-Dither: 0-64",           2,  0,64,0,
                           "Y Bri-Dither: 0-64",           4,  0,64,0,
                           --"Perceptual ColorMatch",     1,  0,1,0, -- no longer used
                           "ColMatch Bri-Weight %", 25,  0,100,0   
                          
);

function f_curl(x,y,w,h) -- SCENE
  local xf,yf,xr,yr,m,r,g,b,rt,gt,bt,c0,c1,c2,c3,d,tw

   xf = x / w;
   yf = y / h;

  d  = (1 - db.distance(xf,yf,0.5,0.5)*2) 
  tw = db.twirl(xf,yf,1,360,0.01,0) -- #Arms,Twirl,DistPow,Rot
  r = tw * 280 * d + yf*80
  g = (tw * 270 + (1-tw)*180*(1-yf))*d + xf*yf*48
  b = (1-tw)*300*d  

  --
  return cap(r),cap(g),cap(b)
end


function f_drem(x,y,w,h) -- SCENE
  local xf,yf,xr,yr,m,r,g,b,rt,gt,bt,c0,c1,c2,c3

   c0 = {192,144,192};	-- Top Left Corner
   c1 = {-32,4,128};	-- Top Right Corner
   c2 = {96,144,196};	-- Bottom Left Corner
   c3 = {240,144,144};	-- Bottom Right Corner

   m = math
   xf = x / w;
   yf = y / h;

   xf,yf = db.rotationFrac(-180*xf,yf,yf*0.7,xf,yf);
   xf,yf = db.rotationFrac(-900*yf,xf,xf,xf,yf);

   xr = 1 - xf
   yr = 1 - yf
   r = (c0[1]*xr + c1[1]*xf)*yr + (c2[1]*xr + c3[1]*xf)*yf;
   g = (c0[2]*xr + c1[2]*xf)*yr + (c2[2]*xr + c3[2]*xf)*yf;
   b = (c0[3]*xr + c1[3]*xf)*yr + (c2[3]*xr + c3[3]*xf)*yf;
  
   r = r*.8 
   g = g*.8
   b = b*.3 - yf*32
 
   -- Inverted RGB
   rt=(g+b)/2
   gt=(r+b)/2
   bt=(r+g)/2
   r,g,b = rt,gt,bt

  --
  return cap(r),cap(g),cap(b)
end


function f_sinr(x,y,w,h) -- SCENE
  local xf,yf,r,g,b,m,sin
  m = math
  xf = x / w
  yf = y / h
  sin = math.abs((yf-0.5)*2 + math.sin(xf*math.pi*2))
  r,g,b = db.shiftHUE( sin * 128,255 - sin * 255,0,-180+xf*360);
  return cap(r),cap(g),cap(b)
end


function f_ball(x,y,w,h) -- SCENE
   local ox,oy,Xr,Yr,W,F,V,SPEC1,SPEC2
   ox = x / w;
   oy = y / h;

   -- Ball
   Xr = ox-0.5; Yr = oy-0.5; 
   W = (1 - 2*math.sqrt(Xr*Xr + Yr*Yr)); 

   -- 'FishEye' distortion / Fake 3D
   F = (math.cos((ox-0.5)*math.pi)*math.cos((oy-0.5)*math.pi))*0.65;
   ox = ox - (ox-0.5)*F; 
   oy = oy - (oy-0.5)*F; 

   -- Checkers
   V = ((math.floor(0.25+ox*10)+math.floor(1+oy*10)) % 2) * 255 * W;

   -- Specularities
   SPEC1 = math.max(0,(1-5*math.sqrt((ox-0.45)*(ox-0.45)+(oy-0.45)*(oy-0.45)))*112);
   SPEC2 = math.max(0,(1-15*math.sqrt((ox-0.49)*(ox-0.49)+(oy-0.48)*(oy-0.48)))*255);

   r = W * 255 + SPEC1 + SPEC2
   g = V + SPEC1 + SPEC2
   b = V + SPEC1 + SPEC2

   return cap(r),cap(g),cap(b)
end

function f_shue(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b
  xf = x / w
  yf = y / h
  r,g,b = db.desaturate(math.abs(200*(yf-0.5)),db.shiftHUE(255,0,0,-180+xf*360));
  return cap(r),cap(g),cap(b)
end

--db.star(xf,yf,sx,sy,rgb,haz,out,lum)
function f_blob(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m,C
  m = math
  xf = x / w
  yf = y / h
  C,r,g,b=0,0,0,0; 
  C=db.star(xf,yf,0.15,0.65,{0.20,0.30,0.50},0.8,57,800); r=r+C[1];g=g+C[2];b=b+C[3];
  C=db.star(xf,yf,0.70,0.90,{0.40,0.25,0.35},0.7,12,500); r=r+C[1];g=g+C[2];b=b+C[3];
  C=db.star(xf,yf,0.85,0.19,{0.40,0.40,0.20},0.5,30,900); r=r+C[1];g=g+C[2];b=b+C[3];
  C=db.star(xf,yf,0.45,0.45,{0.10,0.60,0.30},0.1,24,700); r=r+C[1];g=g+C[2];b=b+C[3];
  return cap(r),cap(g),cap(b)
end




function f_grey(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  r = xf * 255
  g = xf * 255
  b = xf * 255
  return cap(r),cap(g),cap(b)
end

function f_mand(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m,c,P,F,S,r,g,b,ma,px,py,Xr,Yr
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  xf,yf = db.rotationFrac(-120,0.5,0.5,xf,yf);
  Xr = 1-xf; Yr = 1-yf;
  py = 0; if (yf*100 % 10 < 0.25) then py = 1; end
  px = 0; if (xf*100 % 10 < 0.25) then px = 1; end 
  P = 224 - 24*Xr*yf*(px + py); -- Paper
  F = 1-m.abs(Yr-xf*xf)
  S = 1-m.sqrt(m.abs(m.sin(xf*m.pi) - Yr));
  c = 0.25 + db.alpha1(xf,yf,0.25);
  ma = db.mandel(xf,yf,-1.7,0.7,0,64); if ma>=64 then ma = 0; end -- Don't fill with black inside the "bug"
  ma = ma * 24 * (1 - c);

  r = (P - F*(128*yf + 160) + S*144) * c + ma
  g = (P - F*208 + S*128) * c + ma + 24
  b = (P - F*(96*Yr + 160) + S*112) * c + ma

  r = r + (m.floor(r)-127.5)*yf*-2.5;
  g = g + (m.floor(g)-127.5)*yf*-2.2;
  b = b + (m.floor(b)-127.5)*yf*-2;
  
  --
  return cap(r),cap(g),cap(b)
end

function f_curv(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m,P,F,Xr,Yr,mult
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  Xr = 1-xf; Yr = 1-yf
  mult = 0; 
  if (xf*100 % 10 < 0.25) then mult = 1 ; end
  if (yf*100 % 10 < 0.25) then mult = mult + 1; end 
  P = 224 - 24*Xr*yf*mult -- 'Paper'
  F = 1-m.abs(Yr-xf*xf)
  S = 1-m.sqrt(m.abs(m.sin(xf*m.pi) - Yr))

  r = P - F*(96*yf + 160) + S*144
  g = P - F*208 + S*128
  b = P - F*(96*Yr + 160) + S*112 
  
  --
  return cap(r),cap(g),cap(b)
end


function f_rain(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

   r = 255 * math.sin(yf * 2) 
   g = (yf-0.5)*512 * yf
   b = (yf-0.5)*512 * yf

   r,g,b =  db.shiftHUE(r,g,b,xf * 360); 

  --
  return cap(r),cap(g),cap(b)
end


function f_xfad(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  if y%2 == 0 then
   -- PsychoTwirl
   T1 = db.twirl(xf+0.025,yf+0.025,32,360,0.05,0); --  #Arms,Twirl,DistPow,Rot
   T2 = db.twirl(xf-0.025,yf-0.025,32,-360,0.05,0); -- #Arms,Twirl,DistPow,Rot
   r = xf * (16 + (T1 * 208 * (0.5+yf/2)) + (T2 * 208 * (0.5+yf/2)))
   g = xf * (16 + (T1 * 176) + (T2 * 96))
   b = xf * (48 + (T2 * 192) + (T1 * 160))
  end
 
  if y%2 == 1 then
   xr = 1-xf
   xf,yf = db.zoom(xf,yf,0.65,0.5,0.35); 
   xf,yf = db.rotationFrac(15*yf+25*xf,0.5*xf,0.5, xf, yf); 
   S,r,g,b = 0,0,0,0;
   S=db.star(xf,yf,xf,0.5+m.sin(xf*m.pi*2)*0.5,{0.2,0.3,0.5},1,8,700);   r = r+S[1]; g = g+S[2]; b = b+S[3];
   S=db.star(xf,yf,xf,0.5+m.cos(yf*xf*29)*0.2,{0.5,0.3,0.2},1,9,650);    r = r+S[1]; g = g+S[2]; b = b+S[3];
   S=db.star(xf,yf,xf,0.5+m.tan(yf*3-xf*7)*0.5,{0.3,0.5,0.2},0.5,1,109); r = r+S[1]; g = g+S[2]*yf; b = b+S[3];
   r,g,b = r*xr,g*xr,b*xr
  end

  --
  return cap(r),cap(g),cap(b)
end


function f_back(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  r = xf * 255
  g = yf * 255
  b = math.sin((r*r + g*g)^0.5 / 96) * 255

  --
  return cap(r),cap(g),cap(b)
end


function f_star(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

   S,r,g,b = 0,0,0,0;
   --S=db.star(xf,yf,0.85,0.2,{0.6,0.3,0.2},1,57,900);   r = r+S[1]; g = g+S[2]; b = b+S[3];
   xf,yf = db.zoom(xf,yf,0.65,0.5,0.35); -- zoom & pan
   xf,yf = db.rotationFrac(-15*yf+(-25)*xf,0.5*xf,0.5, xf, yf); 
   S=db.star(xf,yf,xf,0.5+m.sin(xf*m.pi*2)*0.5,{0.2,0.3,0.5},1,8,700);   r = r+S[1]; g = g+S[2]; b = b+S[3];
   S=db.star(xf,yf,xf,0.5+m.cos(yf*xf*29)*0.2,{0.5,0.3,0.2},1,9,650);    r = r+S[1]; g = g+S[2]; b = b+S[3];
   S=db.star(xf,yf,xf,0.5+m.tan(yf*3-xf*7)*0.5,{0.3,0.5,0.2},0.5,1,109); r = r+S[1]; g = g+S[2]*yf; b = b+S[3];

  --
  return cap(r),cap(g),cap(b)
end


function f_twrl(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  -- DoubleMix
  --T1 = db.twirl(xf+0.025,yf+0.025,12,180,0.05,0);  -- #Arms,Twirl,DistPow,Rot
  --T2 = db.twirl(xf-0.025,yf-0.025,12,-180,0.05,0); -- #Arms,Twirl,DistPow,Rot
 
  -- PsychoTwirl
  T1 = db.twirl(xf+0.025,yf+0.025,32,360,0.05,0); --  #Arms,Twirl,DistPow,Rot
  T2 = db.twirl(xf-0.025,yf-0.025,32,-360,0.05,0); -- #Arms,Twirl,DistPow,Rot

  r = 16 + (T1 * 208 * (0.5+yf/2)) + (T2 * 208 * (0.5+yf/2))
  g = (T1 * 176) + (T2 * 96)
  b = (T2 * 176) + (T1 * 96)

  --
  return cap(r),cap(g),cap(b)
end



function cap(v)
 return math.min(255,math.max(0,v))
end



if OK == true then

if sampal == 1 then
 for y = 0, 15, 1 do
  for x = 0, 15, 1 do
    r,g,b = f(x,y,15,15)
    setcolor(y*16+x,r,g,b)
  end
 end
end

 if makepal == 1 then db.setSceneryPalette(); end

 pal = {}
 percep = null -- not used anymore
 --percep = 1 -- Use to override Matchcolor or to compare results with custom function
 if percep == 1  then pal = db.fixPalette(db.makePalList(256)); end

 w,h = getpicturesize()

 h10 = math.floor(h/15)
 h3 = math.ceil((h-h10)/3)
 w3 = math.ceil(w/3)

 
 bw = briweight -- 0-100
 --db.fsrender(f,pal,ditherprc,xdith,ydith,percep,xonly, ord_bri,ord_hue,bri_change,hue_change,BRIWEIGHT, wd,ht,ofx,ofy)
   db.fsrender(f_grey,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w,h10,0,0)
 
   db.fsrender(f_mand,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,0,h10)
   db.fsrender(f_rain,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,w3,h10)
   db.fsrender(f_curv,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,w3*2,h10)

   db.fsrender(f_drem,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,0,h10+h3)
   db.fsrender(f_ball,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,w3,h10+h3)
   db.fsrender(f_shue,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,w3*2,h10+h3)

   db.fsrender(f_star,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,0,h10+h3*2)
   db.fsrender(f_blob,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,w3,h10+h3*2)
   db.fsrender(f_curl,pal,ditherprc,xdith,ydith,percep, null, null,   null,   null,      null,      bw,      w3,h3,w3*2,h10+h3*2)



end -- ok