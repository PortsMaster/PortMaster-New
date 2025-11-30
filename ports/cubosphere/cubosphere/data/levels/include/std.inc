USING("FILESYS");

INCLUDEABSOLUTE("/blockdefs/include/colors.inc");


--Are we inside the normal episode listing? Otherwise (warp etc.), this is false
IsNormalEpisodeLevel=true;

secondplayer="";

ScoresVisible=1;
LooseScoreOnDie=1;
GainScoreOnWin=1;

KeyIconSize=0.085;
KeyIconAspectRatio=0.5; 
KeyIconDistanceX=KeyIconAspectRatio*KeyIconSize*0.8;
KeyIconDistanceY=KeyIconSize*(640.0/480.0)*1.0;
KeyIconOffsetX=KeyIconAspectRatio*KeyIconSize;
KeyIconOffsetY=0.02;
KeyIconMaxPerRow=8;

DeathPenaltyScore=150;
LethargoTimeScale=2;
NEXTLEVEL="";
player=-1;
numkeys=0;
LostString="";
OldScore=0;
FlyInBase=-1;
FlyInTime=1.25;
GameTime=0.0;
GameFrame=0;

HasCopyCats=0;



JumpStop=0; --Prevents from jumping, when the in game menu is closed by selecting "continue" with "jump"


 GLOBAL_SetVar("ActivePlayer",-1);
-- GLOBAL_SetVar("WarpZoneLogo",-1);
GLOBAL_SetVar("WarpZoneLogoTimer",-1);

USING("PARTICLE");
USING("GL");

ShowLoading=0;
BallType="ball1";

function CheckDefExchange(defname,typestr)
 --Check older versions --TODO:Remove soon
if typestr=="item" then
   if     defname=="time plus" then defname="time_plus";
   elseif defname=="time minus" then defname="time_minus";
   elseif defname=="jump plus" then defname="jump_plus";
   elseif defname=="jump minus" then defname="jump_minus";
   end;
 end;


 if GLOBAL_GetVar("ExploreMode")==0 then
  return defname;
 end;
 if typestr=="item" then
   if defname=="hourglass" then
     return "diamond2"
   elseif defname=="time_plus" or defname=="time_minus" then
     return "";
   else 
     return defname
   end;
 else
   return defname;
 end;
end;

function PreRender()
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;
end;

function PostRender()
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;
end;

TutorialString="";
GLOBAL_SetVar("TutorialString","");

--keymdl=-1;
key_collected=-1; --Textures
key_missing=-1;

--For letting the score be increased not instantly. Count it up
ScoreIncreaseTime=0.25;
ScoreIncreaseTimer=0;
IncreaseScore=0;
DestScore=0;

startside=-1;
startblock=-1;
startrotation=-1;

MenuSelection=0;
print("Starting a level (".. GLOBAL_GetVar("CurrentLevel")..")");

InScene="start";

snd_nav=SOUND_Load("menunav");
snd_sel=SOUND_Load("menusel");
snd_start=SOUND_Load("levelstart");
snd_clock=SOUND_Load("clocktick");
snd_cam_pan=SOUND_Load("camerapan");
snd_exit=SOUND_Load("exit");


part_exit=-1;
 if GLOBAL_GetVar("UseParticles")~=0 then
  --part_exit=PARTICLE_LoadDef("ball_exit");
end;

darkbg=-1;
screenflash=-1;

Win=0; -- -1 for Loosing, 1 for Winning

GLOBAL_SetVar("StartTime",60);
GLOBAL_SetVar("MaxTime",60);
GLOBAL_SetVar("GoggleTime",15);
GLOBAL_SetVar("LevelMusic",GLOBAL_GetVar("MusicTrack"));
GLOBAL_SetVar("TextOutTimer",0);
GLOBAL_SetVar("ProtectEscPressed",0);

function LevelRestart()
 ACTOR_SetVar(PLAYER_GetActiveActor(player),"KilledString","Restart!");
 SOUND_SetPostEffect("",0,0,0);  
 LEVEL_SetTimeScale(0);
 ACTOR_SetVar(PLAYER_GetActiveActor(player),"IsAlive",-1.01);
 InScene="playing";
end; 



function QuitLevel()
  local othlevel=EpisodeLevelList[GLOBAL_GetVar("LastLevelIndexInEpisode")];
  if IsNormalEpisodeLevel==true or GLOBAL_GetVar("StartUserLevel")~="" or othlevel==nil then 
       SOUND_SetPostEffect("",0,0,0);       
       GLOBAL_SetVar("InGame",0);
         print("Avg. FPS: "..(GameFrame/GameTime));

       if GLOBAL_GetVar("EditorMode")>=2 then
         GLOBAL_SetVar("Editor_LoadLevel","_selection");
         MENU_Load("editorstart");
       elseif GLOBAL_GetVar("InsideTutorial")==1 then
           MENU_Load("tutorial");
       elseif GLOBAL_GetVar("ExploreMode")==0 then
         if GLOBAL_GetVar("StartUserLevel")=="" then
           if GLOBAL_GetVar("InsideFinal")==0 then
             MENU_Load(GLOBAL_GetVar("LoadESCMenu"));
           else
             MENU_Load("final");
           end;
         else
           MENU_Load("userlevel");
         end;
       else
         MENU_Load("exploreepisode");
       end;
       SOUND_StopChannel(-1);
       SOUND_Play(snd_sel,-1);
       LEVEL_Deactivate();
       MENU_Activate();
  else
    GLOBAL_SetVar("CurrentLevel",othlevel)
    InScene="retire"; 
    ShowLoading=1;
    GLOBAL_SetVar("SaveGameProtectScore",0);
    LEVEL_Load(othlevel);
  end;
end;

function BackwardCompatibility(vers,when)
 --For later releases
end;

function MakeJoystickString(stick,button,dir)
	local joystick = require "Joystick"
	local joy = joystick.Get(stick) 
	return (joy:GetGUID()..","..dir..","..button);
end;


function RefreshTwoPlayer()
if GLOBAL_GetVar("TwoPlayers")~=1 then secondplayer=""; return ;end;

local aact=PLAYER_GetActiveActor(player);

for i=0,PLAYER_NumActors(player)-1,1 do
  local cact=PLAYER_GetActor(player,i);

   if math.fmod(i,2)==1 then
        secondplayer="_p2";
      else
        secondplayer="";  
      end;
   if cact==aact then  break; end;
end;
    
end;


