--FILE: Save Palette as a SetPal-script
--(Creates files: pal_zz_SetPalette#.lua)
--by Richard 'DawnBringer' Fhager

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

-- Return the first unused file #
function file_exists_count(name, ext, count)
  local file
  file = name..count..ext
  local f=io.open(file,"r")
  if f~=nil then 
   io.close(f) 
   count = file_exists_count(name, ext, count+1) 
  end
  return count
end
--

maxcol = 255

name = "pal_zz_SetPalette"
ext = ".lua"

count = file_exists_count(name, ext, 0)

--messagebox(" "..count)
 
file = name..count..ext


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

t = "Palette was saved! (#"..count..")"
t = t.."\n\nDir: dawn/_save_palette/"
t = t.."\n\nFile: "..file

messagebox("fil_db_SavePalette.lua",t)