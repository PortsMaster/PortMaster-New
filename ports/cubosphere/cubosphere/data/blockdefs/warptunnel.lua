USING("PARTICLE");

normal_particle_color=COLOR_New(0.2,0.7,0.9,0.4);
secret_particle_color=COLOR_New(0.8,0.0,0.7,0.4);




editortexture=-1;
--effect=-1;
mdl=-1;
sound=-1;
part_effect=-1;
part_effect_in=-1;
normalback=-1;
secretback=-1;

function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 elseif name=="BlockItemsAllowed" then
  return "no";
elseif name=="SideItemsAllowed" then
  return "no";
elseif name=="NumVars" then
  return 2;
 elseif name=="Var1" then
  return "Next_Level";
 elseif name=="VarType1" then
  return "string";
 elseif name=="Var2" then
  return "Direction";
 elseif name=="VarType2" then
  return "int";
 end;
 return default;
end;

function Precache()
 editortexture=TEXDEF_Load("warp_in_editor");

mdl=MDLDEF_Load("warptunnel");

 sound=SOUND_Load("timewarp");
 GLOBAL_SetVar("WarpZoneLogo",TEXTURE_Load("warplogo"));

 secretback=TEXTURE_Load("secretback");
 normalback=TEXTURE_Load("warpback");

 GLOBAL_SetVar("WarpZoneTexture",normalback);

if GLOBAL_GetVar("UseParticles")~=0 then  
  part_effect=PARTICLE_LoadDef("warptunnel");
  part_effect_in=PARTICLE_LoadDef("warptunnel_load");
end;
end



function RenderSide(side)
  SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
end

function DistRenderSide(side)
  local b=SIDE_GetBlock(side);
  if BLOCK_GetVar(b,"Direction")==math.fmod(side,6) then

  MATRIX_Push();
  local dir=SIDE_GetTangent(side);
  local up=SIDE_GetNormal(side);
  local right=VECTOR_Cross(up,dir);
  local pos=VECTOR_Add(SIDE_GetMidpoint(side),VECTOR_Scale(up,0.05*GLOBAL_GetScale()));
  MATRIX_MultBase(right,up,dir,pos);

  MATRIX_Translate(VECTOR_Scale(up,0.05*GLOBAL_GetScale()));
  local time=GLOBAL_GetTime();

  local scale=25+4*math.cos(1.5*time);
  local angle=45*time;

  MATRIX_ScaleUniform(scale);
 local block=SIDE_GetBlock(side);
 local depth=BLOCK_GetVar(block,"WarpTunnelDepth");
--depth=math.sin(depth+depth*depth)/(0.5+0.5*depth*depth);
 depth=math.sin(5*depth*depth)*(1+depth)/(1+6*depth*depth*depth*depth*depth);

  MATRIX_Scale(VECTOR_New(1,depth,1));
  MATRIX_AxisRotate(VECTOR_New(0,1,0),angle);
 -- TEXTURE_Activate(effect,0);
  
 -- BLEND_Activate();
  LIGHT_Disable();
  MATERIAL_SetColor(COLOR_New(1,1,1,1));
 
 -- TEXDEF_RenderDirect(0); 
  GLOBAL_SetVar("RenderColor",BLOCK_GetVar(b,"Secret"));
   MDLDEF_Render(mdl);
  LIGHT_Enable();

--  BLEND_Deactivate();
  MATRIX_Pop();



  elseif GLOBAL_GetVar("EditorMode")==1 then
   -- BLEND_Activate();
    TEXDEF_Render(editortexture,side); 
    TEXDEF_ResetLastRenderedType();
   -- BLEND_Deactivate();
  end; 
 
  

end;

   