function NextActor()
  local aact=PLAYER_GetActiveActor(player);
  if ACTOR_GetVar(aact,"IsAlive")==1 then
    if PLAYER_NextActor(player)~=aact then
      SOUND_Play(snd_cam_pan,-1);
      RefreshTwoPlayer();
    end;
  end;
end;

function TryActorChange()
 local aa=PLAYER_GetActiveActor(player);

 if ACTOR_GetVar(aa,"OnTextout")~=0 then return false; end;

 if ACTOR_CurrentMove(aa)=="jumpup" and ACTOR_GetVar(aa,"Bounce")==1 then
  return true;
 end;

 if ACTOR_CurrentMove(aa)=="none" then 
   local sid=ACTOR_TraceOnSide(aa);
   if sid<0 then
      return false;
   else
     if SIDE_GetType(sid)=="icy1" then
       if ACTOR_GetVar(aa,"RestingOnIce")==sid then
         return true;
       else
         return false;
       end;
     end;
     return true;
   end;
 else
   return false;
 end;
end;

function OnJoyButton(stick,button,dir,down,toggle)
 keyn=MakeJoystickString(stick,button,dir);

 if (InScene=="savegame") then
 return;
end;
  if GLOBAL_GetVar("InGameOptions")~=0 then
   if GLOBAL_GetVar("InGameOptions")==2 then
     GLOBAL_SetVar("InGameOptions",0);
   end;
   return;
  end;

 if (InScene=="playing") then
  if down==1 then
   if ((keyn==GLOBAL_GetVar("Joy_Cancel")) or (keyn==GLOBAL_GetVar("Joy_Cancel_p2"))) and (toggle==1) then
     if GLOBAL_GetVar("ProtectEscPressed")==0 then
        SOUND_Play(snd_sel,-1);
        InScene="pause"; 
        MenuSelection=0;
        LEVEL_SetTimeScale(0);
        PARTICLE_SetTimeScale(0);
     else
       GLOBAL_SetVar("ProtectEscPressed",0);
     end;
   elseif GLOBAL_GetVar("TutorialString")==""  then
     if JumpStop==0 or keyn~=GLOBAL_GetVar("Joy_Jump"..secondplayer) then
        if keyn==GLOBAL_GetVar("Joy_Special"..secondplayer) and toggle==1 and PLAYER_NumActors(player)>1 
              and TryActorChange()==true  then
                 NextActor();
       else     
        if PLAYER_InCameraPan(player)==0 then  
           if HasCopyCats==1 then
             if ACTOR_GetType(PLAYER_GetActiveActor(player))=="copycat" then 
              if keyn~=GLOBAL_GetVar("Joy_Jump") and keyn~=GLOBAL_GetVar("Joy_Forward") then
               for ball=0,ACTOR_NumActors()-1,1 do
                 if ACTOR_IsPlayer(ball) then
                   ACTOR_SendJoyButton(ball,stick,button,dir,down,toggle); 
                 end;
               end; 
              end;
             else
               ACTOR_SendJoyButton(PLAYER_GetActiveActor(player),stick,button,dir,down,toggle);
               for ball=0,ACTOR_NumActors()-1,1 do
                 if ACTOR_GetType(ball)=="copycat" then
                   ACTOR_SendJoyButton(ball,stick,button,dir,down,toggle); 
                 end;
               end; 
             end;
           else
            ACTOR_SendJoyButton(PLAYER_GetActiveActor(player),stick,button,dir,down,toggle);
           end;
        end;
       end;
     end;
   end;
   elseif JumpStop==1 then
    if keyn==GLOBAL_GetVar("Joy_Jump") or  keyn==GLOBAL_GetVar("Joy_Jump_p2") then
     JumpStop=0;
    end;
  end;
 elseif (InScene=="scores") then
   if ((keyn==GLOBAL_GetVar("Joy_Jump")) or (keyn==GLOBAL_GetVar("Joy_Cancel"))) or ((keyn==GLOBAL_GetVar("Joy_Jump_p2")) or (keyn==GLOBAL_GetVar("Joy_Cancel_p2"))) and (toggle==1) then
     InScene="finish"; -- Load the next level/restart
   end;
 elseif ((InScene=="pause") and (toggle==1)) then
   if keyn==GLOBAL_GetVar("Joy_Cancel") or keyn==GLOBAL_GetVar("Joy_Cancel_p2") then
     SOUND_Play(snd_nav,-1);
     InScene="playing";
     LEVEL_SetTimeScale(1);
     PARTICLE_SetTimeScale(1);
   elseif (keyn==GLOBAL_GetVar("Joy_Forward")) or (keyn==GLOBAL_GetVar("Joy_Forward_p2"))  then
     SOUND_Play(snd_nav,-1);
     MenuSelection=MenuSelection-1;
     if MenuSelection<0 then 
         MenuSelection=3;
     end;
   elseif (keyn==GLOBAL_GetVar("Joy_Backward")) or (keyn==GLOBAL_GetVar("Joy_Backward_p2")) then
    SOUND_Play(snd_nav,-1);
     MenuSelection=math.fmod((MenuSelection+1),4);
   elseif (keyn==GLOBAL_GetVar("Joy_Jump")) or (keyn==GLOBAL_GetVar("Joy_Jump_p2")) then
     SOUND_Play(snd_sel,-1);
     if MenuSelection==0 then
       JumpStop=1;
       InScene="playing";
       LEVEL_SetTimeScale(1);
       PARTICLE_SetTimeScale(1);
     elseif MenuSelection==1 then
       LevelRestart();
     elseif MenuSelection==2 then
       --Options
       GLOBAL_SetVar("InGameOptions",1);
       MENU_Load("options");
       MENU_Activate();
       
     else
       QuitLevel();
     end;
   end;

 end;

end;

function OnKeyPressed(key,down,toggle)
 
 keyn=KEYB_GetKeyName(key);
 
 --print(keyn.."  "..key);
 if (keyn=="print-screen") and (toggle==1) then
   DEVICE_ScreenShot();
   return;
 end;

 if GLOBAL_GetVar("EditorMode")==3 then --Overview beenden
   if ((keyn=="Space") or (keyn=="Return")  or (keyn=="Escape")) and (toggle==1) then

        --print("Avg. FPS: "..(GameFrame/GameTime));
       GLOBAL_SetVar("InGame",0);
       GLOBAL_SetVar("Editor_LoadLevel","_selection");
       MENU_Load("editorstart");
       LEVEL_Deactivate();
       MENU_Activate();
   end;
   return;
 end;

