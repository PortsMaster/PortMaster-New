--Configuration: Change it!
local InvulnerabilityTime=15; --In seconds
local MyMusic="star2"; --The music file to be played
local SuperBallMdef="superball"; --Mdef of the superball




INCLUDE("/include/std.inc");

--Particle-Pickup-Setup
pickupcolor=COLOR_New(1,1,1,0.7);
particle_def="blinkingstars"
particle_gravity=140;
particle_flux=1000;
particle_tank=100;
particle_scale=1.5;
emitter_height=0.75;

snd_pickup=SOUND_Load("shield");
superball=-1;

function Precache()
  mdl=MDLDEF_Load("flash");
  
  superball=MDLDEF_Load(SuperBallMdef);
  PrecacheShadow();
end;


function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
end;


function Collide(actorid,itemid)
  
  
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());
  local plr=ACTOR_GetPlayer(actorid);   PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+100);
  ACTOR_SetVar(actorid,"GodModeTimer",InvulnerabilityTime);
  ACTOR_SetVar(actorid,"SuperballMdef",superball);
 
 -- if GLOBAL_GetVar("MusicTrack")~=MyMusic then
 --    GLOBAL_SetVar("MusicTrack",MyMusic);
 --    SOUND_PlayMusic(SOUND_LoadMusic(MyMusic));
 -- end;

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


  ITEM_DistanceRender(item,CAM_ZDistance(pos));
end

function DistRender(item)
    local height=GetHeight(item);
   local picked=ITEM_GetVar(item,"PickedUp");
   if picked==0 then
     RenderShadow(item,height,GLOBAL_GetScale()*0.06);
    RenderMdl(item,height);
   else 
     RenderPickup(item);
   end
end

