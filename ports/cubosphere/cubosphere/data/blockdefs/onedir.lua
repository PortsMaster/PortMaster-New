mdl=-1;
texture=-1;
snd_rebounce=-1;


up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);



function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 1;
 elseif name=="Var1" then
  return "Rotation";
 elseif name=="VarType1" then
  return "int";
 else
 return default;
  end;
end;

function RotateDir(side,inp,num)
 num=math.fmod(num,4);
 local outv=VECTOR_New(inp.x,inp.y,inp.z);
 local norm=SIDE_GetNormal(side);
 for i=1,num,1 do
   outv=VECTOR_Cross(norm,outv);
 end;
 return outv;
end;

function SideCollisionCheck(actorid,sideid)
 local adir=ACTOR_GetDir(actorid);
 local rot=SIDE_GetVar(sideid,"Rotation");
 local sdir=RotateDir(sideid,SIDE_GetTangent(sideid),rot);
 if VECTOR_Dot(adir,sdir)<-0.8 then
  return;
 end;
 local adir=ACTOR_GetUp(actorid);
 local sdir=SIDE_GetNormal(sideid);
 if VECTOR_Dot(adir,sdir)<0.8 then
  return;
 end;

  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
    return;
  end;
  if ACTOR_GetOnSide(actorid)>=0 or ACTOR_GetJumpDistBlocks(actorid)==0 then
    return; --Only check when the actor tries to jump over this block
  end;
  
  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp);
  l=VECTOR_Length(diff);
  diff=VECTOR_Scale(diff,1.0/l);
  l=(l-ACTOR_GetRadius(actorid)-ACTOR_GetGroundOffset(actorid))/GLOBAL_GetScale();
  dot=VECTOR_Dot(diff,norm);
  if (dot<0.9) or (l>2.5) then 
    return;
  end;
  --Get the remaining dest to fly move
  ACTOR_SetJumpDistBlocks(actorid,1);
  
  --FOLLOWING LINE COULD BE SET TO EMIT A SOUND
  --SOUND_Play(snd_rebounce,-1);
  
end;

function MayMove(side,actor,dir)
if (ACTOR_IsPlayer(actor)) then
 local adir=ACTOR_GetDir(actor);
 local sdir=RotateDir(side,SIDE_GetTangent(side),SIDE_GetVar(side,"Rotation"));

 if VECTOR_Dot(adir,sdir)<-0.8 then
  return 1;
 end;

 if (dir=="forward") then 
   return 0;
 elseif (dir=="jumpahead") then 
   ACTOR_CallMove(actor,"jumpup");
  -- print("Wrong dir.. "..VECTOR_ToString(SIDE_GetTangent(side)).."  "..VECTOR_ToString(sdir).."   "..VECTOR_ToString(adir));
   return 0;
 else 
   return 1;
 end;
end;
end;

function SideConstructor(sideid)
 SIDE_SetVar(sideid,"Rotation",0);
end;

function Precache()
  mdl=MDLDEF_Load("onedir");
  texture=TEXDEF_Load("normal1");
  snd_rebounce=SOUND_Load("groundhit");
end




function RenderMdl(side,height)
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,SIDE_GetMidpoint(side));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*1.0);
  MATRIX_AxisRotate(VECTOR_New(0,1,0),SIDE_GetVar(side,"Rotation")*90);
  MDLDEF_Render(mdl);
  MATRIX_Pop();
end;



function RenderSide(side)
  TEXDEF_Render(texture,side);
TEXDEF_ResetLastRenderedType();
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;


  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  
  

  
  RenderMdl(side,height);
end

function MayCull(side)
  return 0;
end