if (InScene=="savegame") then
 return;
end;
  if GLOBAL_GetVar("InGameOptions")~=0 then
   if GLOBAL_GetVar("InGameOptions")==2 then
     GLOBAL_SetVar("InGameOptions",0);
   end;
   return;
  end;

 if (InScene=="playing") then
  if down==1 then
   if (keyn=="Escape") and (toggle==1) then
     if GLOBAL_GetVar("ProtectEscPressed")==0 then
        SOUND_Play(snd_sel,-1);
        InScene="pause"; 
        MenuSelection=0;
        LEVEL_SetTimeScale(0);
        PARTICLE_SetTimeScale(0);
     else
       GLOBAL_SetVar("ProtectEscPressed",0);
     end;
   elseif GLOBAL_GetVar("TutorialString")==""   then
     if key~=GLOBAL_GetVar("Key_Jump"..secondplayer) or JumpStop==0 then
       if key==GLOBAL_GetVar("Key_Special"..secondplayer) and toggle==1 and PLAYER_NumActors(player)>1 
              and TryActorChange()==true  then
         NextActor();
       else       
         if PLAYER_InCameraPan(player)==0 then
           if HasCopyCats==1 then
             if ACTOR_GetType(PLAYER_GetActiveActor(player))=="copycat" then 
              if key~=GLOBAL_GetVar("Key_Jump") and key~=GLOBAL_GetVar("Key_Forward") then
               for ball=0,ACTOR_NumActors()-1,1 do
                 if ACTOR_IsPlayer(ball) then
                   ACTOR_SendKey(ball,key,down,toggle);
                 end;
               end; 
              end;
             else
               ACTOR_SendKey(PLAYER_GetActiveActor(player),key,down,toggle); 
               for ball=0,ACTOR_NumActors()-1,1 do
                 if ACTOR_GetType(ball)=="copycat" then
                   ACTOR_SendKey(ball,key,down,toggle);  
                 end;
               end; 
             end;
           else
             ACTOR_SendKey(PLAYER_GetActiveActor(player),key,down,toggle); 
           end;
         end;
       end;

     end;
   end;

  elseif JumpStop==1 then
    if key==GLOBAL_GetVar("Key_Jump") then
     JumpStop=0;
    end;
  end;
 elseif (InScene=="scores") then
   if ((key==GLOBAL_GetVar("Key_Jump")) or (keyn=="Escape")) and (toggle==1) then
     InScene="finish"; -- Load the next level/restart
   end;
 elseif ((InScene=="pause") and (toggle==1)) then

   if keyn=="Escape" then
     SOUND_Play(snd_nav,-1);
     InScene="playing";
     LEVEL_SetTimeScale(1);
     PARTICLE_SetTimeScale(1);
   elseif (keyn=="Up") then
     SOUND_Play(snd_nav,-1);
     MenuSelection=MenuSelection-1;
     if MenuSelection<0 then 
         MenuSelection=3;
     end;
   elseif (keyn=="Down") then
    SOUND_Play(snd_nav,-1);
     MenuSelection=math.fmod((MenuSelection+1),4);
   elseif (keyn=="Space") or (keyn=="Return") or (key==GLOBAL_GetVar("Key_Jump")) then
     SOUND_Play(snd_sel,-1);
     if MenuSelection==0 then
       if key==GLOBAL_GetVar("Key_Jump") then
          JumpStop=1;
       end;
       InScene="playing";
       LEVEL_SetTimeScale(1);
       PARTICLE_SetTimeScale(1);
     elseif MenuSelection==1 then
       LevelRestart();
     elseif MenuSelection==2 then
       --Options
       GLOBAL_SetVar("InGameOptions",1);
       MENU_Load("options");
       MENU_Activate();
       
     else
       QuitLevel();
     end;
   end;

 end;
end;

function FlyIn()
 
 CAM_Attach(-1);
 CAM_FromBasis(FlyInBase);
 
 local dist=FlyInTime*500.0;
 local angl=-FlyInTime*2.0;
 
 --CAM_AxisRotate(VECTOR_New(1,0,0),0.02*angl);
 CAM_SetPos(VECTOR_Add(CAM_GetPos(),VECTOR_Scale(CAM_GetDir(),dist)));
 CAM_AxisRotate(CAM_GetDir(),angl);
 --print(FlyInTime.."  "..GLOBAL_GetElapsed());
 FlyInTime=FlyInTime-GLOBAL_GetElapsed();
 if FlyInTime<=0 then
  LEVEL_SetCollisionChecksActive(1);
  PARTICLE_SetTimeScale(1);
  if TutorialString=="" then
    InScene="playing";
    LEVEL_SetTimeScale(1);
  else 
    GLOBAL_SetVar("TutorialString",TutorialString);
    --print("Tutor");
    MENU_Load("tutorialhud");
    MENU_Activate();
    InScene="playing";
    end;
 end;
end;

function FlyAround()
  CAM_Attach(-1);
  CAM_AxisRotate(VECTOR_New(0,1,0),GLOBAL_GetElapsed()*1.5*math.sin(0.5*GLOBAL_GetTime()));
  CAM_AxisRotate(VECTOR_New(0,0,1),GLOBAL_GetElapsed()*0.63*math.sin(0.33*GLOBAL_GetTime()));
  CAM_AxisRotate(VECTOR_New(1,0,0),GLOBAL_GetElapsed()*1.37);
  CAM_SetPos(VECTOR_Add(LEVEL_GetCenter(),VECTOR_Scale(CAM_GetDir(),2.0*LEVEL_GetRadius())));
end;

function DarkBG()
 FONT_Load(TRANS_Str("font"));
 FONT_Begin();
 
 MATRIX_Push();
 TEXDEF_Render(darkbg,0);
 MATRIX_Pop();

 
end;

function ShowPauseHUD()
 DarkBG(); 
 FONT_Load(TRANS_Str("font"));
 FONT_Begin();
 

 MATERIAL_SetColor(COLOR_New(0.75,0.75,0.75,1));
 FONT_SetSize(0.05);
 FONT_SetAlign("center","center");
 FONT_Goto(0,0.25);
 FONT_TextOut(TRANS_Str("ingame:paused"));
 







 FONT_SetAlign("right","top");
 FONT_Goto(0.48,0.48);
 FONT_SetSize(0.03);
MATERIAL_SetColor(COLOR_New(0.35,0.35,0.35,1));
 
