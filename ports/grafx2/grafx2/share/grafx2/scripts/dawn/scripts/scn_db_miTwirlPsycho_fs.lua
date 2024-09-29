--SCENE: MathRender - Psycho Twirl
--by Richard 'DawnBringer' Fhager

-- Math-scene render with full Floyd-Steinberg dither


dofile("../libs/dawnbringer_lib.lua")


function f(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m,T1,T2
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
  return db.rgbcaps(r,g,b)
end



db.fsrenderControl(f, "Psycho Twirl", null,null,null, null,null,null, null, null)





