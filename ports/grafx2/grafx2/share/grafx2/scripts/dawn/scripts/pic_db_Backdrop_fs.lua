--PICTURE: Backdrop v3.0 
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_interpolation.lua")

w, h = getpicturesize()

c0 = {getbackupcolor(getbackuppixel(0,0))}
c1 = {getbackupcolor(getbackuppixel(w-1,0))}
c2 = {getbackupcolor(getbackuppixel(0,h-1))}
c3 = {getbackupcolor(getbackuppixel(w-1,h-1))}

i = "This script will create gradients from the corner-pixels of the image, currently:\n\n"
i = i.."TL: "..c0[1]..","..c0[2]..","..c0[3].."\n"
i = i.."TR: "..c1[1]..","..c1[2]..","..c1[3].."\n"
i = i.."BL: "..c2[1]..","..c2[2]..","..c2[3].."\n"
i = i.."BR: "..c3[1]..","..c3[2]..","..c3[3]
messagebox("Backdrop v3.0",i)


 ipfunctions = {{ip_.midip, "2*Cos  (Sharp)"}, 
                {ip_.kenip, "Ken P. (Medium)"}, 
                {ip_.cosip, "Cos    (Medium+)"}, 
                {ip_.linip, "Linear (Smooth)"},
               } 

OK,i1,i2,i3,i4 = inputbox("Interpolation Algorithm",
 "1. "..ipfunctions[1][2],      0,  0,1,-1,
 "2. "..ipfunctions[2][2],      0,  0,1,-1,
 "3. "..ipfunctions[3][2],      0,  0,1,-1,
 "4. "..ipfunctions[4][2],      1,  0,1,-1
);

ip_func = ipfunctions[(i1 + i2*2 + i3*3 + i4*4)][1]


--
if OK == true then

 function f(x,y,w,h) 
   
   local r,g,b,ox,oy
  
   ox,oy = x/w, y/h

   r = ip_func(c0[1],c1[1],c2[1],c3[1],ox,oy)
   g = ip_func(c0[2],c1[2],c2[2],c3[2],ox,oy)
   b = ip_func(c0[3],c1[3],c2[3],c3[3],ox,oy)

   return r,g,b

 end



 db.fsrenderControl(f, "Backdrop", null,null,null, null,null,null, null, null)

end;
--
