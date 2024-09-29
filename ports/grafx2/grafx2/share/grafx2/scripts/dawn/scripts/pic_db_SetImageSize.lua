--PICTURE: Set Image Size V2.0
--by Richard 'DawnBringer' Fhager

--
function sf_modify()

  w,h = getpicturesize()
  
   -- Golden ratio
   disX,disY = w,h
   phi = (1 + math.sqrt(5)) / 2
   max,min,hor = w,h,true; if h > w then max,min,hor = h,w,false; end
   rat = max / min 
   adj = math.floor(phi / rat * max)
   if hor then disX = adj else disY = adj; end 
   --

OK,dummy,picX,picY,half,doubleX,doubleY,quad,golden,scale = inputbox("Image Size ("..w.." x "..h..")",
                           "-- Combinatorial Options * --",0,0,0,4,
                           "* Width",    w,  1,3200,0,
                           "* Height",   h,  1,3200,0,
                           "* Half Size",        0,  0,1,0,
                           "* Double Size X",    0,  0,1,0,
                           "* Double Size Y",    0,  0,1,0,
                           "* Quadruple Size (X4)",   0,  0,1,0,  
                           ">>Golden Ratio ("..disX.."x"..disY..")", 0,  0,1,0,               
                           "SCALE (simple)",   0,  0,1,0    
);

if OK == true then
  
  if quad    == 1 then picX,picY = picX * 4, picY * 4; end
  if doubleX == 1 then picX = picX * 2; end
  if doubleY == 1 then picY = picY * 2; end
  if half    == 1 then picX = picX / 2; picY = picY / 2; end -- This way we can half-size x/y too...

  if golden == 1 then
   picX,picY = disX,disY
  end

  setpicturesize(picX,picY)
end

if scale == 1 then
 xf = w / picX  
 yf = h / picY  
 for y = 0, picY-1, 1 do
  for x = 0, picX-1, 1 do
   ox = x * xf
   oy = y * yf
   c = getbackuppixel(ox,oy)
   putpicturepixel(x,y,c)
 end
 end
end

end
--

--
function sf_presets()

 w,h = getpicturesize()

p = {
     {64,64,"   (PJ avatar)"},
     {100,100," (PJ preview)"},
     {160,200," (C64 wide)"},
     {320,200," (C64)"},
     {320,256," (AmigaLores)"},
     {500,400,""},
     {640,512," (AmigaHires)"},
     {800,600, ""},
     {1024,768,""},
    }

t = {}
for n = 1, #p, 1 do
 t[n] = string.char(96+n)..") "..p[n][1].." x "..p[n][2]..p[n][3]
end

pre = {}

OK,pre[1],pre[2],pre[3],pre[4],pre[5],pre[6],pre[7],pre[8],pre[9]  = inputbox("Set Image Size ("..w.." x "..h..")",
             
                                  t[1],     1,  0,1,-1, 
                                  t[2],     0,  0,1,-1, 
                                  t[3],     0,  0,1,-1,
                                  t[4],     0,  0,1,-1, 
                                  t[5],     0,  0,1,-1, 
                                  t[6],     0,  0,1,-1, 
                                  t[7],     0,  0,1,-1, 
                                  t[8],     0,  0,1,-1,
                                  t[9],     0,  0,1,-1

);

if OK == true then
 for n = 1, #p, 1 do
  if pre[n] == 1 then picX = p[n][1]; picY = p[n][2]; break; end
 end
 setpicturesize(picX,picY)
end

end
--

--
function sf_presets2()

 w,h = getpicturesize()

p = {
     {128,128,""},
     {256,256,""},
     {512,512,""},
     {768,768, ""},
     {814,814, ""},
     {1024,768,""},
     {1280,814,""},
     {1280,1024,""},
     {1600,1200,""}
    }

t = {}
for n = 1, #p, 1 do
 t[n] = string.char(96+n)..") "..p[n][1].." x "..p[n][2]..p[n][3]
end

pre = {}

OK,pre[1],pre[2],pre[3],pre[4],pre[5],pre[6],pre[7],pre[8],pre[9]  = inputbox("Set Image Size ("..w.." x "..h..")",
             
                                  t[1],     1,  0,1,-1, 
                                  t[2],     0,  0,1,-1, 
                                  t[3],     0,  0,1,-1,
                                  t[4],     0,  0,1,-1, 
                                  t[5],     0,  0,1,-1, 
                                  t[6],     0,  0,1,-1, 
                                  t[7],     0,  0,1,-1, 
                                  t[8],     0,  0,1,-1,
                                  t[9],     0,  0,1,-1

);

if OK == true then
 for n = 1, #p, 1 do
  if pre[n] == 1 then picX = p[n][1]; picY = p[n][2]; break; end
 end
 setpicturesize(picX,picY)
end

end
--



function _quit()
 -- nada
end

function main()
 selectbox("Set Image Size", 
  ">MODIFY", sf_modify,
  ">COMMON PRESETS", sf_presets,
  ">SQUARE & LARGE", sf_presets2,
  "[Quit]", _quit
 );
end


main()


