---------------------------------------------------
---------------------------------------------------
--
--             Interactivity Library
--              
--                    V0.5
-- 
--                Prefix: ia_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  Currently just functions to dynamically create selectboxes

---------------------------------------------------



ia_ = {}


--
-- Create a SelectBox menu from an object, sets the .selected parameter in data
--
--
-- ex: o = {list = {{"Text1", func1}, {"Text2", func2}}, selected = 1}
--
function ia_.Menu(o, ofs, maxlen)
 local n,args,i,len,mark,title, sel

 mark = o.markselected or 1 -- 0/1 Mark active item with '*' 
 title = o.title or ""

 maxlen = maxlen or 7 
 maxlen = math.min(8,maxlen) -- Capped at 8 for a max total of 10 buttons (8 + back + more)

 ofs = ofs or math.floor((math.max(0,o.selected-1))/maxlen) * maxlen
 
 --sel = 0

 len = math.min(#o.list-ofs, maxlen)
 args,i = {},1
 for n = 1+ofs, len+ofs, 1 do
  prefix = ""
  if o.selected == n and mark == 1 then prefix = "*"; end
  args[i] = prefix..o.list[n][1]; i=i+1
  args[i] = (function() o.selected = n; sel = n; end); i=i+1
 end

 if (#o.list-ofs) > maxlen then
  args[i] = "[More]"; i=i+1
  args[i] = (function() ia_.Menu(o, maxlen+ofs); end); i=i+1
 end

 if ofs > 0 then
  args[i] = "[Back]"; i=i+1
  args[i] = (function() ia_.Menu(o, ofs-maxlen); end); i=i+1
 end

 selectbox(title, unpack(args))

 -- returning selection is unreliable due to recursion
 --return sel -- Return selected # for direct access to result, 0 means 'Esc' was pressed (nothing selected)

end
--

-- Tool to help dynamically build Selectboxes (one item at a time) 
-- use selectbox("title", unpack(package)) to execute.
-- package is an array
function ia_.AddItem2Package(package, text, func)
 local l
 l = #package
 package[l+1] = text
 package[l+2] = func
 --return package
end
--