if GLOBAL_GetVar("CurrentLevel")~="_selection" then
 local clev=GLOBAL_GetVar("CurrentLevel"); 
 while string.find(clev,"/")~=nil do
  clev=string.sub(clev,string.find(clev,"/")+1);
 end;
 FONT_TextOut(clev); 
end;
 
 
 FONT_SetAlign("center","center");
 FONT_Goto(0,0.0);

 local quitstr;
 if IsNormalEpisodeLevel==true or GLOBAL_GetVar("StartUserLevel")~="" then 
    quitstr=TRANS_Str("ingame:quit");
 else 
    quitstr=TRANS_Str("ingame:quittoepisode");
 end;

 if MenuSelection==0 then
   MATERIAL_SetColor(COLOR_New(0.95,0.95,0.0,1));
   FONT_SetSize(0.04);
   FONT_TextOut(TRANS_Str("ingame:continue"));
   MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);
   FONT_Goto(0,-0.08);
   FONT_TextOut(TRANS_Str("ingame:restart"));
   FONT_Goto(0,-0.16);
   FONT_TextOut(TRANS_Str("main:options"));
   FONT_Goto(0,-0.24);
   FONT_TextOut(quitstr);
elseif MenuSelection==1 then
  MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);

   FONT_TextOut(TRANS_Str("ingame:continue"));
   MATERIAL_SetColor(COLOR_New(0.95,0.95,0.0,1));
   FONT_SetSize(0.04);
   FONT_Goto(0,-0.08);
   FONT_TextOut(TRANS_Str("ingame:restart"));
   FONT_Goto(0,-0.16);
   MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);
   FONT_TextOut(TRANS_Str("main:options"));
   FONT_Goto(0,-0.24);
   FONT_TextOut(quitstr);
 elseif MenuSelection==2 then
   MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);
   FONT_TextOut(TRANS_Str("ingame:continue"));
   FONT_Goto(0,-0.08);
   FONT_TextOut(TRANS_Str("ingame:restart"));
   MATERIAL_SetColor(COLOR_New(0.95,0.95,0.0,1));
   FONT_SetSize(0.04);
   FONT_Goto(0,-0.16);
   FONT_TextOut(TRANS_Str("main:options"));
   FONT_Goto(0,-0.24);
   MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);
   FONT_TextOut(quitstr);
 else 
  MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);
   FONT_TextOut(TRANS_Str("ingame:continue"));
   FONT_Goto(0,-0.08);
   FONT_TextOut(TRANS_Str("ingame:restart"));
   FONT_Goto(0,-0.16);
   FONT_TextOut(TRANS_Str("main:options"));
   FONT_Goto(0,-0.24);
   MATERIAL_SetColor(COLOR_New(0.95,0.95,0.0,1));
   FONT_SetSize(0.04);
   FONT_TextOut(quitstr);
 end

 FONT_End();
end;


function ShowScoreCalcHUD()
 if GLOBAL_GetVar("WarpZoneLogoTimer")>0 then
  WarpZoneHUD();  
 end;

 FONT_Begin();
 FONT_Load(TRANS_Str("font"));
 MATERIAL_SetColor(COLOR_New(1,1,1,1));
 
 FONT_SetSize(0.05);
 FONT_SetAlign("center","center");
 FONT_Goto(0,0.25);

 local showscorescalc=1;

 if Win>0 then
   MATERIAL_SetColor(COLOR_New(0,1,0,1));
   FONT_TextOut(TRANS_Str("ingame:levelcompleted"));
   if  GainScoreOnWin==0 then showscorescalc=0; end;
 else
  MATERIAL_SetColor(COLOR_New(1,0,0,1));
  FONT_TextOut(TRANS_StrD("ingame:lost:"..LostString,LostString));
   if  LooseScoreOnDie==0 then showscorescalc=0; end;
 end;

if showscorescalc==1 then
 FONT_SetSize(0.03);
 MATERIAL_SetColor(COLOR_New(0.75,0.75,0.75,1));
 FONT_Goto(-0.4,-0.0);
 FONT_SetAlign("left","center");
 if GLOBAL_GetVar("ExploreMode")==0 then
   if Win>0 or DeathPenaltyScore==0 then
     FONT_TextOut(TRANS_Str("ingame:scorestring"));
   else
     FONT_TextOut(TRANS_Str("ingame:deathscorestring"));
   end;

 else
   FONT_TextOut(TRANS_Str("ingame:explorescorestring"));
 
 end;


 local mScore=GLOBAL_GetVar("TotalScore");
 
 local Score;
 if ScoreIncreaseTimer>0 then
  ScoreIncreaseTimer=ScoreIncreaseTimer-GLOBAL_GetElapsed()/4.0;
  local t=ScoreIncreaseTimer/ScoreIncreaseTime;
  Score=t*OldScore+(1-t)*mScore;
 end;

 if ScoreIncreaseTimer<=0 then
   Score=mScore;
 end;
 
 Score=math.floor(Score);

 

 FONT_SetAlign("right","center");
 FONT_Goto(0.4,-0.0);

if GLOBAL_GetVar("ExploreMode")==0 then
 if Win>0 then 
   FONT_TextOut(""..OldScore.."\n"..PLAYER_GetVar(player,"Score").."\n"..Score);
 else
  if DeathPenaltyScore==0 then
    FONT_TextOut(""..OldScore.."\n-"..PLAYER_GetVar(player,"Score").."\n"..Score);
  else
    FONT_TextOut(""..OldScore.."\n-"..PLAYER_GetVar(player,"Score").."\n-"..DeathPenaltyScore.."\n"..Score);
  end;
  if GLOBAL_GetVar("SaveGameProtectScore")==1 then
   FONT_SetAlign("center","center");
   FONT_Goto(0.0,-0.15);
      FONT_TextOut(TRANS_Str("ingame:scoreprotected"));
  end;
 end;

else
 FONT_TextOut(PLAYER_GetVar(player,"Score"));

end;


if GLOBAL_GetVar("EditorMode")==0 and GLOBAL_GetVar("StartUserLevel")=="" and GLOBAL_GetVar("InsideTutorial")==0 then
 if SCORE_VarDefined(GLOBAL_GetVar("CurrentLevel"))~=0 and Win>0 then
   if SCORE_GetVar(GLOBAL_GetVar("CurrentLevel"))<PLAYER_GetVar(player,"Score") then
     FONT_SetSize(0.04);
     MATERIAL_SetColor(COLOR_New(0.7,0.7,0.1,1));
     FONT_Goto(0,-0.2);
     FONT_SetAlign("center","bottom");
     FONT_TextOut(TRANS_Str("ingame:newhighscore"));
   end;
 elseif Win>0 then
     FONT_SetSize(0.04);
     MATERIAL_SetColor(COLOR_New(0.7,0.7,0.1,1));
     FONT_Goto(0,-0.2);
     FONT_SetAlign("center","bottom");
     FONT_TextOut(TRANS_Str("ingame:newhighscore"));
 end;
