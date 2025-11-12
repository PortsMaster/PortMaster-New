INCLUDE("/include/std.inc");

pickupsound=-1;

pickupcolor=COLOR_New(1,1,0.8,0.8);

function Precache()
  mdl=MDLDEF_Load("key");
  pickupsound=SOUND_Load("pickup_key");
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
  SOUND_Play(pickupsound,-1);
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());
  local plr=ACTOR_GetPlayer(actorid);   PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+100);
  local numkeys=PLAYER_GetVar(plr,"Keys");
  PLAYER_SetVar(plr,"Keys",numkeys+1);
end

function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid);
 end
end

function RenderMdl(item,height)
  BeginRender(item,height,0.5,GetPhase(item));
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
    RenderShadow(item,height,GLOBAL_GetScale()*0.10);
  else
   RenderPickup(item);
  end
end

