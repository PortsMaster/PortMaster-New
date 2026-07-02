
lvln=GLOBAL_GetVar("CurrentLevel");

patt="lfin";

LooseScoreOnDie=0; 

LEVEL_MAY_SAVE=0;

if string.find(lvln,patt)==nil then
  ScoresVisible=0;
  GainScoreOnWin=0;
else 
  LEVEL_MAY_SAVE=1;
end;