function EmitParticles(side,env,actor)
 local pos=VECTOR_New(0,ACTOR_GetRadius(actor)*1,0);
 local emi=PARTICLE_AddEmitter(part_effect,env);
 EMITTER_SetPos(emi,pos,1);
 EMITTER_SetGravity(emi,SIDE_GetNormal(side),0);

   

 EMITTER_SetColorMultiply(emi,COLOR_New(0.2,0.7,0.9,0.4));

 EMITTER_SetMaxTimeInterval(emi,6/EMITTER_GetVar(emi,"Flux")); --Maximal 6 emitts per think-call 
 EMITTER_SetScaleMultiply(emi,1);

 local emi_in=PARTICLE_AddEmitter(part_effect_in,env);
 EMITTER_SetPos(emi_in,pos,1);
 EMITTER_SetGravity(emi_in,VECTOR_Scale(SIDE_GetNormal(side),-40),0);
 local b=SIDE_GetBlock(side);
 if BLOCK_GetVar(b,"Secret")==0 then
   EMITTER_SetColorMultiply(emi_in,normal_particle_color);
 EMITTER_SetColorMultiply(emi,normal_particle_color);
 else
   EMITTER_SetColorMultiply(emi_in,secret_particle_color);
   EMITTER_SetColorMultiply(emi,secret_particle_color);
 end;
 EMITTER_SetVar(emi_in,"Tank",50);
 EMITTER_SetVar(emi_in,"Flux",1000);
 EMITTER_SetMaxTimeInterval(emi_in,6/EMITTER_GetVar(emi_in,"Flux")); --Maximal 6 emitts per think-call 
 EMITTER_SetScaleMultiply(emi_in,1);
end;


function BlockThink(block)

 if BLOCK_GetVar(block,"Secret")==1 then
   GLOBAL_SetVar("WarpZoneTexture",secretback);
 else 
   GLOBAL_SetVar("WarpZoneTexture",normalback);
 end;

 if GLOBAL_GetVar("WarpZoneLogoTimer")>=0 then
  BLOCK_SetVar(block,"WarpTunnelDepth",BLOCK_GetVar(block,"WarpTunnelDepth")+GLOBAL_GetElapsed());
 end;


 local s=BLOCK_GetVar(block,"Direction");
 if s<0 or s>5 then return end;

 local plr=GLOBAL_GetVar("ActivePlayer");
 if plr<0 then return end;
 plr=PLAYER_GetActiveActor(plr);

 local snorm=SIDE_GetNormal(6*block+s);
 local dot=VECTOR_Dot(ACTOR_GetUp(plr),snorm);
 if (dot<0.8) then return end;
 
 local diff=VECTOR_Sub(ACTOR_GetPos(plr),SIDE_GetMidpoint(6*block+s));
 local h=VECTOR_Dot(diff,snorm);
 local warpdist=0.5*GLOBAL_GetScale();
 if h>warpdist or h<-warpdist then return end;
 local absdist=VECTOR_Length(diff);
 if absdist<warpdist and GLOBAL_GetVar("WarpZoneLogoTimer")<0 then
   SOUND_Play(sound,-1);
   GLOBAL_SetVar("WarpZoneLogoTimer",0);

   GLOBAL_SetVar("WarpTargetLevel",BLOCK_GetVar(block,"Next_Level"));
   local olddvect=ACTOR_GetDir(plr);
   for dir=0,3,1 do
     ACTOR_SetStart(plr,6*block+s,dir);
     local dvect=ACTOR_GetDir(plr);
     local dot=VECTOR_Dot(dvect,olddvect);
     if dot>0.7 then break; end;
   end;

   if GLOBAL_GetVar("UseParticles")~=0 then
     local penv=PARTICLE_CreateEnvOnSide(6*block+s);
     EmitParticles(6*block+s,penv,plr);
   end;


  -- LEVEL_Load(BLOCK_GetVar(block,"Next_Level"));
 end;

end;


function BlockConstructor(block)
  BLOCK_SetVar(block,"Next_Level","warp1");
  BLOCK_SetVar(block,"Direction",0);
  BLOCK_SetVar(block,"WarpTunnelDepth",0);
  BLOCK_SetVar(block,"Secret",0);
  GLOBAL_SetVar("WarpZoneLogoTimer",-1);

end


function IsPassable(block)
 if GLOBAL_GetVar("EditorMode")==1 then
  return 0;
 end;

 return 1;
end

function HasTransparency(block)
    return 1;
end;
