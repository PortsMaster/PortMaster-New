INCLUDE("/include/std.inc");
snd_pickup=-1;

--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.5,0.1,0.9,0.3);
particle_def="pickupfog"
particle_tank=50;
particle_gravity=30;

function Precache()
  mdl=MDLDEF_Load("nojump");
  snd_pickup=SOUND_Load("bouncepill");
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
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());
  if ACTOR_GetVar(actorid,"Bounce")==1 then
    ACTOR_SetVar(actorid,"Bounce",0);
    ACTOR_SetJumpTiming(actorid,0.15,0.10,0.075);
  else
    ACTOR_SetVar(actorid,"NoJump",1);
    ACTOR_SetJumpTiming(actorid,0.0,0.0,-1);
  end;
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
  
  if picked==0 then
    local height=GetHeight(item);
    GetBasis(item,height);
    RenderMdl(item,height);
  end;
 
  ITEM_DistanceRender(item,CAM_ZDistance(pos));
end

function DistRender(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked==0 then
   local height=GetHeight(item);
   RenderShadow(item,height,GLOBAL_GetScale()*0.08);
  else
   RenderPickup(item);
  end
end