end;

end;


 FONT_SetSize(0.025);
 MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
 FONT_Goto(0,-0.35);
 FONT_SetAlign("center","bottom");
 FONT_TextOut(TRANS_Str("ingame:jumptocontinue"));



 FONT_End();
end;





function WriteScores()
  INCLUDEABSOLUTE("/menudefs/include/writescores.inc");
end;


function EmitExitParticles(actor)
 local env=ACTOR_GetVar(actor,"PEnv");
 local pos=VECTOR_New(0,-ACTOR_GetRadius(actor)*1,0);
 local emi=PARTICLE_AddEmitter(part_exit,env);
 EMITTER_SetPos(emi,pos,1);
 EMITTER_SetGravity(emi,VECTOR_Scale(ACTOR_GetUp(actor),-100),0);
end;





function CheckWinAndLoose()


  if GLOBAL_GetVar("EditorMode")==3 then
   FlyAround();
   return;
  end;
  
  if (InScene=="scores") or (InScene=="pause") then
   FlyAround();
   return;
  end;

  if (InScene=="savegame") then
   FlyAround();
   if GLOBAL_GetVar("ProgressSaved")==1 then
     if NEXTLEVEL=="nextlevel" then
       NEXTLEVEL=GetNextLevel();
     end;
    
     LEVEL_Load(NEXTLEVEL);
   end;
   return;
  end;

  RefreshTwoPlayer();

  if InScene=="finish" then
   print("Avg. FPS: "..(GameFrame/GameTime));
   if Win>0 then
      if GLOBAL_GetVar("EditorMode")>=2 then
        LEVEL_Restart();
      else 
        ShowLoading=1;

        if GLOBAL_GetVar("StartUserLevel")=="" then
           local writescores=0;
           if SCORE_VarDefined(GLOBAL_GetVar("CurrentLevel"))~=0 then
             local ps=SCORE_GetVar(GLOBAL_GetVar("CurrentLevel"));
             if PLAYER_GetVar(player,"Score")>ps then
               SCORE_SetVar(GLOBAL_GetVar("CurrentLevel"),PLAYER_GetVar(player,"Score"));
               writescores=1;
             end;
           else
              SCORE_SetVar(GLOBAL_GetVar("CurrentLevel"),PLAYER_GetVar(player,"Score"));
              writescores=1;
           end 

           if writescores==1 then
              WriteScores();
           end;
           
           ThisLevelName=GLOBAL_GetVar("CurrentLevel");
            if NEXTLEVEL=="nextlevel" then
                NEXTLEVEL=GetNextLevel();
             end;
           GLOBAL_SetVar("CurrentLevel",NEXTLEVEL);
           GLOBAL_SetVar("CurrentLevelNum",GLOBAL_GetVar("CurrentLevelNum")+1);

          if GLOBAL_GetVar("ExploreMode")==0 then
           if LEVEL_MAY_SAVE==1 then
             MENU_Load("dosavegame");
             MENU_Activate();
             GLOBAL_SetVar("ProgressSaved",0);
             InScene="savegame";
           else
             GLOBAL_SetVar("SaveGameProtectScore",0);
             LEVEL_Load(NEXTLEVEL);
           end;
          else
             GLOBAL_SetVar("ProgressSaved",0);
             MENU_Load("explorenextlevel");
             MENU_Activate();
             InScene="savegame";
          end


        else
           GLOBAL_SetVar("StartUserLevel",NEXTLEVEL);
           if NEXTLEVEL=="win" then
             GLOBAL_SetVar("SaveGameProtectScore",0);
             LEVEL_Load("win");
           else    
             GLOBAL_SetVar("SaveGameProtectScore",0);
             LEVEL_LoadUserLevel(NEXTLEVEL);
           end;
        end;
        
      end;    
 
       
   else
    if (GLOBAL_GetVar("TotalScore")<0) and (GLOBAL_GetVar("EditorMode")~=2) and (GLOBAL_GetVar("InsideTutorial")==0) and GLOBAL_GetVar("ExploreMode")==0 then 
     SOUND_StopChannel(-1);
     GLOBAL_SetVar("SaveGameProtectScore",0);
     LEVEL_Load("gameover");
    else 
     if GLOBAL_GetVar("InsideTutorial")==1 and GLOBAL_GetVar("TotalScore")<0 then
      GLOBAL_SetVar("TotalScore",0)
     end; 
     SOUND_StopChannel(-1);
     LEVEL_Restart();
    end; 
   end;
   return;
  end;

  if InScene=="start" then
    FlyIn();
    return;
  end;

  CAM_Attach(PLAYER_GetActiveActor(player));




  --Decrement the time, dont do, when on timestop:
   local decrtime=1;
   local bs=ACTOR_GetOnSide(PLAYER_GetActiveActor(player));
   if bs>-1 then
    local str=SIDE_GetType(bs);

    if str=="timestop" then
     decrtime=0;
    end;
   end;
  if decrtime==1 then
    local timescale=1;
    if ACTOR_GetVar(PLAYER_GetActiveActor(player),"Lethargy")>0 then  timescale=LethargoTimeScale ; end;
    PLAYER_SetVar(player,"TimeLeft",PLAYER_GetVar(player,"TimeLeft")-LEVEL_GetElapsed()*timescale);
  end;

   local totimer=GLOBAL_GetVar("TextOutTimer");
   if totimer>0 then
     GLOBAL_SetVar("TextOutTimer",totimer-LEVEL_GetElapsed());
   end;


    GameTime=GameTime+GLOBAL_GetElapsed();
  GameFrame=GameFrame+1;



 


  if PLAYER_GetVar(player,"TimeLeft")<=0 and GLOBAL_GetVar("ExploreMode")==0 then
    ACTOR_SetVar(PLAYER_GetActiveActor(player),"KilledString","Time out!");
    SOUND_SetPostEffect("",0,0,0);
   
    LEVEL_SetTimeScale(0);
    ACTOR_SetVar(PLAYER_GetActiveActor(player),"IsAlive",-1.01);
  end;

 

 local nballs=PLAYER_NumActors(player);
 local playerkeys=PLAYER_GetVar(player,"Keys");
 local balls_in_exit=0;      

 for ballc=0,nballs-1,1 do
  local balli=PLAYER_GetActor(player,ballc);

  if playerkeys>=numkeys then
   local bs=ACTOR_GetOnSide(balli);
    if bs>-1 then
      local str=SIDE_GetType(bs);
      if str=="exit1" and ACTOR_GetVar(balli,"IsAlive")==1 then 
        NEXTLEVEL=SIDE_GetVar(bs,"Next_Level");
        ACTOR_SetVar(balli,"KilledString","Exit");
        ACTOR_SetVar(balli,"IsAlive",0);
        SOUND_Play(snd_exit,-1);
         if part_exit~=-1 then EmitExitParticles(balli); end;
      end;
    end;
   end
 

   if ACTOR_GetVar(balli,"IsAlive")<-1.0 then
    if ACTOR_GetVar(balli,"KilledString")=="Exit" then
     balls_in_exit=balls_in_exit+1;
    else
     Win=-1;
     LostString=ACTOR_GetVar(balli,"KilledString");
     OldScore=GLOBAL_GetVar("TotalScore");
     if LooseScoreOnDie==1 and GLOBAL_GetVar("SaveGameProtectScore")~=1 then GLOBAL_SetVar("TotalScore",OldScore-PLAYER_GetVar(player,"Score")-DeathPenaltyScore); end
    end;
   end;
  end;

 --print(balls_in_exit);


  --Test if all actors are in the exit
   if balls_in_exit==nballs then
        Win=1;
        OldScore=GLOBAL_GetVar("TotalScore");
        if GainScoreOnWin==1 then GLOBAL_SetVar("TotalScore",OldScore+PLAYER_GetVar(player,"Score"));  end;
        LEVEL_SetTimeScale(0); 
        PLAYER_SetVar(player,"Win",1);
   end;

  if Win~=0 then
   InScene="scores";
   ScoreIncreaseTimer=ScoreIncreaseTime;
  end;
