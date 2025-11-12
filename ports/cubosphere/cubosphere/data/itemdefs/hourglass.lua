INCLUDE("/include/std.inc");
snd_pickup=-1;

--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.6,0.6,0.6,0.3);
particle_def="pickupfog"
particle_tank=50;
particle_gravity=50;


function Precache()
  mdl=MDLDEF_Load("hourglass");
  --TODO: Change
  snd_pickup=SOUND_Load("hourglass");
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
  local plr=ACTOR_GetPlayer(actorid);   PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+200);
  --TODO: Change
  PLAYER_SetVar(plr,"TimeLeft",PLAYER_GetVar(plr,"MaxTime")-PLAYER_GetVar(plr,"TimeLeft"));
  SOUND_Play(snd_pickup,-1);
end

function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid);
 end
end

function RenderMdl(item,height)
  BeginRender(item,height,0.5,GetPhase(item));
  MATRIX_AxisRotate(VECTOR_New(0,0,1),20);
  MDLDEF_Render(mdl);
  EndRender();
end;



function Render(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked>g_PickupShowtime then 
   return
  end
  
 
  ITEM_DistanceRender(item,CAM_ZDistance(pos));
end

function DistRender(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked==0 then
   local height=GetHeight(item);
   GetBasis(item,height);
  RenderShadow(item,height,GLOBAL_GetScale()*0.15);
    RenderMdl(item,height);
 
  else
   RenderPickup(item);
  end
end

