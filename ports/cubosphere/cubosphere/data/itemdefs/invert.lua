INCLUDE("/include/std.inc");

snd_pickup=SOUND_Load("invert");

--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.6,0.6,0.6,0.3);
particle_def="pickupfog"
particle_tank=30;
particle_gravity=60;


function Precache()
  mdl=MDLDEF_Load("invert");spritetex=TEXDEF_Load("telesprite");
  PrecacheShadow();
end;


function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
end;function RandomPermutate(array)
 local l=table.getn(array); --Length of the list
 local numperms=l*3; --Number of swaps
 for c=1,numperms,1 do  
   local i=math.random(l); --Getting random entries
   local j=math.random(l);
   local t=array[i];
   array[i]=array[j]; --And swap them
   array[j]=t;
 end
end;

identitymoves={"lookdownpressed","leftpressed","forwardpressed","lookuppressed","jumppressed","rightpressed"};

function CheckPerm(movev)
  local numoncross=0
  for mi=1,table.getn(movev),1 do
    if movev[mi]=="lookdownpressed" or movev[mi]=="forwardpressed" or movev[mi]=="jumppressed" then
      if identitymoves[mi]=="leftpressed" or identitymoves[mi]=="forwardpressed" or identitymoves[mi]=="rightpressed"  then
        --print("INC NUM ON CROSS BECAUSE "..movev[mi].." lies on "..identitymoves[mi]);
        numoncross=numoncross+1;
      end;  
    end;   
  end;
  if numoncross>=2 then return false; else return true; end;
end;

function Collide(actorid,itemid) local moves={"lookdown","left","forward","lookup","jump","right"};
 -- local moves={"forward","left","right"}; --Optional for only permutating left,right and forward
 
  --Get the assigned moves
  movesvalues={};
  for mi=1,table.getn(moves),1 do
   movesvalues[mi]=ACTOR_GetVar(actorid,"key:"..moves[mi]);

  end;
 
  --Permutate them
local nump=0;
repeat
  RandomPermutate(movesvalues);
  nump=nump+1;
until CheckPerm(movesvalues)==true or nump>100;

  --And set them back
  for mi=1,table.getn(moves),1 do
   ACTOR_SetVar(actorid,"key:"..moves[mi],movesvalues[mi]);
  end;
  
  
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

