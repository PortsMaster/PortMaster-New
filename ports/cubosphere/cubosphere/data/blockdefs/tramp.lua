USING("PARTICLE");

local JumpType="far";
--Can be switched to "high" by uncommenting
--local JumpType="high";
local tramp_sound_dist=15;

border=-1;
center=-1;
airemitter=-1;

snd_boing=-1;

function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 end;
 return default;
end;


function Precache()
  center=TEXDEF_Load("airvent");
  snd_boing=SOUND_Load("ventilator");
if GLOBAL_GetVar("UseParticles")~=0 then
  airemitter=PARTICLE_LoadDef("airvent");
end;
end

function ActsOnActor(actor)
  if ACTOR_IsPlayer(actor)==1 then
   return 1;
  end;
  local inter=ACTOR_GetVar(actor,"Interaction");

  if string.find(inter, "t") then
    return 1;
  else
    return 0;
  end;
end;


function MayMove(side,actor,dir)
if (ActsOnActor(actor)==1) then
 if (dir=="left") then return 0;
 elseif (dir=="right") then return 0;
 elseif (dir=="jumpup") then 
     ACTOR_CallMove(actor,"forward");
     ACTOR_CallMove(actor,JumpType.."jump");
   return 0;
 elseif (dir=="jumpahead") then 
     ACTOR_CallMove(actor,"forward");
     ACTOR_CallMove(actor,JumpType.."jump");
   return 0;
 else return 1;
 end;
else
 return 1;
end;
end;



function SideConstructor(side)
  SIDE_SetVar(side,"soundtimer",0);
if GLOBAL_GetVar("UseParticles")~=0 then
  local penv=PARTICLE_CreateEnvOnSide(side);
  SIDE_SetVar(side,"PEnv",penv);
  local emitter=PARTICLE_AddEmitter(airemitter,penv);
  --EMITTER_SetPos(emitter,VECTOR_New(0,0.25*GLOBAL_GetScale(),0),1);
  SIDE_SetVar(side,"SteamEmitter",emitter);
  EMITTER_SetVar(emitter,"Side",side);
  EMITTER_SetVar(emitter,"Activity",0);
end;
end;

steam_mindist=4.8;
steam_maxdist=1.5;

function SideThink(side)
  SIDE_SetVar(side,"soundtimer",SIDE_GetVar(side,"soundtimer")-LEVEL_GetElapsed());

if GLOBAL_GetVar("UseParticles")~=0 then
  local ap=GLOBAL_GetVar("ActivePlayer");
  if GLOBAL_GetVar("EditorMode")~=1 and ap>=0 then
  ap=PLAYER_GetActiveActor(ap);
  local dist=VECTOR_Length(VECTOR_Sub(ACTOR_GetPos(ap),SIDE_GetMidpoint(side)))/GLOBAL_GetScale();
   
   
   local emi=SIDE_GetVar(side,"SteamEmitter");
   if dist>steam_mindist then
     EMITTER_SetVar(emi,"Activity",0);
     EMITTER_SetColorMultiply(emi,COLOR_New(1,1,1,0));
   elseif dist<steam_maxdist then
     EMITTER_SetVar(emi,"Activity",1);
     EMITTER_SetColorMultiply(emi,COLOR_New(1,1,1,1));
   else 
    local a=(steam_mindist-dist)/(steam_mindist-steam_maxdist);
    EMITTER_SetVar(emi,"Activity",a);
    a=3*a; if a>1 then a=1; end;
    EMITTER_SetColorMultiply(emi,COLOR_New(1,1,1,a));
   end;
  end; 
end;
end;

function PlayActorSound(actor,side)
 if GLOBAL_GetVar("ActivePlayer")==actor then
   SOUND_Play(snd_boing,-1);
   return;
 end;
 local dist=VECTOR_Length(VECTOR_Sub(CAM_GetPos(),SIDE_GetMidpoint(side)));
 if dist>tramp_sound_dist*GLOBAL_GetScale() then
  return;
 end;
 local r=SOUND_Play(snd_boing,-1);
 SOUND_Set3dFromCam(r,SIDE_GetMidpoint(side),tramp_sound_dist*GLOBAL_GetScale());
end;

function Event_OnSide(side,actor)
  if (ActsOnActor(actor)==1) then
     --Perform a distance check:
     local mp=SIDE_GetMidpoint(side);
     local pp=ACTOR_GetPos(actor);
     local diff=VECTOR_Sub(mp,pp);
     local l=VECTOR_Length(diff);
     if l<1.1*(ACTOR_GetRadius(actor)+ACTOR_GetGroundOffset(actor)) then
      ACTOR_CallMove(actor,"forward");
      ACTOR_CallMove(actor,JumpType.."jump");
      if SIDE_GetVar(side,"soundtimer")<=0 then
       PlayActorSound(actor,side);
      end;
       SIDE_SetVar(side,"soundtimer",0.2);
     end;
  end;
end;


function RenderSide(side)
  TEXDEF_Render(center,side);


end
