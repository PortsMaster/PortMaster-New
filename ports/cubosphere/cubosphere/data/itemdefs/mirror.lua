INCLUDE("/include/std.inc");

snd_pickup=SOUND_Load("mirror");

--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.6,0.6,0.6,0.3);
particle_def="pickupfog"
particle_tank=30;
particle_gravity=60;

function Precache()
  mdl=MDLDEF_Load("mirror");
  PrecacheShadow();
end;


function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
end;

function Think(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked>g_PickupShowtime then 
   return
  end
  if picked==0 then
   return
  end;
  picked=picked+GLOBAL_GetElapsed();
  ITEM_SetVar(item,"PickedUp",picked);
end;

function Collide(actorid,itemid)
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed()); ACTOR_SetCamZRotation(actorid,3.14159265,1);
  SOUND_Play(snd_pickup,-1);
end

function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid);
 end
end

function RenderMdl(item,height)
  BeginRender(item,height,0.45,GetPhase(item));
  MATRIX_AxisRotate(VECTOR_New(0,0,1),20);
  MDLDEF_Render(mdl);
  EndRender();
end;



function Render(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked>g_PickupShowtime then 
   return
  end
    local height=GetHeight(item);
    GetBasis(item,height);
 
 
 
 
  ITEM_DistanceRender(item,CAM_ZDistance(pos));
end

function DistRender(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked==0 then
   local height=GetHeight(item);
   RenderShadow(item,height,GLOBAL_GetScale()*0.08);
   RenderMdl(item,height);
  else
   RenderPickup(item);
  end
end

