--PICTURE: Matrix Patterns (mem)
--by Richard Fhager

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/memory.lua")



m = {}

m[1] = { -- Checkered
 {1,0},
 {0,1}
}

m[2] = { -- Quarter dots
 {0,1},
 {0,0}
}

m[3] = { -- Scanlines
 {0},
 {1}
}

m[4] = { -- Diagonal Line
 {0,0,1},
 {0,1,0},
 {1,0,0}
}

m[5] = { -- Hexa Dot
 {0,1},
 {0,0},
 {1,0},
 {0,0}
}


m[6] = { -- Box-Corners
 {1,0,1},
 {0,1,0},
 {1,0,1}
}

m[7] = { -- Mesh (Large Crosshatch)
 {1,0,0,0},
 {0,1,0,1},
 {0,0,1,0},
 {0,1,0,1}
}

m[8] = { -- Scanline every 3d
 {0},
 {0},
 {1}
}

m[9] = { -- Hexa Boxes
 {1,1,1,0,1,1,1,0},
 {1,0,1,0,0,0,0,0},
 {1,1,1,0,1,1,1,0},
 {0,0,0,0,1,0,1,0}
}



-- Cool combos:
-- Box-Corners + Mesh (5)
-- Hexa dot + Diagonal Line (3)
-- Quarter dot + Diagonal Line (4)
-- Quarter dot + Box-Corners (3)
-- Quarter dot + Mesh (5) (Vertical Bricks)
-- Scanline 1/2 + Mesh (5) (Horizontal Bricks)
-- Scanline 1/2 + Diagonal (5) (Short Horizontal Bricks)
-- Quarter dot + Mesh + Scanline 1/2 (5) (2/8 Pattern, "5-Dice")
-- Diagonal Line + Mesh (3)
-- Quarter Dot + Hexa dot (4) (Dotted scanlines)
-- Scanline + Hexadot (4 Flicker) "Hexa plots (Inverted Hexadots)"
-- All combos with Hexa-Boxes look pretty cool, esp. Box-Corners


--dotRandom(0.5, getforecolor())




--db.dotMatrix(m[2],c, 300,200,200,100) -- Quarter dot

mact = {
 0, -- 1. Checkered (2x2)
 0, -- 2. 1/4 Dots (2x2) 
 1, -- 3. Scanline 1/2 (1x2)
 0, -- 4. Diagonal Line (3x3)
 0, -- 5. Hexa-Dot (2x4)
 0, -- 6. Box.Corners (3x3)
 1, -- 7. Mesh (4x4)
 0, -- 8. Scanline 1/3 (1x3)
 0  -- 9. Hexa Boxes (8x4)
}

arg=memory.load({m1=mact[1], m2=mact[2], m3=mact[3], m4=mact[4], m5=mact[5], m6=mact[6], m7=mact[7], m8=mact[8], m9=mact[9]})

OK, m1,m2,m3,m4,m5,m6,m7,m8,m9 = inputbox(".Matrix Patterns", 
                          
  "1. Checkered     (2x2)", arg.m1, 0, 1, 0,
  "2. 1/4 Dots      (2x2)", arg.m2, 0, 1, 0,
  "3. Scanline 1/2  (1x2)", arg.m3, 0, 1, 0,
  "4. Diagonal Line (3x3)", arg.m4, 0, 1, 0,
  "5. Hexa-Dots     (2x4)", arg.m5, 0, 1, 0,
  "6. Box-Corners   (3x3)", arg.m6, 0, 1, 0,
  "7. Mesh          (4x4)", arg.m7, 0, 1, 0,
  "8. Scanline 1/3  (1x3)", arg.m8, 0, 1, 0,
  "9. Hexa Boxes    (8x4)", arg.m9, 0, 1, 0  
                                               
);






if OK then

 for n = 1, #mact, 1 do
  mact[n] = loadstring("return m"..n)()
 end

 arg=memory.save({m1=mact[1], m2=mact[2], m3=mact[3], m4=mact[4], m5=mact[5], m6=mact[6], m7=mact[7], m8=mact[8], m9=mact[9]})

 c = getforecolor()
 for n = 1, #mact, 1 do
  if mact[n] == 1 then
   db.dotMatrix(m[n],c)
  end
 end

end




