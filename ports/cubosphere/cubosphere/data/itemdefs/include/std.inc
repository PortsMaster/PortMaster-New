USING("PARTICLE");

--Config-Vars for the Pickup particles
particle_def="pickupstars";
pickupcolor=COLOR_New(1,1,1,1);
particle_gravity=240;
particle_flux=1000;
particle_tank=100;
particle_scale=1;
emitter_height=0.75;

stex=-1;
ptex=-1;
itemsize=0.4*GLOBAL_GetScale();
g_PickupShowtime=0.3;
pickupmaxsize=9.0;
pickuprotspeed=-300.0;


part_itempickup=-1;



up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);

function GetPhase(item)
  return ITEM_GetVar(item,"Phase");
end;

function GetHeight(item)
  local time=GLOBAL_GetTime();
  return (1.0+0.25*math.sin(3*time+GetPhase(item)*2*math.pi))*GLOBAL_GetScale()*0.6;
end;

function GetBasePos(item)
  local side=ITEM_GetSide(item);
  local mp=SIDE_GetMidpoint(side);
  local vup=SIDE_GetNormal(side);
  return VECTOR_Add(mp,VECTOR_Scale(vup,GLOBAL_GetScale()*0.6)); 
end;

function GetBasis(item,height)
  local side=ITEM_GetSide(item);
  local mp=SIDE_GetMidpoint(side);
  
  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  
  pos=VECTOR_Add(mp,VECTOR_Scale(up,height)); 
end; 


function BeginRender(item,height,scale,phase)
 


  MATRIX_Push();
  GetBasis(item,height);
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(GLOBAL_GetScale()*scale);
  MATRIX_AxisRotate(VECTOR_New(0,1,0),GLOBAL_GetTime()*100+phase*360);

   
end;

function EndRender()
  MATRIX_Pop();
end;

function PrecacheShadow()
  stex=TEXDEF_Load("shadow1");
  ptex=TEXDEF_Load("pickup1");
if GLOBAL_GetVar("UseParticles")~=0 then
  part_itempickup=PARTICLE_LoadDef(particle_def);
end;
end;

local function sqr(x) return x*x; end;

function RenderPickup(item)
if GLOBAL_GetVar("UseParticles")~=0 then
 return;
end;

 local picked=ITEM_GetVar(item,"PickedUp");
 local scale=(-sqr(g_PickupShowtime/2.0-picked)*4.0/g_PickupShowtime+1.0)*pickupmaxsize;
 local rot=picked/g_PickupShowtime*pickuprotspeed;
 MATRIX_Push();
  local side=ITEM_GetSide(item);
  local cpos=GetBasePos(item);
  local cdir=CAM_GetDir();
  local cup=CAM_GetUp();
  local cright=VECTOR_Cross(cdir,cup);
  MATRIX_MultBase(cright,cdir,cup,cpos);
  MATRIX_ScaleUniform(scale);
  MATRIX_AxisRotate(VECTOR_New(0,1,0),rot);
  
  TEXDEF_Render(ptex,side);
  MATRIX_Pop();
end;

function RenderShadow(item,height,scale)
  local side=ITEM_GetSide(item);
  local block=SIDE_GetBlock(side);
   if BLOCK_HasTransparency(block)>0 then
    return;
   end;

  MATRIX_Push();
  GetBasis(item,0.1);
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform((1+height*10.0/GLOBAL_GetScale())*scale);
  
  
  
  TEXDEF_Render(stex,side);
  MATRIX_Pop();
end;


function EmitParticles(actor,item)
 local env=ACTOR_GetVar(actor,"PEnv");
 local up=ACTOR_GetUp(actor);
 local pos=VECTOR_New(0,ACTOR_GetRadius(actor)*emitter_height,0);
 local emi=PARTICLE_AddEmitter(part_itempickup,env);
 EMITTER_SetPos(emi,pos,1);
 EMITTER_SetGravity(emi,VECTOR_Scale(up,-particle_gravity),0);
 EMITTER_SetColorMultiply(emi,pickupcolor)
 EMITTER_SetVar(emi,"Tank",particle_tank);
 EMITTER_SetVar(emi,"Flux",particle_flux);
 EMITTER_SetMaxTimeInterval(emi,6/EMITTER_GetVar(emi,"Flux")); --Maximal 6 emitts per think-call 
 EMITTER_SetScaleMultiply(emi,particle_scale);
end;

function BasicCollisionCheck(actorid,itemid)
  if ACTOR_IsPlayer(actorid)==0 then
   return;
  end;
  local playerpos=ACTOR_GetPos(actorid);
  local itempos=GetBasePos(itemid);
  local diff=VECTOR_Sub(playerpos,itempos);
  local l=VECTOR_Length(diff);
  local mindist=(itemsize+ACTOR_GetRadius(actorid));
  if l<=mindist then
  Collide(actorid,itemid);
  if GLOBAL_GetVar("UseParticles")~=0 then
    EmitParticles(actorid,itemid);
  end;
  end
end
