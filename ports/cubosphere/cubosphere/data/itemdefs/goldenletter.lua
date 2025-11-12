INCLUDE("/include/std.inc");

snd_pickup=SOUND_Load("letter");
pickupcolor=COLOR_New(0.9,0.9,0.1,0.6);

function Precache()
  mdl=MDLDEF_Load("goldenletter");
  PrecacheShadow();
end;

function GetEditorInfo(name,default)
 if name=="NumVars" then 
   return 1; 
 elseif name=="Var1" then 
   return "LetterIndex"; 
 elseif name=="VarType1" then
   return "int"; 
 else
   return default;  
 end;
  return default;
end;



function Constructor(id)
  ITEM_SetVar(id,"LetterIndex",0);
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
  local plr=ACTOR_GetPlayer(actorid);   PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+35000);
  SOUND_Play(snd_pickup,-1);

end

function CollisionCheck(actorid,itemid)
 local picked=ITEM_GetVar(itemid,"PickedUp");
 if picked==0 then
   BasicCollisionCheck(actorid,itemid);
 end
end

function RenderMdl(item,height)
 MATRIX_Push();
  GetBasis(item,height);
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(GLOBAL_GetScale()*0.45);

  local lindex=math.fmod(ITEM_GetVar(item,"LetterIndex"),10)+1;
  GLOBAL_SetVar("RenderColor",lindex);

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

