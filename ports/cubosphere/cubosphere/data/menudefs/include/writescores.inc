USING("FILESYS")

confdir="/user";

print("writing highscore file ("..confdir.."/scores.cdef)");
scores=SCORE_Open(confdir.."/scores.cdef");

if scores~=0 then

 local numulvl=FILESYS_StartListDirectory("/levels/",true,false,true,false,".*\\.ldef");
 --print("NUM "..numulvl);
 local counter=0;
 for index = 0, numulvl-1, 1 do
   s=FILESYS_GetListDirectoryEntry(index);
  -- print(s);
   --Strip the extention
   s=string.sub(s,1,string.len(s)-5);
   if SCORE_VarDefined(s)==1 then
     SCORE_Write(scores,s);
   end;
 end;

   SCORE_Close(scores);
else
  print("Score-File could not be written!");
end



