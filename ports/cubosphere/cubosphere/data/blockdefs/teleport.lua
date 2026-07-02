USING("PARTICLE");
INCLUDEABSOLUTE("/blockdefs/include/colors.inc");


mdl=-1;
texture=-1;
snd_rebounce=-1;
snd_tele=-1;
snd_telefrag=-1;


rspeed=100;

teletime=0.4;

spritetex=-1;
part_telefog=-1;
part_telefog_load=-1;

up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);


function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 4;
 elseif name=="Var1" then
  return "StartActive";
 elseif name=="VarType1" then
  return "bool"; 
 elseif name=="Var2" then
  return "Color";
 elseif name=="VarType2" then
  return "basecolor"; 
 elseif name=="Var3" then
  return "DestSide";
 elseif name=="VarType3" then
  return "int"; 
 elseif name=="Var4" then
  return "DestRotation";
 elseif name=="VarType4" then
  return "int"; 
 else
 return default;
  end;
end;


function SideConstructor(sideid)
  SIDE_SetVar(sideid,"Rotation",math.random()*180.0);
  SIDE_SetVar(sideid,"StartActive",1);
  SIDE_SetVar(sideid,"Color",0);
  SIDE_SetVar(sideid,"TeleTime",0);
  SIDE_SetVar(sideid,"TelePlayer",-1);
  SIDE_SetVar(sideid,"DestSide",1);
  SIDE_SetVar(sideid,"DestRotation",0);
  SIDE_SetVar(sideid,"Reteleport",-1); --Avoids a player to be reteleported directly after spawning on a teleport
  if GLOBAL_GetVar("UseParticles")~=0 then
    local penv=PARTICLE_CreateEnvOnSide(sideid);
     SIDE_SetVar(sideid,"PEnv",penv);
  end;
end;

function Precache()
  mdl=MDLDEF_Load("teleport");
  texture=TEXDEF_Load("base");
  --snd_rebounce=SOUND_Load("groundhit");
  snd_tele=SOUND_Load("teleport");
  snd_telefrag=SOUND_Load("spiked");
  spritetex=TEXDEF_Load("telesprite");
if GLOBAL_GetVar("UseParticles")~=0 then  
  part_telefog=PARTICLE_LoadDef("telefog")
  part_telefog_load=PARTICLE_LoadDef("telefog_load")

end;
end



function RenderMdl(side,height)
  
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,SIDE_GetMidpoint(side));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*1.0);
  MATRIX_AxisRotate(VECTOR_New(0,1,0),SIDE_GetVar(side,"Rotation"));
 
  local rcadd;

  if SIDE_GetVar(side,"StartActive")==1 then
    --Add a addtional activation color punch
    local blinkspeed=4;
    rcadd=0.0175*math.sin(blinkspeed*GLOBAL_GetTime());
  else
    rcadd=-0.0175;  
  end;

  ActivateCuboColor(SIDE_GetVar(side,"Color"),rcadd,2.0,0.3,0.0);

  MDLDEF_Render(mdl);
  MATRIX_Pop();
end;



function RenderSide(side)
  TEXDEF_Render(texture,side);
TEXDEF_ResetLastRenderedType();
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;


  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  

  if SIDE_GetVar(side,"StartActive")==1 then
    SIDE_SetVar(side,"Rotation",SIDE_GetVar(side,"Rotation")+GLOBAL_GetElapsed()*rspeed);
  end;

  RenderMdl(side,height);


  if SIDE_GetVar(side,"TeleTime")>0 and GLOBAL_GetVar("UseParticles")==0 then
    SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
  end;
end

function MayCull(side)
  return 0;
end

function MayMove(side,actor,dir)
 if SIDE_GetVar(side,"TeleTime")>0 then
   return 0;
 end;
 return 1;
end;


