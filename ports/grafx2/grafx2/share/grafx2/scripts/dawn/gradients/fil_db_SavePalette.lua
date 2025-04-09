--FILE: Save Palette as a SetPal-script
--(Creates file: pal_zz_SetPalette.lua)
--by Richard 'DawnBringer' Fhager

maxcol = 255

file = "pal_zz_SetPalette.lua"

f = io.open(file, "w");
   
txt = "pal={\n"

comma = ""
for n = 0, maxcol, 1 do
 r,g,b = getcolor(n)
 txt = txt..comma.."{"..n..", "..r..", "..g..", "..b.."}\n"
 comma = ","
end

txt = txt.."}\n"

txt = txt.."\nfor n = 1, #pal, 1 do\n setcolor(pal[n][1],pal[n][2],pal[n][3],pal[n][4])\nend"

f:write(txt) 
f:close()

messagebox("Palette was saved! \n\nFile: "..file)