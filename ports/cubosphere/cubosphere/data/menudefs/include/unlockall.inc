USING("FILESYS")
 local numulvl=FILESYS_StartListDirectory("/levels/",true,false,true,false,".*\\.ldef");
 local counter=0;
 for index = 0, numulvl-1, 1 do
   s=FILESYS_GetListDirectoryEntry(index);
   s=string.sub(s,1,string.len(s)-5);
   if SCORE_VarDefined(s)~=1 then
     SCORE_SetVar(s,1);
   end;
 end;

INCLUDEABSOLUTE("menudefs/include/writescores.inc");
GLOBAL_SetVar("FinalUnlocked",1);
INCLUDEABSOLUTE("menudefs/include/writecfg.inc");
print("All levels unlocked");
