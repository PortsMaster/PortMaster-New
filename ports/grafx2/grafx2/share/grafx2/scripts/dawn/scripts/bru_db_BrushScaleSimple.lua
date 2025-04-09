--BRUSH: Simple Scale V2.0 (Added 3X and 1/3)
--by Richard Fhager 


OK,xscale,yscale,both,dummy,double,triple,half,third = inputbox("Scale Brush",
                           "1. X-Scale",        1,  0,1,-1,
                           "2. Y-Scale",        0,  0,1,-1,
                           "3. Both X & Y",     0,  0,1,-1,
                           "------------------",    0,  0,0, 4,
                           "a)  2X Double Size",    1,  0,1,-2,
                           "b)  3X Triple Size",    0,  0,1,-2,
                           "c) 1/2 Half Size",      0,  0,1,-2,
                           "d) 1/3 Third Size",     0,  0,1,-2                           
);



--
if OK == true then 

w, h = getbrushsize()

ns = third * 1/3 + half * 0.5 + double*2 + triple*3 -- 0.5, 2 or 3

if both == 1 then xscale,yscale = 1,1; end

nw = w + math.ceil(xscale * (ns-1) * w)
nh = h + math.ceil(yscale * (ns-1) * h)

ow = math.ceil(w) / nw
oh = math.ceil(h) / nh

setbrushsize(nw,nh)

 for x = 0, nw - 1, 1 do
  for y = 0, nh - 1, 1 do

    px = x * ow
    py = y * oh

    putbrushpixel(x, y, getbrushbackuppixel(px,py));

  end
 end
--


end -- OK




