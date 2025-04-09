--SCENE: MathRender - Nice Curves V1.5
--by Richard 'DawnBringer' Fhager

-- Math-scene render with full Floyd-Steinberg dither


-- (V1.5 5% speed-up)


dofile("../libs/dawnbringer_lib.lua")



--
function main()

 local abs,sin,pi
 local f, cap

 abs,sin,pi = math.abs, math.sin, math.pi

 cap = db.rgbcaps

--
function f(x,y,w,h) -- SCENE
  local xf,yf,S,P,F,r,g,b,Xr,Xy,mult

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
  F = 1-abs(Yr-xf*xf)
  S = 1-(abs(sin(xf*pi) - Yr))^0.5

  r = P - F*(96*yf + 160) + S*144
  g = P - F*208 + S*128
  b = P - F*(96*Yr + 160) + S*112 
  
  --
  return cap(r,g,b)
end
--


t1 = os.clock()

db.fsrenderControl(f, "Nice Curves", null,null,null, null,null,null, null, null)

--messagebox("Seconds: "..(os.clock() - t1))

end
-- main


main()
