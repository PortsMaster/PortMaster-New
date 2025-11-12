USING("PARTICLE");


TransparentBall=0;

secondplayer="";


BallScale=1;
ModelScale=1;
ShadowScale=1;

part_heatclouds=-1
part_sandclouds=-1
part_exit=-1
part_rebounce=-1

rotspeedmultiply=1;
LethargoTimeScale=0.5;
LethargoTime=4;
rotatestoptime=0.1;

mdl=-1;
stex=-1;

snd_groundhit=-1;
snd_firehit=-1;
snd_iceslide=-1;
snd_magnethum=-1;
snd_captured=-1;
snd_cam_pan=-1;
snd_rebounce=-1;
snd_ballcollide=-1;

iceslide_playing=-1; --means no
onside_sound="";
playing_fire=0;
playing_hum=0;

WobbleinRender=0;

wobbleA=0.05;


recool_speed=0.5;
reheat_speed=1;
fire_temp_hit_increment=0.42; --Temperature to be added when landing on a fire block


function GetMagnetStrength(side)
 local ts=SIDE_GetVar(side,"TwoState");
 local dist=SIDE_GetVar(side,"Distance");
 local ss=SIDE_GetVar(side,"StartStrength");
 if dist==0 then
  return math.fmod(ss,2);
 elseif ts==0 then
   if dist>0 then
     return math.fmod(ss,3);
   else
     return 2-math.fmod(ss,3);
   end; 
 else 
   if dist>0 then
     return 1+math.fmod(ss,2);
   else
     return 2*math.fmod(ss,2);
   end; 
 end;
end;



function LoadBall(name)
  mdl=MDLDEF_Load(name);
  stex=TEXDEF_Load("pshadow1");
  snd_groundhit=SOUND_Load("groundhit");
  snd_iceslide=SOUND_Load("iceslide");
  snd_fire=SOUND_Load("fire");
  snd_firehit=SOUND_Load("firehit");
  snd_sandhit=SOUND_Load("sandhit");
  snd_captured=SOUND_Load("captured");
  snd_magnethum=SOUND_Load("magnet_hum");
  snd_cam_pan=SOUND_Load("camerapan");
  snd_rebounce=SOUND_Load("combojump");
  snd_ballcollide=SOUND_Load("ballcollide");
  if GLOBAL_GetVar("UseParticles")~=0 then
    part_heatclouds=PARTICLE_LoadDef("heatcloud");
    part_sandclouds=PARTICLE_LoadDef("sand");
    part_rebounce=PARTICLE_LoadDef("rebounce");
  end;
end;



