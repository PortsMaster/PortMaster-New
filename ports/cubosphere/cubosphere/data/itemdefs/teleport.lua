--Load the helper file, which contains functions for almost all items
INCLUDE("/include/std.inc");

--Particle Setup
particle_def="telefog";
pickupcolor=COLOR_New(0.8,0.0,0.8,0.4);
particle_gravity=30;
particle_flux=1000;
particle_tank=50;
particle_scale=1;
emitter_height=-0.75;

snd_telefrag=-1;

--Load the pickup sound
snd_pickup=SOUND_Load("spell");

--Is called once, after loading the this script
function Precache()
  mdl=MDLDEF_Load("spell"); --Use the MDLDEF of the goblet for testing purposes
  snd_telefrag=SOUND_Load("spiked");
  PrecacheShadow(); --Call the helper file to load the shadow texture
end;

--This function exports variables to the Level editor
function GetEditorInfo(name,default)
 if name=="NumVars" then --When the Editor needs to know, how many variables the item has,
   return 2; --it will answer with "2"
 elseif name=="Var1" then --When we ask for the name of the first variable
   return "Target"; --return it
 elseif name=="VarType1" then --And for the type of the first varible
   return "int"; --we say it is an integer
 elseif name=="Var2" then --Same stuff for the second variable
   return "TargetRotation";
 elseif name=="VarType2" then
   return "int";
 else
   return default;  --All other querys are answered by the default value
 end;
  return default;
end;

--Called by each item (referenced by <id>) when created
function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random()); --Random phase of the item rotation
  ITEM_SetVar(id,"PickedUp",0); --It is not picked up already
  ITEM_SetVar(id,"Target",1); --Default values for the exported variables
  ITEM_SetVar(id,"TargetRotation",0);
end;


--This function is called when the game is processing the game logic and mechanics
function Think(item)
  local picked=ITEM_GetVar(item,"PickedUp"); --We check, if we have to render the pickup sprite
  if picked>g_PickupShowtime then 
   return --it is picked up already, but the time to pickup effect sprite has lapsed 
  end
  if picked==0 then
   return --Is is not picked up
  end;
  picked=picked+GLOBAL_GetElapsed(); --Increase the time of the pickup effect
  ITEM_SetVar(item,"PickedUp",picked);
end;




function FindDestination(start,offs)
 local lookup={};
 local lookupsize=0;
 for b=0,LEVEL_NumBlocks()-1,1 do
   for s=0,5,1 do
     local checkside=6*b+s;
     if SIDE_GetType(checkside)=="tele_target" then
         lookupsize=lookupsize+1;
         lookup[lookupsize]=checkside;
     end;
   end;
 end;
 if lookupsize==0 then
   return start;
 end;
 local index=math.fmod(math.abs(offs-1),lookupsize);
 return lookup[index+1];
end;


--When an actor <actorid> and an item <itemid> collide, this is called
function Collide(actorid,itemid)
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed()); --Start to show the pickup effect
  local plr=ACTOR_GetPlayer(actorid);   PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+0); --Increase the score
  SOUND_Play(snd_pickup,-1); --Play the sound (-1 means: choose a free channel)

  --And perform the teleport
  local dside=FindDestination(ITEM_GetSide(itemid) ,ITEM_GetVar(itemid,"Target")); --Get the destination side
  local ddir=math.fmod(math.abs(ITEM_GetVar(itemid,"TargetRotation")),4); --and rotation (clamped to 0,1,2,3)

  --Set the actor on the destination
  for i=0,PLAYER_NumActors(plr)-1 do
    local check=PLAYER_GetActor(plr,i);
    local side=ACTOR_TraceOnSide(check);
    if side==dside and side>=0 then
       ACTOR_SetVar(check,"IsAlive",-1);
       ACTOR_SetVar(check,"KilledString","Telefragged!");
       SOUND_Play(snd_telefrag,-1);
       break;
    end;

  end;

  ACTOR_SetVar(actorid,"TeleTime",0.52);
  ACTOR_SetVar(actorid,"TeleColor",-1);
  ACTOR_SetStart(actorid,dside,ddir);
  --And prevent it from playing the rolling animation
  ACTOR_SetVar(actorid,"RollSpeed",0);
end

--Is called, whenever the game logic test collision between actor an item
function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid); --When it is not picked up already, test the collision by the invocation of the standard collision func
 end
end

--Render the model
function RenderMdl(item,height)
  BeginRender(item,height,0.45,GetPhase(item));
  MATRIX_AxisRotate(VECTOR_New(0,0,1),20);
  MDLDEF_Render(mdl);
  EndRender();
end;


--Render call: Render model and add the SHADOW-Render to the Distance Render List (as is has transparency effects)
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
 
  ITEM_DistanceRender(item,CAM_Distance(pos));
end

--Render the shadow
function DistRender(item)
  local picked=ITEM_GetVar(item,"PickedUp");
  if picked==0 then
   local height=GetHeight(item);
   RenderShadow(item,height,GLOBAL_GetScale()*0.08);
  else
   RenderPickup(item);
  end
end

