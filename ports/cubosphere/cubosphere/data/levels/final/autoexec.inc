
local lvln=GLOBAL_GetVar("CurrentLevel");
local rev=string.reverse(lvln);
local nmb=string.match(rev,"%d+");

if nmb~=nil then
 nmb=string.reverse(nmb)+0;
 if nmb==2 and GLOBAL_GetVar("LastLevelIndexInEpisode")<EpisodeLevelCount-1 then
   LEVEL_MAY_SAVE=1;
 else 
   LEVEL_MAY_SAVE=0;
 end;
end;