function OnKeyPressed(actor,key,down,toggle)
  --keyn=KEYB_GetKeyName(key);

  if ACTOR_GetVar(actor,"IsAlive")~=1 then
    return;
  end;
 -- if actor~=PLAYER_GetActiveActor(GLOBAL_GetVar("ActivePlayer")) then
 --   return;
 -- end;
  
  if key==GLOBAL_GetVar("Key_Forward"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:forward"),down);
   elseif key==GLOBAL_GetVar("Key_Left"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:left"),down);
   elseif key==GLOBAL_GetVar("Key_Right"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:right"),down);
   elseif key==GLOBAL_GetVar("Key_LookUp"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:lookup"),down);
   elseif key==GLOBAL_GetVar("Key_LookDown"..secondplayer) then    
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:lookdown"),down);
   elseif key==GLOBAL_GetVar("Key_Jump"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:jump"),down);
   elseif key==GLOBAL_GetVar("Key_Special"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:special"),down);
  end;


end; 

function MakeJoystickString(stick,button,dir)
	local joystick = require "Joystick"
	local joy = joystick.Get(stick) 
	return (joy:GetGUID()..","..dir..","..button);
end;


function OnJoyButton(actor,stick,button,dir,down,toggle)
 local key=MakeJoystickString(stick,button,dir);
 if ACTOR_GetVar(actor,"IsAlive")~=1 then
    return;
  end;
 -- if actor~=GLOBAL_GetVar("ActivePlayer") then
 --   return;
 -- end;
  
 if key==GLOBAL_GetVar("Joy_Forward"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:forward"),down);
   elseif key==GLOBAL_GetVar("Joy_Left"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:left"),down);
   elseif key==GLOBAL_GetVar("Joy_Right"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:right"),down);
   elseif key==GLOBAL_GetVar("Joy_LookUp"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:lookup"),down);
   elseif key==GLOBAL_GetVar("Joy_LookDown"..secondplayer) then    
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:lookdown"),down);
   elseif key==GLOBAL_GetVar("Joy_Jump"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:jump"),down);
  elseif key==GLOBAL_GetVar("Joy_Special"..secondplayer) then
     ACTOR_SetVar(actor,ACTOR_GetVar(actor,"key:special"),down);
  end;


end;



function SideBlockedByOtherBall(actor,side)
 for a=0,ACTOR_NumActors()-1 do
  if ACTOR_IsPlayer(a)==1 and actor~=a then
    if ACTOR_GetOnSide(a)==side and ACTOR_GetVar(a,"IsAlive")==1 then return 1; end;
  end;
 end;
 return 0;
end;


function BlockedByOtherBalls(actor)
 local side=ACTOR_GetOnSide(actor);
 if side==-1 then return 0; end;
 --Now get the adjacient side. This could be: In front facing towards the ball, planar in front of the ball or down the edge
 local pos=ACTOR_GetPos(actor);
 local dir=ACTOR_GetDir(actor);
 local tr=LEVEL_TraceLine(pos,dir);
 if tr["hit"]~=0 and tr["dist"]<1.1*GLOBAL_GetScale() then
  return SideBlockedByOtherBall(actor,tr["side"]);
 end;
 --Get the block planar in front
 local up=ACTOR_GetUp(actor);
 local bp=VECTOR_Scale(VECTOR_Sub(dir,up),GLOBAL_GetScale()*1.5);
 local nblock=BLOCK_AtPos(VECTOR_Add(pos,bp));
 if nblock~=-1 then
   return SideBlockedByOtherBall(actor,6*nblock+(side%6));
 end;
 --Ok, this should be down the edge
 local tside=-1;
 local block=math.floor(side/6);
 for i=0,5 do 
   local dot=VECTOR_Dot(dir,SIDE_GetNormal(6*block+i));
   if dot>0.8 then tside=i; break; end;
 end;
 if tside~=-1 then
   return SideBlockedByOtherBall(actor,(6*block+tside));
 end;
 return 0;
end;


function StopInvulMusic()
    if GLOBAL_GetVar("MusicTrack")~=GLOBAL_GetVar("LevelMusic") then
        GLOBAL_SetVar("MusicTrack",GLOBAL_GetVar("LevelMusic"));
        local mus=SOUND_LoadMusic(GLOBAL_GetVar("MusicTrack")); --Should be already precached
        SOUND_PlayMusic(mus);
    end;
end;

function LethargoEffect(actor)
  local lt=ACTOR_GetVar(actor,"Lethargy");
  local a=ACTOR_GetVar(actor,"LethargyAmplitude");
  local lti=ACTOR_GetVar(actor,"LethargyTimer");
 
  local rt=lti/LethargoTime*math.pi;
  local distortionbase=ACTOR_GetVar(actor,"DistortionBasis");
  BASIS_Set(distortionbase,VECTOR_New(1+a*0.3*math.cos(4*rt),-a*0.3*math.sin(5.34*rt+4),a*0.3*math.cos(4*rt)),VECTOR_New(a*0.33*math.cos(5*rt+3),1-a*0.2*math.cos(3.6*rt+43.3),-a*0.2*math.sin(3*rt+435.3)),VECTOR_New(-a*0.1*math.sin(2.3*rt-0.344435),a*0.1*math.cos(0.345*rt+0.344435),1+a*0.25*math.sin(rt*3)),VECTOR_New(0,0,0));
  CAM_SetDistortionBase(distortionbase);
  lt=lt-LEVEL_GetElapsed();
  ACTOR_SetVar(actor,"Lethargy",lt);
  ACTOR_SetVar(actor,"LethargyTimer",lti+LEVEL_GetElapsed());
  
  if lt>0.5 and a<=1 then 
    ACTOR_SetTimeMultiplicator(actor,LethargoTimeScale);
    a=a+2*LEVEL_GetElapsed();
    if a>1 then a=1 ; end;
  else
    a=a-2*LEVEL_GetElapsed();
    if a<0 then a=0; end;
    ACTOR_SetTimeMultiplicator(actor,a*LethargoTimeScale+(1.0-a)*ACTOR_GetVar(actor,"DefaultTimeMultiplicator"));  
  end;

  SOUND_SetPostEffect("echo",0.75,1.0-a*0.5,a*0.4);

  ACTOR_SetVar(actor,"LethargyAmplitude",a);
end;


function RefreshTwoPlayer(player)
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



function Think(actor)
 local player=GLOBAL_GetVar("ActivePlayer");

 if GLOBAL_GetVar("EditorMode")==0 then
  RefreshTwoPlayer(player);
  end;

 ACTOR_SetVar(actor,"PushTimer",ACTOR_GetVar(actor,"PushTimer")-GLOBAL_GetElapsed());

 local isalive=ACTOR_GetVar(actor,"IsAlive");
 if isalive~=1 then
    if ACTOR_GetVar(actor,"Lethargy")>0 then
     LethargoEffect(actor);
    end;

   
    local aact=PLAYER_GetActiveActor(player);
    
    if aact~=actor and isalive>-1 and (ACTOR_GetVar(aact,"IsAlive")==1 or ACTOR_GetVar(aact,"KilledString")=="Exit") then
     if PLAYER_SelectActor(player,actor)==1 then
         SOUND_Play(snd_cam_pan,-1);
     end;
    end;

    ACTOR_SetSelectable(actor,0);
  
    if isalive<-1.0 and ACTOR_GetVar(actor,"KilledString")=="Exit" and aact==actor then
     if PLAYER_NextActor(player)~=aact then
      SOUND_Play(snd_cam_pan,-1);
     end;
    end;
    ACTOR_SetVar(actor,"IsAlive",isalive-2*GLOBAL_GetElapsed()*(1-PLAYER_InCameraPan(player)));
    ACTOR_SetVar(actor,"GogglesActive",0);
    if ACTOR_GetVar(actor,"KilledString")~="Exit" and ACTOR_GetVar(actor,"KilledString")~="Fell off!" then 
         LEVEL_SetTimeScale(0); 
    end;
    if WobbleinRender==0 then WobbleAndMove(actor); end;
    return;
  end;


  local inlevel=ACTOR_InsideLevel(actor);
  if inlevel==0 then
   --ACTOR_SetVar(actor,"IsAlive",-1);
ACTOR_SetVar(actor,"IsAlive",0);
   ACTOR_SetVar(actor,"KilledString","Fell off!");

   if ACTOR_GetVar(actor,"GodModeTimer")>0 then --Stop special music
    StopInvulMusic();
   end;

  end;

 local lu=ACTOR_GetVar(actor,"lookuppressed");
 local ld=ACTOR_GetVar(actor,"lookdownpressed");

 if GLOBAL_GetVar("ViewAutoReset"..secondplayer)==1 then
   if lu==1 then
     ACTOR_CallMove(actor,"lookup");
   end;
   if ld==1 then
     ACTOR_CallMove(actor,"lookdown");
   end;
  -- if lu-ld==0 then
     ACTOR_CallMove(actor,"lookreset");
  -- end;
 else
   if (lu==1) and (ld==1) then
     ACTOR_CallMove(actor,"lookreset");
   elseif lu==1 then
     ACTOR_CallMove(actor,"lookup");
   elseif ld==1 then
     ACTOR_CallMove(actor,"lookdown");
   end;
 end;

 local rt=ACTOR_GetVar(actor,"rightpressed");
 local lf=ACTOR_GetVar(actor,"leftpressed");

 if ACTOR_GetVar(actor,"Bounce")==0 then
   if rt==1 then
      ACTOR_CallMove(actor,"right");
   elseif ACTOR_CurrentMove(actor)=="right" then
      ACTOR_SetRotateStopTime(actor,0,rotatestoptime);
   end;
   if lf==1 then
      ACTOR_CallMove(actor,"left");
   elseif ACTOR_CurrentMove(actor)=="left" then
      ACTOR_SetRotateStopTime(actor,0,rotatestoptime);
   end;
 end;

 local jump=ACTOR_GetVar(actor,"jumppressed");
 if ACTOR_GetTemporaryMoveSpeedMultiplier(actor)<0 then jump=0; end;
 local fw=ACTOR_GetVar(actor,"forwardpressed");

 if fw==1 then
  if ACTOR_GetVar(actor,"NoJump")==0 or jump==0 then
   if BlockedByOtherBalls(actor)==0 then
     ACTOR_CallMove(actor,"forward");
   end;
  end;
 end;
 


 if jump==1 then
   if ACTOR_GetVar(actor,"Bounce")==1 and fw==1 then
     ACTOR_CallMove(actor,"farjump");
   else
   if ACTOR_GetVar(actor,"NoJump")==0 or (ACTOR_CurrentMove(actor)~="forward") then
     ACTOR_CallMove(actor,"jump");
   end;
   end;
 else
   if ACTOR_GetVar(actor,"Bounce")==1  then
    ACTOR_CallMove(actor,"jump");
   end;
 end;

 if ACTOR_GetVar(actor,"Bounce")==1 then
   if rt==1 then
      ACTOR_CallMove(actor,"right");
   end;
   if lf==1 then
      ACTOR_CallMove(actor,"left");
   end;
 end;

 if ACTOR_GetVar(actor,"GoggleTimer")>0 then
   if ACTOR_GetVar(actor,"GoggleTimer")>4 then
     ACTOR_SetVar(actor,"GogglesActive",1);
   elseif (1.3*ACTOR_GetVar(actor,"GoggleTimer"))-math.floor(1.3*ACTOR_GetVar(actor,"GoggleTimer"))>0.5 then
     ACTOR_SetVar(actor,"GogglesActive",0);
   else
     ACTOR_SetVar(actor,"GogglesActive",1);
   end; 
   ACTOR_SetVar(actor,"GoggleTimer",ACTOR_GetVar(actor,"GoggleTimer")-LEVEL_GetElapsed());
 else  
   ACTOR_SetVar(actor,"GogglesActive",0);
 end;

 if ACTOR_GetVar(actor,"Lethargy")>0 then



  LethargoEffect(actor);
 
  --ChangeMove(actor,ACTOR_GetVar(actor,"prevmove"));
 else
  ACTOR_SetVar(actor,"Lethargy",0)
  ACTOR_SetVar(actor,"LethargyAmplitude",0);
  --ACTOR_SetVar(actor,"LethargyTimer",0);
  ACTOR_SetTimeMultiplicator(actor,ACTOR_GetVar(actor,"DefaultTimeMultiplicator"));
  SOUND_SetPostEffect("",0,0,0);
 end;

  SetCameraParameters(actor);
 
 ACTOR_SetVar(actor,"forwardpressed",0); 
 ACTOR_SetVar(actor,"jumppressed",0);
  ACTOR_SetVar(actor,"leftpressed",0); 
 ACTOR_SetVar(actor,"rightpressed",0);
ACTOR_SetVar(actor,"lookuppressed",0);
ACTOR_SetVar(actor,"lookdownpressed",0);
ACTOR_SetVar(actor,"OnTextout",0);

 if ACTOR_GetVar(actor,"GodModeTimer")>0 then
   local gmt=ACTOR_GetVar(actor,"GodModeTimer");
   gmt=gmt-LEVEL_GetElapsed()
   if gmt<=0 then --Stop special music
      StopInvulMusic();
      gmt=0;
   end;
   ACTOR_SetVar(actor,"GodModeTimer",gmt);
 end; 


    if WobbleinRender==0 then WobbleAndMove(actor); end;

 --Check if we are inside a block
  local blk=BLOCK_AtPos(ACTOR_GetPos(actor));
  if blk>=0 then
   if BLOCK_GetBlocking(blk)==1 then
     local btype=SIDE_GetType(blk*6);
     local blockkills=0;
     if btype=="phaser" then
      -- if BLOCK_GetVar(blk,"State")=="active" then
         blockkills=1;
         BLOCK_SetVar(blk,"timer",0); --This will set the block to be fully visible
         BLOCK_SetVar(blk,"Phase",0);
     --  end;
     elseif btype=="toggleblock" then 
         blockkills=1; 
     end;
     if blockkills==1 then
      ACTOR_SetVar(actor,"IsAlive",0);
      ACTOR_SetVar(actor,"KilledString","Ball inside block!");
      SOUND_Play(snd_captured,-1);
      LEVEL_SetCollisionChecksActive(0);
      if ACTOR_GetVar(actor,"GodModeTimer")>0 then --Stop special music
       StopInvulMusic();
      end;
     end;
   end;
  end;
end;

function SetCameraParameters(actor)
 local tt=ACTOR_GetVar(actor,"TeleTime");
 tt=tt-LEVEL_GetElapsed()/0.8;
 if tt<0 then tt=0; end;
 ACTOR_SetVar(actor,"TeleTime",tt);
--print("tt "..tt);
 local norm=VECTOR_New(3, 3.0/2.0 , 3.0/4.0 );
 local ldown=VECTOR_New(0.01,3.355, 3.0/4.0 );
 local lup=VECTOR_New(2,1.0/4.0,2.0);
 
 local fv=math.sin(tt*math.pi);
 fv=math.pow(fv,2);
 --if tt==0 then
   ACTOR_SetCamParams(actor,"normal",norm); 
   ACTOR_SetCamParams(actor,"lookdown",ldown);
   ACTOR_SetCamParams(actor,"lookup",lup);
-- else 
   --ACTOR_SetCamParams(actor,"normal",VECTOR_Scale(norm,1.0-0.7*fv)); 
--ACTOR_SetCamParams(actor,"normal",VECTOR_New(3-2*math.sin(2*math.pi*(1-tt)), 3.0/2.0-2.5/2.0*math.sin(2*math.pi*(1-tt)) , 3.0/4.0*math.abs(math.cos(2*math.pi*(1-tt))) ));
 --  ACTOR_SetCamParams(actor,"lookdown",ldown);
 --  ACTOR_SetCamParams(actor,"lookup",lup);
 --end;
end;

function Constructor(actor)
 --print("Calling constructor for player "..actor);
 local basis=BASIS_New();
 local s=ACTOR_GetRadius(actor);
 BASIS_SetScale(basis,VECTOR_New(s,s,s));
 ACTOR_SetVar(actor,"Basis",basis);

 local distortionbase=BASIS_New();
 ACTOR_SetVar(actor,"DistortionBasis",distortionbase);

 ACTOR_SetVar(actor,"JumpDistance",2);
 
  ACTOR_SetVar(actor,"OnTextout",0);

 BASIS_AxisRotate(basis,ACTOR_GetSide(actor),math.random()*360);
 BASIS_AxisRotate(basis,ACTOR_GetUp(actor),math.random()*360);
 BASIS_AxisRotate(basis,ACTOR_GetDir(actor),math.random()*360);

ACTOR_SetVar(actor,"IsAlive",1);
 ACTOR_SetVar(actor,"KilledString","");
 ACTOR_SetVar(actor,"GoggleTimer",0);

 ACTOR_SetVar(actor,"RollSpeed",0.0);
 ACTOR_SetVar(actor,"forwardpressed",0);
 ACTOR_SetVar(actor,"jumppressed",0);
  ACTOR_SetVar(actor,"leftpressed",0); 
 ACTOR_SetVar(actor,"rightpressed",0);
ACTOR_SetVar(actor,"lookuppressed",0);
ACTOR_SetVar(actor,"lookdownpressed",0);
ACTOR_SetVar(actor,"specialpressed",0);
ACTOR_SetVar(actor,"lastspecialpressed",0);

 ACTOR_SetVar(actor,"prevmove","none");
 ACTOR_SetVar(actor,"sanddepth",0);
 ACTOR_SetVar(actor,"wobble_x",0);
 ACTOR_SetVar(actor,"wobble_dx",0);
 ACTOR_SetVar(actor,"wobble_AddForce",0.15);
 ACTOR_SetVar(actor,"wobble_Damp",1.5);
 ACTOR_SetVar(actor,"wobble_omega",7);
 ACTOR_SetVar(actor,"wobble_x0",0.05);

 ACTOR_SetVar(actor,"GodModeTimer",0); 
 ACTOR_SetVar(actor,"SuperballMdef",-1);

 ACTOR_SetRadius(actor,GLOBAL_GetScale()/3.0*BallScale);
 local smlt=GLOBAL_GetVar("MoveSpeedMultiply");
 local scl=GLOBAL_GetScale();
 
 ACTOR_SetSpeed(actor,4.2*smlt);
 --ACTOR_SetRotSpeed(actor,ACTOR_GetSpeed(actor));
 ACTOR_SetRotSpeed(actor,rotspeedmultiply*ACTOR_GetSpeed(actor));

 ACTOR_SetJumpParams(actor,scl*16.0*smlt,scl*18*smlt,scl*42*smlt,scl*70*smlt*smlt,scl*30*smlt);
ACTOR_SetRotateStopTime(actor,0,rotatestoptime);

ACTOR_SetJumpDistances(actor,2,3,2);
 
 ACTOR_SetVar(actor,"Bounce",0);
 ACTOR_SetVar(actor,"NoJump",0);
 ACTOR_SetVar(actor,"Lethargy",0);
 ACTOR_SetVar(actor,"LethargyAmplitude",0);
 ACTOR_SetVar(actor,"LethargyTimer",math.random());
 ACTOR_SetVar(actor,"DefaultTimeMultiplicator",1);
 ACTOR_SetVar(actor,"Temperature",0);
 ACTOR_SetVar(actor,"OldTemperature",0);
 ACTOR_SetVar(actor,"Win",0);
 ACTOR_SetVar(actor,"BlendAlpha",1);

 ACTOR_SetVar(actor,"RestingOnIce",-1);
 ACTOR_SetVar(actor,"PushTimer",0);
 ACTOR_SetVar(actor,"LastRebouncedOf",-1);
 ACTOR_SetVar(actor,"LastRebounceCounter",0);

 ACTOR_SetVar(actor,"TeleTime",0);

 ACTOR_SetVar(actor,"WarpTunnelCounter",0);

 SetCameraParameters(actor);

 ACTOR_SetVar(actor,"GogglesActive",0);
 ACTOR_SetVar(actor,"GoggleTimer",0);

 local penv=PARTICLE_CreateEnvOnActor(actor);
 ACTOR_SetVar(actor,"PEnv",penv); 

 if GLOBAL_GetVar("UseParticles")~=0 then
   local emi=PARTICLE_AddEmitter(part_heatclouds,penv);

   EMITTER_SetColorMultiply(emi,COLOR_New(1,1,1,0));
   EMITTER_SetPos(emi,VECTOR_New(0,0.7*ACTOR_GetRadius(actor),0),1);
   ACTOR_SetVar(actor,"HeatEmitter",emi); 
 end;

 ACTOR_SetVar(actor,"IsAlive",1);

--All possible moves
  local moves={"forward","left","right","jump","lookup","lookdown","special"};
  for mi=1,table.getn(moves),1 do
   ACTOR_SetVar(actor,"key:"..moves[mi],moves[mi].."pressed"); -- Bind the variable "key:<move>" to "<move>:pressed" for all <move>
  end;

end;

function ChangeMove(actor,newmove)
 local ar=0.0;
 local rad=ACTOR_GetRadius(actor);
 local scale=GLOBAL_GetScale();
 
 local linmove=ACTOR_GetSpeed(actor)*scale;
 
 local prevmove=ACTOR_GetVar(actor,"prevmove");
 
 if (newmove=="forward") then
   ar=linmove/rad;
 elseif (newmove=="down") then
  ar=(linmove*scale/(scale-rad))/rad;
  
 elseif (newmove=="up") then
  ar=(linmove*scale/(scale+rad))/rad;
  
 elseif (newmove=="jumpahead") then
  ar=linmove/rad;
  
 elseif (newmove=="slidedown") then
  ar=linmove/rad;
 
 elseif (newmove=="changegravity") then
  ar=0; 
 
 end;

 --print(newmove);
 ACTOR_SetVar(actor,"prevmove",newmove);
  ACTOR_SetVar(actor,"RollSpeed",ar);
end;


function  EmitFireSpark(actor)
 local env=ACTOR_GetVar(actor,"PEnv");
 local ps=ACTOR_GetPos(actor);
 
 local sid=ACTOR_GetSide(actor);
 local dir=ACTOR_GetDir(actor);
 local up=ACTOR_GetUp(actor);

 ps=VECTOR_Sub(ps,VECTOR_Scale(up,ACTOR_GetRadius(actor)));

 local num=8;
for i=1,num,1 do
local emi=PARTICLE_AddEmitter(part_firespark,env);
 local phi=6.28318531*i/num+0.3*math.random();
 local theta=1.50-0.4*math.random();
 local speed=6*GLOBAL_GetScale()*(1+math.random());

 local vvec=VECTOR_Scale(VECTOR_Add(VECTOR_Scale(up,math.cos(theta)),VECTOR_Add(VECTOR_Scale(dir,math.cos(phi)*math.sin(theta)),VECTOR_Scale(sid,math.sin(phi)*math.sin(theta)))),speed)

 EMITTER_SetPos(emi,ps,0);
 EMITTER_SetVelocity(emi,vvec);
 EMITTER_SetGravity(emi,VECTOR_Scale(up,-200),1);
end;
end;




function EmitSandParticles(actor)
 local env=ACTOR_GetVar(actor,"PEnv");
 local pos=VECTOR_New(0,-ACTOR_GetRadius(actor)*1,0);
 local emi=PARTICLE_AddEmitter(part_sandclouds,env);
 EMITTER_SetPos(emi,pos,1);
 EMITTER_SetGravity(emi,VECTOR_Scale(ACTOR_GetUp(actor),-100),0);

 EMITTER_SetColorMultiply(emi,COLOR_New(0.9,0.8,0.6,0.4));
 EMITTER_SetVar(emi,"Tank",50);
 EMITTER_SetVar(emi,"Flux",1000);
 EMITTER_SetMaxTimeInterval(emi,6/EMITTER_GetVar(emi,"Flux")); --Maximal 6 emitts per think-call 
 EMITTER_SetScaleMultiply(emi,1);
end;

function Event(id,ev)
  if ev=="hitup" or ev=="hitfront" or ev=="hitground" then
    if ev=="hitground" then
    ACTOR_SetVar(id,"wobble_AddForce",-0.5);
    ACTOR_SetVar(id,"LastRebouncedOf",-1);
    ACTOR_SetVar(id,"LastRebounceCounter",0);
    --Test if we hit a fire block
    local bs=ACTOR_TraceOnSide(id);
     if bs>-1 then
      local str=SIDE_GetType(bs); 
      if (str=="fire") then
        --Add temperature to avoid jumping over an infinite count of fire blocks
         local temp=ACTOR_GetVar(id,"Temperature");
         ACTOR_SetVar(id,"Temperature",temp+fire_temp_hit_increment);
         SOUND_Play(snd_firehit,-1);
       --  EmitFireSpark(id);
         return; 
      elseif str=="sand" then
        SOUND_Play(snd_sandhit,-1);
        if GLOBAL_GetVar("UseParticles")~=0 and ev=="hitground" then
             EmitSandParticles(id);
        end;
        return;
      end;
     end;
   end;
   SOUND_Play(snd_groundhit,-1);
  end;

end;


function RenderShadow(side,scale,pos)
  local block=SIDE_GetBlock(side);
   if BLOCK_HasTransparency(block)>0 then
    return;
   end;

  if scale<=0 then return ; end;

  MATRIX_Push();
  local dir=SIDE_GetTangent(side);
  local up=SIDE_GetNormal(side);
  local right=VECTOR_Cross(up,dir);
  local pos=VECTOR_Add(pos,VECTOR_Scale(up,0.01*GLOBAL_GetScale()));
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(scale);
  TEXDEF_Render(stex,side);
  MATRIX_Pop();
end;

function VectPositive(v)
  local w=VECTOR_New(v.x,v.y,v.z);
  if (w.x<0) then 
   w.x=-w.x;
  end;
  if (w.y<0) then 
   w.y=-w.y;
  end;
  if (w.z<0) then 
   w.z=-w.z;
  end;
  return w;
end;

function WobbleAndMove(actor)
  if (ACTOR_GetVar(actor,"KilledString")=="Spiked!")  then
     ACTOR_SetVar(actor,"wobble_x0",ACTOR_GetVar(actor,"wobble_x0")+GLOBAL_GetElapsed()*0.6);
    end;
    
    local emi;
    if GLOBAL_GetVar("UseParticles")~=0 then

      emi=ACTOR_GetVar(actor,"HeatEmitter");
    end;

    --Go with the temperature
    local temp=ACTOR_GetVar(actor,"Temperature");
    if temp>0 then
     temp=temp-LEVEL_GetElapsed()*recool_speed;
     if temp<0 then
        temp=0;
     end;

     if GLOBAL_GetVar("UseParticles")~=0 then
      EMITTER_SetColorMultiply(emi,COLOR_New(1-0.9*temp,1-0.9*temp,1-0.9*temp,0.9*temp));
     end;

    elseif temp<0 then
     temp=temp+LEVEL_GetElapsed()*reheat_speed;
     if temp>0 then
        temp=0;
     end;
     if GLOBAL_GetVar("UseParticles")~=0 then
      EMITTER_SetColorMultiply(emi,COLOR_New(0,0,0,0));
      EMITTER_Clear(emi);
     end;
    else
     if GLOBAL_GetVar("UseParticles")~=0 then
      EMITTER_SetColorMultiply(emi,COLOR_New(0,0,0,0));
      EMITTER_Clear(emi);
     end;
    end;
    
    local BurnedString="Scorched!";

    if temp>1 then
       temp=1;
        ACTOR_SetVar(actor,"IsAlive",0);
        ACTOR_SetVar(actor,"KilledString",BurnedString);
    elseif temp<-1 then
       temp=-1;
    end;

    if (ACTOR_GetVar(actor,"KilledString")==BurnedString)  then
     ACTOR_SetVar(actor,"wobble_x0",ACTOR_GetVar(actor,"wobble_x0")+GLOBAL_GetElapsed()*0.6);
     temp=1;
    end;


    local bs=ACTOR_TraceOnSide(actor);
    local player=GLOBAL_GetVar("ActivePlayer");
    local aa=-1;
    if player>=0 then
     aa=PLAYER_GetActiveActor(player);
    end;
    if bs>-1 and aa==actor then
      local str=SIDE_GetType(bs); 
      if (str=="icy1" and ACTOR_GetVar(actor,"RestingOnIce")~=bs) then
        ACTOR_SetVar(actor,"sanddepth",0)
        if onside_sound~="ice" and iceslide_playing~=-1 then
            SOUND_StopChannel(iceslide_playing); 
            iceslide_playing=-1;
            onside_sound="";
        end;
        if iceslide_playing==-1 then
          playing_fire=0;
          iceslide_playing=SOUND_PlayLooped(snd_iceslide,-1,-1);
          onside_sound="ice";
        end;
      elseif (str=="fire") then
        ACTOR_SetVar(actor,"sanddepth",0);
        if onside_sound~="fire" and iceslide_playing~=-1 then
            SOUND_StopChannel(iceslide_playing); 
            iceslide_playing=-1;
            onside_sound="";
        end;
         if iceslide_playing==-1 then
          iceslide_playing=SOUND_PlayLooped(snd_fire,-1,-1);
          onside_sound="fire";
        end;
      elseif (str=="magnet") then
        ACTOR_SetVar(actor,"sanddepth",0);
        if onside_sound~="hum" and iceslide_playing~=-1 then
            SOUND_StopChannel(iceslide_playing); 
            iceslide_playing=-1;
            onside_sound="";
        end;
         if iceslide_playing==-1 and GetMagnetStrength(bs)~=0 then
          iceslide_playing=SOUND_PlayLooped(snd_magnethum,-1,-1);
          onside_sound="hum";
        elseif GetMagnetStrength(bs)==0 then
            if iceslide_playing~=-1 then SOUND_StopChannel(iceslide_playing);  end;
            iceslide_playing=-1;
            onside_sound="";
        end;
      else  
         if iceslide_playing~=-1 then
          --Stop sound
          SOUND_StopChannel(iceslide_playing); 
          iceslide_playing=-1;
          onside_sound="";
        end;
      end;
    else 
        
       if iceslide_playing~=-1 and aa==actor then
          --Stop sound
          SOUND_StopChannel(iceslide_playing); 
          iceslide_playing=-1;
          onside_sound="";
        end;
    end

    -- Stop Ice sound inside menus
    if LEVEL_GetElapsed()==0 then --This only occurs inside PAUSE, elsewise it should be >0
     if iceslide_playing~=-1 then
          --Stop sound
          SOUND_StopChannel(iceslide_playing); 
          iceslide_playing=-1;
          onside_sound="";
        end;
     end;


    if bs>-1 then
      local str=SIDE_GetType(bs);    
      if str=="sand" then
        local sd=ACTOR_GetVar(actor,"sanddepth");
        if sd<0.3 then sd=sd+LEVEL_GetElapsed(); if sd>0.3 then sd=0.3 end; end;
        ACTOR_SetVar(actor,"sanddepth",sd);
      else
        ACTOR_SetVar(actor,"sanddepth",0);
      end;
    else
      local sd=ACTOR_GetVar(actor,"sanddepth");
      if sd>0 then sd=sd-3*LEVEL_GetElapsed(); if sd<0 then sd=0 ; end ;end;
      ACTOR_SetVar(actor,"sanddepth",sd);
    end;
        
   
    ACTOR_SetVar(actor,"Temperature",temp);
    ACTOR_SetVar(actor,"OldTemperature",temp);

  --Solve the wobble equation
    local Force=ACTOR_GetVar(actor,"wobble_AddForce");
    ACTOR_SetVar(actor,"wobble_AddForce",0);
    --Obtain the acceleration
    local omega=ACTOR_GetVar(actor,"wobble_omega");
    local wx=ACTOR_GetVar(actor,"wobble_x");
    local wdx=ACTOR_GetVar(actor,"wobble_dx");
    local wddx=-omega*omega*wx-ACTOR_GetVar(actor,"wobble_Damp")*wdx;
    wdx=wdx+wddx*LEVEL_GetElapsed()+Force;
    wx=wx+wdx*LEVEL_GetElapsed();
    
    --Store it
    ACTOR_SetVar(actor,"wobble_x",wx);
    ACTOR_SetVar(actor,"wobble_dx",wdx);

  
  --

 local rspeed=ACTOR_GetVar(actor,"RollSpeed")*ACTOR_GetTemporaryMoveSpeedMultiplier(actor)*ACTOR_GetVar(actor,"DefaultTimeMultiplicator");
if ACTOR_GetVar(actor,"Lethargy")>0 then
 rspeed=rspeed*LethargoTimeScale;
end;
  if rspeed~=0 then
    BASIS_AxisRotate(ACTOR_GetVar(actor,"Basis"),ACTOR_GetSide(actor),rspeed*LEVEL_GetElapsed());
  end;

end;

function SetLightAndBasis(actor)
 
  LIGHT_Enable();
  local gmt=ACTOR_GetVar(actor,"GodModeTimer");
   
    local redshift=0;
    local blueshift=0;
    local temp=ACTOR_GetVar(actor,"Temperature");

    if temp<0 then
      blueshift=-temp;
    elseif temp>0 then
      redshift=temp;
    end;

    if gmt>0 then
       blueshift=0;
       redshift=0; 
       ACTOR_SetVar(actor,"Temperature",0); --Makes invul against fire!
    end; 
    

    local red=0.5+(redshift-blueshift)/2.0*0.8;
    local green=0.5-(redshift+blueshift)/2.0*0.8;
    local blue=0.5-(redshift-blueshift)/2.0*0.8;
    local alpha=1;

 local ks=ACTOR_GetVar(actor,"KilledString");
 if (ks=="Lasered!") or (ks=="Captured!") or (ks=="Poisoned!") or (ks=="EndlessLoop!") or  (ks=="Ball inside block!")  then 
    local c=0.1+0.4*(1.0+math.cos(20*ACTOR_GetVar(actor,"IsAlive")));
    red=c/2; green=0.05; blue=0.05;
 elseif ks=="Exit" then
    alpha=alpha+ACTOR_GetVar(actor,"IsAlive");
 end;
  
   
MATERIAL_SetMultiply(COLOR_New(2*red,2*green,2*blue,alpha));
ACTOR_SetVar(actor,"BlendAlpha",alpha);

   
  local s=1;
  if ACTOR_GetVar(actor,"KilledString")=="Fell off!" then
   s=s+ACTOR_GetVar(actor,"IsAlive");
  elseif ACTOR_GetVar(actor,"WarpTunnelCounter")~=0 then
   local wc=ACTOR_GetVar(actor,"WarpTunnelCounter")*1.5;
   s=s-wc;
   ACTOR_SetVar(actor,"sanddepth",2*(0.5*wc*wc+wc));
ACTOR_CallMove(actor,"lookreset");
   if (s<0) then s=0; end;
  end;


  s=s*ACTOR_GetRadius(actor)*ModelScale;

  local upoffs=ACTOR_GetVar(actor,"wobble_x")-ACTOR_GetVar(actor,"wobble_x0");
    local sideoffs=math.sqrt(1-upoffs)-1;

 

  local basis=ACTOR_GetVar(actor,"Basis");
  
   local aup=VectPositive(ACTOR_GetUp(actor));
   local aside=VectPositive(ACTOR_GetSide(actor));
   local adir=VectPositive(ACTOR_GetDir(actor));


   ds=VECTOR_New(0,0,0);
   ds=VECTOR_Add(VECTOR_Scale(aup,upoffs),VECTOR_Scale(VECTOR_Add(aside,adir),sideoffs));
   

  BASIS_SetPos(basis,VECTOR_Add(ACTOR_GetPos(actor),VECTOR_Scale(ACTOR_GetUp(actor),(upoffs-ACTOR_GetVar(actor,"sanddepth",0))*GLOBAL_GetScale()/2.0)));
 

   
   BASIS_SetScale(basis,VECTOR_Scale(VECTOR_New(1+ds.x,1+ds.y,1+ds.z),s));
 
  --MATRIX_Push();
  --MATRIX_Scale(ACTOR_GetUp(actor));
  BASIS_Push(basis);
end;


function RenderSuperBall(actor)
   
    local blinkbegin=2; 
    local numblinks=5;



 local gmt=ACTOR_GetVar(actor,"GodModeTimer");
 local w=(blinkbegin-gmt)/blinkbegin; 
 if (gmt<blinkbegin) and (math.fmod(math.floor(2*w*numblinks),2)==0) then
   return;
 end;

 SetLightAndBasis(actor);
  MDLDEF_Render(ACTOR_GetVar(actor,"SuperballMdef"));
 BASIS_Pop(ACTOR_GetVar(actor,"Basis"));
end;


function NormalBallRender(actor)
  if ACTOR_GetVar(actor,"BlendAlpha")==1 and TransparentBall==0 then
       MDLDEF_Render(mdl);
  end;
  ACTOR_DistanceRender(actor,CAM_ZDistance(ACTOR_GetPos(actor)));
end;

function Render(actor)
  if ACTOR_GetVar(actor,"IsAlive")<-1.0 then
   if GLOBAL_GetVar("UseParticles")~=0 then
      EMITTER_SetColorMultiply(ACTOR_GetVar(actor,"HeatEmitter"),COLOR_New(0,0,0,0));
      EMITTER_Clear(ACTOR_GetVar(actor,"HeatEmitter"));
     end;
    return;
  end;

  if WobbleinRender==1 then WobbleAndMove(actor); end;
  SetLightAndBasis(actor);
  NormalBallRender(actor);
  BASIS_Pop(ACTOR_GetVar(actor,"Basis"));
MATERIAL_SetMultiply(COLOR_New(1,1,1,1));
end;

function DistRender(actor)

if  ACTOR_GetVar(actor,"BlendAlpha")~=1 or TransparentBall~=0 then
 if ACTOR_GetVar(actor,"BlendAlpha")==1  then
  SetLightAndBasis(actor);
  MDLDEF_Render(mdl);
  BASIS_Pop(ACTOR_GetVar(actor,"Basis"));
  MATERIAL_SetMultiply(COLOR_New(1,1,1,1));
 else
  SetLightAndBasis(actor);
  MATERIAL_SetMultiply(COLOR_New(1,1,1,ACTOR_GetVar(actor,"BlendAlpha")));
  MDLDEF_Render(mdl); --BLEND_Deactivate();
  BASIS_Pop(ACTOR_GetVar(actor,"Basis"));
 end;
end;




 ACTOR_SetVar(actor,"lastspecialpressed",ACTOR_GetVar(actor,"specialpressed"));
 ACTOR_SetVar(actor,"specialpressed",0);

--Trace a line


  local tr=LEVEL_TraceLine(ACTOR_GetPos(actor),VECTOR_Scale(ACTOR_GetUp(actor),-1));
  if tr["hit"]==1 then
     local gs=GLOBAL_GetScale();
     local h=(tr["dist"]-ACTOR_GetRadius(actor))/gs;
--     print(h);
     local ssize=ACTOR_GetRadius(actor)*3*(1+h/5);
     if ssize>gs*1.5 then
       ssize=gs*1.5;
     end;
     local spos=VECTOR_Add(ACTOR_GetPos(actor),VECTOR_Scale(ACTOR_GetUp(actor),-1*tr["dist"]));
     RenderShadow(tr["side"],ssize*ShadowScale,spos);
  end;
  
  --render the superball
    local gmt=ACTOR_GetVar(actor,"GodModeTimer");
  if gmt>0 then
    RenderSuperBall(actor);
  end;

  if DistBallRender then --is a func like this defined?
    DistBallRender(actor);
  end;

MATERIAL_SetMultiply(COLOR_New(1,1,1,1));
end;
 


function ActorCollide(pl,en)
  if ACTOR_GetVar(pl,"IsAlive")~=1 or ACTOR_GetVar(en,"IsAlive")~=1 then
    return;


  end;
  local gmt=ACTOR_GetVar(pl,"GodModeTimer");
  if gmt==0 then
   ACTOR_SetVar(pl,"IsAlive",0);
   ACTOR_SetVar(pl,"KilledString","Captured!");
   SOUND_Play(snd_captured,-1);
   local UltraDifficultMode=ACTOR_GetVar(en,"QuitGameOnCollide"); 
   if UltraDifficultMode==1 then
    print("Trapped into a very evil enemy => Quitting Game");
    GLOBAL_Quit();
   end;
  else
     ACTOR_SetVar(en,"IsAlive",-0.5);
     ACTOR_SetVar(en,"KilledString","Captured!");
     PLAYER_SetVar(ACTOR_GetPlayer(pl),"Score",PLAYER_GetVar(ACTOR_GetPlayer(pl),"Score")+200); --Here you can change the score for killing an enemy
     SOUND_Play(snd_captured,-1);
  end;
end;


function ComboJump(inair,onground)
    local lrb=ACTOR_GetVar(inair,"LastRebouncedOf");
    local lrn=ACTOR_GetVar(inair,"LastRebounceCounter");
    if lrb==onground then
     lrn=lrn+1;
    else
     lrn=1;
    end;
    lrb=onground;
    ACTOR_SetVar(inair,"LastRebouncedOf",lrb);
    ACTOR_SetVar(inair,"LastRebounceCounter",lrn);
    if lrn>5 then
       ACTOR_SetVar(inair,"IsAlive",0);
       ACTOR_SetVar(inair,"KilledString","EndlessLoop!");
       SOUND_Play(snd_captured,-1);
      return;
    end;

  if GLOBAL_GetVar("UseParticles")~=0 then
      local env=ACTOR_GetVar(inair,"PEnv");
      local pos=VECTOR_New(0,-ACTOR_GetRadius(inair)*0.2,0);
      local emi=PARTICLE_AddEmitter(part_rebounce,env);
      EMITTER_SetPos(emi,pos,1);
      EMITTER_SetGravity(emi,VECTOR_Scale(ACTOR_GetUp(inair),-100),0);
   end;


    ACTOR_Rebounce(inair,onground);
    SOUND_Play(snd_rebounce,-1);
    ACTOR_SetVar(inair,"RollSpeed",ACTOR_GetSpeed(inair)*GLOBAL_GetScale()/ACTOR_GetRadius(inair));
    ACTOR_SetVar(inair,"wobble_AddForce",-0.5);
    ACTOR_SetVar(onground,"wobble_AddForce",-0.5); 

end;

function CheckLandingOnSide(actor,side)
 for i=0,PLAYER_NumActors(GLOBAL_GetVar("ActivePlayer"))-1 do
  other=PLAYER_GetActor(i);
  if other~=actor then
   local s=ACTOR_TraceOnSide(other);
   if s==side and ACTOR_GetVar(other,"IsAlive")==1  then
    ComboJump(actor,other);
    return 0;
   end; 
  end; 
 end;
 ACTOR_SetVar(actor,"LastRebouncedOf",-1);
 ACTOR_SetVar(actor,"LastRebounceCounter",0);
 return 1; 
end;

function HandleJumpCollide(inair,onground)
 local inmove=ACTOR_CurrentMove(inair);
 local pair=ACTOR_GetPos(inair);
 local pground=ACTOR_GetPos(onground);
 local diff=VECTOR_Sub(pair,pground);
 local dist=VECTOR_Length(diff);
 local dir=VECTOR_Scale(diff,1/dist);
 local uair=ACTOR_GetUp(inair);
    
 local inters=dist-ACTOR_GetRadius(inair)-ACTOR_GetRadius(onground);
  local uv=ACTOR_GetUpVel(inair);
 if VECTOR_Dot(dir,uair)<-0.7  then
  if uv>0 and inters<-0.2*GLOBAL_GetScale() then
    ACTOR_SetUpVel(inair,uv*(-0.7));
    ACTOR_SetVar(inair,"wobble_AddForce",-0.5);
    ACTOR_SetVar(onground,"wobble_AddForce",-0.5);
    --Rebounce on the top
    --TODO:Sound
    --TODO: Set the jump d_dist
  end;
 elseif VECTOR_Dot(dir,uair)>=0.0 then
   if uv<0 and inters<-0.005*GLOBAL_GetScale() then
     ComboJump(inair,onground)
   else
   
   end;
   
 end;

end;


function HandleOtherCollision(moving,resting,movetype)
 if movetype=="none" then
   return; --Unhandled Should not happen!
 end;
 local ls=ACTOR_PrevOnSide(moving);
 local lst=SIDE_GetType(ls);
 if lst=="icy1" then
   if ACTOR_GetTemporaryMoveSpeedMultiplier(moving)>0 then
    SOUND_Play(snd_ballcollide,-1);
   end;
   ACTOR_SetTemporaryMoveSpeedMultiplier(moving,-0.5);
 elseif lst=="rotate" or ACTOR_GetMovementCheck(moving)==0 then
   if ACTOR_GetTemporaryMoveSpeedMultiplier(moving)>1 then
    SOUND_Play(snd_ballcollide,-1);
   end;
   ACTOR_SetTemporaryMoveSpeedMultiplier(moving,0.5);
   local mdir=ACTOR_GetDir(moving);
   local rside=ACTOR_TraceOnSide(resting);
   for i=0,3 do
    ACTOR_SetStart(resting,rside,i)
    local dot=VECTOR_Dot(mdir,ACTOR_GetDir(resting));
    if dot>0.5 then
     ACTOR_SetMovementCheck(resting,0);
     ACTOR_CallMove(resting,"forward");
     ACTOR_SetVar(resting,"PushTimer",0.1);
     ACTOR_SetVar(moving,"PushTimer",0.1);
     --ACTOR_SetMovementCheck(resting,1);
     break;
    end;
   end;
 end;
end;


function HandleBothInMotion(p1,p2,im1,im2)
 local msp1=ACTOR_GetTemporaryMoveSpeedMultiplier(p1);
 local msp2=ACTOR_GetTemporaryMoveSpeedMultiplier(p2);
 local pt1=ACTOR_GetVar(p1,"PushTimer");
 local pt2=ACTOR_GetVar(p2,"PushTimer");
 if msp1>0 and msp2>0 and pt1<0 and pt2<0 then
   SOUND_Play(snd_ballcollide,-1);
   ACTOR_SetTemporaryMoveSpeedMultiplier(p1,-msp1);
   ACTOR_SetTemporaryMoveSpeedMultiplier(p2,-msp2);
 end;
end;

function HandleSingleAirAirColli(actor,dot,other)
 if dot>0.33 then
   ComboJump(actor,other);
 elseif dot>-0.33 and ACTOR_GetVar(actor,"PushTimer")<=0 then
   ACTOR_SetVar(actor,"PushTimer",0.1);
   ACTOR_FrontSideRebounce(actor);
  SOUND_Play(snd_ballcollide,-1);
 end;
end;

function HandleBothInAir(p1,p2)
 local diff=VECTOR_Sub(ACTOR_GetPos(p1),ACTOR_GetPos(p2));
 local dist=VECTOR_Length(diff);
 local dir=VECTOR_Scale(diff,1/dist);
 local n1=ACTOR_GetUp(p1);
 local n2=ACTOR_GetUp(p2);
 local d1=VECTOR_Dot(n1,dir);
 local d2=-VECTOR_Dot(n2,dir);

 local mid=VECTOR_Scale(VECTOR_Add(ACTOR_GetPos(p1),ACTOR_GetPos(p2)),0.5);
 print("Hit at "..mid.x.." "..mid.y.." "..mid.z);

 HandleSingleAirAirColli(p1,d1,p2);
 HandleSingleAirAirColli(p2,d2,p1);


end;

function ActorCollidePlayer(pl,oth)
  if pl>oth then --This case has already been handled
    return;
  end;
  if ACTOR_GetVar(pl,"IsAlive")~=1 or ACTOR_GetVar(oth,"IsAlive")~=1 then
    return;
  end;
  os1=ACTOR_TraceOnSide(pl);
  os2=ACTOR_TraceOnSide(oth);


  if (os1<0 and os2>=0) then
    HandleJumpCollide(pl,oth);
  elseif (os1>=0 and os2<0) then
    HandleJumpCollide(oth,pl);
  elseif (os1<0 and os2<0) then
    HandleBothInAir(pl,oth);
  else 
   local im1=ACTOR_CurrentMove(pl);
   local im2=ACTOR_CurrentMove(oth);
   if im1=="none" then
     HandleOtherCollision(oth,pl,im2);
   elseif im2=="none" then
     HandleOtherCollision(pl,oth,im1);
   else
     HandleBothInMotion(pl,oth,im1,im2);
   end; 
  end;

end;
