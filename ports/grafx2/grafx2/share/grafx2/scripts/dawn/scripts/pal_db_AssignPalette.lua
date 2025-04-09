--PALETTE: Assign Spare Palette to Main
--by Richard Fhager

--That is; EACH color in palette 1 will replace ONE specific color in palette 2 (ALL colors must be used),
--Looking for the assignment scheme with the smallest total error.

dofile("../libs/dawnbringer_lib.lua")

--
function main()

 local BRIWEIGHT,hist,NOSQUARE, W,H,PIX
 local rnd, pow, abs
 local n,a,b,c1,c2,r1,g1,b1,r2,g2,b2,o1,o2,e1,e2,err,nerr,totalerr,len,sr1,sg1,sb1,sr2,sg2,sb2
 local match, palF, palS, sc1, sc2, hist
 local getColorError, format

 rnd = math.random
 pow = math.pow
 abs = math.abs

OK,ITER,HISTPOW,briweight,BRISORT,NOSQUARE = inputbox("Assign Spare Pal to Main",
                  
                           "Iterations: 10-5M", 100000,  10,5000000,0,  
                           "Histopower: 0-25 (wip)", 0,  0,25,0, 
                           "BriDistance weight %", 25,  0,100,0,  
                        
                           "Inital BriSort",         1,  0,1,0,
                           "Don't Square Errors",    0,  0,1,0
--                                                  
);

if OK == true then

BRIWEIGHT = briweight / 100


W,H = getpicturesize()
PIX = W*H
hist = {}
if HISTPOW > 0 then
  hist = db.makeHistogram() 
  else
   for n = 1, 256, 1 do
     hist[n] = 1
   end
end

--
function getColorError(c1,r1,g1,b1,r2,g2,b2,rw,gw,bw,briweight,hist,nosquare) -- Ok, this could be sped up x10 by pre-calcs
  local err,diff,bri1,bri2,diffB,diffC
  bri1 = db.getBrightness(r1,g1,b1)
  bri2 = db.getBrightness(r2,g2,b2)
  diffB = abs(bri2 - bri1)
  diffC = db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,rw,gw,bw) 
  diff = briweight * (diffB - diffC) + diffC

 --err = (rw*(r1-r2))^2 + (gw*(g1-g2))^2 + (bw*(b1-b2))^2  
 --err = math.sqrt((rw*(r1-r2))^2 + (gw*(g1-g2))^2 + (bw*(b1-b2))^2)  

  if nosquare == 1 then
   err = diff * (1+pow(hist[c1+1]/PIX,HISTPOW/10))
    else
     err = (diff*diff) * (1+pow(hist[c1+1]/PIX,HISTPOW/10))
  end
 

 return err
end
--

--
function format(v,p)
 return math.floor(v * 10^p) / 10^p
end
--

palF = db.fixPalette(db.makePalList(256),BRISORT) -- Sort by Brightness
palS = db.fixPalette(db.makeSparePalList(256),BRISORT)

if #palF ~= #palS then
 messagebox("Palettes are not of equal size")
end

len = math.min(#palF,#palS)

totalerr,avgerr = 0,0
match = {}
for n = 1, len, 1 do
 c1 = palF[n]
 r1 = c1[1]
 g1 = c1[2]
 b1 = c1[3]
 c2 = palS[n]
 r2 = c2[1]
 g2 = c2[2]
 b2 = c2[3]
 --setcolor(n-1,r1,g1,b1)
 --dist[n] = db.getColorDistance_weight(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19) 
 err = getColorError(c1[4],r1,g1,b1,r2,g2,b2,0.26,0.55,0.19,BRIWEIGHT,hist,NOSQUARE)
 totalerr = totalerr + err
 match[n] = {n,err} 
end

--messagebox("Error after brisort: "..totalerr)
statusmessage("Avg. Error: "..math.sqrt(totalerr/len));  waitbreak(0)

for n = 1, ITER, 1 do
 a = rnd(1,len)
 b = rnd(1,len)
 
 err = match[a][2] + match[b][2]

 sc1 = palS[match[a][1]]
 sr1,sg1,sb1 = sc1[1],sc1[2],sc1[3]
 sc2 = palS[match[b][1]]
 sr2,sg2,sb2 = sc2[1],sc2[2],sc2[3]

 c1 = palF[a]
 r1,g1,b1 = c1[1],c1[2],c1[3]
 c2 = palF[b]
 r2,g2,b2 = c2[1],c2[2],c2[3]
 
 e1 = getColorError(c1[4],r1,g1,b1,sr2,sg2,sb2,0.26,0.55,0.19,BRIWEIGHT,hist,NOSQUARE)
 e2 = getColorError(c1[4],r2,g2,b2,sr1,sg1,sb1,0.26,0.55,0.19,BRIWEIGHT,hist,NOSQUARE)

 nerr = e1+e2
 if (nerr < err) then
  o1 = match[b][1]
  o2 = match[a][1]
  match[a] = {o1,e1}
  match[b] = {o2,e2}

  totalerr = totalerr - err + nerr
  avgerr = math.sqrt(totalerr/len)
  statusmessage("Err:"..format(avgerr,1).."-It:"..n.."      ")
  waitbreak(0)
 end

end

for n = 1, len, 1 do
 c1 = palS[match[n][1]]
 r1 = c1[1]
 g1 = c1[2]
 b1 = c1[3]
 --setcolor(n-1,r1,g1,b1)
 setcolor(palF[n][4],r1,g1,b1) -- Since we brightness sorted we must refer to the original color index
end


messagebox("Final Average Error: "..math.sqrt(totalerr/len))

end -- ok

end
-- main

main()
