--PICTURE: Remove Isolated Pixels V1.1
--by Richard 'DawnBringer' Fhager
--
-- * Remove stray pixels
-- * Smart Blur/Photo cleaning (leave details untouched)
-- * Oil/Water-paint Effects
--
-- This algorithm can not just remove stray pixels...
-- it can also smooth or add colors to the image without blurring sharp details! 
--  Use Distance-mode, Limit to high (many samish neighbours), Max Distance +20 and a high Bri-weight of +70%.
-- So it may work as smart-blur or photo-cleaning filter
-- 
-- It can also be used to create types of oil/water painting effects (usually by running the script many times)
--
-- It can also "undither" an image
--

-- (V1.1 Indexed and 24bit methods)


dofile("../libs/dawnbringer_lib.lua")


function remove(limit,mode,radius,diagweight,pal,briweight) -- modes: "index" or "cluster"
  local a,a2,x,y,c1,c2,ro,go,bo,w,h,m,a,hi,hic,cols,n,count,rt,gt,bt,ra,ga,ba,dist,xx,yy,xx2,yy2
  local r2,g2,b2,cluster,bestcluster,len,wt,wt2,cweight,bestcweight,tot,lim,drawcol,ma2,ma

  m = {{-1,-1,diagweight},{0,-1,1},{1,-1,diagweight},{-1,0,1},{1,0,1},{-1,1,diagweight},{0,1,1},{1,1,diagweight}}

  tot = 4 + diagweight*4  
  lim = limit/100 * tot

  markcol = matchcolor(255,128,128)

  cols = {}

  w,h = getpicturesize()

  for y = 0, h-1, 1 do
   drawline(0,y+1,w-1,y+1,markcol)
  for x = 0, w-1, 1 do
   c1 = getbackuppixel(x,y)
   drawcol = c1
   --ro,go,bo = getcolor(c1)

  if mode == "index" then
   for n = 1, 256, 1 do cols[n] = 0; end 

   hi,hic = -1,0
   for a = 1, 8, 1 do -- Adjacent matrix
     ma = m[a]
     xx = x + ma[1]
     yy = y + ma[2]
      if yy>=0 and yy<h and xx>=0 and xx<w then
       wt = ma[3]
       c2 = getbackuppixel(xx,yy)
       --r,g,b = getcolor(c2) 
       cols[c2+1] = cols[c2+1] + wt
       if cols[c2+1] > hi then hi = cols[c2+1]; hic = c2; end
      end
   end -- adjacent
  
   if hic ~= c1 and hi >= lim then
    --putpicturepixel(x,y,hic)
    drawcol = hic
   end

   --putpicturepixel(x,y,matchcolor(r,g,b))
  end -- indexed


  if mode == "cluster" then
 
   bestcluster = {}
   bestcweight = 0
   for a = 1, 8, 1 do -- Find Clusters
     ma = m[a]
     xx = x + ma[1]
     yy = y + ma[2]
      count = 0; cluster = {}; cweight = 0
      if yy>=0 and yy<h and xx>=0 and xx<w then
       count = 1; cluster = {a}; cweight = ma[3]
       c = getbackuppixel(xx,yy)
       r,g,b = getcolor(c) 
       for a2 = 1, 8, 1 do
        ma2 = m[a2]
        xx2 = x + ma2[1]
        yy2 = y + ma2[2]
        wt2 = ma2[3]
        if yy2>=0 and yy2<h and xx2>=0 and xx2<w and a ~= a2 then
          c2 = getbackuppixel(xx2,yy2)
          r2,g2,b2 = getcolor(c2) 
          dist = db.getColorDistance_weightNorm(r,g,b,r2,g2,b2,0.26,0.55,0.19)
          if dist <= radius then 
            count = count + 1
            cluster[count] = a2
            cweight = cweight + wt2
          end -- rad
        end -- if
       end -- a2
      end -- if
      --if #cluster > #bestcluster then bestcluster = cluster; end
      if cweight >= bestcweight then
        bestcweight = cweight
        bestcluster = cluster
      end
   end -- a

   --len = #bestcluster
   len = bestcweight

   if len >= lim and len>0 then
    rt,gt,bt = 0,0,0
    for n = 1, #bestcluster, 1 do -- Find average of best cluster
     ma = m[bestcluster[n]]
      xx = x + ma[1]
      yy = y + ma[2]
      wt = ma[3]
      r,g,b = getcolor(getbackuppixel(xx,yy)) 
      rt = rt + r * wt
      gt = gt + g * wt
      bt = bt + b * wt
    end -- n

     ra = rt / len
     ga = gt / len 
     ba = bt / len

    --drawcol = db.getBestPalMatchHYBRID({ra,ga,ba},pal,briweight,true)
    drawcol = matchcolor2(ra,ga,ba,briweight)
    --putpicturepixel(x,y,c)
   end -- if len

  end -- cluster

  putpicturepixel(x,y,drawcol)


 end;
 --statusmessage("Line: "..y.." / "..h)
 --updatescreen(); if (waitbreak(0)==1) then return; end
 if db.donemeter(5,y,w,h,true) then return; end
 end;

end


OK,IDX,CLU,LIM,DIAG,RAD,BRIWEIGHT = inputbox("Remove Stray Pixels / Smartblur",
                           "1. Color Index",                   1,    0,1,-1, 
                           "2. Color Distance *",              0,    0,1,-1, 
                        
                           "Lonliness required %",            70,  0,100,0,  
                           "Diagonal Weights",               0.7,  0,1,3,    
                           "*Max Distance: 0-255",            10,  0,255,0,  
                           "*ColMatch Bri-Weight %",          25,  0,100,0  
);

if OK == true then

 if IDX == 1 then
  remove(LIM,"index",RAD,DIAG,{},-1)
 end

 if CLU == 1 then
  pal = db.fixPalette(db.makePalList(256))
  remove(LIM,"cluster",RAD,DIAG,pal,BRIWEIGHT/100)
 end

end