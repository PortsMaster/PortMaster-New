INCLUDE("/include/std.inc");

snd_pickup=SOUND_Load("jump_plus");

--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.6,0.6,0.6,0.3);
particle_def="pickupfog"
particle_tank=30;
particle_gravity=60;

function Precache()
  mdl=MDLDEF_Load("jump_plus");
  PrecacheShadow();
end;


function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
end;


function Collide(actorid,itemid) 

local maxsprungweite=5; sprungweite=ACTOR_GetVar(actorid,"JumpDistance")+1;  --
if sprungweite>maxsprungweite then sprungweite=maxsprungweite; 
end;
ACTOR_SetVar(actorid,"JumpDistance",sprungweite);
ACTOR_SetJumpDistances(actorid,sprungweite,3,2);
  
  
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());

  SOUND_Play(snd_pickup,-1);
end

function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid);
 end
end

function RenderMdl(item,height)
  BeginRender(item,height,0.33,GetPhase(item));
  MDLDEF_Render(mdl);
  EndRender();
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



function Render(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked>g_PickupShowtime then 
   return
  end
  local height=GetHeight(item);
  GetBasis(item,height);

  if picked==0 then
    RenderMdl(item,height);
  end;
  ITEM_DistanceRender(item,CAM_ZDistance(pos));
end

function DistRender(item)
    local height=GetHeight(item);
   local picked=ITEM_GetVar(item,"PickedUp");
   if picked==0 then
     RenderShadow(item,height,GLOBAL_GetScale()*0.06);
   else 
     RenderPickup(item);
   end
end

