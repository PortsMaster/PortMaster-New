

svname="/user/saves/"..GLOBAL_GetVar("CurrentEpisode").."/"..GLOBAL_GetVar("SaveToSlot")..".lua";

print("saving game ("..svname..")");

slot=SAVE_Open(svname);
if slot~=0 then
   SAVE_Write(slot,"SAVE_VERSION="..GLOBAL_GetVar("CuboVersion")..";\n");
   SAVE_Write(slot,"LOAD_EPISODE=\""..(GLOBAL_GetVar("CurrentEpisode")).."\";\n");
   SAVE_Write(slot,"LEVEL_NUM="..(GLOBAL_GetVar("LastLevelIndexInEpisode"))..";\n");
   SAVE_Write(slot,"LOAD_LEVEL=\""..(GLOBAL_GetVar("CurrentLevel")).."\";\n");
   SAVE_Write(slot,"LOAD_SCORE="..(GLOBAL_GetVar("TotalScore"))..";\n");
   SAVE_Close(slot);
else
  print("Save Game could not be written!");
end;
