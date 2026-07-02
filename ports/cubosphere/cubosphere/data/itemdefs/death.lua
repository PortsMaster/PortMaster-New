INCLUDE("/include/std.inc");
--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.2,0.7,0.2,0.5);
particle_def="pickupfog"
particle_tank=60;
particle_gravity=10;

function Precache()
      mdl=MDLDEF_Load("acid");       
      snd_pickup=SOUND_Load("death");
      PrecacheShadow();
    end;






function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
end;




function Collide(actorid,itemid)
      ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());                 --Markiere Item als aufgesammelt (und starte Pickup-Animation)
    
      local plr=ACTOR_GetPlayer(actorid);
      PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+1000);

      ACTOR_SetVar(actorid,"IsAlive",0);                                  --Ermorde den Player
      ACTOR_SetVar(actorid,"KilledString","Poisoned!");                     --Setze die Todesart fuer die Score-Anzeige
      SOUND_Play(snd_pickup,-1);                                          --Spiele den Todes-Sound
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

  ITEM_DistanceRender(item,CAM_ZDistance(pos));
end

function DistRender(item)
    local height=GetHeight(item);
   local picked=ITEM_GetVar(item,"PickedUp");
   if picked==0 then
      RenderMdl(item,height);
     RenderShadow(item,height,GLOBAL_GetScale()*0.06);
   else 
     RenderPickup(item);
   end
end

