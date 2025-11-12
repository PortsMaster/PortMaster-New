
local allunlocked=true;
local numletters=10;

 for i=1,numletters,1 do
    local warpname=string.format("warp/w%02dlfin",i);
    if SCORE_VarDefined(warpname)==0 then
      allunlocked=false;
      break;
    end;
 end;


 local lookup={};
 local lookupsize=0;
 for b=0,LEVEL_NumBlocks()-1,1 do
   for s=0,5,1 do
     local checkside=6*b+s;
     if SIDE_GetType(checkside)=="warptunnel" then
       if allunlocked==false then
         LEVEL_DeleteBlock(b);
       else
         BLOCK_SetVar(b,"Secret",1);
       end;
         break;
     end;
   end;   
 end;



INCLUDEABSOLUTE("/levels/autoexec.inc");
