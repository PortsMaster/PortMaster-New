
svname="/user/levels/"..GLOBAL_GetVar("Editor_SaveFileName")..".ldef";

print("saving level ("..svname..")");


f=LEVEL_FileBegin(svname);


if f~=0 then
LEVEL_FileWrite(f,"--#VERSION "..GLOBAL_GetVar("CuboVersion"));
LEVEL_FileWrite(f,"--Created with the internal LEVEL-Editor of Version "..GLOBAL_GetVar("CuboVersion").."\n");
LEVEL_FileWrite(f,"LEVEL_VERSION="..GLOBAL_GetVar("CuboVersion")..";");


LEVEL_FileWrite(f,"--Includes");
LEVEL_FileWrite(f,"if GLOBAL_GetVar(\"EditorMode\")==1 then");
LEVEL_FileWrite(f,"  INCLUDEABSOLUTE(\"/editor/include/editor.inc\");");
LEVEL_FileWrite(f,"else");
LEVEL_FileWrite(f,"  INCLUDEABSOLUTE(\"/levels/include/std.inc\");");
LEVEL_FileWrite(f,"end;");

LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"");

local t=GLOBAL_GetVar("StartTime");
LEVEL_FileWrite(f,"GLOBAL_SetVar(\"StartTime\","..t..")");
local t=GLOBAL_GetVar("MaxTime");
LEVEL_FileWrite(f,"GLOBAL_SetVar(\"MaxTime\","..t..")");
local t=GLOBAL_GetVar("GoggleTime");
LEVEL_FileWrite(f,"GLOBAL_SetVar(\"GoggleTime\","..t..")");
local t=GLOBAL_GetVar("MusicTrack");
LEVEL_FileWrite(f,"GLOBAL_SetVar(\"LevelMusic\",\""..t.."\")");


LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"");

LEVEL_FileWrite(f,"function InitActors()");
for ball=0,ACTOR_NumActors()-1,1 do 
 if ACTOR_IsPlayer(ball)==1 then
   local sbp=BLOCK_GetPos(SIDE_GetBlock(ACTOR_GetOnSide(ball)));
   local ss=math.fmod(ACTOR_GetOnSide(ball),6);
   local sr=ACTOR_GetStartRotation(ball);
   local startside=ACTOR_GetOnSide(ball); 
   local sp=VECTOR_Add(SIDE_GetMidpoint(ACTOR_GetOnSide(ball)),VECTOR_Scale(SIDE_GetNormal(ACTOR_GetOnSide(ball)),GLOBAL_GetScale()*0.5));
   local bi=BLOCK_AtPos(sp); 
   if bi<0 then
     LEVEL_FileWrite(f," AddBall(\""..ACTOR_GetType(ball).."\", VECTOR_New"..VECTOR_ToString(sbp)..", "..ss..", "..sr..  ");");   
   end;
 end;
end;
LEVEL_FileWrite(f,"end;");

LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"");

LEVEL_FileWrite(f,"--Level Data");
LEVEL_FileWrite(f,"function Level()");
LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"  BackwardCompatibility(LEVEL_VERSION,\"pre\");");
LEVEL_FileWrite(f,"  if GLOBAL_GetVar(\"ThemeOverride\")==\"\" then");
LEVEL_FileWrite(f,"     THEME_Load(\""..THEME_GetName().."\");");
LEVEL_FileWrite(f,"  else");
LEVEL_FileWrite(f,"     THEME_Load(GLOBAL_GetVar(\"ThemeOverride\"));");
LEVEL_FileWrite(f,"  end;");

LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"--#LEVEL BEGIN");

LEVEL_FileData(f);

LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"--#LEVEL END");
LEVEL_FileWrite(f,"");
--if startblock>=0 then
--  local sblockpos=BLOCK_GetPos(startblock);
--  LEVEL_FileWrite(f,"  startblockpos=VECTOR_New"..VECTOR_ToString(sblockpos)..";");
--  LEVEL_FileWrite(f,"  startside="..math.fmod(startside,6)..";");
 -- LEVEL_FileWrite(f,"  startrotation="..startrotation..";");
--  LEVEL_FileWrite(f,"  startblock=1; --Means that a start point is set");
--  LEVEL_FileWrite(f,"");
--else
 -- LEVEL_FileWrite(f,"  startblock=-1; --Means that a no start point is set");
--  LEVEL_FileWrite(f," -- NO START POINT!!!");
--end;
LEVEL_FileWrite(f,"  LEVEL_LoadSky();");
LEVEL_FileWrite(f,"  BallType=\""..GLOBAL_GetVar("EditorBall").."\";");
--LEVEL_FileWrite(f,"  NEXTLEVEL=\"win\";");

LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"  if GLOBAL_GetVar(\"EditorMode\")==1 then");
LEVEL_FileWrite(f,"    CamBasis=BASIS_New()");
--Get the Cam Basis
local cpos=CAM_GetPos();
local cdir=CAM_GetDir();
local cside=CAM_GetSide();
local cup=CAM_GetUp();
--And Write it
LEVEL_FileWrite(f,"    BASIS_Set(CamBasis,VECTOR_New"..VECTOR_ToString(cside)..", VECTOR_New"..VECTOR_ToString(cup)..", VECTOR_New"..VECTOR_ToString(cdir)..", VECTOR_New"..VECTOR_ToString(cpos)..")");
LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"    SelBlockX="..BLOCK_GetPos(selectblock)["x"]..";");
LEVEL_FileWrite(f,"    SelBlockY="..BLOCK_GetPos(selectblock)["y"]..";");
LEVEL_FileWrite(f,"    SelBlockZ="..BLOCK_GetPos(selectblock)["z"]..";");

LEVEL_FileWrite(f,"  end");
LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"  BackwardCompatibility(LEVEL_VERSION,\"post\");");
LEVEL_FileWrite(f,"  InitLevel();");
LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"end;");
LEVEL_FileWrite(f,"");
LEVEL_FileWrite(f,"--#FILE END");

LEVEL_FileEnd(f);


else
  print("Error: User Level could not be saved!");
end;