function EmitLoadParticles(actor,side)
 local env=SIDE_GetVar(side,"PEnv");
 local pos=VECTOR_New(0,ACTOR_GetRadius(actor),0);
 local emi=PARTICLE_AddEmitter(part_telefog_load,env);
 EMITTER_SetPos(emi,pos,1);
 EMITTER_SetGravity(emi,VECTOR_Scale(up,0),0);

   local colind=SIDE_GetVar(side,"Color");
  


 
   local s_R={1,0,0,1,1};
   local s_G={0,1,0,1,1};
   local s_B={0,0,1,0,1};

   local r=s_R[colind+1];
   local g=s_G[colind+1];
   local b=s_B[colind+1];

 EMITTER_SetColorMultiply(emi,GetCuboColor(colind,0,2.0,0.4));
 EMITTER_SetVar(emi,"Tank",50);
 EMITTER_SetVar(emi,"Flux",1000);
 EMITTER_SetMaxTimeInterval(emi,6/EMITTER_GetVar(emi,"Flux")); --Maximal 6 emitts per think-call 
 EMITTER_SetScaleMultiply(emi,1);
end;



function SideCollisionCheck(actorid,sideid)


  if ACTOR_GetVar(actorid,"IsAlive")~=1 or SIDE_GetVar(sideid,"StartActive")==0 then
    return;
  end;

  
  if SIDE_GetVar(sideid,"TeleTime")>0 then
    return;
  end;
  
  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp);
  l=VECTOR_Length(diff);
  diff=VECTOR_Scale(diff,1.0/l);
  l=(l-ACTOR_GetRadius(actorid)-ACTOR_GetGroundOffset(actorid))/GLOBAL_GetScale();
  dot=VECTOR_Dot(diff,norm);
  if (dot<0.75) or (l>0.2) then 
    if SIDE_GetVar(sideid,"Reteleport")==actorid then
      SIDE_SetVar(sideid,"Reteleport",-1);
    end;
    return;
  end;

  if SIDE_GetVar(sideid,"Reteleport")==-1 then
    SOUND_Play(snd_tele,-1);
    SIDE_SetVar(sideid,"TelePlayer",actorid);
    SIDE_SetVar(sideid,"TeleTime",teletime);
    
    ACTOR_SetVar(actorid,"TeleTime",1);
    ACTOR_SetVar(actorid,"TeleColor",SIDE_GetVar(sideid,"Color"));

    if GLOBAL_GetVar("UseParticles")~=0 then
      EmitLoadParticles(actorid,sideid)
    end;
  end;
end;


function FindDestination(start,offs)
 local lookup={};
 local lookupsize=0;
 for b=0,LEVEL_NumBlocks()-1,1 do
   for s=0,5,1 do
     local checkside=6*b+s;
     if SIDE_GetType(checkside)=="teleport" then
       if SIDE_GetVar(checkside,"Color")==SIDE_GetVar(start,"Color") and SIDE_GetVar(checkside,"StartActive")==1 then
         lookupsize=lookupsize+1;
         lookup[lookupsize]=checkside;
       end;
     end;
   end;
 end;
 if lookupsize==0 then
   return start;
 end;
 --Now find the start in the lookup
 local index=-1;
 for b=1,lookupsize-1,1 do
   if start>=lookup[b] and start<lookup[b+1] then
     index=b;
     break;
   end;
 end;
 if index==-1 then
   index=lookupsize-1;
 else
   index=index-1;
 end;
 index=index+offs;
 if (index<0) then
    index=-index;
 end;
 index=math.fmod(index,lookupsize);
 return lookup[index+1];
end;


function EmitParticles(actor,side)
 local env=ACTOR_GetVar(actor,"PEnv");
 local up=ACTOR_GetUp(actor);
 local pos=VECTOR_New(0,-(ACTOR_GetRadius(actor))*0.75,0);
 local emi=PARTICLE_AddEmitter(part_telefog,env);
 EMITTER_SetPos(emi,pos,1);
 EMITTER_SetGravity(emi,VECTOR_Scale(up,-30),0);

   local colind=SIDE_GetVar(side,"Color");
  

 EMITTER_SetColorMultiply(emi,GetCuboColor(colind,0,2.0,0.4));
 EMITTER_SetVar(emi,"Tank",50);
 EMITTER_SetVar(emi,"Flux",1000);
 EMITTER_SetMaxTimeInterval(emi,6/EMITTER_GetVar(emi,"Flux")); --Maximal 6 emitts per think-call 
 EMITTER_SetScaleMultiply(emi,1);
