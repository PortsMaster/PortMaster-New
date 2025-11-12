INCLUDE("/include/std.inc");



--Particle-Pickup-Setup
pickupcolor=COLOR_New(0.6,0.6,0.6,0.3);
particle_def="pickupfog"
particle_tank=30;
particle_gravity=60;

snd_rotate=-1;
snd_norotate=-1;

function Precache()
  mdl=MDLDEF_Load("gravity");
  spritetex=TEXDEF_Load("telesprite");
  PrecacheShadow();
  snd_rotate=SOUND_Load("gravityrotate");
  snd_norotate=SOUND_Load("jump_minus");
end;




function GetEditorInfo(name,default)
 if name=="NumVars" then 
   return 1;
 elseif name=="Var1" then 
   return "Direction"; 
 elseif name=="VarType1" then 
   return "int"; 
 else
   return default;  --All other querys are answered by the default value
 end;
  return default;
end;

function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random());
  ITEM_SetVar(id,"PickedUp",0);
  ITEM_SetVar(id,"Direction",0);
  ITEM_SetVar(id,"NoPickup",0);
end;



function GetNewGravity(item)
 local direct=math.fmod(ITEM_GetVar(item,"Direction"),6);
 GetBasis(item,0);
 if direct==0 then
    return VECTOR_Scale(up,1);
  elseif direct==1 then
    return VECTOR_Scale(right,1);
  elseif direct==2 then
    return VECTOR_Scale(dir,1);
  elseif direct==3 then
    return VECTOR_Scale(right,-1);
  elseif direct==4 then
    return VECTOR_Scale(dir,-1);
  else
    return VECTOR_Scale(up,-1);
  end;
end;




function Collide(actorid,itemid) 
  local cent=VECTOR_Add(SIDE_GetMidpoint(ITEM_GetSide(itemid)),VECTOR_Scale(SIDE_GetNormal(ITEM_GetSide(itemid)),GLOBAL_GetScale()));
  local cgres=ACTOR_ChangeGravity(actorid,GetNewGravity(itemid),cent,3,0);


  if cgres==-1 then
    return;
  elseif cgres==5 then
    SOUND_Play(snd_norotate,-1);
  else    
   SOUND_Play(snd_rotate,-1);
  end;
 
  ITEM_SetVar(itemid,"PickedUp",GLOBAL_GetElapsed());
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
  local direct=math.fmod(ITEM_GetVar(item,"Direction"),6);
  if direct==0 then
    MATRIX_MultBase(right,up,dir,pos);
  elseif direct==1 then
    MATRIX_MultBase(dir,right,up,pos);
  elseif direct==2 then
    MATRIX_MultBase(up,dir,right,pos);
  elseif direct==3 then
    MATRIX_MultBase(VECTOR_Scale(dir,-1),VECTOR_Scale(right,-1),up,pos);
  elseif direct==4 then
    MATRIX_MultBase(VECTOR_Scale(up,-1),VECTOR_Scale(dir,-1),right,pos);
  else
    MATRIX_MultBase(VECTOR_Scale(right,-1),VECTOR_Scale(up,-1),dir,pos);
  end;
  MATRIX_ScaleUniform(GLOBAL_GetScale()*0.4);
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
  local height=GLOBAL_GetScale()*0.6;
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

