INCLUDE("/include/std.inc");

snd_pickup=SOUND_Load("pickup_diamond");

pickupcolor=COLOR_New(0.1,0.3,0.9,0.4);

function Precache()
  mdl=MDLDEF_Load("diamond");
  PrecacheShadow();
end;


function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
end;

function RenderMdl(item,height)
  BeginRender(item,height,0.6,GetPhase(item));
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

function Collide(actorid,itemid)
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());
  local plr=ACTOR_GetPlayer(actorid);   PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+500);
  SOUND_Play(snd_pickup,-1);

end

function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid);
 end
end

function Render(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked>g_PickupShowtime then 
   return
  end
  local side=ITEM_GetSide(item);
  local p=SIDE_GetMidpoint(side); 
  ITEM_DistanceRender(item,CAM_ZDistance(p));
end

function DistRender(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked==0 then
    --BLEND_Activate();
  
    LIGHT_Activate(1);
    
    GetBasis(item,height);
    local height=GetHeight(item);
    
    CULL_Mode(2);
    RenderMdl(item,height);
    CULL_Mode(1);
    RenderMdl(item,height);
   -- BLEND_Deactivate();
    LIGHT_Deactivate(1);


    RenderShadow(item,height,GLOBAL_GetScale()*0.15);
 else
   RenderPickup(item);
 end;
end