end;


function SideThink(side)
  local t=SIDE_GetVar(side,"TeleTime");
  local nt=t;
  if (nt<=0) then 
    SIDE_SetVar(side,"TelePlayer",-1);
    SIDE_SetVar(side,"TeleTime",0);
    nt=0;
  else 
    nt=t-LEVEL_GetElapsed();
    if nt<=0 and t>0 then
     --print("Teleport");

     --local ds=math.fmod(math.abs(SIDE_GetVar(side,"DestSide")),LEVEL_NumBlocks()*6);
     --local ds=math.abs(SIDE_GetVar(side,"DestSide"));
     local ds=FindDestination(side,SIDE_GetVar(side,"DestSide"));
     local dr=math.fmod(math.abs(SIDE_GetVar(side,"DestRotation")),4);
     if SIDE_GetType(ds)=="teleport" then
        --Prevents reteleporting 
        local telefrag=SIDE_GetVar(ds,"Reteleport");
        if telefrag~=-1 then
          if ACTOR_IsPlayer(telefrag)==1 then
            ACTOR_SetVar(telefrag,"IsAlive",-1);
            ACTOR_SetVar(telefrag,"KilledString","Telefragged!");
            SOUND_Play(snd_telefrag,-1);
          end;
        end;
        SIDE_SetVar(ds,"Reteleport",SIDE_GetVar(side,"TelePlayer"));
     end;
     ACTOR_SetStart(SIDE_GetVar(side,"TelePlayer"),ds,dr);
if GLOBAL_GetVar("UseParticles")~=0 then
     EmitParticles(SIDE_GetVar(side,"TelePlayer"),side);
end;
     SIDE_GetVar(side,"TelePlayer",-1);
     nt=0;
    end;
  end;
  SIDE_SetVar(side,"TeleTime",nt);
end;


function DrawSprite(side,r,phi,z)
 local picked=SIDE_GetVar(side,"TeleTime");
 local scale=0.1*GLOBAL_GetScale();
 
 MATRIX_Push();
  local cpos=SIDE_GetMidpoint(side);
  local cdir=SIDE_GetTangent(side);
  local cup=SIDE_GetNormal(side);
  local cright=VECTOR_Cross(cdir,cup);

  local cpos=VECTOR_Add(cpos,VECTOR_Add(VECTOR_Scale(cup,z),VECTOR_Add(VECTOR_Scale(cright,r*math.cos(phi)),VECTOR_Scale(cdir,r*math.sin(phi)))));

  local cdir=CAM_GetDir();
  local cup=CAM_GetUp();
  local cright=VECTOR_Cross(cdir,cup);


  MATRIX_MultBase(cright,cdir,cup,cpos);
  MATRIX_ScaleUniform(scale);
  --MATRIX_AxisRotate(VECTOR_New(0,1,0),rot);
  
  TEXDEF_Render(spritetex,side);
  MATRIX_Pop();
end;


function SetSpriteColor(side)
   local colind=SIDE_GetVar(side,"Color");
  
   -- {"red","green","blue","yellow","white"};
   local s_R={1,0,0,1,1};
   local s_G={0,1,0,1,1};
   local s_B={0,0,1,0,1};

   local r=s_R[colind+1];
   local g=s_G[colind+1];
   local b=s_B[colind+1];

   MATERIAL_SetAmbient(COLOR_New(r,g,b,1));
   MATERIAL_SetDiffuse(COLOR_New(r,g,b,1));
   MATERIAL_SetSpecular(COLOR_New(r,g,b,1));
end;


function DistRenderSide(side)
  SetSpriteColor(side);
  local time=SIDE_GetVar(side,"TeleTime");
  time=1-time/teletime;
  local numsprites=10;
  for i=0,numsprites-1,1 do
    local phase=i*2*math.pi/numsprites;
    DrawSprite(side,(2*(time-time*time))*GLOBAL_GetScale(),phase+time*3,0.7*(time)*GLOBAL_GetScale());
  end;
end