end

function AddBall(typ,sbp,ss,sr)
  local act=ACTOR_New(typ);
  local sb=BLOCK_AtPos(sbp);
  local startside=sb*6+ss;
  ACTOR_SetStart(act,startside,sr);
  PLAYER_AddActor(act);
end;




EpisodeLevelCount=0;
EpisodeLevelList={};
ThisLevelName="";

function AddSingleLevel(ln)
        EpisodeLevelCount=EpisodeLevelCount+1;
        EpisodeLevelList[EpisodeLevelCount]=ln;
end;

function AddEpisodePart(fold,tn)
   local numulvl=FILESYS_StartListDirectory("/levels/"..fold.."/",true,false,false,false,".*\\.ldef"); 
   for index = 0, numulvl-1, 1 do
        local f=FILESYS_GetListDirectoryEntry(index);
        f=string.sub(f,1,string.len(f)-5);
        AddSingleLevel(fold.."/"..f);
   end;
end;



function GetNextLevel()
 if ThisLevelName=="" then return NEXTLEVEL; end;
 EpisodeLevelCount=0;
 EpisodeLevelList={};
 INCLUDEABSOLUTE("/levels/"..GLOBAL_GetVar("CurrentEpisode")..".epi");
 for index=1,EpisodeLevelCount,1 do
   if EpisodeLevelList[index]==ThisLevelName then
    local resind=index+1;
     if resind>EpisodeLevelCount then 
          return NEXTLEVEL; 
     else 
       GLOBAL_SetVar("LastLevelIndexInEpisode",index);
       return EpisodeLevelList[resind]; 
     end;
   end;
 end;
 IsNormalEpisodeLevel=false;
 if GLOBAL_GetVar("LastLevelIndexInEpisode")>0 then
  ThisLevelName=EpisodeLevelList[GLOBAL_GetVar("LastLevelIndexInEpisode")];
  return GetNextLevel();
 end;
 return NEXTLEVEL;
end;





function InitLevel()
 ThisLevelName=GLOBAL_GetVar("CurrentLevel");
 IsNormalEpisodeLevel=true;
 GetNextLevel();


 LEVEL_SetCollisionChecksActive(0);
 print("Level-Data loaded, loading the rest");
 
 EFFECT_Load(GLOBAL_GetVar("PostEffect"));
 
 player=0;
 PLAYER_SetCameraSpeed(player,3.0); 

 GLOBAL_SetVar("ActivePlayer",player);

 PLAYER_SetVar(player,"Keys",0);
 PLAYER_SetVar(player,"TimeLeft",GLOBAL_GetVar("StartTime"));
 PLAYER_SetVar(player,"MaxTime",GLOBAL_GetVar("MaxTime"));
 PLAYER_SetVar(player,"Score",0);
 
 IncreaseScore=0;
 ScoreIncreaseTimer=0;
 


if InitActors~=nil then
 InitActors();
else
 AddBall(BallType,startblockpos,startside,startrotation); --old version
end;

HasCopyCats=0;
for ball=0,ACTOR_NumActors()-1,1 do 
 if ACTOR_GetType(ball)=="copycat" then
   HasCopyCats=1;
 end;
end;

act=PLAYER_GetActiveActor(player);
 
 
 CAM_Attach(act);
 FlyInBase=BASIS_New();
 BASIS_ChaseCam(FlyInBase,act);


 FONT_Load(TRANS_Str("font"));
 numkeys=LEVEL_NumItems("key");
 LEVEL_SetTimeScale(0);
  PARTICLE_SetTimeScale(1);

if GLOBAL_GetVar("EditorMode")~=3 then
 SOUND_Play(snd_start,-1);
end;
 
key_missing=TEXTURE_Load("key_missing");
 key_collected=TEXTURE_Load("key_collected");
 
 darkbg=TEXDEF_Load("darkbg");
 screenflash=TEXDEF_Load("screenflash");

 if GLOBAL_GetVar("MusicTrack")~=GLOBAL_GetVar("LevelMusic") then
     GLOBAL_SetVar("MusicTrack",GLOBAL_GetVar("LevelMusic"));
     local mus=SOUND_LoadMusic(GLOBAL_GetVar("MusicTrack"));
     SOUND_PlayMusic(mus);
 end;

 GLOBAL_SetVar("InGame",1);
 GLOBAL_SetVar("InGameOptions",0);

 --Check for a autoexec.inc in the level directory
 local dirname="/levels/";
 if GLOBAL_GetVar("StartUserLevel")~="" then dirname="/user"..dirname; end
 local lvln=GLOBAL_GetVar("CurrentLevel");
 local autoexec="";
  local testautoexec=dirname.."autoexec.inc";
  if FILESYS_FileExists(testautoexec)==1 then autoexec=testautoexec; end;
 while string.find(lvln,"/")~=nil do
  dirname=dirname..string.sub(lvln,1,string.find(lvln,"/"));
  lvln=string.sub(lvln,string.find(lvln,"/")+1);
  testautoexec=dirname.."autoexec.inc";
  if FILESYS_FileExists(testautoexec)==1 then autoexec=testautoexec; end;
 end;
 if autoexec~="" then
   print("Executing "..autoexec);
   INCLUDEABSOLUTE(autoexec);
 end;
