--BRUSH/PICTURE: Rotation V3.2 
--by Richard 'DawnBringer' Fhager 

-- (V3.2 Gamma, Pfunction, New interpolation system, including BiCubic ip, Fractional angles allowed)

--prePIC / preBRU is set in toolbox-script
if prePIC == null then prePIC = 1; end
if preBRU == null then preBRU = 0; end

OK,pic,brush,rot,ipmode,noip,bicubic,spritemode,gamma,resize   = inputbox("Rotation",
                           "1. Picture",          prePIC,  0,1,-2,
                           "2. Brush",            preBRU,  0,1,-2,
                           "Rotation Degrees",       0,  -360,360,2,  
                           "a) IP Smoothness*: 1-4",       2,1,4,0,  
                           "b) No Interpolation",          0,0,1,0,
                           "c) BiCubic IP (photo)",        0,0,1,0,
                           "*SPRITEMODE (no add cols)",    0,0,1,0,
                           "*IP Gamma: 1.0-2.2",          1.6,  1,2.2,3,

                           "Resize to new image",       1,0,1,0                                        
);


if OK == true then

--
-- ROTATE Image or Brush
--
-- target:     1 = Brush, 2 = Picture, 3 = Brush-to-Picture
-- rot:        Rotation in degrees
-- mode:       1 = Simple, 2 = Cosine Interpolation, 2 = BiLinear Interpolation
-- spritemode: 0 = Off, 1 = On (Only match adjacent colors, use with Bilinear-Ip. for good result)
-- resize:     0 = No, 1 = Yes (Resize Image/Brush to fit all gfx, otherwise clip)
-- update:     0 = No, 1 = Yes (Update screen while drawing)
-- xoffset:    For use with Brush-to-Picture operations
-- yoffset:    For use with Brush-to-Picture operations
--
target = 2
if brush == 1 then target = 1; end

if noip == 1 then ipmode = 0; end -- No interpolation, "Simple" or sharp mode
if bicubic == 1 then ipmode = 5; end

dofile("../pfunctions/pfunc_DoRotation.lua")(target,rot,ipmode,spritemode,resize,1, 0,0, gamma)

end -- OK