end 



function DrawKey(x,y,color)
MATRIX_Push();
  MATRIX_Translate(VECTOR_New(x,y,-10));
  --MATRIX_AxisRotate(VECTOR_New(0,1,0),45*math.cos(3*GLOBAL_GetTime()))
  MATRIX_Scale(VECTOR_New(KeyIconAspectRatio*KeyIconSize,640/480*KeyIconSize,KeyIconSize));

  if color==0 then
    TEXTURE_Activate(key_missing,0);   
  else
    TEXTURE_Activate(key_collected,0);
  end;

  glBegin("GL_QUADS");
    glTexCoord2f(0,1); glVertex3f(-0.5,-0.5,0);
    glTexCoord2f(1,1); glVertex3f(0.5,-0.5,0);
    glTexCoord2f(1,0); glVertex3f(0.5,0.5,0);
    glTexCoord2f(0,0); glVertex3f(-0.5,0.5,0);
  glEnd();
  --MDLDEF_Render(keymdl); 
 MATRIX_Pop();
end;



function DrawHourglass(x,y,rel)
MATRIX_Push();
  MATRIX_Translate(VECTOR_New(x,y,-10));
  MATRIX_Scale(VECTOR_New(0.08,0.08*640/480,0.08));

  GLOBAL_SetVar("HourglassHeight",rel);
  MDLDEF_Render(mdl_hourglass); 
 MATRIX_Pop();
end;




function WarpZoneHUD()

   if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;

 FONT_Begin();
 FONT_Load(TRANS_Str("font"));
 MATERIAL_SetColor(COLOR_New(1,1,1,1));
 FONT_SetSize(0.025);


 local t=GLOBAL_GetVar("WarpZoneLogoTimer");
  ACTOR_SetVar(PLAYER_GetActiveActor(player),"WarpTunnelCounter",t);
 local pulse=0;
  local st=t-1.25; if st<0 then st=0; end; if st>1 then pulse=st-1; st=1; end;
  pulse=0.02*math.sin(pulse*20)*1.0/(1.0+4*pulse*pulse);
  


  plr=PLAYER_GetActiveActor(player);
 local lp=ACTOR_GetLookPos(plr);

if st==0 then
  if lp>0 then
    lp=lp-GLOBAL_GetElapsed()*2;
    if lp<0 then lp=0; end;
    ACTOR_SetLookPos(plr,lp);   
  elseif lp<0 then
    lp=lp+GLOBAL_GetElapsed()*2;
    if lp>0 then lp=0; end;
    ACTOR_SetLookPos(plr,lp);
  end;
else
   lp=lp-GLOBAL_GetElapsed()*2;
    if lp<-1 then lp=-1; end;
    ACTOR_SetLookPos(plr,lp);
   ACTOR_SetCamZRotation(plr,(st-pulse)*5,0);

BLEND_Function(771,770);
  MATRIX_Push();
local bc=1-(t-1.25+pulse); if bc<0 then bc=0 ; end;
 MATERIAL_SetColor(COLOR_New(1.0,1,1,bc)); 
  MATRIX_Translate(VECTOR_New(0,0,-12));
MATRIX_AxisRotate(VECTOR_New(0,0,1),2*120*t);
  MATRIX_ScaleUniform(1.75/(1.1-bc)+0.1*math.sin(6*t));
  TEXTURE_Activate(GLOBAL_GetVar("WarpZoneTexture"),0);   
 glBegin("GL_QUADS");
    glTexCoord2f(0,1); glVertex3f(-0.5,-0.5,0);
    glTexCoord2f(1,1); glVertex3f(0.5,-0.5,0);
    glTexCoord2f(1,0); glVertex3f(0.5,0.5,0);
    glTexCoord2f(0,0); glVertex3f(-0.5,0.5,0);
  glEnd();
 MATRIX_Pop();
   MATERIAL_SetColor(COLOR_New(1.0,1,1,1)); 
BLEND_Function(770,771);
end;

 MATRIX_Push();
  MATRIX_Translate(VECTOR_New(0,0,-10));
  MATRIX_AxisRotate(VECTOR_New(0,0,1),-2*530*st);
st=st+pulse;
  MATRIX_Scale(VECTOR_New(0.4*2*st,0.2*2*st,0.2*2*st));
  TEXTURE_Activate(GLOBAL_GetVar("WarpZoneLogo"),0);   
  glBegin("GL_QUADS");
    glTexCoord2f(0,1); glVertex3f(-0.5,-0.5,0);
    glTexCoord2f(1,1); glVertex3f(0.5,-0.5,0);
    glTexCoord2f(1,0); glVertex3f(0.5,0.5,0);
    glTexCoord2f(0,0); glVertex3f(-0.5,0.5,0);
  glEnd();
  MATRIX_Pop(); 
 

  GLOBAL_SetVar("WarpZoneLogoTimer",t+GLOBAL_GetElapsed());
  if t>3.5 then
     NEXTLEVEL=GLOBAL_GetVar("WarpTargetLevel");
     ACTOR_SetVar(plr,"KilledString","Exit");
     ACTOR_SetVar(plr,"IsAlive",0);
     if GainScoreOnWin==1 and Win==0 then GLOBAL_SetVar("TotalScore",OldScore+PLAYER_GetVar(player,"Score"));   end;
     Win=1;
     PLAYER_SetVar(player,"Win",1);
  end;
end;


function ScreenFlash(col)

MATERIAL_SetMultiply(col);
MATERIAL_SetColor(col);
MATERIAL_Invalidate();
 FONT_Load(TRANS_Str("font"));
 FONT_Begin();
 
 MATRIX_Push();
 TEXDEF_Render(screenflash,0);
 MATRIX_Pop();
MATERIAL_SetMultiply(COLOR_New(1,1,1,1));
MATERIAL_Invalidate()

end;


function DrawHUD()
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;

  if GLOBAL_GetVar("InGameOptions")==1 then
   return;
  end;


if (InScene=="savegame") then
 return;
end;

  LIGHT_Disable();
 if InScene=="scores" then
   ShowScoreCalcHUD();
   return;
 end;

 if InScene=="pause" then
   ShowPauseHUD();
   return;
 end;


 if (InScene=="finish" or InScene=="retire") and ShowLoading==1 then
  if GLOBAL_GetVar("WarpZoneLogoTimer")>=0 then
    WarpZoneHUD();
  end;

  FONT_Begin();
  FONT_Load(TRANS_Str("font"));
  FONT_SetAlign("center","center");
  FONT_Goto(0,0.25);
  FONT_SetSize(0.05);
  MATERIAL_SetColor(COLOR_New(0.0,0.95,0.05,1));
  FONT_TextOut("Loading");
  FONT_End();

 end;

 if InScene~="playing" and InScene~="WarpZone" then
  return;
 end;

local tt=ACTOR_GetVar(PLAYER_GetActiveActor(player),"TeleTime");
if tt~=0 then
  local fv=math.sin(tt*math.pi);
  fv=math.pow(fv,10);


  local col;
  local tc=ACTOR_GetVar(PLAYER_GetActiveActor(player),"TeleColor");
  if tc>=0 then 
     col=GetCuboColor(tc,0.5,1,fv); 
  else
     col=COLOR_New(0.0,0.0,0.0,fv); --Teleport Item Color
  end;

  ScreenFlash(col);
end;

 FONT_Begin();
 FONT_Load(TRANS_Str("font"));
 MATERIAL_SetColor(COLOR_New(1,1,1,1));
 FONT_SetSize(0.025);

if GLOBAL_GetVar("ShowFPS")==1 then
 --Get FPS
 local FPS=GLOBAL_GetFPS();
 FONT_SetAlign("left","top");
 FONT_Goto(-0.5,0.5);
 FONT_TextOut("FPS: "..FPS);
end;

 
 local mScore=PLAYER_GetVar(player,"Score");
 if DestScore~=mScore then
   IncreaseScore=DestScore;
   DestScore=mScore;
   ScoreIncreaseTimer=ScoreIncreaseTime;
 end;

 local Score;
 if ScoreIncreaseTimer>0 then
  ScoreIncreaseTimer=ScoreIncreaseTimer-GLOBAL_GetElapsed();
  local t=ScoreIncreaseTimer/ScoreIncreaseTime;
  Score=t*IncreaseScore+(1-t)*DestScore;
 end;

 if ScoreIncreaseTimer<=0 then
   Score=mScore;
 end;
 
 Score=math.floor(Score);

 FONT_SetAlign("center","bottom");
 FONT_SetSize(0.05);
 FONT_Goto(0.0,-0.45);
 MATERIAL_SetColor(COLOR_New(1,1,0,1));
 if ScoresVisible==1 then FONT_TextOut(Score); end

if GLOBAL_GetVar("ExploreMode")==0 then
 local Score=GLOBAL_GetVar("TotalScore");
 FONT_Goto(0.0,-0.50);
 MATERIAL_SetColor(COLOR_New(0.7,0.7,0.7,1));
 if ScoresVisible==1 then FONT_TextOut(Score); end;


 --Out the remaining TimeLeft
 
 local timeleft=math.ceil(PLAYER_GetVar(player,"TimeLeft"));


 
 FONT_SetAlign("center","top");
 FONT_Goto(0.0,0.5);
 FONT_SetSize(0.05);

 local ontimestop=0;
 local bs=ACTOR_GetOnSide(PLAYER_GetActiveActor(player));
   if bs>-1 then
    local str=SIDE_GetType(bs);
    if str=="timestop" then
     ontimestop=1;
    end;
   end;

 if ontimestop==1 then 
   MATERIAL_SetColor(COLOR_New(0,0.3,0.3,1)); 
 elseif timeleft>20 then
   MATERIAL_SetColor(COLOR_New(0,1,0,1));
 elseif timeleft>10 then
   local factor=(timeleft-10.0)/10.0;
   MATERIAL_SetColor(COLOR_New(1.0-factor,factor,0,1));
 else 
   local timescale=1;
   if ACTOR_GetVar(PLAYER_GetActiveActor(player),"Lethargy")>0 then
     timescale=LethargoTimeScale;
   end;
   local oldtime=math.ceil(PLAYER_GetVar(player,"TimeLeft")+LEVEL_GetElapsed()*timescale);
   if oldtime~=timeleft then
     local chan=SOUND_Play(snd_clock,-1);
   end;
   MATERIAL_SetColor(COLOR_New(1,0,0,1));
 end;
 FONT_TextOut(timeleft);
end;

-- The TextOutString

  local totimer=GLOBAL_GetVar("TextOutTimer");
  if totimer>0 then
     FONT_SetAlign("center","top");
     FONT_Goto(0.0,0.4);
     FONT_SetSize(0.03); 
     local alpha=1;
     if totimer<0.1 then
       alpha=10*totimer;
     end;
      MATERIAL_SetColor(COLOR_New(1.0*alpha,1.0*alpha,1.0*alpha,1));
     FONT_TextOut(GLOBAL_GetVar("TextOutStringInGame")); 
  end;


 local playerkeys=PLAYER_GetVar(player,"Keys");
      

 BLEND_Function(770,771);
 MATERIAL_SetColor(COLOR_New(1.0,1,1,1)); 
 local offsx=-0.5+KeyIconOffsetX;
 local offsy=-0.5+KeyIconOffsetY+KeyIconSize*0.5;

 for i=0,numkeys-1,1 do
   if playerkeys>i then
     DrawKey(offsx,offsy,1);
   else 
     DrawKey(offsx,offsy,0);
   end;
   offsx=offsx+KeyIconDistanceX;
  if math.fmod(i+1,KeyIconMaxPerRow)==0 then
     offsy=offsy+KeyIconDistanceY;
     offsx=-0.5+KeyIconOffsetX;
   end;
 end;

 
 if GLOBAL_GetVar("WarpZoneLogoTimer")>=0 then
 if InScene~="WarpZone" then OldScore=GLOBAL_GetVar("TotalScore"); end;
 InScene="WarpZone";
 LEVEL_SetTimeScale(0);
 WarpZoneHUD();
 end;

 BLEND_Deactivate();
 FONT_End();
  LIGHT_Enable();
end;
